-- PGP10 Reading Tracker — Supabase schema (two-layer model)
-- Run once: SQL Editor → New query → paste → Run.
--
-- catalog  = shared structure (subjects → LUs → readings). World-readable.
--            Writable ONLY by the admin email below.
-- progress = each member's private { checked, extras, openLUs }. Own-row only.
--
-- 👉 If your admin email is not the one below, change it in BOTH policies.

-- (optional) remove the old single-table model from the first version
drop table if exists public.tracker_state;

-- ── Shared catalog (single row, id = 1) ──────────────────────────────────────
create table if not exists public.catalog (
  id         int primary key default 1,
  data       jsonb not null default '{"subjects":[]}'::jsonb,
  updated_at timestamptz not null default now(),
  constraint catalog_singleton check (id = 1)
);
alter table public.catalog enable row level security;

-- anyone (even signed-out) can read the catalog
drop policy if exists "catalog read" on public.catalog;
create policy "catalog read" on public.catalog
  for select using (true);

-- only the admin email can insert/update/delete the catalog
drop policy if exists "catalog admin write" on public.catalog;
create policy "catalog admin write" on public.catalog
  for all
  using      ((auth.jwt() ->> 'email') = 'ksabhinav20@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'ksabhinav20@gmail.com');

-- ── Per-member private progress ──────────────────────────────────────────────
create table if not exists public.progress (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.progress enable row level security;

drop policy if exists "own progress" on public.progress;
create policy "own progress" on public.progress
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ── Auto-sync inbox (the userscript drops scraped LUs here) ───────────────────
create table if not exists public.inbox (
  id         bigint generated always as identity primary key,
  payload    jsonb not null,
  created_at timestamptz not null default now()
);
alter table public.inbox enable row level security;

-- the browser userscript (anon) may drop an LU into the inbox
drop policy if exists "inbox insert" on public.inbox;
create policy "inbox insert" on public.inbox
  for insert with check (true);

-- only the admin app can read and clear the inbox (it merges rows into the catalog)
drop policy if exists "inbox admin read" on public.inbox;
create policy "inbox admin read" on public.inbox
  for select using ((auth.jwt() ->> 'email') = 'ksabhinav20@gmail.com');
drop policy if exists "inbox admin delete" on public.inbox;
create policy "inbox admin delete" on public.inbox
  for delete using ((auth.jwt() ->> 'email') = 'ksabhinav20@gmail.com');

-- ── Realtime (live sync across devices) ──────────────────────────────────────
do $$ begin
  alter publication supabase_realtime add table public.catalog;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.progress;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.inbox;
exception when duplicate_object then null; end $$;
