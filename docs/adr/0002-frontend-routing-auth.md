# ADR 0002: Frontend Routing and Auth Strategy

## Status
Accepted

## Context
FleetMan MVP utilizes Next.js App Router for its Web Portal. Because the application natively supports `fr-DZ` and `ar-DZ` localization (using `next-intl`), all top-level public and authenticated routes must account for the locale prefix segment `[locale]`.
We also needed to ensure that unauthenticated users cannot access dashboard metrics (`/[locale]/(dashboard)` logic) and that authenticated users are instantly routed away from public login screens to the main Application Dashboard.

## Decision
We chose a **Middleware + Layout Guard** approach.
1. **`i18n` Middleware:** Next.js uses standard `middleware.ts` to intercept `[locale]` and non-prefixed paths, transparently redirecting to `/fr-DZ` or `/ar-DZ` if missing.
2. **Dashboard Layout SSR Session Validation:** Instead of trying to deeply manage complex edge-middleware authentication rules, we let the `/(dashboard)/layout.tsx` function strictly via Server-Side Rendering (SSR). It calls `createServerSupabaseClient()` and forces a fallback `redirect('/login')` for any unauthenticated traffic attempting to read protected routes.
3. **Removal of Static Fallback Route:** An unconditional redirect layout sitting outside `(dashboard)` (i.e. `app/[locale]/page.tsx`) was removed. Next.js natively merges route subgroups (like `(dashboard)`) into the parent path URL. Therefore, `app/[locale]/(dashboard)/page.tsx` becomes the sole, authoritative handler for the system dashboard root `/[locale]`.

## Consequences
**Pros:**
- **Reliable Redirection Flow:** Avoids infinite refresh loops. SSR renders ensure that users immediately see accurate data based on their session without glitching.
- **Simplicity:** Keeping auth checks in `layout.tsx` guarantees that any nested subroute (`/vehicles`, `/reports`, `/settings`) strictly inherits session protection.

**Cons:**
- **Double Redirects:** When an invalid session attempts to load a localized page, it may hit middleware (for locale sync), hit Root Layout, then redirect to `login`. While perfectly functional, there is a minor waterfall performance delta compared to pure edge middleware auth.
- **Client-Side Refreshing Requirements:** Login/Signup code handles `router.refresh()` to ensure SSR layouts fetch the newest cookies upon session creation/destruction.
