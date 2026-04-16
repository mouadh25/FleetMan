# FleetMan Design System

> **Version:** 1.0  
> **Date:** April 16, 2026  
> **Inspired by:** Fleetio (primary), Linear.app, Vercel, Stripe  
> **Target:** Algerian B2B Fleet Management SaaS

---

## 1. Visual Theme & Atmosphere

### ⚠️ CRITICAL: Light Theme is PRIMARY

> [!IMPORTANT]
> **Dark theme is COUNTERPRODUCTIVE for Algerian field conditions.**
> Field workers (Park Managers, Mechanics) use mobile devices OUTDOORS in bright Algerian sun. Dark text on dark backgrounds is nearly invisible in direct sunlight. Light theme with high contrast is ESSENTIAL.
>
> Dark theme is only acceptable for: indoor mechanic shops, office environments, night shifts.

### Philosophy
**Professional, Trustworthy, Field-Ready.** FleetMan is a B2B command center for fleet operators who need information-dense dashboards AND a mobile app that works under Algerian sun glare with gloved hands.

- **Mood:** Professional corporate tool meets rugged industrial utility
- **Density:** High information density on web (tables, KPIs); focused single-task on mobile
- **Energy:** Calm authority - this is software that manages expensive assets worth millions of DZD
- **Primary Theme:** LIGHT for field/mobile use (outdoor readability)
- **Secondary Theme:** DARK for indoor/mechanic use only

### Brand Personality
- **Trustworthy** - Data-driven, precise, compliant with Law 18-07
- **Field-Ready** - High contrast, large touch targets, offline-capable
- **Professional** - Not playful, not flashy; clean efficiency
- **Local** - Algerian market adapted (Arabic RTL, DZD currency, CCP payments)

---

## 2. Color Palette

### Primary Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `primary-blue` | `#1A3A5C` | Brand identity, sidebar, primary buttons, links |
| `accent-orange` | `#F28C28` | CTAs, urgent actions, warnings, attention |
| `background-light` | `#F5F7FA` | Page background (light mode) |
| `background-dark` | `#121212` | Page background (dark mode), mobile nav |
| `surface-white` | `#FFFFFF` | Cards, modals, inputs |
| `surface-dark` | `#1E1E1E` | Dark mode cards |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `error-red` | `#D32F2F` | Failed audits, overdue items, budget overruns |
| `success-green` | `#2E7D32` | Passed inspections, approved items, active status |
| `warning-amber` | `#F57F17` | Due soon (≤30 days), needs attention |
| `info-blue` | `#1976D2` | Informational badges, links |

### Text Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `text-primary` | `#212121` | Headings, primary content |
| `text-secondary` | `#757575` | Labels, hints, captions |
| `text-disabled` | `#BDBDBD` | Disabled states |
| `text-inverse` | `#FFFFFF` | On dark backgrounds |

### Border & Dividers

| Token | Hex | Usage |
|-------|-----|-------|
| `border-default` | `#E0E0E0` | Card borders, dividers |
| `border-focus` | `#1A3A5C` | Focus rings on inputs |

---

## 3. Typography

### Font Families

| Use | Font | Source |
|-----|------|--------|
| **Latin Primary** | Inter | Google Fonts |
| **Latin Headings** | Inter | Google Fonts, weight 600-700 |
| **Arabic** | Noto Sans Arabic | Google Fonts |
| **Monospace** | JetBrains Mono | Code, IDs, plate numbers |

### Type Scale (Field-Optimized for Outdoor Use)

| Element | Size | Weight | Line Height | Notes |
|---------|------|--------|-------------|-------|
| **Page Title** | 24px | 700 (Bold) | 1.2 | |
| **Section Header** | 18px | 600 (SemiBold) | 1.3 | |
| **Card Title** | 16px | 600 (SemiBold) | 1.4 | |
| **Body Text** | **16px** | 400 (Regular) | 1.5 | **LARGER for outdoor readability** |
| **Label** | 14px | 500 (Medium) | 1.4 | |
| **Caption** | **14px** | 400 (Regular) | 1.4 | **LARGER than typical 12px** |
| **Button** | **16px** | 600 (SemiBold) | 1.0 | **LARGER for gloved touch** |
| **Tabular Numbers** | **16px** | 500 (Medium) | 1.0 | |

