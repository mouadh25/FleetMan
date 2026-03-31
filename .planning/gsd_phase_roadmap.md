# GSD Phase Roadmap: FleetMan MVP (v3)

> **Version:** 1.0.1
> **Date:** March 29, 2026
> **Status:** APPROVED & LOCKED - ANTI-CHEAT SYNCED
> **Methodology:** Pure GSD (Get Shit Done) - Burn-and-Replace Sessions  
> **Stack:** Flutter (Mobile) + Next.js (Web) + Supabase (Backend)

---

## Strategic Architecture Decision

### Two-Milestone Approach

> [!IMPORTANT]
> **MVP1 (Phases 0–7):** Feature-complete beta WITH live CI/CD pipeline, linting, and auto-deploy from Day 1.  
> **MVP2 (Phases 8–10):** Security Hardening, Code Refactoring, and Sovereign VPS Migration.

**Rationale:**
1. **CI/CD + Lint + Deploy are Day 1 infrastructure.** The developer's local PC cannot handle heavy Flutter/Next.js builds. GitHub Actions provides free cloud compute. Vercel provides instant preview URLs. Without these, the developer cannot visually test UX or give proper feedback.
2. **Security hardening is deferred.** Penetration testing, RLS audits, rate limiting, and input sanitization are done AFTER the UX logic is fully approved by real users. No point hardening a screen that might be redesigned.
3. **Sovereign VPS is the final gate.** Only after the app is feature-complete AND security-hardened does it migrate to Algerian soil.

### Execution vs. Management Platform Split

> [!IMPORTANT]
> **Mobile App (Flutter) = Field Execution Only.** Restricted entirely to data-entry roles (Drivers logging fuel/eDVIRs, Mechanics closing work orders, Gatekeepers scanning entries). MVP1 will not include complex dashboards or approval workflows on mobile to ensure rapid deployment.
> **Web Portal (Next.js) = Fleet Management Only.** Reserved for CEOs and Park Managers executing administrative tasks (KPI Analysis, Expense Approvals, Assigning drivers, Triage boards).

### Cloud-Agnostic Mandate

> [!CAUTION]
> **Every Supabase interaction MUST be wrapped behind a repository/service interface.**  
> Never call `supabase.from('vehicles').select()` directly in a Widget or Page. Always call `vehicleRepository.getAll()`. This guarantees that when MVP2 migrates to a sovereign VPS (Algérie Telecom / ICOSNET / MinIO), you swap ONE file per service — not 50 screens.

### Mobile Distribution Strategy: Native APK (NOT PWA)

> [!IMPORTANT]
> FleetMan is a **native Flutter APK** targeting the Google Play Store. NOT a PWA.

**Why native APK over PWA:**
- **Camera access:** Damage photos, receipt OCR, and QR scanning require deep hardware integration that PWAs cannot reliably provide.
- **GPS geofencing:** The anti-cheat geofence for driver eDVIR requires background location access, which is sandboxed/blocked in most mobile browsers.
- **Offline-first:** Native SQLite/Hive storage is far more robust than browser-based IndexedDB for queuing 50+ audits in Algerian dead zones.
- **Play Store trust:** Algerian SME fleet managers trust installed apps more than browser bookmarks.
- **Build on cloud:** GitHub Actions builds the APK so the developer's local PC is never the bottleneck.

### Localization Architecture: AR-DZ (الدارجة) + FR-DZ

> [!IMPORTANT]
> Localization is NOT a Phase 7 afterthought. It is baked in from Phase 1.

**Strategy:**
- **Primary language:** `fr_DZ` (Algerian French) — Used for all formal UI labels, legal documents, and business reports.
- **Secondary language:** `ar_DZ` (Algerian Arabic / Darija) — Used for field worker interfaces (drivers, mechanics).
- All strings use `.arb` (Application Resource Bundle) files: `app_fr_DZ.arb` (template) + `app_ar_DZ.arb`.
- **RTL support:** All Flutter layouts use `EdgeInsetsDirectional` and `AlignmentDirectional` (never `left`/`right`).
- **Next.js:** Uses `next-intl` with `fr-DZ` and `ar-DZ` locale routing.
- **Number/Currency formatting:** `NumberFormat` with `fr_DZ` locale for DZD currency display.

