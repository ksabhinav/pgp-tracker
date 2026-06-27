-- Cache of OpenGraph link previews for comment URLs. Written only by the `unfurl`
-- edge function (service role); clients read it. Paste into Supabase SQL Editor and Run.
create table if not exists public.link_previews (
  url         text primary key,          -- normalised URL (matches the app's normUrl)
  title       text,
  description text,
  image       text,
  site        text,
  fetched_at  timestamptz not null default now()
);
alter table public.link_previews enable row level security;
drop policy if exists "lp read" on public.link_previews;
create policy "lp read" on public.link_previews for select using (auth.uid() is not null);
-- (No client write policy: previews are written by the edge function via the service role.)

-- Optional - live-update cards as previews land (safe to skip):
-- alter publication supabase_realtime add table public.link_previews;
