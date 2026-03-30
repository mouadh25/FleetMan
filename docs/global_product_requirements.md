# FleetMan: Global Product Requirements Document (PRD)

> **Version:** 1.0.1
> **Date:** March 29, 2026
> **Status:** APPROVED & LOCKED - ANTI-CHEAT SYNCED

This document serves as the single source of truth for the entire FleetMan SaaS platform. It consolidates all features, workflows, UI/UX guidelines, security protocols, and architecture decisions tailored for the Algerian B2B market.

---

## 1. Product Vision & Target Market
FleetMan is a production-ready, multi-tenant B2B SaaS designed to modernize fleet management in Algeria. It replaces fragmented WhatsApp messages, paper logbooks, and reactive maintenance with a proactive, digital, and Law 18-07 compliant ecosystem.

- **Primary Goal:** Reduce Total Cost of Ownership (TCO) by minimizing downtime and digitizing maintenance flows.
- **Differentiator:** Uniquely adapted to Algerian realities (Cash, Bank Wire, and CCP payments; AR-DZ/FR-DZ bilingual field workers; poor field internet; local server compliance. Note: CIB/Edahabia online payments are reserved for future dev with partners).
- **Architecture Split:** Strict separation of concerns for MVP1. The Mobile App (Flutter) is heavily optimized for fast Field Execution (data entry, eDVIRs, work orders). The Web Portal (Next.js) serves as the "Command Center" restricted to Management (KPI analysis, approvals, scheduling).

---

## 2. Roles & Permissions (RBAC)
The platform utilizes strict Role-Based Access Control (RBAC). For ease of onboarding, clients can select predefined **Aggregated Personas** that automatically bundle the necessary granular roles.

| Granular Role | Platform | Description | Aggregated Persona (What the Client Selects) |
|---------------|----------|-------------|----------------------------------------------|
| **Super Admin** | Web (AdminOps) | FleetMan internal staff. Manages tenant approvals, limits, invoicing, and platform health. | *FleetMan Internal Only* |
| **CEO / Owner** | Web | High-level dashboard, financial KPIs, cost approvals, vendor spend. | **"CEO / Director"** (CEO only) |
| **Park Manager** | Web & Mobile | The dispatcher/coordinator. Manages vehicles, assigns drivers, triage. | **"Park Manager"** (Manager only) |
| **Field Officer** | Mobile | Field repair staff. Receives work orders, logs parts used, closes tickets. | **"Field Officer / Mechanic"** |
| **Driver** | Mobile | **[OPTIONAL / TOGGLABLE EXCEPTION]** Assigned to specific vehicles. If activated by Office Manager, submits daily eDVIRs. Otherwise, Field Park Manager does it. | **"Driver"** |
| **Gatekeeper** | Tablet / Mobile | Security at the yard. Logs entries/exits and general anomalies (Kiosk Mode). | **"Gatekeeper"** |
| *(All Above)* | Web & Mobile | Combines CEO, Park Manager, and Field Officer rights into a single operational account. | **"One-Man Army"** (Small SMBs) |

> [!NOTE]
> By assigning an aggregated persona like "One-Man Army", the UI dynamically adapts to display the CEO Dashboard, the Manager Triage Boards, and the Field Officer execution tasks all in one seamless interface.

---

## 3. Global UX Workflow & Core Modules

To support clients of different sizes and capabilities, the platform is designed with **Togglable Modules**. Features are activated/deactivated based on the client's subscription tier, and can be manually toggled by the Super Admin in the AdminOps panel.

### 3.1 The "Happy Path" Maintenance Loop
The UX is designed to be frictionless, moving from field reporting to management resolution in clicks.
1. **Reporting (Mobile):** The **Field Park Manager** performs an audit or receives a verbal complaint from a driver. They open the app, tap "Signaler un Problème" (Report Issue), snap a photo (or record a **Voice Note**), add a brief text description, and submit. *(Note: A Driver can only do this directly if the Office Manager has explicitly toggled their Driver App access ON).*
2. **Triage (Web Admin):** The Park Manager receives a notification. They open the web dashboard and see the issue pending. The Park Manager is *obliged* to listen to the voice note/view the photo and translate/expand it into a formal, well-described **Work Order** following best practices before assigning it to a Field Officer.
3. **Execution (Mobile):** The Field Officer (Mechanic) gets a push notification. They open the app, go to "My Tasks". They fix the issue, log the parts used (e.g., "Plaquettes de frein"), enter the cost (e.g., "4500 DZD"), upload a photo of the receipt, and tap "Complete".
4. **Closing (Web Admin):** The Park Manager sees the ticket turn green ("Awaiting Approval"). They verify the cost and receipt, and click "Approve & Close". The vehicle is back online.

