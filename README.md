# 📚 PGP10 Reading Tracker

A mobile-installable (PWA) tracker for PGP10 mandatory & recommended readings, with
progress synced across devices via Supabase (email magic-link login).

**Live app:** https://ksabhinav.github.io/pgp-tracker/

## Features
- Subjects → Learning Units → mandatory/recommended readings, with live progress bars
- **Import Course Outline** — paste the PGP10 content list to scaffold every subject + LU at once
- **Per-LU bookmarklet** — one click on any LU page copies its readings to import
- **Cross-device sync** via Supabase + private email login (Row-Level Security)
- **Installable PWA** — "Add to Home Screen" on iOS/Android, works offline
- Falls back to **local-only mode** (browser storage) if Supabase isn't configured

## One-time Supabase setup
1. Go to https://supabase.com → sign in (GitHub works) → **New project**
   - Name: `pgp-tracker`, region: closest to you (e.g. *South Asia (Mumbai)*), set a DB password.
2. Wait ~2 min for it to provision.
3. **SQL Editor → New query** → paste the contents of [`schema.sql`](schema.sql) → **Run**.
4. **Authentication → Providers → Email** → make sure it's enabled (magic links are on by default).
5. **Authentication → URL Configuration**:
   - **Site URL**: `https://ksabhinav.github.io/pgp-tracker/`
   - **Redirect URLs**: add `https://ksabhinav.github.io/pgp-tracker/`
6. **Project Settings → API** → copy **Project URL** and the **anon public** key into [`config.js`](config.js).

That's it — open the live app, sign in with your email, tap the magic link, and you're synced.

## Local development
Service workers and Supabase auth need `http(s)` (not `file://`):
```bash
cd pgp-tracker
python3 -m http.server 8080   # then open http://localhost:8080
```

## Files
| File | Purpose |
|------|---------|
| `index.html` | The whole app (UI + logic) |
| `config.js` | Your Supabase URL + anon key |
| `schema.sql` | Database table + Row-Level-Security policies |
| `manifest.webmanifest` | PWA metadata |
| `sw.js` | Service worker (offline + install) |
| `vendor/supabase.min.js` | Supabase JS client (vendored for offline use) |
| `icons/` | App icons |
