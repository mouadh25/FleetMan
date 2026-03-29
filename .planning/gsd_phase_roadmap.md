# GSD Phase Roadmap: FleetMan MVP (v2)

> **Methodology:** Pure GSD (Get Shit Done) - Burn-and-Replace Sessions  
> **Stack:** Flutter (Mobile) + Next.js (Web) + Supabase (Backend)

---

## Strategic Architecture Decision

### Two-Milestone Approach

> [!IMPORTANT]
> **MVP1 (Phases 0–7):** Feature-complete, UX-validated Beta.  
> **MVP2 (Phases 8–10):** Production Hardening — CI/CD, Security Audit, Sovereign VPS Migration.

**Rationale:** If you bundle linting, CI/CD pipelines, security audits, and production hardening into every feature phase, you will triple your development time and optimize code that might get rewritten after UX testing. The correct strategy is:

1. **Build fast** → get the full data loop working (Field Manager → Driver → Office → Mechanic → CEO).
2. **Validate the UX** → put it in real users' hands, discover glitches, iterate (using the Iteration Log).
3. **Harden once** → after the UX logic is locked, do ONE dedicated sprint for CI/CD, lint, docs, security, and sovereign deployment.

This prevents wasted engineering on screens that might change after user feedback.

### Cloud-Agnostic Mandate

> [!CAUTION]
> **Every Supabase interaction MUST be wrapped behind a repository/service interface.**  
> Never call `supabase.from('vehicles').select()` directly in a Widget or Page. Always call `vehicleRepository.getAll()`. This guarantees that when MVP2 migrates to a sovereign VPS (Algérie Telecom / ICOSNET / MinIO), you swap ONE file per service — not 50 screens.

---

# MILESTONE 1: Feature-Complete Beta (4 Weeks)

## Phase 0: Database Foundation (Days 1-2)
**Goal:** All tables live on Supabase. SQL files are version-controlled for sovereign replay.

> ☁️ **Cloud-Agnostic Rule:** All migrations are saved as raw `.sql` files in `/supabase/migrations/`. These exact files will be replayed via `psql` on the sovereign VPS during MVP2.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 0.1 | `profiles` table (UUID PK, roles text array, full_name, phone) | `.sql` |
| 0.2 | `vehicles` table (status enum, odometer, legal expiry dates) | `.sql` |
| 0.3 | `gate_logs` table (time_in/out, geofence flag, ordre_de_mission_url) | `.sql` |
| 0.4 | `edvir_inspections` table (checklist JSONB, odometer, Pass/Fail) | `.sql` |
| 0.5 | `issues` table (reporter, photo URL, status enum) | `.sql` |
| 0.6 | `work_orders` table (mechanic, cash_cost_dzd, receipt URL, status) | `.sql` |
| 0.7 | `inventory_parts` + `vendors` tables | `.sql` |
| 0.8 | Row Level Security (RLS) policies for all tables | `.sql` |
| 0.9 | Execute migrations on Supabase `mzuippdkhsqifxacssex` | Live DB |
| 0.10 | Generate TypeScript types | `database.types.ts` |

**Verify:** `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'` → 7 tables.

---

## Phase 1: Auth & Role Routing (Days 3-5)
**Goal:** Login → RBAC role-based navigation.

> ☁️ **Cloud-Agnostic Rule:** Auth logic wrapped in `AuthRepository` interface. Supabase-specific calls isolated in `SupabaseAuthRepository implements AuthRepository`.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 1.1 | Scaffold Flutter project | `/mobile` |
| 1.2 | Add Supabase SDK + GoRouter + Riverpod | `pubspec.yaml` |
| 1.3 | Create `AuthRepository` interface + `SupabaseAuthRepository` impl | `auth_repository.dart` |
| 1.4 | Login Screen (high-contrast, AR/FR toggle) | `login_screen.dart` |
| 1.5 | Registration Screen | `register_screen.dart` |
| 1.6 | Role Router (fetch `profiles.roles` → navigate) | `role_router.dart` |
| 1.7 | Stub Home Screens per role | 3 stub files |

**Verify:** Register → set roles in Supabase → login → confirm correct home screen.

---

## Phase 2: Vehicle Onboarding (Days 6-8)
**Goal:** Add vehicles, view Vehicle Detail Card.

> ☁️ **Cloud-Agnostic Rule:** File uploads use `StorageRepository` wrapping S3-Compatible API. Next.js uses `VehicleRepository` interface (no raw Supabase calls in pages).

| Task | Atomic Action | Output |
|------|---------------|--------|
| 2.1 | Scaffold Next.js project | `/web` |
| 2.2 | Web Login (Supabase Auth SSR) | `login/page.tsx` |
| 2.3 | "Add Vehicle" form (plate, model, odometer, legal doc upload) | `vehicles/new/page.tsx` |
| 2.4 | Vehicle List (filterable, searchable) | `vehicles/page.tsx` |
| 2.5 | Vehicle Detail Card (status, driver, CPK, legal expiry) | `vehicles/[id]/page.tsx` |
| 2.6 | Flutter mobile Vehicle Card (QR scan) | `vehicle_card_screen.dart` |