### 3.2 The Gatekeeper "Kiosk Mode" Workflow (Togglable)
For companies with secure yards, the app provides a dedicated Kiosk Mode for the Gatekeeper (Poste Police).
- **Setup:** A tablet is mounted at the gate, locked to the Kiosk route (`/kiosk/gate`).
- **Entry/Exit Flow:**
  1. Vehicle approaches. Guard scans the vehicle's QR sticker or types the first 3 digits of the plate.
  2. Large UI buttons appear: **[ENTRÉE]** and **[SORTIE]**.
  3. Guard taps [SORTIE]. The system instantly checks for a valid "Ordre de Mission" (Mission Order). If valid, screen flashes green and logs the timestamp. If invalid, screen flashes red and blocks exit.
- **Digital Logbook (Main Courante):** Guard taps the "Journal" tab to log non-fleet visitors or anomalies.
- *Activation:* Dynamically locked/unlocked via the client's subscription tier in AdminOps.

### 3.3 eDVIR & Fuel Logging Workflow
By default, the **Field Park Manager** assumes the responsibility of inspecting the vehicles before they leave the yard, as it is unrealistic to expect 100% of drivers to use a mobile app. 

- **Default Pre-Trip (Park Manager):** The Park Manager walks the yard, selects the vehicle, and runs through the 5-step checklist (Tires, Fluids, Lights, Odometer, Physical Damage) before handing over the keys.
- **The Driver App Exception (Togglable):** If activated, the driver uses a highly simplified interface to **Log Fuel**. Because fuel prices are standardized in Algeria via subsidies, the driver does *not* enter the price per liter or total liters. They only:
   1. Enter the **Amount Paid (DZD)**
   2. Snap a photo of the **Receipt**
   3. Snap a photo of the **Odometer**
   
   *The system automatically calculates the exact liters based on the vehicle's pre-configured `fuel_type` (Essence/Mazout/Sirghaz).* 
- **The "Triangle of Truth" (Anti-Cheat):** As part of the Driver App exception, Top-Tier Premium clients benefit from a silent, one-time GPS ping captured exactly when the driver submits a fuel log. This, combined with Gatekeeper logs and Mechanic odometers, feeds a **Data Health Score (0-100%)** that flags cheating drivers instantly to the CEO.
- *Activation:* Geofencing for the eDVIR is a Phase 2 Scale feature, configurable in AdminOps.

---

## 4. Public Face & Onboarding Workflow

### 4.1 Marketing Landing Page
- **Hero Section:** Clean, light theme (highly readable for corporate SaaS), showcasing the web dashboard and mobile interface. Call to action: "Essai gratuit 14 jours".
- **Value Proposition:** "Réduisez l'immobilisation de vos véhicules de 30%."
- **Trust Elements:** Local compliance badges (Hébergé en Algérie, Loi 18-07), data sovereignty guarantees.

### 4.2 Frictionless Onboarding & Smart Guide
1. **Account Creation:** Clean, split-screen UI. Email, password, and Company Name. (Behind the scenes: Auto-provisions a secure Supabase Tenant ID).
2. **Context Gathering:** Select fleet size. This defines defaults and directs the user to the correct feature tier.
3. **The 'Smart Guide' Flow:** Instead of abandoning the user in an empty app, a "Smart Guide" interactive tour opens. It strictly guides the user step-by-step through filling out the proper forms: 
   - Add/Invite exactly one Driver.
   - Register exactly one Vehicle.
   - Log a starting odometer reading.
   *Users cannot start using the software wildly until this structured setup is complete, ensuring high data quality from Day 1.*

---

## 5. Pricing Strategy & Market Segmentation (Algerian Market)

It is critical to position FleetMan strictly as a **Fleet Management & Maintenance SaaS**, *not* a GPS tracking/telematics hardware solution. By requiring zero hardware installation, we focus purely on operational workflow optimization. 

Our pricing is strictly B2B structured via **Yearly Contracts**. Payments are usually divided into tranches (Trimestrial or Semestrial), allowing for a **15% discount if paid fully upfront yearly.** All payments are collected locally via **Cash or Bank Wire** (CIB/Edahabia online card payments are reserved for future partner integrations).

| Tier | Target Audience | Features Gated | Base Pricing Concept |
|------|-----------------|----------------|----------------------|
| **Starter** | TPE (< 10 Vehicles) | Core Maintenance Loop, "One-Man Army" role, Basic eDVIR. | Highly accessible entry price (e.g., Flat fee of ~8,000 DZD/month for the fleet) |
| **Pro** | PME (11 - 50 Vehicles) | Starter + Geofencing, Full RBAC (Manager/Field separate), CSV Exports. | Standard pricing (e.g., ~800 to 1,200 DZD / vehicle / month) |
| **Enterprise** | Large Fleets (50+) | Pro + Gatekeeper Kiosk, Kiosk Main Courante, API Access. | Custom Setup Fee + Volume Discount (e.g., ~600 DZD / vehicle / month) |

