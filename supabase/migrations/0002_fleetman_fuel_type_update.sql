-- Migration: 0002_fleetman_fuel_type_update
-- Description: Adds fuel_type to vehicles for automatic liter calculation in Algeria

CREATE TYPE public.fuel_type AS ENUM ('DIESEL', 'GASOLINE', 'LPG');

ALTER TABLE public.vehicles ADD COLUMN fuel_type public.fuel_type DEFAULT 'DIESEL';
