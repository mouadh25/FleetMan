# 🚛 FleetMan Master Documentation

> **Context Status:** ~65% used | **Recommendation:** Split into feature branches for Phase 3+
> **This document is the SINGLE SOURCE OF TRUTH for agent orchestration**
> **⚠️ CRITICAL UPDATE:** See [Conductor Framework v1.0](/docs/conductor_framework.md) for Skills 2.0 architecture

> **Version:** 2.0
> **Date:** April 16, 2026
> **Purpose:** Complete project reference + Agent orchestration guide + Implementation roadmap

---

## TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [Audit Report Summary](#2-audit-report-summary)
3. [Design System Recommendation](#3-design-system-recommendation) - ⚠️ Updated v3
4. [Agent Workflow Methodology](#4-agent-workflow-methodology) - ⚠️ Conductor Framework
5. [Implementation Roadmap](#5-implementation-roadmap)
6. [Agent Handoff Prompts](#6-agent-handoff-prompts)

---

## 1. PROJECT OVERVIEW

### 1.1 Product Vision

**FleetMan** is a maintenance-first, zero-hardware B2B SaaS for Algerian SME fleets (10-50 vehicles).

**Core Value Proposition:** *"Stop tracking dots. Start protecting assets."*

- GPS trackers tell you where a truck died
- FleetMan tells you why it's going to die next week—and stops it

### 1.2 Target Market

| Attribute | Value |
|-----------|-------|
| Geography | Algeria (primary), North Africa (expansion) |
| Audience | Transport & logistics SMEs |
| Fleet Size | 10-50 vehicles |
| Buyer | CEO/Owner, DAF (Financial Director) |
| Pain Points | WhatsApp chaos, paper logbooks, reactive maintenance |
| Compliance | Law 18-07 (Algerian data sovereignty) |

### 1.3 Tech Stack

| Layer | Technology | Notes |
|-------|------------|-------|
| Mobile | Flutter (Dart) | Native APK, offline-first |
| Web | Next.js (React/TypeScript) | Server-side rendering |
| Database | Supabase (PostgreSQL) | RLS, multi-tenant |
| Storage | Supabase Storage (S3-compatible) | Photos, receipts |
| Auth | Supabase Auth | Email/password |
| Hosting | Vercel (Web) | Auto-deploy |
| CI/CD | GitHub Actions | Mobile APK builds |

### 1.4 Architecture Principles

1. **Cloud-Agnostic:** All Supabase calls wrapped in Repository interfaces
2. **Multi-Tenant:** RLS enforces tenant isolation
3. **Offline-First:** Mobile works in Algerian dead zones
4. **Bilingual:** FR-DZ (formal) + AR-DZ (field workers)
5. **RBAC:** 7 roles with aggregated persona support
6. **Field-Optimized:** Light theme PRIMARY, 56px touch targets, 16px min fonts

### 1.5 Database Schema (16 Tables)

```
tenants           → Client companies
profiles          → Users with roles[]
vehicles          → Fleet assets
edvir_inspections → Daily inspections
issues            → Reported defects
work_orders       → Active repairs
work_order_parts  → Parts consumption
vendors           → External suppliers
inventory_parts   → Warehouse stock
fuel_logs         → Fuel tracking
gate_logs         → Entry/exit logs
driver_assignments→ Calendar tracking
ordres_de_mission → Mission orders
maintenance_schedules → PM alerts
payments          → Billing
leads             → Demo requests
vendor_ratings    → QoS scoring
```

---

## 2. AUDIT REPORT SUMMARY

### 2.1 Completion Status

| Phase | Description | Status | Completion |
|-------|-------------|--------|------------|
| Phase 0 | Database Foundation | ✅ Done | 100% |
| Phase 1 | Mobile Auth + CI/CD | ✅ Done | 95% |
| Phase 2 | Web Scaffolding | ⚠️ Partial | 70% |
| Phase 3 | Field Manager Loop | ✅ Done | 100% |
| Phase 4 | Maintenance Loop (Audits) | ✅ Done | 100% |
| Phase 5 | Home Screens | ✅ Done | 100% |
| Phase 6 | CEO Dashboard | ⚠️ Partial | 50% |
| Phase 6.5 | AdminOps Panel | ❌ Not Done | 0% |
| Phase 7 | Landing + Onboarding | ❌ Not Done | 0% |

**Overall MVP Completion: ~55%**

### 2.2 Critical Gaps

| Gap | Severity | Impact |
|-----|----------|--------|
| No work order flow | CRITICAL | Core business loop missing |
| Web dashboard empty | HIGH | CEO sees nothing |
| No issues → WO conversion | HIGH | Triage workflow missing |

### 2.3 Code Quality Assessment

| Aspect | Rating | Notes |
|--------|--------|-------|
| Architecture | ⭐⭐⭐⭐⭐ | Repository pattern, cloud-agnostic |
| Database Schema | ⭐⭐⭐⭐⭐ | Well-designed, comprehensive |
| Auth Flow | ⭐⭐⭐⭐ | Clean, proper error handling |
| Repository Pattern | ⭐⭐⭐⭐⭐ | Correctly implemented |
| Localization | ⭐⭐⭐⭐⭐ | FR-DZ + AR-DZ, RTL-ready |
| Mobile CI/CD | ⭐⭐⭐⭐ | Functional APK builds |
| Home Screens | ⭐⭐⭐⭐ | All 5 roles implemented |
| Web Functionality | ⭐ | Empty pages |
| Offline Capability | ⭐⭐⭐⭐ | OfflineSyncService integrated |

### 2.4 What Works

✅ Zero-hardware positioning is genuinely differentiated  
✅ Law 18-07 compliance is a real competitive moat  
✅ CCP payment handling is market-adapted  
✅ Bilingual (FR-DZ/AR-DZ) shows local commitment  
✅ Repository pattern correctly implemented  
✅ RLS multi-tenant isolation production-ready  

### 2.5 What Doesn't Work

❌ "TCO reduction" messaging is too abstract  
❌ "Anti-cheat" language may alarm clients  
❌ No social proof or case studies  
❌ Landing page doesn't exist  
❌ Home screens are non-functional stubs  

---

## 3. DESIGN SYSTEM RECOMMENDATION

### 3.1 FleetMan Design Direction (v3 - "Firrion" Field-Optimized)

> ⚠️ **CRITICAL UPDATE:** Light theme is PRIMARY for outdoor field use. Dark theme is secondary (indoor mechanic only). Field workers use devices in bright Algerian sun - dark theme is counterproductive.

Based on Fleetio analysis and Algerian market requirements:

| Attribute | FleetMan Decision | Rationale |
|-----------|------------------|-----------|
| **Primary Color** | Deep Blue `#1A3A5C` | Professional, trustworthy, corporate |
| **Accent/CTA** | Safety Orange `#F28C28` | High visibility, alerts, CTAs |
| **Error** | Red `#D32F2F` | Budget overruns, failures |
| **Success** | Green `#2E7D32` | Passed audits, approvals |
| **Warning** | Amber `#F57F17` | Due soon, needs attention |
| **Background Light** | `#F5F7FA` | **PRIMARY** - Clean, high contrast, outdoor |
| **Surface White** | `#FFFFFF` | Maximum clarity for cards/modals |
| **Background Dark** | `#121212` | **SECONDARY** - Indoor mechanic only |
| **Touch Target** | **56x56dp MINIMUM** | **FIELD-OPTIMIZED** - Gloved hands |
| **Font Size Body** | **16px minimum** | **FIELD-OPTIMIZED** - Outdoor readability |
| **Font Size Caption** | **14px minimum** | **FIELD-OPTIMIZED** - Not 12px |
| **Border Radius** | 12px | Modern, rounded |

### 3.2 Fleetio-Inspired Components

Based on Fleetio screenshot analysis:

| Component | FleetMan Implementation |
|-----------|------------------------|
| **Sidebar** | Collapsible, icon+label, section groups, RTL-ready |
| **Top Bar** | Logo, global search, quick-add (+), notifications, avatar |
| **Data Tables** | Sortable, filterable, paginated, status badges |
| **Status Badges** | Semantic traffic-light colors (green/gray/red/orange) |
| **Dashboard Widgets** | KPI cards with sparklines, trend indicators |
| **Filter Chips** | Dropdowns above tables |
| **Form Inputs** | Text, select, date, phone (with DZ code), file upload |
| **Step Wizard** | Progress bar, left form/right illustration |
| **Modal** | Centered overlay for confirmations |
| **Empty State** | Illustration + CTA when no data |

### 3.3 Mobile-Specific Design (Field-Optimized)

> ⚠️ **LIGHT THEME PRIMARY:** Dark theme is counterproductive for outdoor field use in Algerian sun.

| Aspect | FleetMan Mobile | Notes |
|--------|----------------|-------|
| **Navigation** | Bottom tab bar (Home, Search, Browse, More) | Light background |
| **Theme** | **LIGHT PRIMARY** - White/gray backgrounds | Dark is secondary |
| **Home Screen** | Action shortcuts (Scan, Inspect, Log Fuel) | Large 56px buttons |
| **QR Scanner** | Prominent, camera-first | Light theme for visibility |
| **Offline Indicator** | Clear visual when queued | Sync status prominent |
| **Typography** | Inter (Latin), Noto Sans Arabic | 16px body min |
| **Touch Targets** | **56px minimum** | Gloved hands |
| **Contrast** | 10:1+ for outdoor | High contrast essential |

### 3.4 Recommended Free Design Resources

| Resource | Use | URL |
|----------|-----|-----|
| **Tailwind UI** | Web components, layout patterns | tailwindui.com |
| **Headless UI** | Accessible React components | headlessui.com |
| **Heroicons** | SVG icons (MIT licensed) | heroicons.com |
| **Phosphor Icons** | Multi-weight icon set | phosphor-icons.com |
| **Inter Font** | Google Fonts (Latin) | fonts.google.com |
| **Noto Sans Arabic** | Google Fonts (Arabic) | fonts.google.com |
| **Radix UI** | Web primitives | radix-ui.com |
| **Flutter Material** | Mobile components | material.io |

### 3.5 Design NOT Recommended

| Resource | Why Not |
|----------|--------|
| **Shadcn/UI** | Over-engineered for MVP, adds dependency complexity |
| **Chakra UI** | React-only, not suitable for Flutter alignment |
| **Material Design 3** | Too generic, doesn't match FleetMan brand |
| **DaisyUI** | Tailwind-only, not mobile-aligned |

---

## 4. AGENT WORKFLOW METHODOLOGY

### 4.1 The Problem with Long Context

When AI context exceeds 70-80% capacity:
- Quality degrades significantly
- Instructions get lost or contradictory
- Code inconsistencies multiply
- Agent "forgets" earlier decisions

### 4.2 Recommended: Tiered Agent Architecture

For FleetMan, recommend a **3-Tier Agent Structure**:

```
┌─────────────────────────────────────────────────────┐
│  TIER 1: ORCHESTRATOR (Human or Senior Agent)      │
│  • Project manager / Tech lead                     │
│  • Breaks work into atomic tasks                   │
│  • Validates outputs                               │
│  • Updates master documentation                    │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│  TIER 2: SPECIALIST AGENTS (Single Focus)          │
│  • Mobile Flutter Agent                            │
│  • Web Next.js Agent                               │
│  • Database/Supabase Agent                         │
│  • UX/Design Agent                                 │
│  • Read ONLY from current docs                     │
│  • Write to feature branches                       │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│  TIER 3: VALIDATION AGENT                          │
│  • Runs tests                                      │
│  • Lints code                                      │
│  • Verifies requirements                           │
│  • Reports back to Orchestrator                    │
└─────────────────────────────────────────────────────┘
```

### 4.3 Global Rules (.cursorrules / .geminirules) Structure

```markdown
# FleetMan Global Rules

## PROJECT IDENTITY
- Name: FleetMan
- Type: B2B SaaS (Algerian Fleet Management)
- Stack: Flutter + Next.js + Supabase
- Phase: MVP Development (35% complete)

## ABSOLUTE RULES (NEVER BREAK)
1. All Supabase calls MUST use Repository pattern
2. All commits MUST be atomic (one feature per commit)
3. All code MUST pass lint before PR
4. All new features MUST have migration file
5. NEVER call Supabase directly from UI components
6. NEVER use magic numbers - use constants
7. All strings MUST use localization keys
8. **LIGHT THEME PRIMARY for mobile field use** (dark is secondary for indoor mechanic only)
9. **56px minimum touch targets** (gloved hands requirement)
10. **16px minimum font size for field workers** (outdoor readability)
11. Cloud-agnostic storage: Use S3-compatible API (not proprietary SDK)

## CODING STANDARDS
- Flutter: Riverpod for state, GoRouter for navigation
- Web: Next.js App Router, TypeScript strict mode
- DB: Repository interfaces, DTOs, proper typing
- Styling: Design tokens only (no hardcoded colors)

## FILE STRUCTURE
- mobile/lib/features/{feature}/{layer}/
- web/src/features/{feature}/components/
- supabase/migrations/{sequence}_{description}.sql

## WORKFLOW
1. Read .planning/agent-task-template.md
2. Read relevant docs from /docs
3. Execute atomic task
4. Update docs/progress.md
5. Commit with conventional commit
```

### 4.4 Skills vs Global Rules

| Aspect | Global Rules | Skills |
|--------|-------------|--------|
| **Scope** | Project-wide standards | Task-specific expertise |
| **Persistence** | Always loaded | On-demand |
| **Examples** | "Use Repository pattern" | "Flutter offline sync" |
| **Best For** | Coding standards | Complex procedures |

**Recommendation for FleetMan:**
- Use **Global Rules** for project standards (Repository pattern, file structure, naming)
- Use **Skills** for complex implementations (offline sync, PDF generation, OCR)

> ⚠️ **NEW (v2):** See **[Conductor Framework v1.0](/docs/conductor_framework.md)** for the complete **Skills 2.0 architecture**. This defines 15+ skill definitions with autonomous execution protocols, quality gates, and escalation procedures for vibe-coding workflows.

### 4.5 FleetMan Conductor Framework (Skills 2.0)

| Framework | Pros | Cons | FleetMan Fit |
|-----------|------|------|--------------|
| **Conductor (Claude)** | Structured handoffs, state tracking | Requires external tool | ⭐⭐⭐⭐ |
| **CrewAI** | Multi-agent orchestration | Overkill for single dev | ⭐⭐ |
| **AutoGen** | Microsoft ecosystem | Complex setup | ⭐⭐ |
| **Custom Scripts** | Full control | Maintenance burden | ⭐⭐⭐⭐⭐ |

**Recommendation:** Use **custom scripts + Global Rules** for FleetMan:
- Simple handoff markdown files
- Structured progress tracking
- No external dependencies
- Full control over workflow

### 4.6 Recommended FleetMan Agent Workflow

```
┌─────────────────────────────────────────────────────────┐
│  SINGLE AGENT EXECUTION CYCLE                          │
│                                                         │
│  1. READ PHASE                                          │
│     • Read .cursorrules / .geminirules                 │
│     • Read relevant /docs files                         │
│     • Read previous agent handoff                       │
│                                                         │
│  2. PLAN PHASE                                          │
│     • List all files to modify                         │
│     • List all files to create                         │
│     • Estimate complexity                               │
│     • Identify risks                                    │
│                                                         │
│  3. EXECUTE PHASE                                       │
│     • Modify/create files one at a time                │
│     • Verify each change                                │
│     • Run linter after each file                        │
│                                                         │
│  4. DOCUMENT PHASE                                      │
│     • Update /docs/handoff_to_next_agent.md            │
│     • Update /docs/progress.md                          │
│     • Update relevant .md files                        │
│                                                         │
│  5. COMMIT PHASE                                        │
│     • git add .                                        │
│     • git commit -m "feat(scope): description"         │
│     • git push                                          │
└─────────────────────────────────────────────────────────┘
```

### 4.7 Context Management Strategy

To prevent context overflow:

| Technique | When to Use |
|-----------|-------------|
| **File References** | "See `/docs/pricing_strategy.md`" instead of copying |
| **Summaries** | Replace long files with 5-line summaries |
| **Incremental Handoffs** | Each agent only reads previous agent's output |
| **Feature Branches** | Each phase/feature gets its own branch |
| **Archive Old Docs** | Move completed phases to `/docs/archive/` |

---

## 5. IMPLEMENTATION ROADMAP

### 5.1 Recommended Sequence (8-10 Weeks)

#### Week 1-2: Critical Fixes + Phase 3 (Field Manager Loop)

| Day | Task | Output |
|-----|------|--------|
| 1-2 | Fix enum mismatches (DB ↔ Code) | Unified status types |
| 3-4 | Wire VehicleCardScreen to repository | Mobile shows real data |
| 5-7 | Build QR Scanner screen | Vehicle identification |
| 8-10 | Build Audit Form (photo, checklist) | eDVIR implementation |
| 11-14 | Build offline queue service | Syncs when online |

**Deliverable:** Park Manager can scan truck → do audit → submit photo → creates Issue

#### Week 3-4: Phase 4 (Maintenance Loop)

| Day | Task | Output |
|-----|------|--------|
| 15-17 | Build Issues Inbox (web) | Park Manager sees issues |
| 18-19 | Build Work Order creation | Formal task from issue |
| 20-22 | Build Mechanic mobile queue | Field Officer gets tasks |
| 23-25 | Build Parts consumption | Warehouse/external tracking |
| 26-28 | Build Receipt capture | Cost documentation |

**Deliverable:** Issue → Work Order → Mechanic completes → cost logged

#### Week 5-6: Phase 5 (eDVIR + Driver Assignment)

| Day | Task | Output |
|-----|------|--------|
| 29-31 | Build eDVIR checklist (mobile) | Daily inspection flow |
| 32-33 | Implement vehicle status states | Status → AVAILABLE/IN_MISSION/etc |
| 34-36 | Build Driver Assignment calendar | Assign drivers to vehicles |
| 37-39 | Build basic Ordre de Mission PDF | Mission documentation |
| 40-42 | Driver App toggle mechanism | Enable/disable driver access |

**Deliverable:** Daily eDVIR → Vehicle status changes → Driver assigned → Mission created

#### Week 7-8: Phase 6 (CEO Dashboard)

| Day | Task | Output |
|-----|------|--------|
| 43-45 | Build TCO calculation + display | Total cost per vehicle |
| 46-47 | Build CPK ranking table | Cost per KM ranking |
| 48-50 | Build Approval queue | CEO approves high-cost repairs |
| 51-53 | Build Fleet Availability widget | % of fleet ready |
| 54-56 | Build CSV export utility | Data export for accounting |

**Deliverable:** CEO sees TCO, CPK, fleet health, approval queue

#### Week 9-10: Phase 7 (Onboarding + Polish)

| Day | Task | Output |
|-----|------|--------|
| 57-59 | Build Smart Guide wizard | Guided onboarding |
| 60-62 | Build basic Landing page | Marketing presence |
| 63-65 | Build AdminOps tenant management | Super admin panel |
| 66-68 | Integration testing | Full flow verification |
| 69-70 | Bug fixes + polish | Production ready |

**Deliverable:** Complete MVP, ready for beta testing

### 5.2 What to SKIP for MVP

| Feature | Why Skip |
|---------|---------|
| Voice Notes | Infrastructure complexity, marginal value |
| OCR Receipt Scanning | Manual entry is 3 seconds |
| Gatekeeper Kiosk | No Enterprise clients yet |
| Predictive Maintenance ML | Requires 6+ months data |
| Chargily Integration | Manual CCP sufficient for <20 clients |
| API Access | No Enterprise clients |
| Full RTL Testing | Test before launch, not during |

### 5.3 Milestone Gates

| Milestone | Criteria | Go/No-Go |
|-----------|----------|----------|
| **M1: Core Loop** | Issue → Work Order → Resolution | Gate to Phase 5 |
| **M2: Field Ready** | eDVIR + Offline + Photo | Gate to Phase 6 |
| **M3: Executive Ready** | CEO Dashboard + KPIs | Gate to Phase 7 |
| **M4: MVP Complete** | Onboarding + Landing | Beta release |

---

## 6. AGENT HANDOFF PROMPTS

### 6.1 Master Handoff Prompt (For New Agent Sessions)

```
You are an expert full-stack developer working on FleetMan, an Algerian B2B Fleet Management SaaS.

## Project Context
- Stack: Flutter (Mobile) + Next.js (Web) + Supabase (Backend)
- Phase: MVP Development (~35% complete)
- Target: Algerian SME fleets (10-50 vehicles)
- Core Value: Maintenance-first, zero-hardware fleet management

## Current State (READ FIRST)
1. Database schema is complete (16 tables, RLS enabled)
2. Mobile: Auth + CI/CD + Design System done (95%)
3. Web: Scaffold + Vehicles + Auth done (70%)
4. All home screens are STUBS - zero functionality
5. NO work order flow exists
6. NO eDVIR implementation
7. NO CEO dashboard

## Your Task
[INSERT SPECIFIC TASK HERE]

## Workflow
1. Read `.cursorrules` and `.geminirules` FIRST
2. Read relevant docs from `/docs` directory
3. Read previous agent handoff from `/docs/handoff_to_next_agent.md`
4. Execute ONLY your assigned task
5. Update `/docs/handoff_to_next_agent.md` with your progress
6. Commit with: `git commit -m "feat(scope): description"`

## Absolute Rules
1. NEVER call Supabase directly from UI - use Repository pattern
2. All commits MUST be atomic (one feature per commit)
3. All strings MUST use localization keys (FR-DZ + AR-DZ)
4. NEVER break existing functionality
5. Write cloud-agnostic code (Repository interfaces)

## Files to Read
- `/docs/FLEETMAN_MVP_COMPLETE_AUDIT_REPORT.md`
- `/docs/global_product_requirements.md`
- `/docs/ux_workflow_logic.md`
- `/docs/implementation_plan.md`
- `/docs/handoff_to_next_agent.md`

Start by reading the audit report and implementation plan, then wait for my confirmation before executing.
```

### 6.2 Phase 3 (Field Manager Loop) Agent Prompt

```
## PHASE 3 EXECUTION: Field Manager Loop

You are executing Phase 3 of FleetMan MVP development.

### Starting Point
- Auth is working (Phase 1 complete)
- Vehicles can be added/viewed (Phase 2 partial)
- All home screens are stubs

### Your Mission
Build the field manager's core workflow:
1. QR Scanner → Identify vehicle
2. Audit Form → Photo + Checklist + Pass/Fail
3. Issue Generation → Auto-creates Issue on "Fail"
4. Offline Queue → Works in dead zones

### Specific Tasks
1. **Create StorageRepository** (interface + Supabase impl)
   - Bucket: `vehicle_photos`
   - Methods: uploadPhoto(), getPhotoUrl()
   
2. **Create QRScreen**
   - Mobile: `mobile/lib/features/field/qr_scanner_screen.dart`
   - Uses `mobile_scanner` package
   - On scan → navigates to Audit Form

3. **Create AuditForm**
   - Mobile: `mobile/lib/features/field/audit_form_screen.dart`
   - Checklist: Tires, Lights, Fluids, Mirrors, Odometer
   - Camera: Photo capture
   - Pass/Fail toggle
   - On Fail → creates Issue in DB

4. **Create OfflineQueue**
   - Mobile: `mobile/lib/core/services/offline_sync_service.dart`
   - Hive/SQLite for local storage
   - Auto-sync when online

### Cloud-Agnostic Rule
All Supabase calls via Repository. Example:
```dart
// ✅ CORRECT
final photoUrl = await storageRepository.uploadPhoto(file);

// ❌ WRONG  
await supabase.storage.from('vehicle_photos').upload(...)
```

### File Outputs
- `mobile/lib/core/repositories/storage_repository.dart` (interface)
- `mobile/lib/core/repositories/supabase_storage_repository.dart` (impl)
- `mobile/lib/features/field/qr_scanner_screen.dart`
- `mobile/lib/features/field/audit_form_screen.dart`
- `mobile/lib/core/services/offline_sync_service.dart`

### Verify
After building:
1. Run `flutter analyze` - zero warnings
2. Test QR scan on physical device
3. Test airplane mode → audit queues → reconnect → syncs

Commit message: `feat(phase-3): implement field manager audit loop`

Read `/docs/phase_3_handoff.md` for full context, then wait for approval.
```

### 6.3 Phase 4 (Maintenance Loop) Agent Prompt

```
## PHASE 4 EXECUTION: Maintenance Loop

You are executing Phase 4 of FleetMan MVP development.

### Starting Point
- Phase 3 complete: Park Manager can audit trucks and create Issues
- Web: Vehicle list and detail done
- Mobile: Auth done, vehicles partially done

### Your Mission
Build the maintenance workflow:
1. Issues Inbox (Web) → Park Manager triages
2. Work Order creation → Formal task from Issue
3. Mechanic Queue (Mobile) → Field Officer executes
4. Parts consumption → Warehouse or external
5. Receipt capture → Cost documentation

### Specific Tasks

#### Web: Issues Inbox
- Page: `web/src/app/[locale]/(dashboard)/issues/page.tsx`
- Shows: All OPEN issues with photo, vehicle, reporter
- Actions: "Create Work Order" button

#### Web: Create Work Order
- Page: `web/src/app/[locale]/(dashboard)/work-orders/new/page.tsx`
- Converts Issue to Work Order
- Assigns to Mechanic
- Sets priority, type

#### Mobile: Mechanic Home
- Replace `mechanic_home_stub.dart` with real implementation
- Shows: "My Assigned Work Orders" list
- Tap → Work Order detail

#### Mobile: Work Order Detail
- Screen: `mobile/lib/features/mechanic/work_order_detail_screen.dart`
- Shows: Photos from Issue
- Actions: Update status, Add parts, Upload receipt

#### Mobile: Parts Selector
- Widget: `mobile/lib/features/mechanic/parts_selector_widget.dart`
- Sources: Warehouse stock OR External vendor
- For external: Snap receipt photo

#### Mobile: Job Complete
- Action: Resolution photo + Signature
- Updates: Work Order status → COMPLETED

### Repository Pattern
```typescript
// Web
interface WorkOrderRepository {
  getByMechanic(mechanicId: string): Promise<WorkOrder[]>
  getById(id: string): Promise<WorkOrder | null>
  create(dto: CreateWorkOrderDTO): Promise<WorkOrder>
  updateStatus(id: string, status: WorkOrderStatus): Promise<void>
  addParts(id: string, parts: WorkOrderPart[]): Promise<void>
}
```

### File Outputs
- `web/src/app/[locale]/(dashboard)/issues/page.tsx`
- `web/src/app/[locale]/(dashboard)/work-orders/new/page.tsx`
- `web/src/lib/repositories/work-order-repository.ts`
- `web/src/lib/repositories/supabase-work-order-repository.ts`
- `mobile/lib/features/mechanic/mechanic_home_screen.dart` (replaces stub)
- `mobile/lib/features/mechanic/work_order_detail_screen.dart`
- `mobile/lib/features/mechanic/parts_selector_widget.dart`

### Verify
1. Run `npm run lint` (web) and `flutter analyze` (mobile)
2. Full flow: Issue → WO → Mechanic completes → Cost logged
3. Check Supabase: work_orders and work_order_parts populated

Commit message: `feat(phase-4): implement maintenance loop`

Read previous agent handoff, then wait for approval.
```

### 6.4 Phase 5 (eDVIR) Agent Prompt

```
## PHASE 5 EXECUTION: eDVIR + Asset Control

You are executing Phase 5 of FleetMan MVP development.

### Starting Point
- Phase 3: Audit flow works
- Phase 4: Work order flow works
- Need: Daily inspection loop + vehicle status

### Your Mission
1. Daily eDVIR checklist (mobile)
2. Vehicle status state machine
3. Driver assignment calendar (web)
4. Basic Ordre de Mission PDF

### Specific Tasks

#### Mobile: eDVIR Checklist
- Screen: `mobile/lib/features/edvir/edvir_checklist_screen.dart`
- Pre-departure inspection form
- Checklist: Tires, Lights, Mirrors, Fluids, Odometer
- Pass/Fail → updates vehicle status
- On Fail → creates Issue (reuse Phase 3 logic)

#### Mobile: Vehicle Status States
Statuses (from PRD):
- AVAILABLE → In yard, ready
- IN_MISSION → On assigned trip
- ADMINISTRATIVE_IN_USE → Non-mission out (washing, inspection)
- OUT_OF_SERVICE → Cannot drive
- IN_SHOP → Being repaired
- NEEDS_ATTENTION → Light damage, drivable

#### Web: Driver Assignment Calendar
- Page: `web/src/app/[locale]/(dashboard)/calendar/page.tsx`
- Shows: Vehicles (rows) × Days (columns)
- Drag driver onto vehicle → assigns
- Auto-generates Ordre de Mission

#### PDF: Ordre de Mission Generation
- Supabase Edge Function: `supabase/functions/generate-ordre-mission/`
- Inputs: vehicle_id, driver_id, destination, purpose
- Output: PDF URL stored in `ordres_de_mission.pdf_url`

### Database Considerations
The `driver_assignments` table already exists in migration 0001:
```sql
- id, tenant_id, vehicle_id, driver_id, assigned_by
- start_time, end_time, status (SCHEDULED/ACTIVE/COMPLETED)
```

### File Outputs
- `mobile/lib/features/edvir/edvir_checklist_screen.dart`
- `mobile/lib/core/repositories/vehicle_repository.dart` (updated)
- `web/src/app/[locale]/(dashboard)/calendar/page.tsx`
- `supabase/functions/generate-ordre-mission/index.ts`

### Verify
1. Park Manager runs eDVIR → vehicle status changes
2. Assign driver on calendar → Ordre de Mission PDF generated
3. Check vehicle status in DB reflects eDVIR result

Commit message: `feat(phase-5): implement eDVIR and driver assignment`

Read relevant docs, then wait for approval.
```

### 6.5 Phase 6 (CEO Dashboard) Agent Prompt

```
## PHASE 6 EXECUTION: CEO Dashboard

You are executing Phase 6 of FleetMan MVP development.

### Starting Point
- Phases 3-5 complete: Full operational loop works
- Need: Executive visibility and financial controls

### Your Mission
1. TCO (Total Cost of Ownership) per vehicle
2. CPK (Cost Per Kilometer) ranking
3. Approval queue for high-cost repairs
4. Fleet availability percentage
5. CSV export utility

### KPIs from PRD

#### KPI 1: TCO Per Vehicle
```
TCO = SUM(work_order_parts.unit_cost_dzd × quantity) 
    + SUM(fuel_logs.cost_dzd)
    + SUM(insurance, taxes, etc.)
```
Display: Large number in DZD + sparkline trend

#### KPI 2: CPK Ranking
```
CPK = TCO / (current_odometer - starting_odometer)
```
Display: Ranked table, worst at top, color-coded

#### KPI 3: Fleet Availability
```
Availability = (AVAILABLE + IN_MISSION) / Total × 100
```
Display: Donut chart, green ≥85%, orange 70-84%, red <70%

#### KPI 4: Approval Queue
```
work_orders WHERE status = 'AWAITING_APPROVAL' 
  AND cash_cost_dzd > tenant.auto_approve_threshold_dzd
```
Display: Badge count + Approve/Reject buttons

### Specific Tasks

#### Web: CEO Dashboard Page
- Page: `web/src/app/[locale]/(dashboard)/dashboard/page.tsx`
- Layout: Grid of KPI widgets
- Gate: Check user roles includes 'CEO'

#### Web: KPI Widgets
- Components: `web/src/app/[locale]/(dashboard)/components/kpi-tco-widget.tsx`
- `kpi-cpk-widget.tsx`, `kpi-availability-widget.tsx`, `kpi-approval-queue.tsx`

#### Web: CSV Export Utility
- Utility: `web/src/lib/utils/export-csv.ts`
- Usage: Add "Export" button to all data tables

### Repository Queries (Examples)
```typescript
// TCO calculation
const tco = await supabase
  .from('work_order_parts')
  .select('unit_cost_dzd, quantity')
  .eq('vehicle_id', vehicleId);

// CPK calculation
const vehicle = await vehicleRepo.getById(vehicleId);
const cpk = tco / (vehicle.current_odometer - vehicle.starting_odometer);
```

### File Outputs
- `web/src/app/[locale]/(dashboard)/dashboard/page.tsx`
- `web/src/app/[locale]/(dashboard)/components/kpi-tco-widget.tsx`
- `web/src/app/[locale]/(dashboard)/components/kpi-cpk-widget.tsx`
- `web/src/app/[locale]/(dashboard)/components/kpi-availability-widget.tsx`
- `web/src/app/[locale]/(dashboard)/components/kpi-approval-queue.tsx`
- `web/src/lib/utils/export-csv.ts`

### Verify
1. Populate 5 vehicles + 10 work orders
2. CEO dashboard shows correct TCO and CPK
3. High-cost repair requires approval
4. CSV exports correctly

Commit message: `feat(phase-6): implement CEO dashboard`

Read previous handoffs, then wait for approval.
```

### 6.6 Phase 7 (Landing + Onboarding) Agent Prompt

```
## PHASE 7 EXECUTION: Landing Page + Onboarding

You are executing Phase 7 of FleetMan MVP development.

### Starting Point
- Phases 3-6 complete: Full product works
- Need: Marketing presence + guided onboarding

### Your Mission
1. Public Landing Page
2. "Request Demo" form → Lead capture
3. Smart Guide onboarding wizard
4. AdminOps tenant management (basic)

### Specific Tasks

#### Web: Landing Page
- Route: `web/src/app/[locale]/page.tsx` (public, no auth)
- Sections: Hero, Features, Pricing, CTA
- Hero: "Réduisez l'immobilisation de 30%"
- CTA: "Demander une démo"

#### Web: Request Demo Form
- Page: `web/src/app/[locale]/demo/page.tsx`
- Fields: Company name, contact name, email, phone, fleet size
- Submits to `leads` table (already exists in DB)
- Confirmation: "Nous vous contacterons sous 24h"

#### Web: Smart Guide Onboarding
- After registration, redirect to `/onboarding`
- Steps:
  1. Add your first vehicle (form)
  2. Add your first driver (form)  
  3. Set your financial threshold (number input)
  4. Complete → redirect to dashboard
- Blocking: Cannot access dashboard until complete

#### Web: Basic AdminOps
- Route: `/admin` (guarded by is_super_admin)
- Tenant list: All companies, status, signup date
- Actions: Approve, Suspend, View details

### File Outputs
- `web/src/app/[locale]/page.tsx` (landing)
- `web/src/app/[locale]/demo/page.tsx`
- `web/src/app/[locale]/onboarding/page.tsx`
- `web/src/app/[locale]/onboarding/components/step-vehicle.tsx`
- `web/src/app/[locale]/onboarding/components/step-driver.tsx`
- `web/src/app/[locale]/onboarding/components/step-threshold.tsx`
- `web/src/app/[locale]/admin/page.tsx`

### Verify
1. Landing page loads, mobile responsive
2. Demo form submits lead to DB
3. New user → Smart Guide → Cannot bypass
4. Super admin can see all tenants

Commit message: `feat(phase-7): implement landing and onboarding`

Read docs, then wait for approval.
```

---

## APPENDIX: FILE REFERENCE

### Key Documentation Files

| File | Purpose |
|------|---------|
| `/docs/FLEETMAN_MVP_COMPLETE_AUDIT_REPORT.md` | Current project state |
| `/docs/global_product_requirements.md` | Full PRD (source of truth) |
| `/docs/ux_workflow_logic.md` | Detailed UX flows |
| `/docs/implementation_plan.md` | Phase-by-phase roadmap |
| `/docs/architecture_compliance.md` | Technical + legal architecture |
| `/docs/pricing_marketing_strategy.md` | Market positioning |
| `/docs/design_system_admin_panel_research.md` | Fleetio analysis |
| `/docs/handoff_to_next_agent.md` | Current agent state |

### Database Migrations

| File | Purpose |
|------|---------|
| `0000_fleetman_initial_schema.sql` | Core 7 tables |
| `0001_fleetman_v4_kpi_schema_update.sql` | KPI tables |
| `0002_fleetman_fuel_type_update.sql` | Fuel enum |
| `0003_fleetman_tenant_registration_trigger.sql` | Auto-provisioning |
| `0004_align_vehicles_schema.sql` | Column alignment |

### Repository Interfaces

| Mobile | Web | Purpose |
|--------|-----|---------|
| `auth_repository.dart` | `auth-repository.ts` | Authentication |
| `vehicle_repository.dart` | `vehicle-repository.ts` | Vehicles |
| `storage_repository.dart` | (in vehicle repo) | File uploads |

---

*End of Master Documentation*
