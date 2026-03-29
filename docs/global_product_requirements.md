# FleetMan: Global Product Requirements Document (PRD)

This document serves as the single source of truth for the entire FleetMan SaaS platform. It consolidates all features, workflows, UI/UX guidelines, security protocols, and architecture decisions tailored for the Algerian B2B market.

---

## 1. Product Vision & Target Market
FleetMan is a production-ready, multi-tenant B2B SaaS designed to modernize fleet management in Algeria. It replaces fragmented WhatsApp messages, paper logbooks, and reactive maintenance with a proactive, digital, and Law 18-07 compliant ecosystem.

- **Primary Goal:** Reduce Total Cost of Ownership (TCO) by minimizing downtime and digitizing maintenance flows.
- **Differentiator:** Uniquely adapted to Algerian realities (CCP payments, AR-DZ/FR-DZ bilingual field workers, poor field internet, local server compliance).

---

## 2. Roles & Permissions (RBAC)
The platform utilizes strict Role-Based Access Control (RBAC) to ensure users only see what their job requires.

| Role | Platform | Description |
|------|----------|-------------|
| **Super Admin** | Web (AdminOps) | FleetMan internal staff. Manages tenant approvals, limits, invoicing, and platform health. |
| **CEO / Owner** | Web | The client's boss. High-level dashboard, financial KPIs, cost approvals, vendor spend. |
| **Park Manager** | Web & Mobile | The dispatcher/coordinator. Manages vehicles, assigns drivers, converts issues to work orders. |
| **Mechanic** | Mobile | Field repair staff. Receives work orders, logs parts used, captures receipt photos, closes tickets. |
| **Driver** | Mobile | Assigned to specific vehicles. Submits daily eDVIR forms. |
| **Gatekeeper** | Tablet / Mobile | Security at the yard. Logs entries/exits and general anomalies (Kiosk Mode). |

> [!NOTE]
> Roles can be combined. A small company might have one person acting as both Park Manager and Mechanic. The UI adapts dynamically based on the user's role array.

---

## 3. Global UX Workflow & Core Modules

To support clients of different sizes and capabilities, the platform is designed with **Togglable Modules**. A basic client might only want maintenance tracking, while an advanced client wants the full Kiosk and geofencing experience.

### 3.1 The "Happy Path" Maintenance Loop
The UX is designed to be frictionless, moving from field reporting to management resolution in clicks.
1. **Reporting (Mobile):** Driver notices a defect during their shift. They open the app, tap "Signaler un Problème" (Report Issue), snap a photo, add a 1-sentence description, and submit.
2. **Triage (Web Admin):** The Park Manager receives a notification (bell icon). They open the web dashboard, see the issue in the "Pending" column (Kanban style). They drag it to "In Progress" and assign a Mechanic from a dropdown.
3. **Execution (Mobile):** The Mechanic gets a push notification. They open the app, go to "My Tasks". They fix the issue, log the parts used (e.g., "Plaquettes de frein"), enter the cost (e.g., "4500 DZD"), upload a photo of the receipt, and tap "Complete".
4. **Closing (Web Admin):** The Park Manager sees the ticket turn green ("Awaiting Approval"). They verify the cost and receipt, and click "Approve & Close". The vehicle is back online.

### 3.2 The Gatekeeper "Kiosk Mode" Workflow (Togglable)
For companies with secure yards, the app provides a dedicated Kiosk Mode for the Gatekeeper (Poste Police).
- **Setup:** A tablet is mounted at the gate, locked to the Kiosk route (`/kiosk/gate`).
- **Entry/Exit Flow:**
  1. Vehicle approaches. Guard scans the vehicle's QR sticker or types the first 3 digits of the plate.
  2. Large UI buttons appear: **[ENTRÉE]** and **[SORTIE]**.
  3. Guard taps [SORTIE]. The system instantly checks for a valid "Ordre de Mission" (Mission Order). If valid, screen flashes green and logs the timestamp. If invalid, the screen flashes red and blocks exit.
- **Digital Logbook (Main Courante):** Guard taps the "Journal" tab to log non-fleet visitors (e.g., "Camion Naftal - Livraison, 14:00") or anomalies.
- *Activation:* Toggled ON/OFF per tenant via billing.

### 3.3 Driver eDVIR & Geofencing Workflow (Togglable)
- **Pre-Trip:** Driver logs in, selects vehicle, and runs through a 5-step checklist (Tires, Fluids, Lights, Odometer, Physical Damage).
- **Fraud Prevention:** The app requests GPS coordinates. If the driver is not physically inside the predefined yard geo-fence (e.g., 50m radius of the depot), the app prevents form submission.
- *Activation:* Geofencing can be toggled OFF by the CEO for remote logic companies.

---

## 4. Public Face & Onboarding Workflow

