# FleetMan Next Agent Handoff

## 🚨 IMPORTANT: Read Before Starting

This document contains instructions for the next agent. **Read ALL sections before beginning work.**

---

## Conductor Framework Compliance

1. Read [`docs/MASTER_FLEETMAN_AGENT_ORCHESTRATION_GUIDE.md`](docs/MASTER_FLEETMAN_AGENT_ORCHESTRATION_GUIDE.md)
2. Read [`docs/adr/0003-antigravity-gsd-workflow.md`](docs/adr/0003-antigravity-gsd-workflow.md)
3. Use MCP for ALL verification steps
4. **No commit unless code is tested locally**
5. Atomic commits with detailed messages

---

## Current State: Phase 4 COMPLETE

### Verification Results (via MCP)

**GitHub:**
- ✅ 30+ commits on `origin/main`
- ✅ All Phase 4 commits present

**Supabase (`mzuippdkhsqifxacssex`):**
- ✅ 18 tables including `audits`
- ✅ `audit-photos` storage bucket (public, 10MB)
- ✅ RLS policies for audits and storage

**Flutter Analyze:**
- ✅ 0 errors
- ⚠️ 34 info-level warnings (deprecated `withOpacity`, 1 unawaited future)

---

## Required Verification Steps

### Before ANY Code Change

```bash
# 1. Verify GitHub is up to date
mcp--github-mcp-server--list_commits --owner "mouadh25" --repo "FleetMan" --perPage 5

# 2. Verify Supabase schema
mcp--supabase-mcp-server--execute_sql --project_id "mzuippdkhsqifxacssex" --query "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"

# 3. Run flutter analyze locally
cd mobile && flutter analyze
```

### After Code Change (Before Commit)

```bash
# 1. Run flutter analyze (0 errors required)
cd mobile && flutter analyze

# 2. Test locally if possible
cd mobile && flutter run

# 3. Git commit only after local verification
git add .
git commit -m "feat(scope): detailed message"
git push
```

### After Push

```bash
# Verify via MCP
mcp--github-mcp-server--list_commits --owner "mouadh25" --repo "FleetMan" --perPage 1
```

---

## Next Agent Task: Complete Remaining Home Screens

### Phase 5 Priorities

The MVP currently has these home screens implemented:

| Role | Status | File |
|------|--------|------|
| Gatekeeper | ✅ Complete | [`gatekeeper_home_stub.dart`](mobile/lib/features/home/presentation/gatekeeper_home_stub.dart) |
| CEO | ❌ Stub | [`ceo_home_stub.dart`](mobile/lib/features/home/presentation/ceo_home_stub.dart) |
| Driver | ❌ Stub | [`driver_home_stub.dart`](mobile/lib/features/home/presentation/driver_home_stub.dart) |
| Mechanic | ❌ Stub | [`mechanic_home_stub.dart`](mobile/lib/features/home/presentation/mechanic_home_stub.dart) |
| Park Manager | ❌ Stub | [`park_manager_home_stub.dart`](mobile/lib/features/home/presentation/park_manager_stub.dart) |

### Gatekeeper Home (✅ DONE - Use as Reference)

The [`gatekeeper_home_stub.dart`](mobile/lib/features/home/presentation/gatekeeper_home_stub.dart) is fully implemented with:
- 56px QR Scanner button
- Connectivity indicator
- Pending sync badge
- OfflineSyncService integration
- StreamBuilder for real-time updates

### Implement Next Home Screens

**Recommended Order:**
1. **Driver Home** - Most impactful for daily operations
2. **Mechanic Home** - Maintenance workflow
3. **CEO Home** - Executive dashboard
4. **Park Manager Home** - Vehicle allocation

### Required Per Home Screen

- [ ] Role-specific UI
- [ ] Appropriate navigation/actions
- [ ] Connectivity awareness
- [ ] Role-specific localization strings

---

## MCP Commands Reference

### GitHub
```bash
# List commits
mcp--github-mcp-server--list_commits --owner "mouadh25" --repo "FleetMan" --perPage 10

# Get PR status
mcp--github-mcp-server--get_pull_request --owner "mouadh25" --repo "FleetMan" --pull_number 1
```

### Supabase
```bash
# List tables
mcp--supabase-mcp-server--execute_sql --project_id "mzuippdkhsqifxacssex" --query "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"

# Verify audits table
mcp--supabase-mcp-server--execute_sql --project_id "mzuippdkhsqifxacssex" --query "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'audits';"

# Verify storage bucket
mcp--supabase-mcp-server--execute_sql --project_id "mzuippdkhsqifxacssex" --query "SELECT * FROM storage.buckets WHERE id = 'audit-photos';"
```

### Vercel (if configured)
```bash
mcp--vercel-mcp-server--list_deployments --projectId "prj_9NaT8cAKFiLVejrqKNgD5cSu5" --teamId "team_XmRGNF9F1iFz4y5P6R8j2T9k"
```

---

## Known Issues to Fix (Optional)

If working on existing code, consider fixing:

1. **`withOpacity` deprecation** - Replace with `withValues(alpha: x)` in Flutter 3.22+
2. **`unawaited_futures`** in [`offline_sync_service.dart:155`](mobile/lib/features/sync/data/offline_sync_service.dart:155) - Add `await` or `unawaited()`
3. **`unnecessary_type_check`** in [`offline_sync_service.dart:205`](mobile/lib/features/sync/data/offline_sync_service.dart:205)

---

## Infrastructure Links

| Service | URL |
|---------|-----|
| GitHub | https://github.com/mouadh25/FleetMan |
| Supabase | https://supabase.com/dashboard/project/mzuippdkhsqifxacssex |
| Vercel | Check Vercel dashboard |

---

## Files Structure Reference

```
mobile/
├── lib/
│   ├── main.dart
│   ├── core/routing/app_router.dart
│   ├── features/
│   │   ├── audit/
│   │   │   ├── domain/audit.dart
│   │   │   └── presentation/audit_form_screen.dart
│   │   ├── auth/
│   │   │   ├── data/supabase_auth_repository.dart
│   │   │   ├── domain/auth_repository.dart
│   │   │   └── presentation/login_screen.dart, register_screen.dart
│   │   ├── home/presentation/
│   │   │   ├── ceo_home_stub.dart (TODO)
│   │   │   ├── driver_home_stub.dart (TODO)
│   │   │   ├── gatekeeper_home_stub.dart (DONE)
│   │   │   ├── mechanic_home_stub.dart (TODO)
│   │   │   └── park_manager_home_stub.dart (TODO)
│   │   ├── scanner/presentation/qr_scanner_screen.dart
│   │   ├── storage/
│   │   │   ├── domain/storage_repository.dart
│   │   │   └── data/supabase_storage_repository.dart
│   │   ├── sync/data/offline_sync_service.dart
│   │   └── vehicles/
│   │       ├── data/supabase_vehicle_repository.dart
│   │       ├── domain/vehicle.dart
│   │       └── presentation/vehicle_card_screen.dart
│   └── l10n/ (AR, FR, AR-DZ, FR-DZ)
```

---

## Testing Instructions

### Mobile App Flow
1. Login as gatekeeper
2. Gatekeeper Home → QR Scanner
3. Scan vehicle QR → Audit Form
4. Complete 5-item checklist
5. Add photos
6. Submit

### Web App Flow
1. Go to Vercel deployment
2. Login/Register
3. Navigate vehicles

---

**Document Version:** 1.0
**Last Updated:** 2026-04-16
**Author:** Phase 4 Agent (Conductor Framework compliant)
