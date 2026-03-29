# UX & Workflow Logic Report: The FleetMan Ecosystem

> **Version:** 1.0.0
> **Date:** March 29, 2026
> **Status:** APPROVED & LOCKED FOR MVP1 EXECUTION
> **Architecture Inspiration:** Fleetio Multi-Platform Model
> **Target Market:** Algerian SMB Fleets

A world-class fleet management platform separates the noise based on who is holding the screen. Here is the precise, logical workflow across the ecosystem, connecting the mobile field operators to the web dashboard executives.

---

## 1. Field Park Manager (Mobile App)
**Role:** The Controller & Auditor. Because drivers may attempt to hide damages (like a cracked mirror) to avoid salary deductions, the Field Manager acts as the company's eyes on the ground, holding drivers accountable.

### The Daily Workflow:
1. **Morning Yard Reconciliation (Shift Catch-up):** Because trucks move 24/7 but management does not, the Field Manager starts their shift by reconciling the night. Using the Night Guard's paper logs, the Manager inputs the exact "Time Out" for trucks that departed early and "Time In" for late arrivals. *(Note: This manual entry by the Manager will be strictly secured by **Phase 2 Geofencing** later, but for MVP it is location-agnostic).*
2. **Asset Auditing (Control Checks):** Walks the yard doing independent control checks. Scans a QR code stuck to a physically parked truck.
3. **Pre-Trip Check / Asset Control (eDVIR):** The Field Park Manager is the **default user** performing the daily eDVIR. Before handing keys to a driver, the Manager selects the vehicle in the App, checks the condition (Tires, Lights, Odometer), and submits the 'Pass'. If a defect is found, they submit a 'Fail' and instantly flag it.
4. **Issue Generation:** Submitting a failed audit or hitting "Report Problem" instantly creates an "Open Issue" in the cloud, paired with their photos and Voice Notes.
5. **Live Gate Logging (Time In/Time Out):** Throughout the rest of their shift, the Field Manager manually clicks "Time Out" when a vehicle leaves the park, and "Time In" when it returns.

### UX Feel & Rules:
*   **Camera-First:** The camera is the ultimate source of truth to prove driver negligence.
*   **High Contrast & Thick Buttons:** Designed to be used outside in the glaring Algerian sun.
*   **Offline First:** If they are in a dead zone, the audit saves locally and syncs automatically when 4G returns.

---

## 2. The Driver (OPTIONAL EXCEPTION - Highly Restricted)
**Role:** Operating the vehicle and taking legal accountability. In Algeria, the driver is legally responsible for the vehicle on the road.

**CRITICAL RULE:** *The Driver is NOT the primary user of this app.* Expecting 100% of drivers to install an app is impossible for an MVP. By default, the **Field Park Manager** performs the eDVIR inspection and hands them the keys.

### The Toggleable Exception Strategy:
*   **Activation via Office Manager:** The Office Manager must explicitly go into the admin settings and toggle **"Enable Driver App Access"** for a specific trusted driver.
*   If toggled ON, the user assumes the role of an app-user. If it remains OFF, they exist merely as a text-name on the Office Manager's calendar.

### The Daily Workflow (ONLY if toggled ON):
1. **The Restricted View:** The Driver logs into the app, seeing **only** the vehicle assigned to them via the Office Manager's Calendar.
2. **Time Logging:** The Driver clicks "Time Out" to start their mission. *(Phase 2: secured by GPS).*
3. **Pre-Departure eDVIR:** Before leaving, the app forces them to run the physical checklist (Tires, Lights, Mirrors) instead of the Park Manager doing it for them.
4. **Accountability Transfer:** By clicking "Submit", the driver assumes legal responsibility, giving the Park Manager proof they signed off on the truck's condition before departure.

---

## 3. Field Repair Man / Mechanic (Mobile App - Role Based)
**Role:** Getting trucks back on the road ASAP. *(Note: Because mechanics are frequently outsourced in Algeria, the Field Manager simply uses the "Mechanic View" to oversee and log the outsourced work themselves).*