### UI Design System (Design Tokens)

Before any screen is built, a shared Design Token file defines the visual DNA of the entire app:

| Token | Value | Rationale |
|-------|-------|-----------|
| **Primary Color** | Deep Blue `#1A3A5C` | Professional fleet management feel |
| **Accent Color** | Safety Orange `#F28C28` | High visibility for alerts and CTAs |
| **Error Color** | Red `#D32F2F` | Budget overruns, failed inspections |
| **Success Color** | Green `#2E7D32` | Passed audits, approved costs |
| **Background (Light)** | `#F5F7FA` | Clean, readable |
| **Background (Dark)** | `#121212` | Night mode for early morning field managers |
| **Font (Latin)** | Inter / Roboto | Clean, professional, Google Fonts |
| **Font (Arabic)** | Noto Sans Arabic | Full Darija/MSA glyph support |
| **Touch Target** | Min 48x48dp | Algerian sun glare + gloved hands |
| **Border Radius** | 12px | Modern, rounded feel |

These tokens are defined ONCE in:
- **Flutter:** `lib/core/theme/app_theme.dart`
- **Next.js:** `styles/design-tokens.css` (CSS custom properties)

---

# MILESTONE 1: Feature-Complete Beta (4 Weeks)

## Phase 0: Database Foundation (Days 1-2)
**Goal:** All tables live on Supabase. SQL files are version-controlled for sovereign replay.

> ☁️ **Cloud-Agnostic Rule:** All migrations are saved as raw `.sql` files in `/supabase/migrations/`. These exact files will be replayed via `psql` on the sovereign VPS during MVP2.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [x] | 0.1 | `profiles` table (UUID PK, roles text array, full_name, phone) | `.sql` |
| [x] | 0.2 | `vehicles` table (status enum, odometer, legal expiry dates) | `.sql` |
| [x] | 0.3 | `edvir_inspections` table (checklist JSONB, odometer, Pass/Fail) | `.sql` |
| [x] | 0.4 | `issues` table (reporter, photo URL, status enum) | `.sql` |
| [x] | 0.5 | `work_orders` table (mechanic, cash_cost_dzd, receipt URL, status) | `.sql` |
| [x] | 0.6 | `inventory_parts` + `vendors` tables | `.sql` |
| [x] | 0.7 | `tenants` table (subscriptions, limits, approval_status) | `.sql` |
| [x] | 0.8 | Row Level Security (RLS) policies for all tables | `.sql` |
| [x] | 0.9 | Execute `0000_fleetman_initial_schema` migration on Supabase | Live DB |
| [x] | 0.9.1| Execute `0001_fleetman_v4_kpi_schema_update` migration for full Anti-Cheat Architecture | Live DB |
| [x] | 0.9.2| Execute `0002_fleetman_fuel_type_update` migration for auto-fuel Liters calculation in Algeria | Live DB |
| [x] | 0.10 | Generate TypeScript types | `database.types.ts` |

**Verify:** `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'` → 16 tables.

---

## Phase 1: Design System, Auth, Localization & Mobile CI/CD (Days 3-6)
**Goal:** Design tokens → Bilingual login → RBAC routing → Flutter builds on GitHub Actions → APK available for testing.

