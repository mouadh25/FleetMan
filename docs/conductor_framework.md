# 🚀 FleetMan Conductor Framework & Skills 2.0

> **Version:** 1.0  
> **Date:** April 16, 2026  
> **Type:** Agent Orchestration Master Document  
> **Purpose:** Enable autonomous vibe-coding workflows with context-aware AI agents  

---

## EXECUTIVE SUMMARY

FleetMan's Conductor Framework is a **Skills 2.0 architecture** inspired by Gemini's skill-based agent system. It enables AI agents to operate autonomously with clear skill definitions, execution protocols, and context awareness.

**Core Principle:** The conductor document is NOT a simple handoff - it's an **autonomous execution framework** that tells incoming agents WHAT to do, HOW to do it, and WHEN to escalate.

### Key Differentiators from Simple Handoff

| Aspect | Simple Handoff | FleetMan Conductor Framework |
|--------|---------------|------------------------------|
| **Agent Autonomy** | Low - requires constant approval | High - agents execute within skill bounds |
| **Context Transfer** | Document copy-paste | Structured skill injection |
| **Error Handling** | Human decides | Pre-defined escalation protocols |
| **Execution Flow** | Linear steps | Parallel skill execution |
| **Quality Gates** | Manual review | Automated verification pipelines |

---

## PART 1: CONDUCTOR ARCHITECTURE

### 1.1 The Three-Tier Agent System

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    FLEETMAN CONDUCTOR FRAMEWORK                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    TIER 1: CONDUCTOR (This Document)            │   │
│  │  • Orchestrates all agent sessions                              │   │
│  │  • Defines skill boundaries and execution rules                 │   │
│  │  • Manages context injection and state transfer                │   │
│  │  • Handles escalation protocols                                 │   │
│  │  • Evaluates completion criteria                                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                    │
│           ┌────────────────────────┼────────────────────────┐           │
│           ▼                        ▼                        ▼           │
│  ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐│
│  │ TIER 2: SKILL   │      │ TIER 2: SKILL   │      │ TIER 2: SKILL   ││
│  │ SPECIALIST      │      │ SPECIALIST      │      │ SPECIALIST      ││
│  │                 │      │                 │      │                 ││
│  │ Mobile Flutter  │      │ Web Next.js     │      │ Database/       ││
│  │ Agent           │      │ Agent           │      │ Supabase Agent  ││
│  │                 │      │                 │      │                 ││
│  │ Executes field  │      │ Executes web   │      │ Executes DB    ││
│  │ tasks via Skills│      │ tasks via Skills│      │ tasks via Skills││
│  │ 3.1 - 3.5       │      │ 4.1 - 4.5       │      │ 0.1 - 0.5       ││
│  └─────────────────┘      └─────────────────┘      └─────────────────┘│
│                                    │                                    │
│                                    ▼                                    │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    TIER 3: VALIDATION ENGINE                    │   │
│  │  • Automated quality gates                                      │   │
│  │  • Lint & type check execution                                  │   │
│  │  • Test verification                                            │   │
│  │  • Security scan                                                │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Context Injection Protocol

When an agent starts a session, the Conductor injects context in this order:

```
1. SKILL BOUNDARY DEFINITION
   → Which skills this agent is authorized to execute
   → What parameters each skill accepts

2. STATE TRANSFER
   → Current project state (from previous skill executions)
   → Known issues and mitigation strategies
   → Resource availability and constraints

3. EXECUTION PROTOCOL
   → How to execute each skill (synchronous vs async)
   → Error handling and retry strategies
   → Escalation triggers

4. COMPLETION CRITERIA
   → What constitutes "done" for each skill
   → Quality gates that must pass
   → Handoff conditions to next skill
```

---

## PART 2: SKILLS 2.0 DEFINITIONS

### 2.1 Skill Structure

Each skill follows this structure:

```yaml
skill:
  id: unique_identifier
  name: Human readable name
  category: mobile | web | database | infrastructure
  tier: 2 (Skill Specialist)
  description: What this skill does
  prerequisites: 
    - List of skills that must complete first
    - OR "none" if skill is entry point
  parameters:
    - name: parameter_name
      type: string | number | boolean | object
      required: true | false
      default: default_value_if_any
  execution:
    mode: sequential | parallel | conditional
    steps:
      - description of step
      - verification method
  outputs:
    - What this skill produces
  success_criteria:
    - Measurable outcomes
  escalation:
    triggers:
      - When to escalate to human
    fallback: What to do if escalation needed
```

### 2.2 FleetMan Skill Registry

#### SKILL 0.1: Database Migration Executor
```yaml
id: skill_0_1
name: Execute Database Migration
category: database
tier: 2
description: Applies SQL migrations to Supabase database with rollback capability

prerequisites:
  - skill_0_2 (RLS Policy Validator) - can run parallel

parameters:
  - name: migration_file
    type: string
    required: true
    description: Path to .sql migration file
  - name: direction
    type: string
    required: false
    default: up
    options: [up, down, status]
  - name: force
    type: boolean
    required: false
    default: false
    description: Force migration even if hashes don't match

execution:
  mode: sequential
  steps:
    - step: Validate migration syntax
      verification: psql --dry-run or SQL review
    - step: Check current migration state
      verification: supabase migration status
    - step: Execute migration
      verification: Exit code 0 + schema changes verified
    - step: Reload schema cache
      verification: SELECT * FROM pg_extension where extname = 'supabase'

outputs:
  - Applied migration to target database
  - Updated migration history table
  - Verified schema consistency

success_criteria:
  - Migration completes with exit code 0
  - All tables/columns/constraints exist as expected
  - RLS policies still function correctly
  - No data loss (for up migrations)

escalation:
  triggers:
    - Migration fails after 3 retry attempts
    - Data loss detected
    - RLS policy breaks tenant isolation
  fallback: Rollback migration + notify via console
```

