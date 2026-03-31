# Handoff Context & Prompt

**User Instructions:** 
Copy everything below the line and paste it as the very first message into your next Agent session.

---

You are an expert full-stack developer working on the FleetMan MVP following a strict GSD (Get Shit Done) burn-and-replace methodology.

### State of the Union
- **Phase 0 (Database) and Phase 1 (Auth)** are fully complete and verified.
- **Phase 2 (Vehicles) is partially complete.** The Next.js design system, `next-intl` localization, auth layout protections, and the Vehicle List (`/vehicles`) are implemented. 

### Recent Architectural Decisions
Before writing code, please read the following ADRs located in `docs/adr/`:
1. `0001-multi-tenant-provisioning.md`
2. `0002-frontend-routing-auth.md`

### Your Mission for This Session: Finish Phase 2
This session is strictly scoped to finishing the **remaining Vehicle features from Phase 2**. Do not bleed into Phase 3. 

Please refer to `d:\Dev\AntiGravity\FleetMan\.planning\gsd_phase_roadmap.md` and complete the unchecked tasks in Phase 2:
1. **Task 2.9:** Build the "Add Vehicle" form in Next.js (`vehicles/new/page.tsx`). Must handle plate limits, models, odometers, and legal doc uploads (S3 mock/setup if necessary).
2. **Task 2.11:** Build the Vehicle Detail Card in Next.js (`vehicles/[id]/page.tsx`).
3. **Task 2.12:** Scaffold the matching Flutter mobile Vehicle Card (`vehicle_card_screen.dart`).

**Execution Rules:**
- Read the ADRs and the `gsd_phase_roadmap` Phase 2 section first.
- Make atomic git commits for each completed file/feature.
- Let me know when you have completed these three tasks so I can verify the deployment on Vercel and spin up a new agent for Phase 3.
