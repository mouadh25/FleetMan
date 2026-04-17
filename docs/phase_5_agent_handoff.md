# FleetMan Phase 6 Agent Handoff

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

## Current State: Phase 5 COMPLETE

### Verification Results (via MCP)

**GitHub:**
- ✅ 30+ commits on `origin/main`
- ✅ Phase 5 commits present (503030f, 6b36c6d, 8f47c3b)

**Supabase (`mzuippdkhsqifxacssex`):**
- ✅ 18 tables including `audits`
- ✅ `audit-photos` storage bucket (public, 10MB)
- ✅ RLS policies for audits and storage

**Flutter Analyze:**
- ✅ 0 errors
- ⚠️ 1 info-level warning (prefer_final_fields in audit_form_screen.dart:35 - acceptable)

---

## Next Agent Task: Phase 6 - Web Dashboard + AdminOps Panel

### Phase 6 Priorities

Based on [`docs/MASTER_FLEETMAN_AGENT_ORCHESTRATION_GUIDE.md`](docs/MASTER_FLEETMAN_AGENT_ORCHESTRATION_GUIDE.md:95):

| Phase | Description | Status | Priority |
|-------|-------------|--------|----------|
| Phase 6 | CEO Dashboard | ⚠️ Partial (50%) | HIGH |
| Phase 6.5 | AdminOps Panel | ❌ Not Done | MEDIUM |
| Phase 7 | Landing + Onboarding | ❌ Not Done | LOW |

### Recommended Next Steps

1. **Complete Web CEO Dashboard** - Link to vehicles data, show fleet metrics
2. **Implement AdminOps Panel** - Tenant management, user roles
3. **Fix Web Authentication Flow** - Login/Register with Supabase

---

## Required Verification Steps

### Before ANY Code Change

```bash
# 1. Verify GitHub is up to date
mcp--github-mcp-server--list_commits --owner "mouadh25" --repo "FleetMan" --perPage 5

# 2. Verify Supabase schema
mcp--supabase-mcp-server--execute_sql --project_id "mzuippdkhsqifxacssex" --query "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;"

# 3. For Flutter changes
cd mobile && flutter analyze

# 4. For Web changes
cd web && npm run lint && npm run build
```

### After Code Change (Before Commit)

```bash
# 1. Run flutter analyze (0 errors required) OR web lint/build
cd mobile && flutter analyze

# 2. Test locally if possible
cd mobile && flutter run
# OR
cd web && npm run dev

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

### Vercel
```bash
# List deployments (if MCP token has access)
mcp--vercel-mcp-server--list_deployments --projectId "prj_YEBtNxsQHaXCUoOAdJP0YTJwNXzf" --teamId "team_QvCmtB39fQmCmLF41XnzP5de"
```

---

## Infrastructure Links

| Service | URL |
|---------|-----|
| GitHub | https://github.com/mouadh25/FleetMan |
| Supabase | https://supabase.com/dashboard/project/mzuippdkhsqifxacssex |
| Vercel | https://vercel.com/antigravity/fleetman |

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
│   │   ├── home/presentation/ (ALL 5 ROLES DONE)
│   │   │   ├── ceo_home_stub.dart ✅
│   │   │   ├── driver_home_stub.dart ✅
│   │   │   ├── gatekeeper_home_stub.dart ✅
│   │   │   ├── mechanic_home_stub.dart ✅
│   │   │   └── park_manager_home_stub.dart ✅
│   │   ├── scanner/presentation/qr_scanner_screen.dart
│   │   ├── storage/
│   │   ├── sync/data/offline_sync_service.dart
│   │   └── vehicles/
│   └── l10n/ (AR, FR, AR-DZ, FR-DZ)
web/
├── src/
│   ├── app/[locale]/ (dashboard, vehicles, login, register)
│   ├── lib/ (repositories, supabase client)
│   └── i18n/ (localization)
├── messages/ (ar-DZ.json, fr-DZ.json)
└── vercel.json
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
3. Navigate to dashboard/vehicles

---

## Known Issues to Fix (Optional)

1. **`prefer_final_fields`** in [`audit_form_screen.dart:35`](mobile/lib/features/audit/presentation/audit_form_screen.dart:35) - Could break functionality if changed
2. **Vercel MCP 403** - MCP server permissions issue, not a pipeline problem

---

## Agent Workflow Checklist

- [ ] Read MASTER_FLEETMAN_AGENT_ORCHESTRATION_GUIDE.md
- [ ] Read ADR 0003-antigravity-gsd-workflow.md
- [ ] Verify GitHub/Supabase status via MCP
- [ ] Implement features incrementally
- [ ] Run `flutter analyze` OR `npm run lint/build` after changes
- [ ] Test locally if possible
- [ ] Commit with atomic, detailed messages
- [ ] Push and verify via MCP
- [ ] Update this document when complete

---

**Document Version:** 1.0
**Last Updated:** 2026-04-16
**Author:** Phase 5 Agent (Conductor Framework compliant)