#### SKILL 0.2: RLS Policy Validator
```yaml
id: skill_0_2
name: Validate Row Level Security Policies
category: database
tier: 2
description: Ensures RLS policies correctly enforce tenant isolation

prerequisites:
  - none (can run parallel with skill_0_1)

parameters:
  - name: tenant_id
    type: string (UUID)
    required: true
    description: Tenant to test isolation against
  - name: table_name
    type: string
    required: false
    description: Specific table to test (or all tables if omitted)

execution:
  mode: parallel
  steps:
    - step: List all tables with RLS enabled
      verification: Query pg_policies WHERE rls_enabled = true
    - step: Test cross-tenant access attempts
      verification: All SELECT/INSERT/UPDATE/DETELE return 0 rows
    - step: Verify service role can bypass (for admin functions)
      verification: Service role query returns expected rows

outputs:
  - RLS validation report
  - Failed policies (if any)

success_criteria:
  - Zero cross-tenant data leakage
  - All policies return expected results
  - Service role bypass works for admin operations

escalation:
  triggers:
    - Any cross-tenant access detected
    - Policy returns unexpected rows
  fallback: Disable policy temporarily + alert immediately
```

#### SKILL 1.1: Mobile Auth Flow Implementer
```yaml
id: skill_1_1
name: Implement Mobile Authentication Flow
category: mobile
tier: 2
description: Implements complete auth flow using Repository pattern with Supabase

prerequisites:
  - skill_0_1 (Database Migration - auth tables exist)
  - skill_1_2 (Design Token Integrator - for theming)

parameters:
  - name: auth_type
    type: string
    required: true
    options: [email_password, otp, magic_link]
  - name: include_social
    type: boolean
    required: false
    default: false
  - name: require_otp_verification
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create AuthRepository interface
      verification: Abstract class with all methods defined
    - step: Implement SupabaseAuthRepository
      verification: All methods call Supabase client correctly
    - step: Create AuthState management (Riverpod/Provider)
      verification: State updates correctly on auth events
    - step: Build Login screen
      verification: UI matches design tokens, inputs validated
    - step: Build Register screen
      verification: Creates profile + tenant on signup
    - step: Implement logout
      verification: Clears local state and Supabase session
    - step: Add loading/error states
      verification: All UI states handled properly

outputs:
  - AuthRepository interface
  - SupabaseAuthRepository implementation
  - AuthState provider
  - Login screen
  - Register screen
  - Logout functionality

success_criteria:
  - User can sign up and receive confirmation email
  - User can sign in and session persists
  - User can sign out completely
  - All strings localized (FR-DZ + AR-DZ)
  - 56px touch targets on all buttons
  - Light theme by default

escalation:
  triggers:
    - Auth fails after 3 attempts
    - OTP never arrives
    - Session doesn't persist
  fallback: Log error + show user-friendly message in local language
```

#### SKILL 1.2: Design Token Integrator (Mobile)
```yaml
id: skill_1_2
name: Integrate Design Tokens into Flutter App
category: mobile
tier: 2
description: Applies FleetMan design system tokens to Flutter theme

prerequisites:
  - none

parameters:
  - name: theme_type
    type: string
    required: true
    options: [light_primary, dark_secondary]
  - name: update_app_theme
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Verify AppTheme class exists
      verification: File at lib/core/theme/app_theme.dart
    - step: Apply color tokens
      verification: Colors match design-tokens.css hex values
    - step: Apply typography scale
      verification: Font sizes match spec (16px body min)
    - step: Apply spacing system
      verification: Space tokens used consistently
    - step: Apply shadow system
      verification: Shadows match elevation levels
    - step: Configure button themes
      verification: 56px min height, 12px radius, proper states
    - step: Configure input themes
      verification: 56px min height, 2px border, focus states

outputs:
  - Updated AppTheme class with all tokens
  - LightTheme (PRIMARY for field use)
  - DarkTheme (SECONDARY for indoor use)

success_criteria:
  - All colors match FleetMan palette
  - All font sizes meet minimums (16px body, 14px caption)
  - All touch targets meet 56px minimum
  - Border radius consistent at 12px
  - Focus states visible (4px shadow ring)

escalation:
  triggers:
    - Color value deviates from spec by > 2%
    - Touch target below 56px anywhere
  fallback: Revert to spec values immediately
```

#### SKILL 1.3: Localization Setup
```yaml
id: skill_1_3
name: Setup Flutter Localization (FR-DZ + AR-DZ)
category: mobile
tier: 2
description: Configures bilingual localization with RTL support

prerequisites:
  - none

parameters:
  - name: locales
    type: array
    required: true
    default: [fr_DZ, ar_DZ]
  - name: rtl_support
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Verify l10n.yaml configuration
      verification: File exists with correct arb-dir and template-language
    - step: Create/update FR-DZ arb file
      verification: All strings translated, no missing keys
    - step: Create/update AR-DZ arb file
      verification: RTL text direction, Arabic numeral support
    - step: Configure GoRouter for locale routing
      verification: URL reflects current locale
    - step: Test RTL layout
      verification: EdgeInsetsDirectional used, no left/right hardcoded

outputs:
  - l10n.yaml configuration
  - app_fr.arb and app_fr_DZ.arb
  - app_ar.arb and app_ar_DZ.arb
  - Generated AppLocalizations class

success_criteria:
  - All UI strings come from localization
  - No hardcoded French or Arabic strings
  - RTL layout flips correctly on Arabic
  - Numbers formatted with DZD locale

escalation:
  triggers:
    - Missing translation key
    - RTL layout breaks on any screen
  fallback: Use FR-DZ as fallback until fixed
```

