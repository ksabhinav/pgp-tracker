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

-- ── Realtime (live sync across devices) ──────────────────────────────────────
do $$ begin
  alter publication supabase_realtime add table public.catalog;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.progress;
exception when duplicate_object then null; end $$;
