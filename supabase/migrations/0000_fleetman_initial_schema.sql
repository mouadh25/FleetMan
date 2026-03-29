-- Migration: 0000_fleetman_initial_schema
-- Description: Core schema for FleetMan MVP. Multi-tenant with Role-Based Access Control and strict Row Level Security.

-- 1. Create Enums
CREATE TYPE public.vehicle_status AS ENUM ('AVAILABLE', 'IN_USE', 'MAINTENANCE', 'OUT_OF_SERVICE');
CREATE TYPE public.issue_status AS ENUM ('OPEN', 'TRIAGED', 'RESOLVED');
CREATE TYPE public.work_order_status AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED');

-- 2. Create tenants table
CREATE TABLE public.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  subscription_tier TEXT DEFAULT 'trial',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Create profiles table (extends auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE SET NULL,
  full_name TEXT,
  phone TEXT,
  roles TEXT[] DEFAULT '{}',
  is_super_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Create vehicles table
CREATE TABLE public.vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  plate_number TEXT NOT NULL,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  current_odometer INTEGER DEFAULT 0,
  status public.vehicle_status DEFAULT 'AVAILABLE',
  insurance_expiry DATE,
  controle_technique_expiry DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. Create edvir_inspections table
CREATE TABLE public.edvir_inspections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  inspector_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  odometer INTEGER NOT NULL,
  checklist JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_pass BOOLEAN NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. Create issues table
CREATE TABLE public.issues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  photo_url TEXT,
  voice_note_url TEXT,
  status public.issue_status DEFAULT 'OPEN',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 7. Create vendors table
CREATE TABLE public.vendors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  contact_number TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. Create inventory_parts table
CREATE TABLE public.inventory_parts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  part_number TEXT,
  stock_quantity INTEGER DEFAULT 0,
  unit_cost_dzd INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 9. Create work_orders table
CREATE TABLE public.work_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  issue_id UUID REFERENCES public.issues(id) ON DELETE CASCADE,
  mechanic_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  status public.work_order_status DEFAULT 'PENDING',
  cash_cost_dzd INTEGER DEFAULT 0,
  receipt_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 10. Security & Row Level Security (RLS) Functions

-- Helper function to get the current user's tenant_id securely
CREATE OR REPLACE FUNCTION public.get_tenant_id()
RETURNS UUID AS $$
  SELECT tenant_id FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Helper function to check if the current user is a super admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT is_super_admin FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Expose Tables to RLS
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.edvir_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_orders ENABLE ROW LEVEL SECURITY;

-- 11. Define Policies

-- Tenants Policy: Super admins see all. Users can only see their own tenant row.
CREATE POLICY "Tenants Isolation Policy" ON public.tenants
FOR ALL USING (
  public.is_super_admin() OR id = public.get_tenant_id()
);

-- Profiles Policy: Users can read/update their own profile regardless of tenant_id. 
-- Otherwise, they can only see profiles within their own tenant (or see all if super admin).
CREATE POLICY "Profiles Isolation Policy" ON public.profiles
FOR ALL USING (
  id = auth.uid() OR public.is_super_admin() OR tenant_id = public.get_tenant_id()
);

-- Standard Tenant Isolation Policy for all operational tables
CREATE POLICY "Tenant Isolation Policy" ON public.vehicles FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.edvir_inspections FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.issues FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.vendors FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.inventory_parts FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.work_orders FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());

-- 12. Authentication Trigger
-- Automatically create a profile when a new user signs up in Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, is_super_admin, roles)
  VALUES (
    NEW.id, 
    NEW.raw_user_meta_data->>'full_name', 
    FALSE, 
    '{}'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