> ☁️ **Cloud-Agnostic Rule:** Auth logic wrapped in `AuthRepository` interface. Supabase-specific calls isolated in `SupabaseAuthRepository implements AuthRepository`.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [x] | 1.1 | Scaffold Flutter project | `/mobile` |
| [x] | 1.2 | Add Supabase SDK + GoRouter + Riverpod + `flutter_localizations` + `intl` | `pubspec.yaml` |
| [x] | 1.3 | Configure `flutter_lints` + custom `analysis_options.yaml` | `analysis_options.yaml` |
| [x] | 1.4 | **Create Design Token theme** (colors, fonts, spacing, touch targets) | `lib/core/theme/app_theme.dart` |
| [x] | 1.5 | **Setup l10n** — create `l10n.yaml`, `app_fr_DZ.arb` (template), `app_ar_DZ.arb` | `lib/l10n/` |
| [x] | 1.6 | Create `AuthRepository` interface + `SupabaseAuthRepository` impl | `auth_repository.dart` |
| [x] | 1.7 | Auth Screens (Email/Password Login) | `login_screen.dart` |
| [x] | 1.8 | Registration Screen | `register_screen.dart` |
| [x] | 1.9 | Role Router (fetch `profiles.roles` → navigate) | `role_router.dart` |
| [x] | 1.10 | Stub Home Screens per role | 3 stub files |
| [x] | 1.11 | **GitHub Actions: Flutter CI** — on push: `flutter analyze` + `flutter build apk --debug` | `.github/workflows/mobile_ci.yml` |
| [x] | 1.12 | **GitHub Actions: APK Artifact** — upload built APK as downloadable artifact | Same workflow file |

**Verify:** Push code → GitHub Actions runs → lint passes → APK downloadable → install on phone → toggle AR-DZ/FR-DZ → UI flips RTL → register → set roles → correct home screen.

---

## Phase 2: Vehicle Onboarding, Web Design System & CI/CD (Days 7-9)
**Goal:** Web design tokens → Add vehicles → Vehicle Detail Card → auto-deploy to Vercel.

> ☁️ **Cloud-Agnostic Rule:** File uploads use `StorageRepository` wrapping S3-Compatible API. Next.js uses `VehicleRepository` interface (no raw Supabase calls in pages).

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [x] | 2.1 | Scaffold Next.js project | `/web` |
| [x] | 2.2 | **Create Web Design Token system** (CSS custom properties matching Flutter theme) | `styles/design-tokens.css` |
| [x] | 2.3 | **Setup `next-intl`** for FR-DZ / AR-DZ locale routing + RTL | `i18n/` config |
| [x] | 2.4 | Configure ESLint + Prettier | `.eslintrc.js`, `.prettierrc` |
| [x] | 2.5 | **Link GitHub repo to Vercel** (auto-deploy `main` to production URL) | Vercel project |
| [ ] | 2.6 | **GitHub Actions: Web CI** — on PR: `npm run lint` + `npm run build` | `.github/workflows/web_ci.yml` |
| [x] | 2.8 | Web Login (Supabase Auth SSR, bilingual) | `login/page.tsx` |
| [x] | 2.9 | "Add Vehicle" form (plate, model, odometer, legal doc upload) | `vehicles/new/page.tsx` |
| [x] | 2.10 | Vehicle List (filterable, searchable) | `vehicles/page.tsx` |
| [x] | 2.11 | Vehicle Detail Card (status, driver, CPK, legal expiry) | `vehicles/[id]/page.tsx` |
| [x] | 2.12 | Flutter mobile Vehicle Card (QR scan) | `vehicle_card_screen.dart` |

**Verify:** Push code → GitHub Actions lint passes → Vercel auto-deploys → open live URL → toggle FR-DZ/AR-DZ → UI flips RTL → add 3 vehicles → confirm list + detail card.

---

## Phase 3: Field Manager Loop (Days 9-12)
**Goal:** Yard audits, gate logging, issue generation, offline sync.

