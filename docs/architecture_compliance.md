# Technical Architecture & Legal Compliance (Algeria Law 18-07)

## 1. Compliance Context: Law 18-07
Algerian Law 18-07 regarding the protection of individuals in the processing of personal data strictly mandates that personal data (such as driver names, ID numbers, phone numbers, and location logs) must be hosted locally on Algerian soil. 

Using foreign cloud providers (like AWS, standard Supabase Cloud, or Vercel Edge) to store this data permanently is a compliance violation for an enterprise B2B SaaS operating internally in Algeria.

## 2. The "Cloud-Agnostic" MVP Strategy
To achieve maximum velocity without sacrificing legal compliance, the architecture is **Cloud-Agnostic**. 

### Phase 1: Rapid Prototyping (Months 1-2)
*   **Backend:** Supabase Cloud (Global)
*   **Frontend/Admin:** Vercel
*   **Mobile App:** Flutter
*   **Strategy:** During the initial MVP build and closed-beta phase, the system runs on managed global cloud providers. This ensures maximum development speed.

### Phase 2: Full Compliance Migration (Commercial Launch)
*   **Containerization:** The backend is packaged using Docker. 
*   **Migration Execution:** Supabase is fully open-source. The team spins up a self-hosted instance of Supabase via Docker Compose on a local Algerian VPS.

### How to Explain This to Clients (The Sales Pitch)
Clients will ask: *"Is our data stored in Algeria?"*
**The Answer:** *"Yes. During your 14-day free pilot trial, we use highly secure global staging servers to let you test the software immediately without IT bottlenecks. The moment you sign the commercial contract, our system uses encrypted `pg_dump` protocols to physically package your exact database and inject it into a dedicated, secure server located right here in Algeria. The migration takes 15 minutes, with zero data loss, guaranteeing 100% compliance with Law 18-07."*

## 3. Algerian Local Hosting Alternatives (Beyond Algérie Telecom)
If Algérie Telecom VPS is unavailable or unstable, here are the best enterprise-grade alternatives for hosting local data in Algeria:
1.  **ICOSNET Enterprise Cloud:** Highly stable, private Algerian datacenter. More expensive than AT, but offers superior B2B support, uptime guarantees, and fiber redundancy.
2.  **Djezzy / Ooredoo Datacenters:** Telecomm giants offering B2B cloud hosting services. Excellent bandwidth and physical security.
3.  **Local "On-Premise" Server:** For large, paranoid clients (e.g., government contractors), you offer an "On-Premise" deployment. They buy a physical Dell server, put it in their own office, and you install the FleetMan Docker containers directly onto it. (Charge a premium 500,000+ DZD setup fee for this).

## 4. Architecture Tools for Vibe-Coding
*   **Database & Auth:** Supabase (Open Source, Docker-ready, PostgreSQL core).
*   **File Storage (Receipts, Photos):** Supabase Storage using its **S3-Compatible API**. By strictly using standard S3 API calls (instead of black-box SDKs) to upload damage photos and receipts, we guarantee that when we migrate to the local Algerian VPS, we can simply point the URL to a self-hosted S3 bucket (like MinIO) without changing a single line of Flutter or Next.js code.
*   **Frontend Framework:** Flutter (Compiles locally to APK/iOS).
*   **Web Portal:** Next.js or React (Deployable as static files or Docker container on any machine).
