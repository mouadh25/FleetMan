-- Migration: 0003_fleetman_tenant_registration_trigger
-- Description: Updates the handle_new_user trigger to read `company_name` from metadata.
-- If `company_name` exists, it automatically creates a new Tenant and assigns the user as a CEO.
-- Otherwise, it creates the profile without a tenant (for invited employees).

CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
DECLARE
  v_tenant_id UUID;
  v_company_name TEXT;
BEGIN
  v_company_name := NEW.raw_user_meta_data->>'company_name';

  IF v_company_name IS NOT NULL AND v_company_name != '' THEN
    -- 1. Create the new Organization/Tenant
    INSERT INTO public.tenants (name, subscription_tier)
    VALUES (v_company_name, 'trial')
    RETURNING id INTO v_tenant_id;
    
    -- 2. Create the Founder's Profile and assign 'CEO' role
    INSERT INTO public.profiles (id, tenant_id, full_name, is_super_admin, roles)
    VALUES (
      NEW.id, 
      v_tenant_id,
      NEW.raw_user_meta_data->>'full_name', 
      FALSE, 
      ARRAY['CEO']
    );
  ELSE
    -- Normal user (invited by admin later, tenant_id assigned at invitation)
    INSERT INTO public.profiles (id, full_name, is_super_admin, roles)
    VALUES (
      NEW.id, 
      NEW.raw_user_meta_data->>'full_name', 
      FALSE, 
      '{}'
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