**Verify:** Add 3 vehicles via web → confirm list renders → open detail card → all fields correct.

---

## Phase 3: Field Manager Loop (Days 9-12)
**Goal:** Yard audits, gate logging, issue generation, offline sync.

> ☁️ **Cloud-Agnostic Rule:** Photo upload via `StorageRepository` (S3 API). Offline queue uses local SQLite/Hive, not Supabase-specific caching.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 3.1 | QR Scanner screen | `qr_scanner_screen.dart` |
| 3.2 | Audit Form (odometer, damage checklist, camera, Pass/Fail) | `audit_form_screen.dart` |
| 3.3 | Gate Log screen (Time In/Out buttons) | `gate_log_screen.dart` |
| 3.4 | Morning Reconciliation mode (manual entry, geofence-exempt) | `gate_log_screen.dart` |
| 3.5 | Photo Upload (S3-Compatible) | `storage_service.dart` |
| 3.6 | Auto-Issue on "Fail" audit | Edge Function or client |
| 3.7 | Offline queue + auto-sync | `offline_sync_service.dart` |

**Verify:** Scan QR → submit Fail → confirm Issue in DB. Airplane mode test → sync on reconnect.

---

## Phase 4: Maintenance Loop (Days 13-17)
**Goal:** Issue → Work Order → Mechanic resolution → cost tracking.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 4.1 | Office Manager Issues Inbox (web) | `issues/page.tsx` |
| 4.2 | "Convert to Work Order" action | `work-orders/new/page.tsx` |
| 4.3 | Mechanic "My Work Orders" queue (mobile) | `work_orders_screen.dart` |
| 4.4 | Work Order Detail (view photos, update status) | `work_order_detail_screen.dart` |
| 4.5 | Parts Consumption (warehouse stock / external vendor) | `parts_selector_widget.dart` |
| 4.6 | Receipt Photo + OCR fallback | `receipt_capture_screen.dart` |
| 4.7 | "Job Complete" (resolution photo, signature) | `work_order_detail_screen.dart` |
| 4.8 | Inventory Management (web) | `inventory/page.tsx` |
| 4.9 | Vendor Management (web) | `vendors/page.tsx` |

**Verify:** Full loop: Issue → Work Order → Mechanic completes → cost logged in DB.

---

## Phase 5: Driver eDVIR & Geofencing (Days 18-20)
**Goal:** Pre-departure inspections secured by GPS fence.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 5.1 | Driver Home (restricted to assigned vehicle only) | `driver_home_screen.dart` |
| 5.2 | GPS Geofence service (50m radius check) | `geofence_service.dart` |
| 5.3 | eDVIR Checklist (Tires, Lights, Mirrors, Fluids, Odometer) | `edvir_checklist_screen.dart` |
| 5.4 | Geofenced "Time Out" button | `driver_home_screen.dart` |
| 5.5 | Driver Assignment calendar (web, drag-drop) | `calendar/page.tsx` |
| 5.6 | Automated Ordre de Mission PDF | Supabase Edge Function |

**Verify:** Assign driver → login as driver → submit eDVIR → verify geofence blocks remote access.

---

## Phase 6: CEO Dashboard (Days 21-24)
**Goal:** TCO, CPK, approval workflows, CSV export.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 6.1 | CEO landing page (TCO pie chart, fleet health) | `dashboard/page.tsx` |
| 6.2 | CPK ranked vehicle table | Dashboard component |
| 6.3 | Approval Workflow (Approve/Reject high-cost repairs) | `approvals/page.tsx` |
| 6.4 | Vendor Spend report | `reports/vendors/page.tsx` |
| 6.5 | Export to CSV on all tables | Utility function |
| 6.6 | Legal Document Expiry alerts | Dashboard component |

**Verify:** Populate 5 vehicles + 10 work orders → confirm charts → export CSV → validate in Excel.

---

## Phase 7: UX Polish & Beta Release (Days 25-28)
**Goal:** Bilingual UI, PM alerts, onboarding wizard, deploy to staging.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 7.1 | Predictive PM Alert engine (distance + time based) | Edge Function |
| 7.2 | PM Calendar view (web) | Calendar component |
| 7.3 | Arabic/French language toggle (RTL for Flutter + Next.js) | Localization files |
| 7.4 | UI polish pass (high-contrast, animations, loading states) | All screens |
| 7.5 | Client Onboarding wizard | `onboarding/page.tsx` |
| 7.6 | Deploy Web to Vercel (staging) | Staging URL |
| 7.7 | Build debug APK for field testing | `.apk` |

**Verify:** Full E2E walkthrough in both Arabic and French. PM alert fires correctly.

> [!WARNING]
> **MVP1 ENDS HERE.** At this point you have a feature-complete beta. You hand it to 2-3 real Algerian fleet operators for UX validation. Collect feedback in the Iteration Log. Fix UX glitches. Only after the UX logic is fully approved do you proceed to MVP2.

