# ADR 0001: Multi-Tenant Workspace Provisioning via Supabase Triggers

## Status
Accepted

## Context
FleetMan MVP requires absolute multi-tenant data isolation. Each user belongs to an organization (Tenant), and all their data (vehicles, issues, audits) must be strictly isolated via Postgres Row Level Security (RLS) policies based on their `tenant_id`. 
During the registration flow on both the Flutter Mobile App and Next.js Web Portal, we needed a seamless way to create a company workspace automatically when a new user signs up without requiring complex distributed API calls or risking phantom records.

## Decision
We elected to rely on **Supabase `auth.users` metadata and Postgres Triggers** to handle automated tenant provisioning. 
When calling `supabase.auth.signUp()`, the frontend passes the `company_name` and `full_name` via the `options.data` payload.

A Postgres Function (`handle_new_user`) triggered on `AFTER INSERT ON auth.users` securely executes entirely within the database transaction:
1. It reads `company_name` from the `raw_user_meta_data` JSONB object.
2. It inserts a new row into the `tenants` table.
3. It inserts a new row into the `profiles` table, mapping the `auth.uid()` to the newly created `tenant_id` and setting the default role (e.g., `park_manager`).

## Consequences
**Pros:**
- **Atomic Operations:** Guarantees that users are never created without a corresponding `profiles` and `tenants` mapping.
- **Security:** RLS policies work instantly on the first login since `profiles.tenant_id` is populated synchronously at database level.
- **Simplicity:** The frontend registration code is incredibly simple—just a standard `auth.signUp` call with raw metadata mapping. No custom API routes required.

**Cons:**
- **Database Coupling:** Core business logic is coupled to Supabase/Postgres triggers, which slightly steepens the learning curve if migrating to a strictly non-Postgres NoSQL backend in the future (though our Phase 10 strategy involves self-hosting Postgres anyway).
- **Metadata Limitations:** Moving complex arrays or deeply nested structures via `raw_user_meta_data` can be unintuitive. However, for a flat `full_name` and `company_name`, it is perfectly suited.