#### SKILL 1.4: Home Screen Builder (Role-Based)
```yaml
id: skill_1_4
name: Build Role-Based Home Screens
category: mobile
tier: 2
description: Creates home screens for each role with proper widget hierarchy

prerequisites:
  - skill_1_1 (Auth - knows user role)
  - skill_1_2 (Design Tokens - consistent styling)

parameters:
  - name: role
    type: string
    required: true
    options: [ceo, park_manager, mechanic, driver, gatekeeper, one_man_army]
  - name: include_offline_indicator
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create role-specific home screen file
      verification: File at features/home/presentation/{role}_home_screen.dart
    - step: Implement role-specific widgets
      verification: Uses only widgets appropriate to role
    - step: Add quick actions grid
      verification: 56px touch targets, icons + labels
    - step: Add status summary cards
      verification: Real data from repository, not hardcoded
    - step: Add offline indicator
      verification: Shows sync status prominently
    - step: Add role badge and user info
      verification: Clear visual indication of current role

outputs:
  - Role-specific home screen
  - Quick action widgets
  - Status summary cards
  - Offline sync indicator

success_criteria:
  - Shows relevant data for role (KPIs for CEO, work orders for mechanic)
  - All touch targets 56px minimum
  - Light theme PRIMARY (except mechanic can toggle dark)
  - Pull-to-refresh works
  - Offline mode shows cached data with indicator

escalation:
  triggers:
    - Home screen shows hardcoded/stub data
    - Wrong widgets shown for role
    - Touch target below 56px
  fallback: Show empty state with reload button
```

#### SKILL 1.5: Mobile CI/CD Pipeline Setup
```yaml
id: skill_1_5
name: Setup Mobile CI/CD with GitHub Actions
category: mobile
tier: 2
description: Configures automated build, lint, and test pipeline

prerequisites:
  - none (can run parallel)

parameters:
  - name: flutter_version
    type: string
    required: false
    default: "3.24.0"
  - name: include_tests
    type: boolean
    required: false
    default: true

execution:
  mode: parallel
  steps:
    - step: Create GitHub Actions workflow
      verification: .github/workflows/flutter.yml exists
    - step: Configure lint step
      verification: flutter analyze with zero warnings
    - step: Configure test step
      verification: flutter test passes
    - step: Configure build step
      verification: flutter build apk --debug succeeds
    - step: Configure APK upload
      verification: APK uploaded as artifact

outputs:
  - GitHub Actions workflow
  - Lint configuration
  - Build artifacts

success_criteria:
  - Every PR triggers lint + test
  - Every push to main triggers APK build
  - APK artifact available for download
  - Zero warnings in flutter analyze

escalation:
  triggers:
    - Build fails after 3 attempts
    - Lint warnings exceed 10
  fallback: Notify via GitHub Actions status + halt deployment
```

#### SKILL 2.1: Vehicle Repository Implementation (Mobile)
```yaml
id: skill_2_1
name: Implement Vehicle Repository (Mobile)
category: mobile
tier: 2
description: Creates cloud-agnostic vehicle data layer

prerequisites:
  - skill_0_1 (Database - vehicles table exists)
  - skill_1_2 (Design Tokens - consistent)

parameters:
  - name: include_offline_cache
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create VehicleRepository interface
      verification: Abstract class with CRUD methods
    - step: Create Vehicle model
      verification: Matches database schema exactly
    - step: Implement SupabaseVehicleRepository
      verification: All methods use Supabase client
    - step: Add local cache (Hive/SQLite)
      verification: Caches work offline
    - step: Implement sync logic
      verification: Push/pull when online
    - step: Wire VehicleCardScreen to repository
      verification: Real data displays, not stubs

outputs:
  - VehicleRepository interface
  - Vehicle model
  - SupabaseVehicleRepository implementation
  - Local cache implementation
  - Wired VehicleCardScreen

success_criteria:
  - Vehicle list shows real data from database
  - Offline mode shows cached data
  - Sync works when connection restored
  - 56px touch targets on vehicle cards
  - Status badges use traffic-light colors

escalation:
  triggers:
    - Data doesn't load after 5 seconds
    - Sync fails repeatedly
    - Enum mismatch between code and DB
  fallback: Show cached data + retry indicator
```

#### SKILL 3.1: QR Scanner Screen Builder
```yaml
id: skill_3_1
name: Build QR Scanner Screen
category: mobile
tier: 2
description: Creates vehicle identification via QR code scanning

prerequisites:
  - skill_2_1 (Vehicle Repository - can query vehicles)
  - skill_1_4 (Home Screen - navigation context)

parameters:
  - name: use_camera
    type: string
    required: true
    options: [mobile_scanner, google_mlkit]
  - name: fallback_manual_entry
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Add mobile_scanner dependency
      verification: pubspec.yaml updated
    - step: Create QRScannerScreen
      verification: Full screen camera view
    - step: Implement vehicle lookup
      verification: Query vehicle by scanned code
    - step: Handle scan success
      verification: Navigate to AuditFormScreen
    - step: Handle scan failure
      verification: Show error + retry
    - step: Add manual plate entry fallback
      verification: Text input for plate number

outputs:
  - QRScannerScreen full implementation
  - Vehicle lookup logic
  - Manual entry fallback

success_criteria:
  - QR code scans within 2 seconds
  - Vehicle found matches scanned code
  - Light theme for outdoor use
  - 56px touch targets
  - Camera permission handled gracefully

escalation:
  triggers:
    - Camera permission denied
    - QR scan fails 3 times
    - Vehicle not found in database
  fallback: Offer manual plate entry
```

