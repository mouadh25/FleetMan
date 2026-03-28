# FleetMan 🚛
**The Algerian Fleet Management MVP**

FleetMan is a modern, maintenance-first, "mobile-first" B2B SaaS platform specifically engineered for the Algerian transport and logistics market. 

Unlike traditional platforms that rely on expensive hardware installations to track live GPS dots on a map, FleetMan focuses on the absolute source of financial leakage: **Preventative Maintenance, Asset Accountability, and Legal Compliance.**

> *"Knowing your truck is physically parked in Oran doesn't matter if the engine is dead because nobody changed the oil. Stop tracking dots. Start protecting assets."*

---

## 🎯 The "Blue Ocean" Strategy
Algerian SMEs are fatigued by expensive GPS subscriptions (15,000 DZD upfront + 1,500 DZD/mo) that offer minimal maintenance utility. FleetMan undercuts this market by operating on a **"Zero Hardware, High Accountability"** model. 

*   **Pricing:** Boldly aggressive "Per Active Vehicle" flat-rate (e.g., 1,000 DZD/mo/vehicle). 
*   **The Hook:** A user-friendly, High-Contrast mobile app that forces drivers to log daily eDVIRs (inspections) and immediately reports damages to the CEO's dashboard.
*   **Compliance Protocol:** Natively integrates Algerian Law 18-07 by utilizing Supabase's open-source architecture for local Algérie Telecom VPS migration.

---

## 🏗️ The 6-Persona UX Architecture
The platform is built on a massive, unified **Role-Based Access Control (RBAC)** ecosystem. There is only ONE connected app. The UI morphs entirely based on who logs in:

1.  📸 **The Field Manager (Mobile):** The Auditor. Walks the yard, verifies truck damages, generates Open Issues with photo evidence, and logs specific Gate Time-In/Time-Outs.
2.  📱 **The Driver (Mobile/Tablet Kiosk):** Conducts mandatory Pre-Departure eDVIR inspections. Secured by strict GPS geofencing to prevent remote "ghost logging."
3.  💻 **The Office Manager (Web Portal):** The Dispatcher. Assigns drivers, generates automated PDF *Ordre de Mission* documents, and tracks *Contrôle Technique* expirations.
4.  🔧 **The Mechanic (Mobile):** Receives Work Orders, checks parts out of the internal "Light Warehouse," or photographs receipts from external vendors.
5.  📈 **The CEO (Web Dashboard):** The Financial Gatekeeper. Approves high-cost repairs, monitors Total Cost of Ownership (TCO), and tracks Cost per Kilometer (CPK).
6.  🛡️ **The Solo Operator (The "One-Man Army"):** An edge case natively handled by Supabase SQL arrays (`roles: ['field_manager', 'ceo']`). The app dynamically combines the UI, allowing an SME owner to do yard audits of a truck and instantly approve its repair cost from the exact same interface.

---

## ⚙️ Tech Stack & AI-Coding Architecture
This repository is engineered specifically for hyper-agile "Vibe Coding" using the **Pure GSD (Get Shit Done)** methodology to eliminate AI context drift.

*   **Frontend Mobile:** Flutter (Dart) - Optimized for high-contrast, offline-first offline usage in Algerian dead zones.
*   **Frontend Web:** Next.js (React) / TailwindCSS - High-density data tables and calendar views for the Office/CEO dashboard.
*   **Backend & Auth:** Supabase (PostgreSQL, Edge Functions)
*   **File Storage (Damage Photos/Receipts):** Supabase Storage using strictly standard **S3-Compatible API** protocols. This ensures that when the app scales and requires strict data sovereignty under Law 18-07, the backend can be migrated to a local Datacenter (e.g., MinIO on an Algérie Telecom VPS) without rewriting a single line of Flutter/Next.js code.

---

### 🚀 Getting Started (Vibe-Coding Rules)
*   **Zero Drift Context:** This repo does NOT use bloated AI chat sessions. 
*   **Execution:** Every feature is built using atomized, burn-and-replace agent sessions based strictly on the Master UX & Schema documents located in the `/docs` directory. 
*   **No Hardware Dependencies:** The codebase is 100% software-reliant.
