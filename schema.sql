-- PGP10 Reading Tracker — Supabase schema
-- Run this once in your Supabase project: SQL Editor → New query → paste → Run.

create table if not exists public.tracker_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.tracker_state enable row level security;

-- Each user can only see and modify their own row.
drop policy if exists "own row - select" on public.tracker_state;
create policy "own row - select" on public.tracker_state
  for select using (auth.uid() = user_id);

drop policy if exists "own row - insert" on public.tracker_state;
create policy "own row - insert" on public.tracker_state
  for insert with check (auth.uid() = user_id);

drop policy if exists "own row - update" on public.tracker_state;
create policy "own row - update" on public.tracker_state
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
