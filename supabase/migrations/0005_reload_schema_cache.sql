-- Migration: 0005_reload_schema_cache
-- Description: Forces PostgREST to reload the schema cache. Required for odometer_km edge issue.

NOTIFY pgrst, 'reload schema';