> ☁️ **Cloud-Agnostic Rule:** Photo upload via `StorageRepository` (S3 API). Offline queue uses local SQLite/Hive, not Supabase-specific caching.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 3.1 | QR Scanner screen | `qr_scanner_screen.dart` |
| [ ] | 3.2 | Audit Form (odometer, damage checklist, camera + Voice Notes, Pass/Fail) | `audit_form_screen.dart` |
| [ ] | 3.3 | Photo & Audio Upload (S3-Compatible) | `storage_service.dart` |
| [ ] | 3.4 | Auto-Issue on "Fail" audit | Edge Function or client |
| [ ] | 3.5 | Offline queue + auto-sync | `offline_sync_service.dart` |
| [ ] | 3.6 | Web Gate Logs Viewer (for Park Manager) | `gate-logs/page.tsx` |

**Verify:** Scan QR → submit Fail (with voice note) → confirm Issue in DB. Airplane mode test → sync on reconnect.

---

## Phase 4: Maintenance Loop (Days 13-17)
**Goal:** Issue → Work Order → Mechanic resolution → cost tracking.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 4.1 | Office Manager Issues Inbox (web) | `issues/page.tsx` |
| [ ] | 4.2 | "Convert to Work Order" action | `work-orders/new/page.tsx` |
| [ ] | 4.3 | Mechanic "My Work Orders" queue (mobile) | `work_orders_screen.dart` |
| [ ] | 4.4 | Work Order Detail (view photos, update status) | `work_order_detail_screen.dart` |
| [ ] | 4.5 | Parts Consumption (junction DB logic) | `parts_selector_widget.dart` |
| [ ] | 4.6 | Receipt Photo + OCR fallback (Parts/Fuel) | `receipt_capture_screen.dart` |
| [ ] | 4.7 | Log Fuel Stop (Liters, Cost, Vendor) | `fuel_logging_screen.dart` |
| [ ] | 4.8 | "Job Complete" (resolution photo, signature) | `work_order_detail_screen.dart` |
| [ ] | 4.9 | Inventory Management (web) | `inventory/page.tsx` |
| [ ] | 4.10 | Vendor Management (web) | `vendors/page.tsx` |

**Verify:** Full loop: Issue → Work Order → Mechanic completes → cost logged in DB.

---

## Phase 5: Park Manager eDVIR & Asset Control (Days 18-20)
**Goal:** Pre-departure inspections submitted via mobile by the Park Manager (or a toggled-ON Driver).

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 5.1 | Vehicle Selection Home Screen | `vehicle_selection_screen.dart` |
| [ ] | 5.2 | eDVIR Checklist (Tires, Lights, Mirrors, Fluids, Odometer) | `edvir_checklist_screen.dart` |
| [ ] | 5.3 | Driver Assignment calendar (web, drag-drop) | `calendar/page.tsx` |
| [ ] | 5.4 | Automated Ordre de Mission PDF | Supabase Edge Function |
| [ ] | 5.5 | Office Manager Toggle: "Enable Driver App Access" | `admin/drivers/page.tsx` |
| [ ] | 5.6 | **Driver App Fuel Logging (with Premium Top-Tier Silent Geo-Ping)** | `driver_fuel_screen.dart` |

**Verify:** Login as Park Manager → run eDVIR on a truck. Assign driver on Web. Toggle "App Access" for Driver to test the exception flow.

---

## Phase 6: CEO Dashboard (Days 21-24)
**Goal:** TCO, CPK, approval workflows, CSV export.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 6.1 | CEO landing page (TCO pie chart, fleet health) | `dashboard/page.tsx` |
| [ ] | 6.2 | CPK ranked vehicle table | Dashboard component |
| [ ] | 6.3 | Approval Workflow (Approve/Reject high-cost repairs) | `approvals/page.tsx` |
| [ ] | 6.4 | Vendor Spend report | `reports/vendors/page.tsx` |
| [ ] | 6.5 | Export to CSV on all tables | Utility function |
| [ ] | 6.6 | Legal Document Expiry alerts | Dashboard component |
| [ ] | 6.7 | **Data Health / Driver Score KPI** (The Triangle of Truth widget) | Dashboard widget |

