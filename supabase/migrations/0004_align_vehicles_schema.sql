-- Migration: 0004_align_vehicles_schema
-- Description: Align vehicle table columns and enums with TypeScript interfaces

-- 1. Rename misnamed columns
ALTER TABLE public.vehicles RENAME COLUMN current_odometer TO odometer_km;
ALTER TABLE public.vehicles RENAME COLUMN controle_technique_expiry TO technical_inspection_expiry;
ALTER TABLE public.vehicles RENAME COLUMN autorisation_circulation_expiry TO circulation_card_expiry;

-- 2. Add missing columns
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS year integer;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS vin text;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS assigned_driver_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS photo_url text;
ALTER TABLE public.vehicles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- 3. Rebuild vehicle_status enum
ALTER TYPE public.vehicle_status RENAME TO vehicle_status_old;
CREATE TYPE public.vehicle_status AS ENUM ('active', 'in_maintenance', 'out_of_service');
ALTER TABLE public.vehicles ALTER COLUMN status DROP DEFAULT;

ALTER TABLE public.vehicles ALTER COLUMN status TYPE public.vehicle_status 
  USING 'active'::public.vehicle_status;
ALTER TABLE public.vehicles ALTER COLUMN status SET DEFAULT 'active'::public.vehicle_status;
DROP TYPE public.vehicle_status_old CASCADE;

-- 4. Rebuild fuel_type enum
ALTER TYPE public.fuel_type RENAME TO fuel_type_old;
CREATE TYPE public.fuel_type AS ENUM ('diesel', 'essence_sans_plomb', 'sirghaz_gplc');
ALTER TABLE public.vehicles ALTER COLUMN fuel_type DROP DEFAULT;

ALTER TABLE public.vehicles ALTER COLUMN fuel_type TYPE public.fuel_type 
  USING 'diesel'::public.fuel_type;
ALTER TABLE public.vehicles ALTER COLUMN fuel_type SET DEFAULT 'diesel'::public.fuel_type;
DROP TYPE public.fuel_type_old CASCADE;
