# GSD Phase Roadmap: FleetMan MVP

> **Methodology:** Pure GSD (Get Shit Done) - Burn-and-Replace Sessions
> **Timeline:** 4 Weeks (28 Days)  
> **Stack:** Flutter (Mobile) + Next.js (Web) + Supabase (Backend)

---

## Phase 0: Database Foundation (Days 1-2)
**Goal:** Create the absolute source of truth for every future agent session.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 0.1 | Write the complete SQL migration for `profiles` table (RBAC roles array) | `.sql` file |
| 0.2 | Write the SQL migration for `vehicles` table (status enum, odometer, legal expiry dates) | `.sql` file |
| 0.3 | Write the SQL migration for `gate_logs` table (time_in, time_out, geofence flag) | `.sql` file |
| 0.4 | Write the SQL migration for `edvir_inspections` table (checklist JSONB, odometer) | `.sql` file |
| 0.5 | Write the SQL migration for `issues` table (reporter, photo URL, status) | `.sql` file |
| 0.6 | Write the SQL migration for `work_orders` table (mechanic, cost, receipt photo) | `.sql` file |
| 0.7 | Write the SQL migration for `inventory_parts` + `vendors` tables | `.sql` file |
| 0.8 | Write all Row Level Security (RLS) policies for every table | `.sql` file |
| 0.9 | Execute all migrations on Supabase project `mzuippdkhsqifxacssex` | Live DB |
| 0.10 | Generate TypeScript types from the live schema | `types.ts` |

**Verification:** Run `SELECT * FROM information_schema.tables WHERE table_schema = 'public'` and confirm all 7 tables exist.

---

## Phase 1: Auth & Role Routing (Days 3-5)
**Goal:** A user can register, log in, and be routed to the correct UI based on their role.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 1.1 | Scaffold Flutter project (`flutter create fleetman_mobile`) | `/mobile` directory |
| 1.2 | Add Supabase Flutter SDK + GoRouter dependencies | `pubspec.yaml` |
| 1.3 | Build the Login Screen (email/password, high-contrast, bilingual AR/FR toggle) | `login_screen.dart` |
| 1.4 | Build the Registration Screen (name, phone, email, password) | `register_screen.dart` |
| 1.5 | Build the Auth Service (Supabase sign-in, sign-up, session persistence) | `auth_service.dart` |
| 1.6 | Build the Role Router: After login, fetch `profiles.roles` and navigate to the correct home screen | `role_router.dart` |
| 1.7 | Create placeholder Home Screens for each role (Field Manager, Driver, Mechanic) | 3 stub files |

**Verification:** Register a new user via the app. Manually set their `roles` to `['field_manager']` in Supabase Dashboard. Log in and confirm the app routes to the Field Manager Home stub.

---

## Phase 2: Vehicle Onboarding & The Asset Card (Days 6-8)
**Goal:** The Office Manager can add vehicles to the system. Any user can view a Vehicle Detail Card.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 2.1 | Scaffold Next.js project (`npx create-next-app@latest`) | `/web` directory |
| 2.2 | Build the Web Login Page (Supabase Auth, redirect to role-based dashboard) | `login/page.tsx` |
| 2.3 | Build the "Add Vehicle" form (license plate, make/model, initial odometer, upload legal docs) | `vehicles/new/page.tsx` |
| 2.4 | Build the Vehicle List table (filterable by status, searchable by plate) | `vehicles/page.tsx` |
| 2.5 | Build the Vehicle Detail Card (Current Status, Assigned Driver, Cost/KM, Legal Doc Expiry) | `vehicles/[id]/page.tsx` |
| 2.6 | Build the Flutter mobile "Vehicle Card" (QR scan opens the card) | `vehicle_card_screen.dart` |

**Verification:** Add 3 test vehicles via the web form. Confirm they appear in the list. Open a Vehicle Detail Card and confirm all fields render.

---

## Phase 3: The Field Manager Loop (Days 9-12)
**Goal:** The Field Manager can perform yard audits, log gate times, and generate issues.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 3.1 | Build the QR Scanner screen (scan vehicle QR -> open audit form) | `qr_scanner_screen.dart` |
| 3.2 | Build the Audit Form (odometer input, damage checklist, photo capture, Pass/Fail) | `audit_form_screen.dart` |
| 3.3 | Build the Gate Log screen (tap vehicle -> "Time Out" / "Time In" buttons) | `gate_log_screen.dart` |
| 3.4 | Implement the Morning Reconciliation mode (manual time entry, geofence-exempt flag) | Logic in `gate_log_screen.dart` |
| 3.5 | Build the Photo Upload service (Supabase S3-Compatible Storage) | `storage_service.dart` |
| 3.6 | Implement auto-Issue generation on "Fail" audit submission | Supabase Edge Function or client logic |
| 3.7 | Build the offline queue (save audits/gate logs locally, sync on reconnect) | `offline_sync_service.dart` |

**Verification:** Scan a test QR code. Submit a "Fail" audit with a photo. Confirm an Open Issue appears in the Supabase `issues` table. Toggle airplane mode, submit another audit, re-enable data, confirm it syncs.

---

