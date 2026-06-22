-- PGP10 Reading Tracker -- reader + annotation layer (additive)
-- Paste into Supabase SQL Editor and Run. Safe to run on top of your existing schema:
-- everything here is "create if not exists" / "add column if not exists" and re-runnable.
--
-- Adds three things:
--   reading_content : one captured snapshot per source (article / video / reflowed PDF)
--   highlights      : per-user highlights, anchored by char offset into the snapshot text
--   comments.highlight_id : lets an existing comment hang off a highlight (a margin note),
--                           reusing your whole comments pipeline (attachments, avatars, realtime)

-- == Captured content (the snapshot a reading opens into) =====================
create table if not exists public.reading_content (
  url          text primary key,                 -- normalised source URL (the key the userscript/app knows)
  reading_id   text,                             -- convenience link to a catalog / shared-reading id
  title        text,
  kind         text not null default 'article',  -- 'article' | 'video' | 'pdf'
  content_html text,                             -- clean reflowable HTML (articles AND reflowed PDFs)
  embed_url    text,                             -- for kind='video' (real iframe/player src)
  source_file  text,                             -- for kind='pdf': original file in the uploads bucket
  page_map     jsonb,                            -- for reflowed PDFs: [{page,start,end}, ...] char-range -> page
  extracted_by text,                             -- 'readability' | 'pdfjs' | 'parser' | 'ocr' (provenance / quality)
  needs_review boolean default false,            -- true for OCR'd / low-confidence text worth an eyeball
  captured_by  uuid references auth.users(id) on delete set null,
  captured_at  timestamptz not null default now()
);
alter table public.reading_content enable row level security;

-- READ: signed-in cohort only. NOT world-readable like the catalog, on purpose:
-- full article / PDF text of paywalled sources should stay behind the login.
drop policy if exists "content read" on public.reading_content;
create policy "content read" on public.reading_content
  for select using (auth.uid() is not null);

-- WRITE: admin only (curated, matches your catalog). The admin app / PDF upload flow writes here.
-- 👉 To let ANY signed-in member capture content instead, replace both lines below with:
--      using (auth.uid() is not null) with check (auth.uid() is not null)
drop policy if exists "content admin write" on public.reading_content;
create policy "content admin write" on public.reading_content
  for all
  using      ((auth.jwt() ->> 'email') = 'ksabhinav20@gmail.com')
  with check ((auth.jwt() ->> 'email') = 'ksabhinav20@gmail.com');

-- == Highlights (the collaborative layer) ====================================
-- Same "any signed-in user reads, each owner writes their own" shape as comments.
create table if not exists public.highlights (
  id         uuid primary key default gen_random_uuid(),
  reading_id text not null,                 -- same join key as completions / comments
  user_id    uuid not null references auth.users(id) on delete cascade,
  start_off  int  not null,                 -- char offset into the reader container's textContent
  end_off    int  not null,
  quote      text,                          -- the highlighted text (display + re-anchor fallback)
  page       int,                           -- for PDFs: page this falls on (from page_map); null otherwise
  color      text,                          -- defaults from the author's profile colour
  note       text,                          -- optional quick note (or use comments.highlight_id for a thread)
  created_at timestamptz not null default now()
);
alter table public.highlights enable row level security;
drop policy if exists "highlights read" on public.highlights;
create policy "highlights read" on public.highlights for select using (auth.uid() is not null);
drop policy if exists "highlights write own" on public.highlights;
create policy "highlights write own" on public.highlights for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- == Reuse comments as margin notes on a highlight ===========================
-- highlight_id null  -> a reading-level comment (today's behaviour, unchanged)
-- highlight_id set   -> a note attached to a specific highlight
alter table public.comments add column if not exists highlight_id uuid
  references public.highlights(id) on delete cascade;

-- == Per-member privacy toggles (default: share everything) ===================
-- When false, that member's completions / highlights / comments are hidden from
-- everyone else's public views (the member still sees their own).
alter table public.profiles add column if not exists share_completions boolean default true;
alter table public.profiles add column if not exists share_highlights  boolean default true;
alter table public.profiles add column if not exists share_comments    boolean default true;

-- == Realtime (live highlights / content across devices) =====================
do $$ begin alter publication supabase_realtime add table public.reading_content;
exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.highlights;
exception when duplicate_object then null; end $$;