> [!WARNING]
> **Field Worker Minimum Size:** Never go below 14px for ANY text used by field workers. 16px is preferred for body text in mobile field contexts.

### Arabic Typography Rules
- All Flutter layouts use `EdgeInsetsDirectional` and `AlignmentDirectional`
- Never use `left`/`right` - use `start`/`end`
- Text alignment flips automatically with RTL layout
- Numbers always use `NumberFormat` with `fr_DZ` locale for DZD display

---

## 4. Component Styling

### Buttons

#### Primary Button
```css
background-color: #1A3A5C;
color: #FFFFFF;
min-height: 48px; /* Touch target */
border-radius: 12px;
padding: 12px 24px;
font-weight: 600;
```
**States:**
- Hover: brightness(1.1)
- Active: brightness(0.95)
- Disabled: opacity 0.5, cursor not-allowed
- Loading: spinner icon, text "Chargement..."

#### Secondary Button
```css
background-color: transparent;
color: #1A3A5C;
border: 2px solid #1A3A5C;
min-height: 48px;
border-radius: 12px;
```

#### Danger Button
```css
background-color: #D32F2F;
color: #FFFFFF;
/* Same dimensions as Primary */
```

#### Icon Button
```css
min-width: 48px;
min-height: 48px;
border-radius: 12px;
icon-size: 24px;
```

### Form Inputs

```css
background-color: #FFFFFF;
border: 1px solid #E0E0E0;
border-radius: 12px;
min-height: 48px;
padding: 12px 16px;
font-size: 14px;
```

**States:**
- Focus: border-color: #1A3A5C, box-shadow: 0 0 0 3px rgba(26, 58, 92, 0.1)
- Error: border-color: #D32F2F, helper text in red
- Disabled: background: #F5F5F5, cursor not-allowed

### Cards

```css
background-color: #FFFFFF;
border: 1px solid #E0E0E0;
border-radius: 12px;
padding: 24px;
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
```

### Status Badges

