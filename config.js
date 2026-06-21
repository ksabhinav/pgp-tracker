// ─────────────────────────────────────────────────────────────────────────────
// Supabase connection for the PGP10 Reading Tracker.
//
// Fill these from your Supabase project:  Project Settings → API
//   • url     = "Project URL"
//   • anonKey = "anon public" key (NOT the service_role key)
//
// The anon key is DESIGNED to be public — your data is protected by
// Row-Level Security, so only your logged-in account can read/write it.
//
// While these say YOUR_… the app runs in local-only mode (no login, no sync).
// ─────────────────────────────────────────────────────────────────────────────
window.PGP_CONFIG = {
  url: "YOUR_SUPABASE_URL",
  anonKey: "YOUR_SUPABASE_ANON_KEY"
};