### The Daily Workflow:
1. **The Notification:** Receives a push notification: *"Work Order #145 Assigned: Fix cracked mirror on Truck 10452-116-16."*
2. **Diagnosis via App:** Opens the work order. Sees the exact photo the Field Park Manager took.
3. **Vehicle Status Update:** The system relies on strict **Vehicle Status** states to accurately separate "Productive Utilization" from downtime:
   - *Available* (In the yard, ready to go)
   - *In Mission* (On assigned trip, generating revenue)
   - *Administrative In-Use* (Out of park for non-mission tasks: e.g., washing, technical inspection, insurance photos)
   - *Out of Service (OOS)* (Legally or mechanically unable to drive)
   - *In Shop* (Currently being wrenched on)
   - *Needs Attention* (Light damage, but drivable)
   This strict terminology feeds the central reporting to calculate precise KPIs for the CEO: **"Median Productive Availability"** and **"Asset Utilization Rate"**.
4. **Parts Consumption:** 
   - **Internal Warehouse:** Selects preventive items (filters, oils, tires) from the "Light Warehouse" stock. *(Vibe-Code Feature: Once onboarding is complete, the system's PM logic generates a **Predictive Parts Forecast**—e.g., advising the Office Manager to order 15 oil filters next month based on median fleet usage).*
   - **Approved Suppliers:** If the part isn't in stock, they select from an "Approved Provider List". The Office Manager can call the provider via phone to verify availability. If it's a new shop, they can dynamically add a new parts supplier.
   - **External Purchases:** If bought locally for cash, they snap a photo of the receipt. **(Vibe-Code Feature:** Use an OCR API to auto-fill the receipt amount. Manual fallback available if illegible).
5. **Resolution:** Taps "Job Complete", snaps a photo of the shiny new mirror, and signs with their finger.

### UX Feel & Rules:
*   **Laser-Focused:** No graphs, no fleet lists. Just a queue of "My Assigned Work Orders".
*   **Proof of Work:** Photo validation prevents fraud and "ghost repairs."

---

## 4. Office Park Manager (Web Portal / Desktop App)
**Role:** The Command Center. This is the heavy UI you saw in the Fleetio screenshots, with the massive left sidebar.

### The Daily Workflow:
1. **Triaging Inbox:** Logs in. The dashboard highlights "Action Needed". Sees the "Cracked Mirror" issue submitted by the Field Manager, including any **Voice Notes** and photos attached by the driver/reporter.
2. **Formal Conversion (Mandatory):** The platform forces the Park Manager to play the audio and write a formal, structured "Work Order" before assigning it. This acts as an administrative translation layer between a stressed driver and the mechanic.
3. **PM Reminders (Preventive Maintenance):** Checks the schedule. The system utilizes **Configurable Predictive Early Alerts**. The user can configure the system to mathematically alert them 7, 14, or 30 days in advance based on either **Median Daily Usage (Distance)** or **Strict Timelines** (e.g., exactly 6 months for insurance renewals). These proactive alerts automatically populate the fleet calendar for active planning.
4. **Driver Assignments & Ordre de Mission (Calendar):** Opens the calendar UI and drops a driver onto an "Available" vehicle. 
   - **Smart Transformation:** This action instantly changes the vehicle status from *Available* to **"Assigned - Ready for Departure"**.
   - **Automated Legal Cover:** The system instantly triggers a reminder and dynamically generates a digital *Ordre de Mission* PDF. This completely removes the burden of tracking paperwork from the Field Manager.
5. **Vehicle State Recap (The Single Source of Truth):** The Web Portal provides a highly accessible dashboard per vehicle via search. It displays **Current Status** (Available/OOS/Needs Attention), Assigned Driver, high-impact metrics (Cost per KM), and uploaded Algerian compliance documents (*Contrôle Technique*, *Autorisation de Circulation*, *Assurance*, etc.).
6. **Vendor & Partner Notation System:** Manages the system's notation database. The Office Manager **classes** external mechanic shops, part vendors, and drivers by their **Quality of Service** and **Pricing/Efficiency** scores (gathered over time). This empowers the Office Manager to identify top performers and negotiate better deals.

### UX Feel & Rules:
*   **Information Dense:** Tables, filters, bulk actions. They need to see 50 trucks at once.
*   **Calendar Views:** Just like the Fleetio `Vehicle Assignments` screenshot, visualizing schedules is key to minimizing downtime.

---

## 5. CEO / Financial Officer (Web Dashboard)
**Role:** Protecting the cash flow. They don't care about cracked mirrors; they care about money bleeding.

### The Daily Workflow:
1. **The Executive Snapshot:** Logs in. The landing page shows the **Total Cost of Ownership (TCO)** pie chart (e.g., 40% Fuel, 30% Maintenance, 30% Depreciation/Lease).
2. **Cost per Kilometer (CPK):** The most important metric. Looks at a ranked list of vehicles by CPK. Sees that Truck #4 is costing 45 DZD/km to run, while the fleet average is 15 DZD/km. (Decision: Sell Truck #4).
3. **Repair Validation (Approval Workflows):** 
   - Routine minor repairs are auto-approved based on **preconfigured client thresholds** (e.g., auto-approve anything under 20,000 DZD).
   - High-cost repairs (e.g., a 150,000 DZD engine rebuild) break the threshold and are flagged. The CEO reviews the mechanic's photos and parts list, then clicks "Approve Financials" or "Reject".
4. **Vendor Spend & Efficiency Review:** Reviews aggregated reporting on the "Top and Bottom Performing" vendors and drivers (data annotated by the Office Manager) to make high-level decisions on supplier contracts.

### UX Feel & Rules:
*   **Visual Storytelling:** Red text for budget overruns, green for savings. 
*   **Frictionless Approvals:** Big "Approve" buttons for high-ticket items.
*   **Exportability:** "Export to CSV" buttons everywhere for their own accounting tools.

---

### Logical Data Funnel Summary
1. **First Log-in / Client Onboarding:** The baseline data is set (Vehicles, Legal documents, Financial Approval Thresholds).
2. **(Mobile) Field Park Manager (THE CORE USER):** Acts as the Auditor and Gatekeeper. They perform the Pre-Trip eDVIRs, verify odometers, and document damages via voice notes/photos.
3. **(Mobile) The Driver Exception:** Only logs in if the Office Manager explicitly activated their app access. Otherwise, they are completely invisible to the software layer.
4. **(Web) Office Manager:** Routes the data (Assigns driver *Ordre de Mission*, triages audio notes into formal Work Orders, schedules maintenance).
5. **(Mobile) Field Officer/Mechanic:** Closes the loop (Fixes vehicles, logs parts out of warehouse, uploads receipts).
6. **(Web) CEO:** Views the aggregated KPIs (TCO, CPK, Median Availability) and approves high-value Work Orders. 
 
This is the exact loop that makes platforms like Fleetio worth billions. Implementing this 6-step loop with Vibe Code is the fastest path to a highly scalable MVP.

---

## 6. The SMB Edge Case: The Solo Fleet Operator ("One-Man Army")
**Role:** In many Algerian SMBs (e.g., fleets of 5-15 trucks), the company owner or a single trusted employee handles everything. They literally act as the Field Manager, Office Manager, Mechanic, AND the Financial CEO.

### How the Logic Supports This:
Instead of forcing the user to juggle 4 different logins, the software features an **"Aggregated Persona" (The One-Man Army Role)**. 
- During onboarding, the client selects the "One-Man Army" pre-set, which auto-assigns an array of roles (`roles: ["field_manager", "office_manager", "mechanic", "ceo"]`).
- When the Solo Operator logs into the **Mobile App**, the UI dynamically renders the QR Scanner and eDVIR tools (Field roles) *plus* the Work Order completion forms (Mechanic role). 
- When they log into the **Web Portal**, the UI renders the Dispatch Calendar (Office role) *plus* the Financial Approvals Dashboard (CEO role). 

**Vibe-Coding Feasibility:** This is extremely fast and bug-free to build. Supabase handles RBAC natively via a single database column, and Flutter simply uses `if/then` conditionals to show or hide UI blocks based on the user's role array. This elegant architecture allows the app to flawlessly scale from a 1-man operation up to a massive 50-person corporate hierarchy without modifying any core backend logic.