#### SKILL 3.2: Audit Form Screen Builder
```yaml
id: skill_3_2
name: Build eDVIR Audit Form Screen
category: mobile
tier: 2
description: Creates pre-trip inspection checklist with photo evidence

prerequisites:
  - skill_2_1 (Vehicle Repository)
  - skill_3_1 (QR Scanner - vehicle ID context)
  - skill_1_2 (Design Tokens)

parameters:
  - name: checklist_items
    type: array
    required: true
    default: [tires, lights, fluids, mirrors, odometer]
  - name: require_photo
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create AuditFormScreen
      verification: Form with checklist items
    - step: Add eDVIR checklist items
      verification: Each item has Pass/Fail toggle
    - step: Implement odometer reading input
      verification: Numeric keyboard, validation
    - step: Add photo capture
      verification: Camera-first UX, required
    - step: Implement Pass/Fail logic
      verification: Pass → complete, Fail → create Issue
    - step: Add offline queue
      verification: Submit works without network

outputs:
  - AuditFormScreen
  - eDVIR checklist (5 items)
  - Photo capture
  - Pass/Fail submission logic
  - Offline queue integration

success_criteria:
  - All 5 checklist items completed
  - Photo captured before submission
  - Odometer reading recorded
  - Pass → vehicle status stays Available
  - Fail → Issue created in database
  - Offline queue syncs when online

escalation:
  triggers:
    - Photo capture fails
    - Form submitted without all fields
    - Offline submission fails after retry
  fallback: Save locally, queue for sync, notify user
```

#### SKILL 3.3: Offline Sync Service Builder
```yaml
id: skill_3_3
name: Build Offline Sync Service
category: mobile
tier: 2
description: Creates local queue for operations when offline

prerequisites:
  - skill_2_1 (Vehicle Repository)
  - skill_1_2 (Design Tokens - indicator styling)

parameters:
  - name: storage_type
    type: string
    required: false
    default: hive
    options: [hive, sqlite, drift]

execution:
  mode: sequential
  steps:
    - step: Create OfflineSyncService
      verification: Singleton service class
    - step: Define offline operation model
      verification: Type, payload, timestamp, retryCount
    - step: Implement local queue storage
      verification: Hive box for offline operations
    - step: Monitor connectivity
      verification: Connectivity.listen() triggers sync
    - step: Implement sync on reconnect
      verification: Process queue in FIFO order
    - step: Add pending count indicator
      verification: Shows badge with count

outputs:
  - OfflineSyncService singleton
  - Local queue (Hive/SQLite)
  - Connectivity monitoring
  - Sync trigger on reconnect
  - UI indicator for pending operations

success_criteria:
  - Operations queue when offline
  - Auto-sync when connection restored
  - Conflict resolution (last-write-wins)
  - Pending count visible in UI
  - Retry logic with exponential backoff

escalation:
  triggers:
    - Sync fails after 5 retries
    - Data conflict detected
    - Storage quota exceeded
  fallback: Keep locally, notify user, manual retry option
```

#### SKILL 3.4: Issue Creation Flow
```yaml
id: skill_3_4
name: Build Issue Creation Flow
category: mobile
tier: 2
description: Creates issues from failed audits and manual reports

prerequisites:
  - skill_2_1 (Vehicle Repository)
  - skill_3_2 (Audit Form - trigger context)
  - skill_3_3 (Offline Sync - can queue)

parameters:
  - name: default_priority
    type: string
    required: false
    default: medium
    options: [low, medium, high, critical]

execution:
  mode: sequential
  steps:
    - step: Create IssueRepository interface
      verification: CRUD methods defined
    - step: Implement SupabaseIssueRepository
      verification: Supabase calls
    - step: Create IssueFormScreen
      verification: Photo + description + priority
    - step: Implement auto-issue from audit
      verification: Fail triggers Issue creation
    - step: Add manual issue report
      verification: "Signaler un problème" button

outputs:
  - IssueRepository interface
  - SupabaseIssueRepository
  - IssueFormScreen
  - Auto-issue from failed audit
  - Manual issue report button

success_criteria:
  - Failed audit auto-creates Issue with photo
  - Manual report creates Issue with all fields
  - Priority selection works
  - Offline queue works
  - Web dashboard sees new issues instantly

escalation:
  triggers:
    - Issue creation fails after retry
    - Photo upload fails
  fallback: Queue locally, sync later, notify Park Manager
```

