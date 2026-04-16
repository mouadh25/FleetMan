# Handoff Context & Prompt: Transitioning to Phase 3

**User Instructions:** 
Copy everything below the line and paste it as the very first message into your next Agent session.

---

You are an expert full-stack developer working on the FleetMan MVP. We are following a strict **GSD (Get Shit Done)** burn-and-replace methodology to eliminate AI context drift. You are stepping into the workspace completely fresh to execute **Phase 3**.

### State of the Union
- **Phases 0, 1, and 2 are 100% COMPLETE AND DEPLOYED.**
- **Database (Supabase):** RLS, tenant controls, and the `vehicles` table are perfectly synced and cloud-agnostic. 
- **Web (Next.js):** Vercel web deployment is live. Forms and design tokens (`fr-DZ` / `ar-DZ`) are functioning perfectly.
- **Mobile (Flutter):** Foundation, Auth, and Design System are stable.
- **CRITICAL MCP ISOLATION RULES:** To prevent global cloud contamination, you MUST read `.geminirules` and `.agent/workflows/mcp-safety.md` before executing any MCP tool. You are targeting Supabase project `mzuippdkhsqifxacssex` and Vercel project `prj_YEBtNxsQHaXCUoOAdJP0YTJwNXzf`.

### Your Mission for This Session: Execute Phase 3 (The Field Manager Loop)
This session is strictly scoped to building out **Phase 3**. Your goal is to enable field managers to audit trucks in the yard using QR scanners, take damage photos, and log audio notes.

Please refer to `d:\Dev\AntiGravity\FleetMan\.planning\gsd_phase_roadmap.md` and complete the Phase 3 tasks atomically:

1. **Storage Infrastructure:** Build the `StorageRepository` (both Web and Mobile) pointing to the Supabase S3-Compatible Storage API. Make sure buckets for `vehicle_photos`, `document_scans`, and `voice_notes` are active.
2. **Mobile Audit Loop (Flutter):** 
   - Build `qr_scanner_screen.dart` to identify the vehicle.
   - Build the `audit_form_screen.dart` (odometer check, damage checklist, camera capture, Voice Notes, Pass/Fail toggle).
   - Implement an SQLite/Hive offline queue cache (`offline_sync_service.dart`) so audits queue locally during Algerian dead-zones and sync upon reconnect.
3. **Automated Issue Generation:** If an audit is marked "Fail", dynamically generate a new row in the `issues` table.
4. **Web Monitor (Next.js):** Build the `gate-logs/page.tsx` so the Web Office Manager can view the incoming streaming logs.

**Execution Rules:**
- Read the roadmap and the specific handoff file `docs/phase_3_handoff.md` before writing code.
- Write cloud-agnostic code. The `StorageRepository` MUST be an interface that encapsulates the database/storage logic. Do not put raw S3 SDK calls directly in Widget logic.
- Make atomic Git commits for each major feature.
- Let me know your Implementation Plan to tackle these tasks, and wait for my approval before executing.