**Verify:** Populate 5 vehicles + 10 work orders → confirm charts → export CSV → validate in Excel.

---

## Phase 6.5: AdminOps Panel (Days 24-26)
**Goal:** Super Admin dashboard to manage tenants, approve trials, and log payments (CCP/BaridiMob/Chargily).

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 6.5.1 | Create `/admin` route group with `super_admin` middleware guard | `admin/layout.tsx` |
| [ ] | 6.5.2 | Build Tenant Dashboard (status filters, trial countdown) | `admin/tenants/page.tsx` |
| [ ] | 6.5.3 | Build Approve/Reject/Suspend tenant actions | Admin API routes |
| [ ] | 6.5.4 | Build "Login As" impersonation | Auth service |
| [ ] | 6.5.5 | Build Payment Log (Hybrid CCP + Chargily entry) | `admin/payments/page.tsx` |

**Verify:** Create test company → appears as "Pending" → Approve → log CCP payment → Company Active.

---

## Phase 7: Landing Page, Client Onboarding & Beta Release (Days 27-30)
**Goal:** Public marketing page, guided onboarding wizard, PM alerts, and final beta deployment.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| | | **Landing Page (Public Marketing)** | |
| [ ] | 7.1 | Build the public landing page (hero, features, pricing tiers, CTA "Request Demo") | `web/app/(public)/page.tsx` |
| [ ] | 7.2 | SEO optimization (meta tags, OG images, structured data) | `layout.tsx` metadata |
| [ ] | 7.3 | "Request Demo" form → stores lead in Supabase `leads` table | Edge Function |
| | | **Client Onboarding & Setup** | |
| [ ] | 7.4 | Step 1: Company Profile setup | `onboarding/step-1.tsx` |
| [ ] | 7.5 | Step 2: Select "Aggregated Roles" (One-Man Army vs Separated) | `onboarding/step-2.tsx` |
| [ ] | 7.6 | Dashboard Smart Checklist (Static widget guiding user exactly what to click: Add Vehicle, Add Driver) | `dashboard/checklist.tsx` |
| [ ] | 7.7 | Set Financial Thresholds (auto-approve limit in DZD, PM alert intervals) | `onboarding/step-4.tsx` |
| | | **Predictive Maintenance & Polish** | |
| [ ] | 7.8 | Predictive PM Alert engine (distance-based + time-based early warnings) | Edge Function |
| [ ] | 7.9 | PM Calendar view (web, upcoming maintenance events) | Calendar component |
| [ ] | 7.10 | Final UI polish pass (high-contrast, animations, loading states, empty states) | All screens |
| [ ] | 7.11 | Build release APK for field testing | `.apk` via GitHub Actions |

**Verify:** Visit landing page → submit demo lead → confirm in DB. Register new company → complete all 5 onboarding steps → confirm vehicles + roles created. PM alert fires correctly. Full E2E walkthrough in both AR-DZ and FR-DZ.

> [!WARNING]
> **MVP1 ENDS HERE.** At this point you have a feature-complete beta. You hand it to 2-3 real Algerian fleet operators for UX validation. Collect feedback in the Iteration Log. Fix UX glitches. Only after the UX logic is fully approved do you proceed to MVP2.

---

# MILESTONE 2: Production Hardening & Sovereign Deployment (2 Weeks)

## Phase 8: Code Refactoring & Documentation (Days 29-32)
**Goal:** Clean up technical debt accumulated during rapid MVP1 development. Write proper documentation.