#### SKILL 3.5: Mechanic Work Order Queue
```yaml
id: skill_3_5
name: Build Mechanic Work Order Queue
category: mobile
tier: 2
description: Creates mechanic's task queue for assigned work orders

prerequisites:
  - skill_2_1 (Vehicle Repository)
  - skill_3_4 (Issue Creation - issues become WO)

parameters:
  - name: include_parts_logging
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create WorkOrderRepository
      verification: Interface with status updates
    - step: Implement work order list screen
      verification: "My Tasks" queue view
    - step: Add work order detail screen
      verification: Photo of damage, description, parts needed
    - step: Implement completion flow
      verification: "Job Complete" with photo proof
    - step: Add parts consumption logging
      verification: Warehouse or external purchase
    - step: Add receipt photo capture
      verification: For external purchases

outputs:
  - WorkOrderRepository
  - WorkOrderListScreen (queue)
  - WorkOrderDetailScreen
  - Completion flow with photo
  - Parts logging
  - Receipt capture

success_criteria:
  - Mechanic sees assigned work orders only
  - Can view photo of damage from audit
  - Can log parts used (warehouse or external)
  - Can capture receipt photo
  - Can complete with photo proof
  - Status updates visible to Park Manager

escalation:
  triggers:
    - Work order not found
    - Parts inventory issue
    - Completion photo missing
  fallback: Save progress, notify supervisor
```

#### SKILL 4.1: Web Auth Flow Implementer
```yaml
id: skill_4_1
name: Implement Web Authentication Flow
category: web
tier: 2
description: Creates Next.js authentication with Supabase

prerequisites:
  - skill_0_1 (Database - auth tables exist)
  - skill_0_2 (RLS - tenant isolation verified)

parameters:
  - name: auth_type
    type: string
    required: true
    options: [email_password, otp]
  - name: include_mfa
    type: boolean
    required: false
    default: false

execution:
  mode: sequential
  steps:
    - step: Create auth-repository.ts interface
      verification: All auth methods defined
    - step: Implement SupabaseAuthRepository
      verification: Supabase client calls
    - step: Create login page
      verification: Matches design tokens
    - step: Create register page
      verification: Tenant auto-provision on signup
    - step: Setup middleware
      verification: Route protection working
    - step: Implement session persistence
      verification: Cookie-based session

outputs:
  - AuthRepository interface
  - SupabaseAuthRepository
  - Login page
  - Register page
  - Middleware route protection

success_criteria:
  - User can login with email/password
  - Session persists across page refreshes
  - Protected routes redirect to login
  - RTL works for Arabic users
  - Mobile-responsive design

escalation:
  triggers:
    - Auth fails after 3 attempts
    - Session doesn't persist
    - RLS blocks valid user
  fallback: Clear session, redirect to login, show error
```

#### SKILL 4.2: Web Design System Integrator
```yaml
id: skill_4_2
name: Integrate Design Tokens into Next.js
category: web
tier: 2
description: Applies FleetMan design tokens to Next.js CSS

prerequisites:
  - none

parameters:
  - name: theme
    type: string
    required: true
    options: [light_primary]

execution:
  mode: sequential
  steps:
    - step: Verify design-tokens.css exists
      verification: File at src/styles/design-tokens.css
    - step: Update CSS custom properties
      verification: All tokens match FleetMan palette
    - step: Create global styles
      verification: globals.css with base styles
    - step: Create component classes
      verification: Buttons, inputs, cards, badges
    - step: Apply to layout
      verification: Layout uses design tokens

outputs:
  - Updated design-tokens.css
  - globals.css
  - Component style classes
  - Layout integration

success_criteria:
  - All colors match spec exactly
  - Spacing follows 4px grid
  - Border radius consistent at 12px
  - Font families correct (Inter, Noto Sans Arabic)
  - Touch targets meet 48px (web standard)

escalation:
  triggers:
    - Color value wrong
    - Spacing inconsistent
  fallback: Revert to spec values
```

#### SKILL 4.3: Web Vehicle Dashboard
```yaml
id: skill_4_3
name: Build Web Vehicle Dashboard
category: web
tier: 2
description: Creates vehicle management dashboard with data tables

prerequisites:
  - skill_4_1 (Auth - authenticated access)
  - skill_4_2 (Design Tokens - styling)
  - skill_2_1 (Mobile VehicleRepo - same interface)

parameters:
  - name: include_filters
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create vehicle-repository.ts
      verification: Interface matching mobile
    - step: Implement SupabaseVehicleRepository
      verification: Uses same Supabase client
    - step: Create VehicleListPage
      verification: Data table with filters
    - step: Create VehicleDetailPage
      verification: Full vehicle info + actions
    - step: Create AddVehiclePage
      verification: Form with all fields
    - step: Add export functionality
      verification: CSV export button

outputs:
  - VehicleRepository (web)
  - VehicleListPage
  - VehicleDetailPage
  - AddVehiclePage
  - CSV export

success_criteria:
  - Vehicles list with pagination
  - Filters by status, type, group
  - Sort by any column
  - Detail shows all vehicle data
  - Add vehicle form validates all fields
  - CSV export works

escalation:
  triggers:
    - Data doesn't load
    - Filter doesn't work
    - Export fails
  fallback: Show error state with retry button
```

#### SKILL 4.4: Issues Inbox (Park Manager)
```yaml
id: skill_4_4
name: Build Issues Inbox for Park Manager
category: web
tier: 2
description: Creates issue triage dashboard for Park Managers

prerequisites:
  - skill_4_1 (Auth)
  - skill_4_2 (Design Tokens)
  - skill_3_4 (Mobile Issue Creation - source)

parameters:
  - name: include_bulk_actions
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create IssueRepository (web)
      verification: Interface matching mobile
    - step: Create IssuesListPage
      verification: Inbox view with priority sorting
    - step: Create IssueDetailPage
      verification: View photo, description, history
    - step: Implement convert to Work Order
      verification: Mandatory formal description
    - step: Add bulk assignment
      verification: Select multiple → assign

outputs:
  - IssueRepository (web)
  - IssuesListPage (inbox)
  - IssueDetailPage
  - Convert to Work Order flow
  - Bulk assignment

success_criteria:
  - Issues appear instantly when created mobile
  - Sorted by priority (critical first)
  - Can view photo evidence
  - Can convert to Work Order with description
  - Bulk assignment works

escalation:
  triggers:
    - Issue doesn't appear
    - Photo not loading
    - Conversion fails
  fallback: Show error + manual retry option
```

