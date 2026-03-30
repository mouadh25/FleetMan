# GSD HANDOFF: FleetMan Phase 2 — Web Scaffolding & Vehicle Onboarding

You are executing **Phase 2 (Tasks 2.1–2.12)** of FleetMan, an Algerian Fleet Management SaaS. This is a **GSD (Get Shit Done) burn session** — no planning, no research, just flawless execution.

### Project Identity & Context
*   **Repo:** `d:\Dev\AntiGravity\FleetMan` → GitHub `mouadh25/FleetMan`
*   **Supabase Project ID:** `mzuippdkhsqifxacssex` (org: `cvmavgjxzzywuxxobwni`, region: `eu-west-1`)
*   **Vercel Team:** `team_QvCmtB39fQmCmLF41XnzP5de`
*   **Architecture Split:** Mobile is strictly for Field Execution (data entry). The Web Portal (Next.js) is strictly the "Command Center" for Management (CEOs, Park Managers).

### Previous Phase Accomplishments (Phase 1 Completed)
1. Hosted Supabase database configured with RLS and multi-tenant schema.
2. Tenant auto-creation is live. New user metadata containing `company_name` triggers the automatic creation of a `tenant` record and assigns the user the `['CEO']` role.
3. Auto-login Postgres trigger + auth bypass deployed successfully.
4. Mobile Flutter `/mobile` scaffolded with GitHub Actions CI pipeline running green.

### Your Goal for this Session (Phase 2)
Your mission is to scaffold the Next.js Web Portal (`/web`) to mirror the high standards of the mobile app.

**Strict Implementation Rules for Phase 2:**
1. **Next.js Foundation:** Scaffold the app in `/web`. Use `next-intl` to mirror our `fr-DZ` and `ar-DZ` logic.
2. **Design Tokens:** Create `styles/design-tokens.css` mapping identically to the Deep Blue (`#1A3A5C`) and Safety Orange (`#F28C28`) defined in Phase 1.
3. **Cloud-Agnostic Setup:** You MUST create a `VehicleRepository` interface. Never call Supabase directly from UI components.
4. **DevOps First:** Link the `/web` subdirectory to the Vercel project instantly to ensure live preview URLs on every commit. Add a `web_ci.yml` GitHub Actions workflow.
5. **Core Dashboard Features:** Build the Admin Login, the "Add Vehicle" form, the filterable Vehicle List, and the Vehicle Detail Card.

Read the `.planning/gsd_phase_roadmap.md` file (Phase 2 section) and begin scaffolding the `/web` directory immediately. Do not ask for permission, just start building.