| Status | Style |
|--------|-------|
| **Active/Available** | Green dot (#2E7D32) + green background tint |
| **In Mission/In Use** | Blue dot (#1976D2) + blue background tint |
| **Maintenance/In Shop** | Orange dot (#F28C28) + orange background tint |
| **Out of Service** | Red dot (#D32F2F) + red background tint |
| **Needs Attention** | Amber dot (#F57F17) + amber background tint |

Badge format: `border-radius: 20px; padding: 4px 12px; font-size: 12px; font-weight: 600; text-transform: uppercase;`

### Data Tables

```css
header-background: #FAFAFA;
header-text: #757575, uppercase, 13px, weight 500;
row-hover: #F5F5F5;
row-border: 1px solid #E0E0E0;
cell-padding: 12px 16px;
```

### Navigation

#### Web Sidebar
- Width: 256px (expanded), 64px (collapsed)
- Background: #FFFFFF
- Active item: light blue tint background (#E3F2FD), primary blue text
- Hover: #F5F5F5 background
- Icons: 24px, with 12px gap to label

#### Mobile Bottom Navigation
- Height: 64px (+ safe area)
- Background: #121212 (dark)
- Active icon: accent-orange (#F28C28)
- Inactive icon: #9E9E9E
- Icons: 24px
- Labels: 10px, weight 500

### Modals

```css
overlay: rgba(0, 0, 0, 0.5);
modal-background: #FFFFFF;
modal-border-radius: 16px;
modal-padding: 24px;
modal-max-width: 480px;
```

### Empty States

```
icon-size: 64px
icon-color: #BDBDBD
title: 18px, weight 600, text-primary
description: 14px, text-secondary
CTA button: Primary style
```

---

## 5. Layout Principles

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Tight gaps |
| `space-2` | 8px | Icon-label gaps |
| `space-3` | 12px | Input padding |
| `space-4` | 16px | Card padding, standard gaps |
| `space-5` | 20px | Section gaps |
| `space-6` | 24px | Card margins |
| `space-8` | 32px | Large section gaps |
| `space-10` | 40px | Page section margins |

### Grid System

**Web Dashboard:**
- Max content width: 1280px
- Sidebar: 256px fixed
- Content area: fluid
- Card grid: 12-column, 24px gap

**Mobile:**
- Single column, full width with 16px horizontal padding
- Cards stack vertically

### Whitespace Rules

- Never crowd elements - minimum 16px between sections
- Tables: 12px vertical cell padding minimum
- Forms: 16px between field groups
- Buttons: 12px minimum between adjacent buttons

---

## 6. Depth & Elevation

### Shadow System

| Level | CSS | Usage |
|-------|-----|-------|
| **Subtle** | `0 1px 2px rgba(0, 0, 0, 0.05)` | Cards, inputs |
| **Medium** | `0 4px 6px rgba(0, 0, 0, 0.07)` | Dropdowns, popovers |
| **High** | `0 10px 15px rgba(0, 0, 0, 0.1)` | Modals |

### Border Radius

| Element | Radius |
|---------|--------|
| Buttons | 12px |
| Cards | 12px |
| Inputs | 12px |
| Badges | 20px (pill) |
| Modals | 16px |
| Avatars | 50% (circle) |

---

## 7. Do's and Don'ts

### ✅ DO

1. **LIGHT theme for field/mobile** - Dark is only for indoor mechanic use
2. **56px minimum touch targets** - Algerian field workers use gloves
3. **High contrast for outdoor** - Test in direct sunlight
4. **Use Inter for all Latin text** - Never use system fonts
5. **Use Noto Sans Arabic for Arabic text** - Never use Arabic in Inter
6. **Use status badges** - Traffic light system (green/orange/red)
7. **Show DZD currency with NumberFormat** - "1 500 000 د.ج" not "$2,200"
8. **Use RTL layout for Arabic** - EdgeInsetsDirectional, AlignmentDirectional
9. **Offline indicator** - Show sync status prominently
10. **Large plate number display** - Fleet operators scan from distance
11. **Use design tokens only** - No hardcoded colors
12. **16px minimum font for field workers** - Outdoor readability

### ❌ DON'T

1. **Don't make dark theme default** - Counterproductive in Algerian sun
2. **Don't use 48px touch targets** - Too small for gloved hands
3. **Don't use small fonts** - Minimum 16px for field workers
4. **Don't hardcode colors** - Use design tokens only
5. **Don't skip localization** - All strings must be translated
6. **Don't use left/right for positioning** - Breaks RTL
7. **Don't show prices in EUR/USD** - Always DZD
8. **Don't use proprietary SDKs for storage** - Use S3-compatible API
9. **Don't use placeholder images** - Real vehicle photos only
10. **Don't make CEO dashboard data-light** - They want ALL numbers

---

## 8. Responsive Behavior

### Breakpoints

| Name | Width | Target |
|------|-------|--------|
| `sm` | 640px | Large phones landscape |
| `md` | 768px | Tablets |
| `lg` | 1024px | Laptops |
| `xl` | 1280px | Desktops |
| `2xl` | 1536px | Large monitors |

### Mobile Touch Targets (Field-Optimized)

> [!IMPORTANT]
> **56px is the MINIMUM for FleetMan field use.** Algerian field workers often wear gloves, making 48px insufficient for reliable touch interaction.

| Element | Minimum | FleetMan Standard | Rationale |
|---------|---------|-------------------|-----------|
| **Primary buttons** | 48px | **56px** | Gloved hands, outdoor use |
| **Form inputs** | 48px | **56px** | Gloved hands |
| **Icon buttons** | 48px | **56px** | Gloved hands |
| **List items** | 48px | **56px** | Gloved hands |
| **Secondary buttons** | 48px | **56px** | Gloved hands |

**Rationale:** Field workers (Park Managers, Mechanics) wear gloves and work in bright sunlight. 48px is the Android/iOS minimum accessibility standard but is insufficient for gloved operation. 56px provides reliable touch target with buffer for imprecise aim.

### Collapsing Strategy

| Desktop | Tablet | Mobile |
|---------|--------|--------|
| Full sidebar | Collapsed sidebar (icons only) | Bottom navigation |
| Multi-column dashboard | 2-column | Single column |
| Dense data tables | Horizontally scrollable | Card list view |

---

## 9. "Firrion" Design Language

**Firrion** (فرّيون) = Arabic transliteration of "Version" + "Iron" + Algerian flair

FleetMan's unique visual identity - **Professional Industrial meets Algerian Field-Ready**.

### Design Fusion

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLEETMAN "FIRRION" DESIGN                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ WEB DASHBOARD (Fleetio-inspired)                        │   │
│  │ • Dense data tables with status badges                  │   │
│  │ • Collapsible sidebar with grouped navigation          │   │
│  │ • KPI cards with trend indicators                       │   │
│  │ • Light theme PRIMARY (office environment)             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ MOBILE APP (Field-Optimized)                           │   │
│  │ • LIGHT THEME PRIMARY (Algerian sun readability)       │   │
│  │ • 56px touch targets (gloved hands)                    │   │
│  │ • 16px minimum font size (outdoor visibility)          │   │
│  │ • High contrast for outdoor use                        │   │
│  │ • Dark theme ONLY for indoor mechanic use              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ FORMS & BUTTONS (Stripe-inspired)                      │   │
│  │ • Subtle gradient on primary CTAs                       │   │
│  │ • 12px border radius, spacious padding                  │   │
│  │ • Clear error states with red accent                    │   │
│  │ • Loading states with spinners                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ TYPOGRAPHY (Vercel-inspired)                           │   │
│  │ • Inter for Latin, Noto Sans Arabic for Arabic         │   │
│  │ • JetBrains Mono for IDs, plate numbers                │   │
│  │ • Bold titles (700), medium labels (500)               │   │
│  │ • Tabular numbers for financial data                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 10. Agent Prompt Guide & Conductor Framework

> [!IMPORTANT]
> For AI agent orchestration and autonomous execution workflows, see the complete **Conductor Framework** document at `/docs/conductor_framework.md`. This document defines Skills 2.0 architecture with 15+ skill definitions, execution protocols, and quality gates.

When building new UI, use this prompt template:

```
Build a [component name] for FleetMan fleet management SaaS.

Design requirements:
- Primary color: #1A3A5C (Deep Blue)
- Accent: #F28C28 (Safety Orange)
- Font: Inter (Latin), Noto Sans Arabic (Arabic)
- Touch targets: 56px MINIMUM (field-optimized)
- Border radius: 12px
- Use design tokens from DESIGN.md
- Light theme PRIMARY (outdoor field use)

Context:
- Target users: Algerian fleet operators
- Mobile use: Field inspections, outdoor use (LIGHT THEME)
- Web use: Office dashboards, data tables
- RTL support: Required for Arabic (AR-DZ)
- Currency: DZD (Algerian Dinar)
- Gloved hands: 56px touch targets required

Examples of good patterns:
- Fleetio dashboard: Dense data tables with status badges
- Linear.app: Clean sidebar navigation (mobile mechanic only)
- Vercel: Minimal, precise spacing

Anti-patterns to avoid:
- Dark theme for field/mobile (visibility issue in sunlight)
- Small fonts (<16px for field workers)
- Touch targets below 56px
- Low contrast colors for outdoor use
```

---

## 10. Implementation References

### Flutter Theme File
`mobile/lib/core/theme/app_theme.dart`

### Web CSS Tokens
`web/src/styles/design-tokens.css`

### Status Badge Implementation
```dart
// Flutter example
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  decoration: BoxDecoration(
    color: AppTheme.successGreen.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    'ACTIVE',
    style: TextStyle(
      color: AppTheme.successGreen,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
  ),
)
```

### Web Status Badge
```css
.status-badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge--active {
  background-color: rgba(46, 125, 50, 0.1);
  color: #2E7D32;
}

.status-badge--error {
  background-color: rgba(211, 47, 47, 0.1);
  color: #D32F2F;
}
```

---

*End of FleetMan Design System*