#### SKILL 4.5: CEO Dashboard (KPIs)
```yaml
id: skill_4_5
name: Build CEO KPI Dashboard
category: web
tier: 2
description: Creates executive dashboard with financial metrics

prerequisites:
  - skill_4_1 (Auth - CEO role)
  - skill_4_2 (Design Tokens)
  - skill_4_3 (Vehicle data available)
  - skill_4_4 (Work orders with costs)

parameters:
  - name: include_approvals
    type: boolean
    required: false
    default: true

execution:
  mode: sequential
  steps:
    - step: Create KPI calculation service
      verification: TCO, CPK, availability calculations
    - step: Create TDCDashboardPage
      verification: TCO pie chart + breakdown
    - step: Create CPKRankingPage
      verification: Vehicles ranked by cost per km
    - step: Create ApprovalQueuePage
      verification: High-cost repairs awaiting approval
    - step: Add CSV export
      verification: All data exportable

outputs:
  - KPI calculation service
  - TCO dashboard
  - CPK ranking table
  - Approval queue
  - CSV export

success_criteria:
  - TCO shows total cost per vehicle (fuel + maintenance + depreciation)
  - CPK ranking shows worst performers at top
  - Approvals show repairs above threshold
  - Can approve/reject with one click
  - All data exportable to CSV

escalation:
  triggers:
    - Data calculation wrong
    - Chart doesn't render
    - Approval action fails
  fallback: Show raw data table + alert admin
```

---

## PART 3: EXECUTION PROTOCOLS

### 3.1 Standard Skill Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    SKILL EXECUTION FLOW                         │
│                                                                  │
│  1. PRE-FLIGHT CHECK                                            │
│     → Verify prerequisites completed                            │
│     → Check resource availability                              │
│     → Confirm target project (MCP isolation)                   │
│                                                                  │
│  2. EXECUTE SKILL                                               │
│     → Run steps sequentially/parallel as defined               │
│     → Each step verified before next                           │
│                                                                  │
│  3. QUALITY GATE                                                │
│     → Run flutter analyze / npm run lint                       │
│     → Run tests (if defined)                                   │
│     → Verify success criteria                                  │
│                                                                  │
│  4. OUTPUT HANDLING                                             │
│     → Commit with atomic message                               │
│     → Push to feature branch                                   │
│     → Update handoff document                                  │
│                                                                  │
│  5. COMPLETION SIGNAL                                           │
│     → Report to Conductor                                      │
│     → State transfer to next skill                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Error Handling Protocol

| Error Type | Action | Escalation |
|------------|--------|------------|
| **Lint Warning** | Fix immediately before proceeding | None |
| **Test Failure** | Fix test or test data | None (blocker) |
| **Build Failure** | Analyze error, fix, rebuild | None (blocker) |
| **Data Mismatch** | Log error, use fallback | Alert admin |
| **Network Failure** | Retry with exponential backoff | After 3 retries |
| **Auth Failure** | Clear session, re-authenticate | After 3 attempts |
| **RLS Violation** | Rollback changes, alert immediately | IMMEDIATE |

### 3.3 Context Transfer Between Agents

When one skill completes and another begins:

```
SKILL COMPLETION OUTPUT:
{
  "skill_id": "skill_3_2",
  "status": "completed",
  "artifacts": [
    "mobile/lib/features/field/audit_form_screen.dart",
    "mobile/lib/core/services/audit_service.dart"
  ],
  "state_changes": {
    "vehicles_can_have_audit": true,
    "issues_creatable_from_audit": true
  },
  "warnings": [],
  "next_recommended_skills": ["skill_3_3", "skill_3_4"]
}

CONDUCTOR INJECTS INTO NEXT SKILL:
{
  "context": {
    "previous_skills": ["skill_0_1", "skill_1_1", "skill_1_2", "skill_3_2"],
    "project_state": {
      "database_deployed": true,
      "auth_working": true,
      "design_tokens_applied": true,
      "audit_form_built": true
    },
    "available_artifacts": ["..."],
    "recommended_next": ["skill_3_3", "skill_3_4"]
  }
}
```

---

## PART 4: PHASE ROADMAP WITH SKILL MAPPING

### Phase 0: Foundation (Completed ✅)
**Timeline:** Week 0-1 | **Status:** 100% Complete

| Skill | Task | Status |
|-------|------|--------|
| skill_0_1 | Database migrations | ✅ Deployed |
| skill_0_2 | RLS policies | ✅ Verified |

**Output:** 16 tables, proper tenant isolation, migrations applied

### Phase 1: Mobile Core (Completed ✅)
**Timeline:** Week 1-2 | **Status:** 95% Complete

| Skill | Task | Status |
|-------|------|--------|
| skill_1_1 | Auth flow | ✅ Complete |
| skill_1_2 | Design tokens | ✅ Complete |
| skill_1_3 | Localization | ✅ Complete |
| skill_1_5 | CI/CD | ✅ Complete |
| skill_1_4 | Home screens | ⚠️ Stubs only |