> [!NOTE]
> CI/CD pipelines, linting, and Vercel auto-deploy were already set up in Phases 1-2. This phase focuses exclusively on code quality and knowledge capture.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 8.1 | Deep refactor pass: eliminate code duplication across Flutter screens | All `.dart` files |
| [ ] | 8.2 | Deep refactor pass: standardize Next.js page patterns and shared hooks | All `.tsx` files |
| [ ] | 8.3 | Fix all lint warnings to zero (enforce strict lint compliance) | All files |
| [ ] | 8.4 | Add inline code documentation (DartDoc) on all public APIs and Repositories | All `.dart` files |
| [ ] | 8.5 | Add inline code documentation (JSDoc) on all public APIs and hooks | All `.tsx` files |
| [ ] | 8.6 | Write Flutter widget tests for critical flows (Auth, eDVIR, Gate Log) | `/test` directory |
| [ ] | 8.7 | Write the comprehensive User Manual | `docs/user_manual.md` |
| [ ] | 8.8 | Write the API / Repository Architecture Guide (for future developers) | `docs/architecture_guide.md` |

**Verify:** `flutter analyze` → zero warnings. `npm run lint` → zero warnings. All widget tests pass. User manual covers all 6 personas.

---

## Phase 9: Security Audit & Hardening (Days 33-35)
**Goal:** Lock down every surface before commercial deployment.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 9.1 | Audit all RLS policies (verify no data leaks between organizations) | Security report |
| [ ] | 9.2 | Enable Supabase Auth email confirmation + rate limiting | Supabase config |
| [ ] | 9.3 | Add input validation/sanitization on all forms (Flutter + Next.js) | All forms |
| [ ] | 9.4 | Implement API rate limiting on Edge Functions | Edge Function config |
| [ ] | 9.5 | Penetration test: attempt to access other users' data via API | Manual test |
| [ ] | 9.6 | Add HTTPS-only, CSP headers, and CORS policies to Next.js | `next.config.js` |

**Verify:** Attempt to query another user's vehicles via direct API → blocked. Attempt SQL injection → sanitized.

---

## Phase 10: Sovereign VPS Migration (Days 36-38)
**Goal:** Full Law 18-07 compliance. All data on Algerian soil.

| Status | Task | Atomic Action | Output |
|---|---|---|---|
| [ ] | 10.1 | Provision Algérie Telecom VPS (or ICOSNET) | Server access |
| [ ] | 10.2 | Install Docker + Docker Compose on VPS | Running containers |
| [ ] | 10.3 | Deploy self-hosted Supabase via Docker Compose | Local Supabase instance |
| [ ] | 10.4 | Deploy MinIO (S3-compatible storage) on VPS | Local storage bucket |
| [ ] | 10.5 | Run `pg_dump` from cloud Supabase → `psql` restore on local VPS | Migrated database |
| [ ] | 10.6 | Swap `StorageRepository` endpoint from cloud to MinIO URL | `.env` change |
| [ ] | 10.7 | Swap `AuthRepository` / `VehicleRepository` endpoints to local VPS | `.env` change |
| [ ] | 10.8 | Swap Vercel deployment to local VPS (PM2 or Docker) | Local web server |
| [ ] | 10.9 | Full E2E regression test on sovereign infrastructure | Test report |

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
│                                                        Phase 6.5  │
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
└───────────────┬───────────────────────────────────────────────────┘
                │
┌───────────────▼ MILESTONE 3: Scale & Add-Ons (Phase 11) ──────────┐
│                                                                   │
│  11.1 gate_logs table & Gatekeeper Kiosk Tablet App               │
│  11.2 eDVIR Native Background GPS Geofencing                      │
│  11.3 Interactive Onboarding "Smart Guide" Overlay UI             │
│  11.4 FCM Push Notifications for Mechanics                        │
└───────────────────────────────────────────────────────────────────┘

## GSD Execution Rules
1. **One phase at a time.** Never start Phase N+1 until Phase N is verified.
2. **One task per agent session.** Fresh agent, hand it the context file + specific files, execute, verify, commit, kill.
3. **Atomic git commits.** `git commit -m "feat(phase-0): create vehicles table migration"`
4. **Update Iteration Log** after each phase.
5. **Cloud-Agnostic mandate.** Never call Supabase SDK directly in Widgets/Pages. Always use Repository interfaces.