## Phase 4: The Maintenance Loop (Days 13-17)
**Goal:** Issues can be converted to Work Orders, assigned to a Mechanic, and resolved with parts + cost tracking.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 4.1 | Build the Office Manager "Issues Inbox" (web, list of Open Issues with photos) | `issues/page.tsx` |
| 4.2 | Build the "Convert to Work Order" action (assign mechanic, set priority) | `work-orders/new/page.tsx` |
| 4.3 | Build the Mechanic mobile "My Work Orders" queue | `work_orders_screen.dart` |
| 4.4 | Build the Work Order Detail screen (view photos, update status, log resolution) | `work_order_detail_screen.dart` |
| 4.5 | Build the Parts Consumption flow (select from warehouse stock or external vendor) | `parts_selector_widget.dart` |
| 4.6 | Build the Receipt Photo + OCR fallback flow (snap receipt, auto-fill cost) | `receipt_capture_screen.dart` |
| 4.7 | Build the "Job Complete" flow (resolution photo, digital signature, status update) | Logic in `work_order_detail_screen.dart` |
| 4.8 | Build the Inventory Management screen (web, add/edit parts, stock levels) | `inventory/page.tsx` |
| 4.9 | Build the Vendor Management screen (web, add/rate vendors) | `vendors/page.tsx` |

**Verification:** Create an Issue from Field Manager audit. Convert it to a Work Order via the web. Open the Mechanic app and confirm the Work Order appears. Complete it with a receipt photo and resolution. Confirm the `work_orders` table shows `status: Completed` and `cash_cost_dzd` is populated.

---

## Phase 5: The Driver eDVIR & Geofencing (Days 18-20)
**Goal:** Drivers can perform mandatory pre-departure inspections, secured by GPS geofencing.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 5.1 | Build the Driver Home screen (restricted view: only their assigned vehicle) | `driver_home_screen.dart` |
| 5.2 | Build the GPS Geofence service (check if phone is within 50m of yard coordinates) | `geofence_service.dart` |
| 5.3 | Build the eDVIR Checklist screen (Tires, Lights, Mirrors, Fluids, Odometer) | `edvir_checklist_screen.dart` |
| 5.4 | Build the "Time Out" geofenced button (disabled if outside fence) | Logic in `driver_home_screen.dart` |
| 5.5 | Build the Driver Assignment calendar (web, Office Manager drags driver onto vehicle) | `calendar/page.tsx` |
| 5.6 | Implement automated Ordre de Mission PDF generation on assignment | Supabase Edge Function |

**Verification:** Assign a driver to a vehicle via the web calendar. Log in as that driver on mobile. Confirm only the assigned vehicle is visible. Submit an eDVIR. Confirm the `edvir_inspections` table is populated. Verify the geofence blocks "Time Out" when GPS coordinates are faked to a remote location.

---

## Phase 6: CEO Dashboard & Financial KPIs (Days 21-24)
**Goal:** The CEO sees the money. TCO, CPK, Approval Workflows, and Export.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 6.1 | Build the CEO landing page (TCO pie chart, fleet health summary) | `dashboard/page.tsx` |
| 6.2 | Build the Cost per Kilometer (CPK) ranked vehicle table | Component in dashboard |
| 6.3 | Build the Approval Workflow (pending high-cost repairs, Approve/Reject buttons) | `approvals/page.tsx` |
| 6.4 | Build the Vendor Spend report (aggregated by vendor, sortable) | `reports/vendors/page.tsx` |
| 6.5 | Implement the "Export to CSV" functionality on all tables | Utility function |
| 6.6 | Build the Legal Document Expiry alerts dashboard (Contrôle Technique, Assurance) | Component in dashboard |

**Verification:** Populate the database with 5 vehicles and 10 completed work orders with varying costs. Log in as CEO. Confirm TCO chart renders with accurate percentages. Confirm CPK ranking sorts correctly. Export a CSV and open it in Excel to validate data integrity.

---

## Phase 7: Polish, PM Alerts & Deployment (Days 25-28)
**Goal:** Predictive maintenance alerts, bilingual support, and production deployment.

| Task | Atomic Action | Output |
|------|---------------|--------|
| 7.1 | Implement Predictive PM Alert engine (distance-based + time-based early warnings) | Supabase Edge Function |
| 7.2 | Build the PM Calendar view (web, upcoming maintenance events) | Component in calendar |
| 7.3 | Implement Arabic/French language toggle (RTL support for Flutter + Next.js) | Localization files |
| 7.4 | Final UI polish pass (high-contrast themes, animations, loading states) | All screens |
| 7.5 | Build the Client Onboarding wizard (first-time setup: add vehicles, set thresholds) | `onboarding/page.tsx` |
| 7.6 | Deploy Web Portal to Vercel (link GitHub repo) | Live URL |
| 7.7 | Build Android APK release | `.apk` file |
| 7.8 | Write the User Manual / Quick Start Guide | `docs/user_manual.md` |

**Verification:** Full end-to-end walkthrough: Register → Onboard 3 vehicles → Field Manager audits → Issue generated → Work Order assigned → Mechanic resolves → CEO approves cost → PM alert fires for next month. All screens render correctly in both Arabic and French.

---

## Dependency Chain
```
Phase 0 (DB) ──► Phase 1 (Auth) ──► Phase 2 (Vehicles) ──┐
                                                           ├──► Phase 4 (Maintenance)
                                          Phase 3 (Field) ─┘         │
                                                                      ▼
                                          Phase 5 (Driver) ──► Phase 6 (CEO) ──► Phase 7 (Polish)
```

## GSD Execution Rules
1. **One phase at a time.** Never start Phase N+1 until Phase N is verified.
2. **One task per agent session.** Open a fresh agent, hand it the context file + the specific files needed, execute the task, verify, commit, kill the session.
3. **Commit after every task.** Atomic git commits only (`git commit -m "feat(phase-0): create vehicles table migration"`).
4. **Update the Iteration Log** in `.planning/fleetman_project_context.md` after completing each phase.