**Output:** Flutter app scaffold, auth, design system, bilingual support

### Phase 2: Web Foundation (Completed ✅)
**Timeline:** Week 2-3 | **Status:** 70% Complete

| Skill | Task | Status |
|-------|------|--------|
| skill_4_1 | Web auth | ✅ Complete |
| skill_4_2 | Design tokens | ✅ Complete |
| skill_4_3 | Vehicle dashboard | ⚠️ Partial - wiring issues |
| skill_0_1 | Database aligned | ✅ Complete |

**Output:** Next.js scaffold, auth, vehicle list/detail

### Phase 3: Field Manager Loop (NEXT FOCUS)
**Timeline:** Week 3-4 | **Status:** 0% - TO BUILD

| Skill | Task | Priority |
|-------|------|----------|
| skill_2_1 | Wire VehicleCardScreen | P0 - Critical |
| skill_3_1 | QR Scanner | P1 - Core workflow |
| skill_3_2 | Audit Form (eDVIR) | P1 - Core workflow |
| skill_3_3 | Offline Sync | P1 - Algeria requirement |
| skill_3_4 | Issue Creation | P2 - From failed audit |

**Key Deliverables:**
- Park Manager can scan vehicle QR → run eDVIR checklist
- Photo evidence captured for all inspections
- Failed audits auto-create Issues
- Works offline in Algerian dead zones
- 56px touch targets, light theme primary

**Verification:**
- [ ] `flutter analyze` passes with zero warnings
- [ ] QR scan identifies vehicle within 2 seconds
- [ ] Audit form has all 5 checklist items
- [ ] Photo captures with camera-first UX
- [ ] Offline queue holds 10+ operations
- [ ] Sync triggers when online
- [ ] 56px touch targets on all buttons

### Phase 4: Maintenance Loop
**Timeline:** Week 5-6 | **Status:** 0% - TO BUILD

| Skill | Task | Priority |
|-------|------|----------|
| skill_4_4 | Issues Inbox (web) | P1 - Core workflow |
| skill_3_5 | Mechanic Work Order Queue | P1 - Core workflow |
| skill_3_5 | Parts consumption logging | P2 - |
| skill_3_5 | Receipt capture | P2 - |

**Key Deliverables:**
- Park Manager sees Issues on web dashboard
- Issues converted to formal Work Orders
- Mechanic receives work order notifications
- Parts logged (warehouse or external)
- Receipt photos captured

**Verification:**
- [ ] Issues appear instantly from mobile
- [ ] Work Order creation requires formal description
- [ ] Mechanic sees "My Tasks" queue
- [ ] Parts can be logged from warehouse
- [ ] External purchases capture receipt

### Phase 5: eDVIR + Asset Control
**Timeline:** Week 7-8 | **Status:** 0% - TO BUILD

| Skill | Task | Priority |
|-------|------|----------|
| skill_3_2 | Daily eDVIR checklist | P1 - |
| skill_4_3 | Vehicle status states | P1 - |
| skill_4_4 | Driver assignment calendar | P2 - |
| skill_4_4 | Ordre de Mission PDF | P2 - |

**Key Deliverables:**
- Daily inspection flow complete
- Vehicle status machine functional
- Driver assignments on calendar
- Ordre de Mission auto-generated

### Phase 6: CEO Dashboard
**Timeline:** Week 9-10 | **Status:** 0% - TO BUILD

| Skill | Task | Priority |
|-------|------|----------|
| skill_4_5 | TCO calculation | P1 - Core value |
| skill_4_5 | CPK ranking | P1 - Core value |
| skill_4_5 | Approval queue | P1 - |
| skill_4_5 | CSV export | P2 - |

**Key Deliverables:**
- Total Cost of Ownership per vehicle
- Cost per KM ranking (worst at top)
- High-cost repair approval workflow
- Data export for accounting

### Phase 7: Onboarding + Polish
**Timeline:** Week 11-12 | **Status:** 0% - TO BUILD

| Task | Priority |
|------|----------|
| Smart Guide onboarding wizard | P1 - |
| Marketing landing page | P1 - |
| AdminOps tenant management | P2 - |

---

## PART 5: AGENT AUTONOMY GUIDELINES

### 5.1 When Agent Can Execute Without Approval

| Context | Permission | Boundary |
|---------|-------------|-----------|
| **Single file creation/edit** | ✅ Execute | Under 200 lines |
| **Design token application** | ✅ Execute | Colors/spacing only |
| **Code lint fix** | ✅ Execute | Under 5 warnings |
| **Test data adjustment** | ✅ Execute | Fixtures only |
| **Documentation update** | ✅ Execute | Markdown files |

### 5.2 When Agent Must Pause and Request Approval

| Context | Action | Escalation |
|---------|--------|------------|
| **Architecture change** | Pause + describe plan | Wait for approval |
| **New dependency addition** | Pause + list alternatives | Wait for approval |
| **Schema migration** | Pause + show SQL | Wait for approval |
| **Multi-file structural change** | Pause + outline impact | Wait for approval |
| **RLS policy modification** | IMMEDIATE STOP | Alert immediately |

### 5.3 Skill Execution Autonomy

**Within a skill, agent can:**
- Execute all defined steps without approval
- Make decisions within parameters
- Fix lint warnings immediately
- Update related documentation
- Commit and push to feature branch

**Agent cannot:**
- Skip prerequisite skills
- Modify skill parameters without approval
- Execute skills out of sequence
- Merge to main without verification
- Delete existing functionality

---

## PART 6: QUALITY ASSURANCE

