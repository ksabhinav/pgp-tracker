# 📚 PGP10 Reading Tracker

A mobile-installable (PWA) tracker for PGP10 readings. One **shared catalog** of
subjects → Learning Units → readings (curated by the admin), and **private
per-member progress** that syncs across devices in realtime.

**Live app:** https://ksabhinav.github.io/pgp-tracker/

## Who can do what
- **Admin** (`ksabhinav20@gmail.com`) — signs in and can import the course outline,
  add subjects/LUs, and add shared readings. Edits appear for everyone, live.
- **Members** — anyone. Tick readings to track progress, and add their *own* private
  readings (never shown to others). No structural controls, no delete.
- **Login is optional.** Without logging in, everything saves to that device.
  Logging in (magic link) syncs your progress across all your devices in realtime.

## Two-layer data model
| Table | Holds | Who can write |
|-------|-------|---------------|
| `catalog` | shared subjects/LUs/readings (one row) | admin email only (RLS) |
| `progress` | each member's `{checked, extras, openLUs}` | that user only (RLS) |

## One-time Supabase setup
1. In your project, open **SQL Editor → New query**, paste [`schema.sql`](schema.sql), **Run**.
   - It creates both tables, the RLS policies, and enables realtime.
   - The admin email is hard-coded in the two `catalog` policies — if you ever change
     `adminEmail` in `config.js`, change it in `schema.sql` too and re-run.
2. **Authentication → URL Configuration**:
   - **Site URL**: `https://ksabhinav.github.io/pgp-tracker/`
   - **Redirect URLs**: add `https://ksabhinav.github.io/pgp-tracker/`
3. Open the live app → **Sign in to sync** → use the admin email. On first admin login,
   the catalog auto-seeds with the bundled PP231 content. Import more as the course runs.

`config.js` already holds the project URL, publishable key, and admin email.

## Google sign-in (recommended — avoids email rate limits)
Supabase's built-in email sender is throttled to a few magic links/hour. Google sign-in
sends no email, so it has no such limit. To enable it:

1. **Supabase → Authentication → Providers → Google** → toggle on, and copy the shown
   **Callback URL** (`https://<project>.supabase.co/auth/v1/callback`).
2. **Google Cloud Console** (console.cloud.google.com) → new/any project:
   - **APIs & Services → OAuth consent screen**: External; set app name + support email.
     Either **Publish** it (members see a one-time "unverified app" screen they click past),
     or keep it in Testing and add each member's Gmail under **Test users**.
   - **APIs & Services → Credentials → Create credentials → OAuth client ID → Web application**:
     - Authorized JavaScript origins: `https://ksabhinav.github.io`
     - Authorized redirect URIs: the **Callback URL** from step 1
     - Create → copy the **Client ID** and **Client secret**.
3. Paste Client ID + secret back into the Supabase Google provider → **Save**.

That's it — "Continue with Google" then works for the admin and every member.

## Local development
```bash
cd pgp-tracker
python3 -m http.server 8080   # open http://localhost:8080
```

## Files
| File | Purpose |
|------|---------|
| `index.html` | The whole app (UI + logic) |
| `config.js` | Supabase URL, publishable key, admin email |
| `schema.sql` | Tables + RLS + realtime |
| `manifest.webmanifest`, `sw.js` | PWA install + offline |
| `vendor/supabase.min.js` | Supabase client (vendored for offline) |
| `icons/` | App icons |
