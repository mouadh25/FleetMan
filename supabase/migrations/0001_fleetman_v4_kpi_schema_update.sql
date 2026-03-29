-- Migration: 0001_fleetman_v4_kpi_schema_update
-- Description: Evolves the Phase 0 schema to support the complete V4 UX Architecture (Anti-Cheat, KPIs, Triangle of Truth)

-------------------------------------------------
-- 1. ENUM EXPANSIONS
-------------------------------------------------
-- vehicle_status missing IN_MISSION and NEEDS_ATTENTION. Postgres requires adding them one by one.
ALTER TYPE public.vehicle_status ADD VALUE 'IN_MISSION';
ALTER TYPE public.vehicle_status ADD VALUE 'NEEDS_ATTENTION';

-- work_order_status missing AWAITING_APPROVAL
ALTER TYPE public.work_order_status ADD VALUE 'AWAITING_APPROVAL';

-- Create new Enums
CREATE TYPE public.issue_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
CREATE TYPE public.work_order_type AS ENUM ('PREVENTIVE', 'CORRECTIVE', 'EMERGENCY');
CREATE TYPE public.gate_log_type AS ENUM ('IN', 'OUT', 'ANOMALY');

-------------------------------------------------
-- 2. ALTER EXISTING TABLES (NEW COLUMNS)
-------------------------------------------------

-- tenants
ALTER TABLE public.tenants ADD COLUMN auto_approve_threshold_dzd INTEGER DEFAULT 20000;

-- vehicles
ALTER TABLE public.vehicles ADD COLUMN starting_odometer INTEGER DEFAULT 0;
ALTER TABLE public.vehicles ADD COLUMN autorisation_circulation_expiry DATE;

-- issues
ALTER TABLE public.issues ADD COLUMN priority public.issue_priority DEFAULT 'LOW';

-- work_orders
ALTER TABLE public.work_orders ADD COLUMN type public.work_order_type DEFAULT 'CORRECTIVE';
ALTER TABLE public.work_orders ADD COLUMN description TEXT;
ALTER TABLE public.work_orders ADD COLUMN approved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.work_orders ADD COLUMN approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.work_orders ADD COLUMN completed_at TIMESTAMP WITH TIME ZONE;
-- Removing cash_cost_dzd is not strictly necessary but it's replaced by work_order_parts logic. 
-- For backwards compatibility we leave it or rename it. We leave it for now.

-------------------------------------------------
-- 3. CREATE NEW TABLES
-------------------------------------------------

-- 3.1 work_order_parts (KPI 1, KPI 4, KPI 6)
CREATE TABLE public.work_order_parts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  work_order_id UUID NOT NULL REFERENCES public.work_orders(id) ON DELETE CASCADE,
  inventory_part_id UUID REFERENCES public.inventory_parts(id) ON DELETE SET NULL, -- Null if external/cash
  vendor_id UUID REFERENCES public.vendors(id) ON DELETE SET NULL, -- Null if warehouse
  source TEXT NOT NULL CHECK (source IN ('WAREHOUSE', 'EXTERNAL', 'CASH')),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_cost_dzd INTEGER NOT NULL,
  receipt_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.2 vendor_ratings (KPI 6)
CREATE TABLE public.vendor_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
  rater_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  quality_score INTEGER NOT NULL CHECK (quality_score BETWEEN 1 AND 5),
  pricing_score INTEGER NOT NULL CHECK (pricing_score BETWEEN 1 AND 5),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.3 gate_logs (KPI 12, KPI 16)
CREATE TABLE public.gate_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  logged_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type public.gate_log_type NOT NULL,
  odometer INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.4 fuel_logs (KPI 13, KPI 16 Fuel Accuracy)
CREATE TABLE public.fuel_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  logged_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  odometer_at_fill INTEGER NOT NULL,
  liters NUMERIC(10, 2) NOT NULL,
  cost_dzd INTEGER NOT NULL,
  vendor_name TEXT,
  receipt_url TEXT,
  is_missing_odometer BOOLEAN DEFAULT FALSE,
  geo_ping_lat NUMERIC(10, 8),
  geo_ping_lng NUMERIC(10, 8),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.5 maintenance_schedules (KPI 15 PM Compliance)
CREATE TABLE public.maintenance_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  interval_km INTEGER,
  interval_months INTEGER,
  last_performed_odometer INTEGER,
  last_performed_date DATE,
  next_due_odometer INTEGER,
  next_due_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.6 driver_assignments (Calendar integration)
CREATE TABLE public.driver_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE CASCADE,
  driver_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  assigned_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL DEFAULT 'SCHEDULED',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.7 ordres_de_mission
CREATE TABLE public.ordres_de_mission (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  assignment_id UUID NOT NULL REFERENCES public.driver_assignments(id) ON DELETE CASCADE,
  mission_purpose TEXT NOT NULL,
  destination TEXT NOT NULL,
  pdf_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.8 payments (Phase 6.5 AdminOps)
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  amount_dzd INTEGER NOT NULL,
  method TEXT NOT NULL CHECK (method IN ('CASH', 'CCP', 'BARIDIMOB', 'CHARGILY')),
  reference_number TEXT,
  verified_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  verified_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3.9 leads (Phase 7 Public Site)
CREATE TABLE public.leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name TEXT NOT NULL,
  contact_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  fleet_size INTEGER NOT NULL,
  status TEXT DEFAULT 'NEW',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-------------------------------------------------
-- 4. ROW LEVEL SECURITY (RLS) FOR NEW TABLES
-------------------------------------------------
ALTER TABLE public.work_order_parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gate_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maintenance_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.driver_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordres_de_mission ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
-- Default leads table isolation (only Super Admins can see leads, but anyone/anons can insert)
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant Isolation Policy" ON public.work_order_parts FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.vendor_ratings FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.gate_logs FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.fuel_logs FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.maintenance_schedules FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.driver_assignments FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.ordres_de_mission FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());
CREATE POLICY "Tenant Isolation Policy" ON public.payments FOR ALL USING (public.is_super_admin() OR tenant_id = public.get_tenant_id());

-- Leads RLS: Anonymous insert allowed, read only by Super Admins
CREATE POLICY "Leads Insert Policy" ON public.leads FOR INSERT WITH CHECK (true);
CREATE POLICY "Leads Select Policy" ON public.leads FOR SELECT USING (public.is_super_admin());