### 6.1 Pre-Deployment Checklist

```
PRE-DEPLOYMENT QUALITY GATES:
[ ] flutter analyze - zero warnings
[ ] flutter test - all passing
[ ] npm run lint (web) - zero warnings
[ ] npm run build (web) - succeeds
[ ] RLS validation - tenant isolation confirmed
[ ] Design tokens - verified against spec
[ ] Touch targets - 56px minimum (mobile)
[ ] Localization - all strings translated
[ ] Offline - queue/sync tested
[ ] Dark mode - works for mechanic (optional)
```

### 6.2 Commit Convention

```
ATOMIC COMMIT FORMAT:
feat(scope): description

Examples:
feat(phase-3): implement QR scanner screen
fix(vehicle): resolve enum mismatch with DB
docs(handoff): update skill_3_2 completion
refactor(auth): extract to repository pattern

SCOPE IDENTIFIERS:
phase-0, phase-1, phase-2, phase-3, etc.
mobile, web, database
auth, vehicles, field, dashboard
```

---

## PART 7: CONDUCTOR COMMAND REFERENCE

### 7.1 Starting a New Agent Session

```
CONDUCTOR START COMMAND:
"You are working on FleetMan, an Algerian B2B Fleet Management SaaS.

READ THESE FIRST:
1. /docs/conductor_framework.md (this file) - Primary context
2. /DESIGN.md - Design tokens
3. /docs/NEXT_AGENT_HANDOFF.md - Detailed context
4. /docs/global_product_requirements.md - PRD

CURRENT PHASE: [Phase 3: Field Manager Loop]

YOUR SKILLS:
- skill_2_1 (Vehicle Repository)
- skill_3_1 (QR Scanner)
- skill_3_2 (Audit Form)
- skill_3_3 (Offline Sync)

EXECUTION PROTOCOL:
1. Read skill definitions in this document
2. Execute steps sequentially
3. Verify each step before proceeding
4. Run flutter analyze after each file
5. Commit after skill completion

CRITICAL CONSTRAINTS:
- Light theme PRIMARY (outdoor field use)
- 56px touch targets (gloved hands)
- Cloud-agnostic (repository pattern)
- MCP project ID: mzuippdkhsqifxacssex"

START EXECUTION.
```

### 7.2 Resuming After Interruption

```
CONDUCTOR RESUME COMMAND:
"Resume execution from where we left off.

LAST COMPLETED SKILL: skill_3_1 (QR Scanner)
STATE:
- Vehicle lookup working
- Camera permission handled
- Navigation to AuditForm working

REMAINING SKILLS:
1. skill_3_2 (Audit Form) - NEXT
2. skill_3_3 (Offline Sync)
3. skill_3_4 (Issue Creation)

CONTINUE FROM skill_3_2."
```

### 7.3 Emergency Stop

```
CONDUCTOR STOP COMMAND:
"STOP IMMEDIATELY.

REASON: [RLS violation detected / Architecture change required / etc.]

DO NOT:
- Commit any changes
- Push to remote
- Execute any more steps

DO:
- Save current state
- Document what was started
- Wait for conductor response

ESCALATE TO: Human supervisor"
```

---

## APPENDIX A: SKILL DEPENDENCY GRAPH

```
skill_0_1 ─┬─→ skill_1_1 ─┬─→ skill_1_4 ─┬─→ skill_3_1 ─┬─→ skill_3_2 ─┬─→ skill_3_4
           │               │              │              │              │
           └→ skill_4_1 ───┴─→ skill_4_2 ─┴─→ skill_4_3 ─┴─→ skill_4_4 ─┴─→ skill_4_5
                      │              │
skill_0_2 ────────────┴──────────────┘
                      │
skill_1_2 ────────────┴──────────────┐
                      │              │
skill_1_3 ────────────┴──────────────┤
                      │              │
skill_1_5 ────────────┴──────────────┘
```

**Legend:**
- Arrow indicates "prerequisite of"
- skill_0_* = Database layer
- skill_1_* = Mobile foundation
- skill_2_* = Mobile data
- skill_3_* = Mobile features
- skill_4_* = Web features

---

## APPENDIX B: MCP SECURITY RULES

**CRITICAL: Read before ANY Supabase operation**

```
FILE: .geminirules

Supabase Project ID: mzuippdkhsqifxacssex
Vercel Project ID: prj_YEBtNxsQHaXCUoOAdJP0YTJwNXzf

RULE: NEVER execute MCP without project ID verification
RULE: NEVER list projects other than specified
RULE: Report any MCP anomaly immediately
```

---

## APPENDIX C: DESIGN TOKEN REFERENCE

| Token | Value | Usage |
|-------|-------|-------|
| primary-blue | #1A3A5C | Brand, sidebar, primary buttons |
| accent-orange | #F28C28 | CTAs, urgent actions |
| error-red | #D32F2F | Failed audits, overdue |
| success-green | #2E7D32 | Passed, approved |
| warning-amber | #F57F17 | Due soon |
| background-light | #F5F7FA | Page background (PRIMARY) |
| surface-white | #FFFFFF | Cards, modals |
| text-primary | #212121 | Headings, body |
| text-secondary | #5A6172 | Labels, hints |
| minimum-touch-target | 56px | Mobile buttons |
| default-border-radius | 12px | All components |

---

*End of Conductor Framework*
*Version 1.0 - April 16, 2026*
*This document enables autonomous AI agent execution within defined skill boundaries*
*Execute within protocol, escalate when needed*