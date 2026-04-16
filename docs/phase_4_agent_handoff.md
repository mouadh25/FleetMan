# 🚀 FleetMan Phase 4 Agent Handoff

> **For**: Next Agent (Claude Code)  
> **From**: Phase 3 Completion Agent  
> **Date**: 2026-04-16  
> **Project**: FleetMan - Algerian B2B Fleet Management SaaS

---

## 📋 MISSION SUMMARY

Phase 3 (Field Manager Loop) is complete. The mobile app now has:
- QR Scanner for vehicle identification
- eDVIR Audit Form with 5-item checklist
- Offline Sync Service with Hive storage

Your job is Phase 4: **Database Schema + Integration Testing**

---

## 🎯 YOUR SKILLS (PRIORITY ORDER)

### skill_4_1: Create Audits Database Schema (PRIORITY 0)
**Location**: `supabase/migrations/`

Create `0006_fleetman_audits_schema.sql`:
```sql
CREATE TABLE audits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id UUID NOT NULL REFERENCES vehicles(id),
  inspector_id UUID NOT NULL REFERENCES auth.users(id),
  odometer_km INTEGER NOT NULL,
  pass_fail BOOLEAN NOT NULL,
  damage_notes TEXT,
  checklist JSONB NOT NULL,
  photo_urls JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Policies
ALTER TABLE audits ENABLE ROW LEVEL SECURITY;

CREATE POLICY audits_tenant_isolation ON audits
  USING (vehicle_id IN (
    SELECT id FROM vehicles WHERE tenant_id = auth.jwt() ->> 'tenant_id'
  ));

CREATE POLICY audits_insert ON audits
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

### skill_4_2: Implement Supabase Storage Repository (PRIORITY 1)
**Location**: `mobile/lib/features/storage/`

Create cloud-agnostic storage interface:
- `mobile/lib/features/storage/domain/storage_repository.dart` (abstract)
- `mobile/lib/features/storage/data/supabase_storage_repository.dart` (impl)
- Support upload/download/delete operations
- Implement `StorageRepository` interface for future S3 compatibility

### skill_4_3: Wire Audit Form to Supabase (PRIORITY 1)
**Location**: `mobile/lib/features/audit/`

Update `audit_form_screen.dart`:
1. Inject `SupabaseVehicleRepository` and new `SupabaseStorageRepository`
2. On submit: upload photos to Supabase Storage first
3. Then insert audit record to `audits` table
4. On failure: queue to `OfflineSyncService`

### skill_4_4: Gatekeeper Home Integration (PRIORITY 2)
**Location**: `mobile/lib/features/home/presentation/gatekeeper_home_stub.dart`

Replace stub with real home screen:
- Add prominent QR Scanner button (56px)
- Add recent audits list
- Add pending sync indicator
- Show connectivity status

---

## 📁 CRITICAL FILE LOCATIONS

```
mobile/
├── lib/
│   ├── features/
│   │   ├── scanner/presentation/qr_scanner_screen.dart    ← QR Scanner
│   │   ├── audit/
│   │   │   ├── domain/audit.dart                          ← Audit model
│   │   │   └── presentation/audit_form_screen.dart        ← eDVIR form
│   │   ├── sync/data/offline_sync_service.dart            ← Offline queue
│   │   └── storage/                                       ← CREATE THIS
│   ├── core/routing/app_router.dart                       ← Routes
│   └── l10n/                                              ← i18n
supabase/
└── migrations/
    ├── 0006_fleetman_audits_schema.sql                    ← CREATE THIS
    └── 0005_reload_schema_cache.sql                       ← Reference
```

---

## 🔧 EXECUTION PROTOCOL

1. **Analyze First**: Read `docs/conductor_framework.md` (Skills 4.1-4.4)
2. **Execute Sequential**: skill_4_1 → skill_4_2 → skill_4_3 → skill_4_4
3. **Verify**: Run `flutter analyze` after each skill
4. **Commit**: Atomic commits per skill
5. **Push**: After all skills complete

---

## ✅ SUCCESS CRITERIA

- [ ] `audits` table created with RLS policies
- [ ] `StorageRepository` interface defined and implemented
- [ ] Audit form uploads photos to Supabase Storage
- [ ] Audit form submits to `audits` table on success
- [ ] Audit form queues to `OfflineSyncService` on failure
- [ ] Gatekeeper home has QR Scanner button
- [ ] `flutter analyze` shows zero errors

---

## 🌍 CONSTRAINTS (NON-NEGOTIABLE)

| Constraint | Value |
|------------|-------|
| Theme | Light (outdoor field use) |
| Touch Targets | 56px minimum |
| Font Size | 16px minimum |
| Architecture | Cloud-agnostic (repository pattern) |
| i18n | AR/DZ/FR (existing strings) |

---

## 🚨 ESCALATION TRIGGERS

Escalate to human if:
- Migration fails after 3 retries
- Supabase Storage bucket creation fails
- Photo upload fails repeatedly
- RLS policy breaks tenant isolation

---

## 💡 HELPFUL CONTEXT

- MCP Project ID: `mzuippdkhsqifxacssex`
- Supabase URL: `https://mzuippdkhsqifxacssex.supabase.co`
- Mobile uses `mobile_scanner` for QR, `image_picker` for photos
- Offline sync already implemented - just needs database integration
- Design tokens: See `DESIGN.md` (56px targets, light theme)

---

**Good luck, Agent! The field managers are counting on you. 🚗💨**