---

# MILESTONE 2: Production Hardening & Sovereign Deployment (2 Weeks)

## Phase 8: CI/CD Pipeline & Code Quality (Days 29-32)
**Goal:** Automated build, lint, test, and deploy pipeline.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 8.1 | Configure GitHub Actions: Flutter analyze + test on PR | `.github/workflows/mobile.yml` |
| 8.2 | Configure GitHub Actions: Next.js lint + build on PR | `.github/workflows/web.yml` |
| 8.3 | Configure GitHub Actions: Auto-deploy to Vercel on merge to `main` | `.github/workflows/deploy.yml` |
| 8.4 | Add `flutter_lints` + custom lint rules | `analysis_options.yaml` |
| 8.5 | Add ESLint + Prettier to Next.js | `.eslintrc.js`, `.prettierrc` |
| 8.6 | Refactor all code to pass lint (zero warnings) | All files |
| 8.7 | Add inline code documentation (DartDoc / JSDoc) on all public APIs | All files |
| 8.8 | Write the comprehensive User Manual | `docs/user_manual.md` |

**Verify:** Push a PR → GitHub Actions runs → lint passes → build succeeds → auto-deploys to Vercel.

---

## Phase 9: Security Audit & Hardening (Days 33-35)
**Goal:** Lock down every surface before commercial deployment.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 9.1 | Audit all RLS policies (verify no data leaks between organizations) | Security report |
| 9.2 | Enable Supabase Auth email confirmation + rate limiting | Supabase config |
| 9.3 | Add input validation/sanitization on all forms (Flutter + Next.js) | All forms |
| 9.4 | Implement API rate limiting on Edge Functions | Edge Function config |
| 9.5 | Penetration test: attempt to access other users' data via API | Manual test |
| 9.6 | Add HTTPS-only, CSP headers, and CORS policies to Next.js | `next.config.js` |

**Verify:** Attempt to query another user's vehicles via direct API → blocked. Attempt SQL injection → sanitized.

---

## Phase 10: Sovereign VPS Migration (Days 36-38)
**Goal:** Full Law 18-07 compliance. All data on Algerian soil.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 10.1 | Provision Algérie Telecom VPS (or ICOSNET) | Server access |
| 10.2 | Install Docker + Docker Compose on VPS | Running containers |
| 10.3 | Deploy self-hosted Supabase via Docker Compose | Local Supabase instance |
| 10.4 | Deploy MinIO (S3-compatible storage) on VPS | Local storage bucket |
| 10.5 | Run `pg_dump` from cloud Supabase → `psql` restore on local VPS | Migrated database |
| 10.6 | Swap `StorageRepository` endpoint from cloud to MinIO URL | `.env` change |
| 10.7 | Swap `AuthRepository` / `VehicleRepository` endpoints to local VPS | `.env` change |
| 10.8 | Swap Vercel deployment to local VPS (PM2 or Docker) | Local web server |
| 10.9 | Full E2E regression test on sovereign infrastructure | Test report |

**Verify:** All data queries hit the local VPS. `traceroute` confirms zero data leaves Algeria.

> [!IMPORTANT]
> Because every Supabase call was wrapped behind Repository interfaces (Phase 1-6), Tasks 10.6 and 10.7 are literally ONE environment variable change each. Zero code rewrite.

---

## Dependency Chain (Full)
```
┌─────────────── MILESTONE 1: Feature-Complete Beta ───────────────┐
│                                                                   │
│  Phase 0 (DB) → Phase 1 (Auth) → Phase 2 (Vehicles) ──┐         │
│                                                         ├→ Ph 4  │
│                                          Phase 3 (Field)┘   │    │
│                                                              ▼    │
│                                          Phase 5 (Driver) → Ph 6  │
│                                                              │    │
│                                                         Phase 7   │
└──────────────────────────────────────────────────────────┬────────┘
                                                           │
                            ┌── UX VALIDATION GATE ──┐     │
                            │  Real user feedback     │◄────┘
                            │  Iteration Log updated  │
                            └──────────┬──────────────┘
                                       │
┌─────────────── MILESTONE 2: Production Hardening ────────────────┐
│                                                                   │
│  Phase 8 (CI/CD + Lint + Docs) → Phase 9 (Security) → Phase 10  │
│                                                    (Sovereign VPS)│
└───────────────────────────────────────────────────────────────────┘
```

## GSD Execution Rules
1. **One phase at a time.** Never start Phase N+1 until Phase N is verified.
2. **One task per agent session.** Fresh agent, hand it the context file + specific files, execute, verify, commit, kill.
3. **Atomic git commits.** `git commit -m "feat(phase-0): create vehicles table migration"`
4. **Update Iteration Log** after each phase.
5. **Cloud-Agnostic mandate.** Never call Supabase SDK directly in Widgets/Pages. Always use Repository interfaces.
