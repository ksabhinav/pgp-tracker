// ─────────────────────────────────────────────────────────────────────────────
// Supabase connection for the PGP10 Reading Tracker.
//
//   url        = Supabase Project URL
//   anonKey    = publishable / anon key (safe to be public — protected by RLS)
//   adminEmail = the one account allowed to edit the shared catalog
//                (import outline, add subjects/LUs/shared readings).
//                Everyone else is a member: their own progress + private readings.
// ─────────────────────────────────────────────────────────────────────────────
window.PGP_CONFIG = {
  url: "https://hjpqbfzhjsxdxxbrvkvi.supabase.co",
  anonKey: "sb_publishable_4VnssfN1prmotvDYx7qWhg_yb6KQ8oz",
  adminEmail: "ksabhinav20@gmail.com"
};
