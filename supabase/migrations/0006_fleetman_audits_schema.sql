-- Migration: 0006_fleetman_audits_schema
-- Description: Creates audits table for eDVIR field inspections with tenant isolation
-- Project: FleetMan Phase 4
-- Date: 2026-04-16

BEGIN;

-- Create audits table for vehicle field inspections
CREATE TABLE IF NOT EXISTS audits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  inspector_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  odometer_km INTEGER NOT NULL CHECK (odometer_km >= 0),
  pass_fail BOOLEAN NOT NULL,
  damage_notes TEXT,
  checklist JSONB NOT NULL DEFAULT '[]',
  photo_urls JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index for vehicle lookups
CREATE INDEX idx_audits_vehicle_id ON audits(vehicle_id);

-- Index for inspector lookups
CREATE INDEX idx_audits_inspector_id ON audits(inspector_id);

-- Index for date range queries
CREATE INDEX idx_audits_created_at ON audits(created_at DESC);

-- Enable RLS
ALTER TABLE audits ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Tenant isolation via vehicle_id join
CREATE POLICY audits_tenant_isolation ON audits
  FOR ALL
  USING (
    vehicle_id IN (
      SELECT id FROM vehicles WHERE tenant_id = (auth.jwt() ->> 'tenant_id')::UUID
    )
  );

-- RLS Policy: Authenticated users can insert audits
CREATE POLICY audits_insert ON audits
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- RLS Policy: Authenticated users can read their own audits
CREATE POLICY audits_select ON audits
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- RLS Policy: Only inserters can update/delete (future use)
CREATE POLICY audits_update ON audits
  FOR UPDATE
  USING (auth.uid() = inspector_id);

COMMIT;

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';