> [!NOTE]
> B2B clients in Algeria require an invoice and manual bank transfer verification. The Super Admin in the `AdminOps` panel will manually verify bank wire receipts to toggle a client's status from "Trial" to "Active - Pro Tier".

---

## 6. Security & Multi-Tenancy (Production Readiness)

A B2B SaaS must guarantee data isolation and security.

1. **Strict Tenant Isolation:** 
   - Every database table (`vehicles`, `issues`, etc.) contains a `tenant_id`.
   - **Row Level Security (RLS)** is enabled on Supabase. A JWT token policy enforces that users can only `SELECT/INSERT/UPDATE` rows where `tenant_id` matches their verified company profile.
2. **Authentication Flow (Secure & Standardized):**
   - **Cloudflare Turnstile** integration on all Auth pages to stop bots.
   - Standard Email/Password login.
   - **6-Digit OTP** for email verification and password renewals (No magic links; OTP codes are culturally and technically more reliable for SMS/Email in enterprise setups).
3. **Data Liberation:**
   - Every major table in the web dashboard features an "Export to CSV/Excel" button for accounting and reporting transparency.

---

## 6. High-Level Database Schema

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `tenants` | Client companies | id, name, subscription_tier, status |
| `profiles` | All users | id, tenant_id, auth_id, full_name, role[] |
| `vehicles` | Fleet assets | id, tenant_id, plate_number, status, starting_odometer |
| `issues` | Reported defects | id, tenant_id, vehicle_id, description, status, priority |
| `work_orders` | Active repairs | id, tenant_id, issue_id, mechanic_id, status, type, completed_at |
| `edvir_inspections` | Driver inspections | id, tenant_id, vehicle_id, inspector_id, is_pass |
| `inventory_parts` | Warehouse stock | id, tenant_id, name, part_number, stock_quantity |
| `vendors` | External suppliers | id, tenant_id, name, contact_number |
| `work_order_parts` | Repair costs (Junction) | id, work_order_id, inventory_part_id, quantity, unit_cost_dzd, source |
| `fuel_logs` | Fuel efficiency / CPK | id, tenant_id, vehicle_id, odometer_at_fill, liters, cost_dzd |
| `gate_logs` | Kiosk entries / Utilization | id, tenant_id, vehicle_id, type (in/out), odometer |
| `driver_assignments`| Calendar tracking | id, tenant_id, vehicle_id, driver_id, status |
| `ordres_de_mission` | Validated departures | id, tenant_id, vehicle_id, driver_id, pdf_url |
| `maintenance_schedules`| Preventive alerts | id, tenant_id, vehicle_id, interval_km, next_due_date |
| `payments` | Cash/Wire logs | id, tenant_id, amount_dzd, method, verified_by |
| `leads` | Website demos | id, company_name, contact_name, fleet_size |
| `vendor_ratings` | QoS & Pricing ranking | id, tenant_id, vendor_id, quality_score, pricing_score |

---

## 7. Architecture & Deployment Lifecycle

1. **Tech Stack:**
   - Mobile: Flutter (Native APK for Android/Play Store to ensure robust offline storage, OCR, and background GPS).
   - Web: Next.js (AdminOps, Public Pages, Client Web Dashboard).
   - Database/Auth/Storage: Supabase.
2. **Strict Development Standards:**
   - **Atomic Commits:** All git commits must be logically fractioned, isolated, and dependency-related (following Conventional Commits).
   - **Linting & Debuggability:** Continuous ESLint/Prettier on Next.js and `flutter analyze` ensuring zero warnings before deployments. High-level debuggability with proper robust logging.
   - **Documentation:** Proper in-code and system-level documentation maintained side-by-side with feature code.
3. **CI/CD Pipeline (GitHub Actions):**
   - Automatically lints code, runs tests, and builds the Flutter APK on every push.
   - Automatically builds and deploys the Next.js frontend to Vercel for previewing.
4. **Phase 2 Sovereign Migration (Law 18-07):**
   - All code is written using **Repository Interfaces** (e.g., `VehicleRepository`).
   - When the app is legally required to move to Algerian soil, the configuration is swapped to point to a self-hosted Dockerized Supabase instance on an Algérie Telecom / ICOSNET VPS. Zero application logic needs to change.

---

### End of Document
*This PRD defines the boundary of the "Production-Ready MVP". Any feature not listed here is out of scope for Milestone 1.*
