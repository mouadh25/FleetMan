# Design System & AdminOps Panel Research

## Part 1: Fleetio-Inspired Design System for FleetMan

### Visual Analysis from Fleetio Screenshots

From the 16 Fleetio screenshots analyzed, here is the extracted design language:

#### Color System

| Role | Fleetio Original | FleetMan Adaptation | Rationale |
|------|-----------------|---------------------|-----------|
| **Brand / Primary** | Emerald Green `#2E7D32` | Same or slightly deeper `#1B5E20` | Fleetio's green = trust, safety, operational readiness. Keep it. |
| **Sidebar Active** | Light Green tint `#E8F5E9` | Same | Active nav item background in Fleetio's sidebar |
| **Sidebar BG (Default)** | White `#FFFFFF` | White (Light) / `#1E1E1E` (Dark) | Fleetio offers Green, Light, and Dark Gray sidebar themes |
| **Top Bar** | White `#FFFFFF` | Same | Clean, minimal topbar with search and quick-add |
| **Accent / CTA** | Green `#43A047` | Same | "Add Vehicle", "Add Service Entry" buttons |
| **Status: Active** | Green dot `#4CAF50` | Same | Vehicle status badges |
| **Status: Sold/Inactive** | Gray dot `#9E9E9E` | Adapt to `Hors Service` | |
| **Status: Overdue** | Red text `#D32F2F` | Same | Overdue service reminders |
| **Status: Due Soon** | Orange/Amber `#F57F17` | Same | Upcoming maintenance warnings |
| **Status: Scheduled** | Green dot `#4CAF50` | Same | Scheduled work orders |
| **Data Table BG** | White `#FFFFFF` | Same | Clean, scannable data tables |
| **Table Row Hover** | `#F5F5F5` | Same | Subtle gray hover |
| **Table Header** | `#FAFAFA` with bottom border | Same | Light gray header row |
| **Background** | `#F5F7FA` | Same | Page background behind cards |
| **Card/Widget** | White with `1px #E0E0E0` border | Same | Dashboard widgets |
| **Text Primary** | `#212121` | Same | High-contrast body text |
| **Text Secondary** | `#757575` | Same | Labels, hints, captions |
| **Link Text** | Green `#2E7D32` | Same | Clickable vehicle names, navigation |

#### Typography

| Use | Fleetio | FleetMan |
|-----|---------|----------|
| **Latin Font** | Inter / System Default | **Inter** (Google Fonts) |
| **Arabic Font** | N/A | **Noto Sans Arabic** |
| **Page Title** | 24px semibold | Same |
| **Section Header** | 18px medium | Same |
| **Table Header** | 13px medium, uppercase | Same |
| **Body Text** | 14px regular | Same |
| **Caption/Label** | 12px regular, gray | Same |

#### Layout Patterns (from Screenshots)

| Pattern | Fleetio Implementation | FleetMan Adaptation |
|---------|----------------------|---------------------|
| **Sidebar** | Collapsible, icon + label, grouped by module | Same structure, add AR-DZ RTL flip |
| **Global Search** | Top center, "Search Fleetio" | "بحث / Rechercher" bilingual placeholder |
| **Quick Add** | `+` button top right | Same, contextual per role |
| **Data Tables** | Sortable columns, status badges, inline actions (edit/delete icons) | Same, with larger touch targets for mobile |
| **Dashboard** | Widget grid, draggable, "+ Add Widgets" button | Same |
| **Filters** | Dropdown chips above table (Vehicle Type, Status, Group...) | Same, adapt to Algerian categories |
| **Onboarding** | Left form + right illustration, progress bar at top | Same pattern for our wizard |
| **Detail View** | Card-based, tabs (All, Assigned, Unassigned, Archived) | Same |

#### Component Library Checklist

From the screenshots, these core components are needed:

- [ ] `SidebarNav` — Collapsible, icon+label, section groups, RTL-ready
- [ ] `TopBar` — Logo, global search, quick-add (+), notifications bell, user avatar
- [ ] `DataTable` — Sortable, filterable, paginated, status badges, inline actions
- [ ] `StatusBadge` — Green dot (Active), Gray dot (Inactive), Red (Overdue), Orange (Due Soon)
- [ ] `DashboardWidget` — Card with title, KPI number, trend line, "..." menu
- [ ] `FilterChips` — Dropdowns above tables for filtering
- [ ] `FormInput` — Text, select, date, phone (with DZ country code), file upload
- [ ] `StepWizard` — Progress bar at top, left form / right illustration
- [ ] `Modal` — Centered overlay for confirmations, detail previews
- [ ] `EmptyState` — Illustration + call-to-action when no data exists

---

## Part 2: AdminOps Panel (Super Admin / Platform Operations)

### Why You Need This

FleetMan is a **multi-tenant SaaS**. Each client (transport company) is a tenant. But who manages the tenants themselves? Who approves signups? Who handles billing? That's the **AdminOps Panel** — your internal back-office.

> [!IMPORTANT]
> The AdminOps Panel is **NOT visible to clients**. It is a separate, internal-only web interface accessible only by FleetMan team members (you + your operations staff).

### Architecture: Separate App or Same App?

| Approach | Pros | Cons |
|----------|------|------|
| **Same Next.js app, `/admin` route** | Simpler deployment, shared components | Security risk if route protection fails |
| **Separate Next.js app** | Complete isolation, independent deploy | Double maintenance, no shared code |
| **Same app, `super_admin` role** | ✅ One codebase, RBAC controls access, simple | Requires strict RLS + middleware |

**Recommendation for FleetMan:** Use the **same Next.js app with a `super_admin` role** gate. The `super_admin` role is checked in middleware — if the user doesn't have it, the `/admin/*` routes return 403. This keeps things simple for an MVP while being secure enough.

### AdminOps Features (MVP)

#### Tier 1: Must Have for Launch

| Feature | Description |
|---------|-------------|
| **Tenant Dashboard** | List all companies: name, plan, status (pending/active/suspended/expired), signup date, vehicle count |
| **Approval Gate** | New signups land in "Pending" state. Super admin reviews and clicks "Approve" → triggers welcome email + activates account |
| **Manual Activation** | Super admin can manually upgrade/downgrade a tenant's plan |
| **Trial Monitor** | Shows trial countdown per tenant (14 days). Auto-flags tenants at Day 12 for follow-up |
| **Suspend / Deactivate** | One-click to suspend a non-paying tenant (blocks login, preserves data) |
| **Impersonation** | "Login As" button to see exactly what the client sees (for debugging/support) |

#### Tier 2: Post-Launch

| Feature | Description |
|---------|-------------|
| **Revenue Dashboard** | MRR, ARR, churn rate, ARPU |
| **Payment History** | Log of all payments received (manual or via gateway) |
| **Usage Analytics** | Vehicles per tenant, active users, storage consumed |
| **Email Templates** | Manage welcome, trial expiry, payment reminder emails |
| **Feature Flags** | Toggle features per tenant (e.g., enable GPS module for Premium only) |

### Database Changes Required

A new `tenants` table is needed (separate from `profiles`):

```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name TEXT NOT NULL,
  plan TEXT DEFAULT 'trial', -- 'trial', 'starter', 'pro', 'enterprise'
  status TEXT DEFAULT 'pending', -- 'pending', 'active', 'suspended', 'expired'
  trial_ends_at TIMESTAMPTZ,
  activated_at TIMESTAMPTZ,
  suspended_at TIMESTAMPTZ,
  max_vehicles INTEGER DEFAULT 10,
  max_users INTEGER DEFAULT 5,
  billing_email TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Link profiles to tenants
ALTER TABLE profiles ADD COLUMN tenant_id UUID REFERENCES tenants(id);
```

---

## Part 3: Payment Strategy for Algerian Market

### The Reality

> [!WARNING]
> **Stripe, Paddle, and Chargebee do NOT work in Algeria.** You cannot use international subscription billing platforms.

### Available Payment Methods (Ranked by Feasibility)

