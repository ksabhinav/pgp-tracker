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

-- ── Social layer (profiles, completions, shared readings, comments) ──────────
-- All readable by any signed-in user; each row writable only by its owner.

create table if not exists public.profiles (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  name       text,
  emoji      text,
  color      text,
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles read" on public.profiles;
create policy "profiles read" on public.profiles for select using (auth.uid() is not null);
drop policy if exists "profiles write own" on public.profiles;
create policy "profiles write own" on public.profiles for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- who has completed which reading (reading_id = catalog or shared-reading id)
create table if not exists public.completions (
  user_id    uuid not null references auth.users(id) on delete cascade,
  reading_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, reading_id)
);
alter table public.completions enable row level security;
drop policy if exists "completions read" on public.completions;
create policy "completions read" on public.completions for select using (auth.uid() is not null);
drop policy if exists "completions write own" on public.completions;
create policy "completions write own" on public.completions for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- member-contributed readings, attributed to whoever added them
create table if not exists public.shared_readings (
  id           uuid primary key default gen_random_uuid(),
  lu_id        text not null,
  reading_type text not null,          -- 'mandatory' | 'recommended'
  name         text not null,
  url          text default '',
  descr        text default '',
  added_by     uuid not null references auth.users(id) on delete cascade,
  created_at   timestamptz not null default now()
);
alter table public.shared_readings enable row level security;
drop policy if exists "shared read" on public.shared_readings;
create policy "shared read" on public.shared_readings for select using (auth.uid() is not null);
drop policy if exists "shared write own" on public.shared_readings;
create policy "shared write own" on public.shared_readings for all
  using (auth.uid() = added_by) with check (auth.uid() = added_by);

-- per-reading discussion
create table if not exists public.comments (
  id         uuid primary key default gen_random_uuid(),
  reading_id text not null,
  user_id    uuid not null references auth.users(id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now()
);
alter table public.comments enable row level security;
drop policy if exists "comments read" on public.comments;
create policy "comments read" on public.comments for select using (auth.uid() is not null);
drop policy if exists "comments insert own" on public.comments;
create policy "comments insert own" on public.comments for insert with check (auth.uid() = user_id);
drop policy if exists "comments delete own" on public.comments;
create policy "comments delete own" on public.comments for delete using (auth.uid() = user_id);

-- ── File uploads (PDFs in comments & suggested readings) ─────────────────────
-- A public storage bucket; signed-in users upload, everyone can read.
insert into storage.buckets (id, name, public)
  values ('uploads', 'uploads', true)
  on conflict (id) do update set public = true;

drop policy if exists "uploads read" on storage.objects;
create policy "uploads read" on storage.objects
  for select using (bucket_id = 'uploads');
drop policy if exists "uploads insert" on storage.objects;
create policy "uploads insert" on storage.objects
  for insert to authenticated with check (bucket_id = 'uploads');
drop policy if exists "uploads update own" on storage.objects;
create policy "uploads update own" on storage.objects
  for update to authenticated using (bucket_id = 'uploads' and owner = auth.uid());
drop policy if exists "uploads delete own" on storage.objects;
create policy "uploads delete own" on storage.objects
  for delete to authenticated using (bucket_id = 'uploads' and owner = auth.uid());

-- attachment (PDF url) on comments
alter table public.comments add column if not exists attachment text;

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
do $$ begin
  alter publication supabase_realtime add table public.completions;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.shared_readings;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.comments;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.profiles;
exception when duplicate_object then null; end $$;
