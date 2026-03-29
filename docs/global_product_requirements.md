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

## 3. Core Modules & Workflows

To support clients of different sizes and capabilities, the platform is designed with **Togglable Modules**. A basic client might only want maintenance tracking, while an advanced client wants the full Kiosk and geofencing experience.

### 3.1 Maintenance & Work Order Loop (Core)
- **Reporting:** Driver/Gatekeeper logs an "Issue" (e.g., broken mirror) with a photo.
- **Triage:** Park Manager reviews the Issue on the web dashboard and converts it into a "Work Order" assigned to a Mechanic.
- **Resolution:** Mechanic opens the Mobile App, views the task, logs spare parts used, inputs the cash cost in DZD, uploads a photo of the receipt/repair, and marks it "Complete".

### 3.2 The Gatekeeper "Kiosk Mode" (Togglable Feature)
For companies with secure yards, the app provides a dedicated Kiosk Mode for the Gatekeeper (Poste Police).
- **Time In / Time Out:** The guard scans a vehicle's QR code on an assigned tablet to log precise entry/exit times.
- **Ordre de Mission Check:** Blocks exit if the vehicle lacks an approved mission order.
- **Digital Logbook (Main Courante):** Replaces the physical security log. The guard can log visitors, supplier trucks, or anomalies (e.g., unauthorized access attempt) directly into the system.
- *Activation:* This module can be toggled ON/OFF by the CEO per tenant.

### 3.3 Driver eDVIR & Geofencing (Togglable Feature)
- **Pre-Trip Inspection:** Driver logs into the app, sees their assigned vehicle, and completes a checklist (Tires, Fluids, Lights, Mirrors, Odometer).
- **Geofenced Integrity:** To prevent drivers from filling out the form from home, the app checks if the phone's GPS is within 50 meters of the company yard. 
- *Activation:* Geofencing can be toggled OFF by the CEO if GPS tracking is deemed too rigid for their specific workflow.

---

## 4. Public Face: Landing Page & Onboarding

### 4.1 Marketing Landing Page
- **Hero Section:** High-contrast, dark theme showcasing mobile and web dashboards. Call to action: "Essai gratuit 14 jours" (14-day free trial).
- **Trust Elements:** Local compliance badges, data sovereignty guarantees, pricing tiers (Starter, Pro, Enterprise).

### 4.2 Frictionless Onboarding Wizard
1. **Account Creation:** Email, secure password, Company Name (generates Tenant ID).
2. **Context Gathering:** Select fleet size (helps FleetMan staff qualify the lead).
3. **The 'Aha' Moment:** The user inputs one vehicle plate number. They are instantly dropped into a populated dashboard with a checklist: *Add a driver, Log an issue, Complete setup.*

---

## 5. Security & Multi-Tenancy (Production Readiness)

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