| Method | How It Works | Feasibility for FleetMan |
|--------|-------------|--------------------------|
| **1. CCP/BaridiMob Transfer** | Client sends payment to your CCP account. You manually verify. | ✅ **Best for MVP.** Zero integration cost. 90% of Algerians have CCP. |
| **2. Chargily (Local Middleware)** | Algerian fintech wrapping SATIM. Accepts CIB + Edahabia cards online. | ✅ **Best for automation.** Simple API. ~2% fees. |
| **3. Direct SATIM/CIB** | Direct bank integration. Accepts CIB cards. | ⚠️ Complex, expensive setup. Not for MVP. |
| **4. Manual Invoice + Virement** | Send PDF invoice, client does bank virement. | ✅ For enterprise clients only. |

### Recommended Approach: Hybrid Model

```
┌──────────────── Payment Flow ────────────────┐
│                                               │
│  Client signs up → 14-day free trial          │
│                    │                          │
│                    ▼                          │
│  Trial expires → SuperAdmin contact via call  │
│                    │                          │
│                    ├── Option A: CCP/BaridiMob│
│                    │   Client sends DZD       │
│                    │   SuperAdmin verifies     │
│                    │   Clicks "Activate"       │
│                    │                          │
│                    ├── Option B: Chargily      │
│                    │   Client pays via CIB     │
│                    │   Webhook auto-activates  │
│                    │                          │
│                    └── Option C: Invoice       │
│                        For enterprise only     │
│                                               │
└───────────────────────────────────────────────┘
```

**Why this is the best approach for Algeria:**
1. **CCP/BaridiMob is king** — Every Algerian has a CCP account. They are comfortable sending money via BaridiMob. Zero friction.
2. **Phone call closes deals** — Algerian B2B sales are relationship-driven. The super admin calls the client at Day 12, discusses needs, and sends CCP payment instructions.
3. **Chargily for scale** — Once you have 50+ clients, manual verification becomes a bottleneck. Integrate Chargily to automate CIB/Edahabia payments.
4. **No recurring auto-billing at MVP** — Algerian clients are not accustomed to automatic subscription charges. Start with manual renewal and migrate to auto-billing when trust is established.

### Tax Compliance
- 19% VAT (TVA) applies to all digital services in Algeria
- Each payment must generate a `facture` (invoice) with:
  - Company NIF (Numéro d'Identification Fiscale)
  - Article number
  - TVA amount clearly separated
  - Sequential invoice numbering

---

## Part 4: Impact on GSD Phase Roadmap

### What Changes

| Change | Where in Roadmap |
|--------|-----------------|
| Design System tokens moved to **Phase 1** research task (not hardcoded upfront) | Phase 1 |
| `tenants` table added to **Phase 0** | Phase 0 (new Task 0.8) |
| AdminOps Panel added as **new Phase 6.5** (between CEO Dashboard and Polish) | New Phase |
| Chargily payment integration deferred to **MVP2 Phase 8** | Phase 8 |
| CCP/BaridiMob manual verification built into AdminOps MVP | Phase 6.5 |

### Recommended Phase Insert

**Phase 6.5: AdminOps Panel (Days 24-26)** — 3 days

| Task | Atomic Action | Output |
|------|---------------|--------|
| 6.5.1 | Create `/admin` route group with `super_admin` middleware guard | `admin/layout.tsx` |
| 6.5.2 | Build Tenant Dashboard (all companies, status filters, search) | `admin/tenants/page.tsx` |
| 6.5.3 | Build Tenant Detail view (plan, users, vehicles, trial countdown) | `admin/tenants/[id]/page.tsx` |
| 6.5.4 | Build Approve/Reject/Suspend actions | Admin API routes |
| 6.5.5 | Build Trial Monitor (auto-flag at Day 12, expiry countdown) | Dashboard widget |
| 6.5.6 | Build "Login As" impersonation (super admin sees client's view) | Auth service |
| 6.5.7 | Build Payment Log (manual entry: date, amount DZD, method, receipt) | `admin/payments/page.tsx` |

**Verify:** Create a test company → it appears as "Pending" → Approve → trial starts → Day 12 flag fires → Log a CCP payment → Company shows "Active".