### 4.1 Marketing Landing Page
- **Hero Section:** High-contrast, dark theme showcasing mobile and web dashboards. Call to action: "Essai gratuit 14 jours" (14-day free trial).
- **Value Proposition:** "Réduisez l'immobilisation de vos véhicules de 30%."
- **Trust Elements:** Local compliance badges (Hébergé en Algérie, Loi 18-07), data sovereignty guarantees.

### 4.2 Frictionless Onboarding Wizard
1. **Account Creation:** Clean, split-screen UI. Email, password, and Company Name. (Behind the scenes: Auto-provisions a secure Supabase Tenant ID).
2. **Context Gathering:** Select fleet size (1-15, 16-50, 50+). This routes the user to the correct pricing tier offering.
3. **The 'Aha' Moment:** The user inputs one vehicle plate number. They are instantly dropped into a populated dashboard with a checklist widget: *Add a driver, Log an issue, Complete setup.*

---

## 5. Pricing Strategy & Market Segmentation (Algerian Market)

It is critical to position FleetMan strictly as a **Fleet Management & Maintenance SaaS**, *not* a GPS tracking/telematics hardware solution. While local GPS tracking providers sell hardware boxes (1,500 to 4,000 DZD/veh/month), FleetMan focuses purely on operational software efficiency: preventive maintenance, digital work orders, eDVIRs, and gate logging. Because we require zero hardware installation, we can price aggressively, scale instantly, and achieve high ROI based strictly on workflow optimization.

| Tier | Target Audience | Features Included | Estimated Price (DZD) |
|------|-----------------|-------------------|-----------------------|
| **Starter** | TPE (1 - 15 Vehicles) | Core Maintenance Loop, Web Dashboard, Mobile Driver App (Basic), Max 3 Admin seats. | **~1,200 DZD** / veh / month |
| **Pro** | SMB/PME (16 - 50 Vehicles) | Starter + Total eDVIR, Geo-fencing capabilities, unlimited internal users, CSV Exports. | **~2,000 DZD** / veh / month |
| **Enterprise** | Large Fleets (50+ Vehicles) | Pro + Gatekeeper Kiosk (Main Courante), Ordre de Mission Verification, Dedicated Account Manager. | **Custom Setup Fee** + Volume Discount (e.g., ~1,500 DZD / veh) |

> [!TIP]
> **Market penetration tactic:** In Algeria, SMBs are hesitant to buy software with an automated credit card subscription. We will allow the 14-day trial, then require payment via **CCP/BaridiMob** (manual verification via AdminOps) for Starter/Pro tiers, migrating to fully automated Edahabia/CIB (Chargily) once trust is established.

---

## 6. Security & Multi-Tenancy (Production Readiness)

A B2B SaaS must guarantee data isolation and security.

1. **Strict Tenant Isolation:** 
   - Every database table (`vehicles`, `issues`, etc.) contains a `tenant_id`.
   - **Row Level Security (RLS)** is enabled on Supabase. A JWT token policy enforces that users can only `SELECT/INSERT/UPDATE` rows where `tenant_id` matches their verified company profile.
2. **Authentication Flow:**
   - Standard Email/Password login.
   - Built-in "Forgot Password" / Reset flow.
   - Secure email invites for adding new staff.
3. **Data Liberation:**
   - Every major table in the web dashboard features an "Export to CSV/Excel" button for accounting and reporting transparency.

---

## 6. High-Level Database Schema

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `tenants` | Client companies | id, name, plan, status, trial_ends_at |
| `profiles` | All users | id, tenant_id, auth_id, full_name, role[] |
| `vehicles` | Fleet assets | id, tenant_id, make, license_plate, status |
| `issues` | Reported defects | id, tenant_id, vehicle_id, description, status |
| `work_orders` | Active repairs | id, tenant_id, issue_id, mechanic_id, cost_dzd |
| `edvir_logs` | Driver inspections | id, tenant_id, vehicle_id, driver_id, pass_fail |
| `gate_logs` | Kiosk entries | id, tenant_id, vehicle_id, type (in/out/anomaly) |

---

## 7. Architecture & Deployment Lifecycle

1. **Tech Stack:**
   - Mobile: Flutter (Native APK for Android/Play Store to ensure robust offline storage, OCR, and background GPS).
   - Web: Next.js (AdminOps, Public Pages, Client Web Dashboard).
   - Database/Auth/Storage: Supabase.
2. **CI/CD Pipeline (GitHub Actions):**
   - Automatically lints code, runs tests, and builds the Flutter APK on every push.
   - Automatically builds and deploys the Next.js frontend to Vercel for previewing.
3. **Phase 2 Sovereign Migration (Law 18-07):**
   - All code is written using **Repository Interfaces** (e.g., `VehicleRepository`).
   - When the app is legally required to move to Algerian soil, the configuration is swapped to point to a self-hosted Dockerized Supabase instance on an Algérie Telecom / ICOSNET VPS. Zero application logic needs to change.

---

### End of Document
*This PRD defines the boundary of the "Production-Ready MVP". Any feature not listed here is out of scope for Milestone 1.*
