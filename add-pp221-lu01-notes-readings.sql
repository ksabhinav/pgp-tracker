-- Add the two readings named in PP221 · LU-01 notes as recommended readings:
-- "Rise of Nations" (Nitin Pai video) and "Federalism" (OCPI Ch. 4, Mitra & Pehl).
-- ("The State", OCPI Ch. 1, is already a mandatory reading, so it's not duplicated.)
-- Targeted + idempotent (re-running won't duplicate). Paste into the Supabase SQL Editor and Run.
update public.catalog c
set data = jsonb_set(c.data, '{subjects}', (
  select jsonb_agg(
    case when s->>'id' = 'pp221'
      then jsonb_set(s, '{lus}', (
        select jsonb_agg(
          case when l->>'id' = 'pp221_lu01'
            then jsonb_set(l, '{recommended}',
              (select coalesce(jsonb_agg(r), '[]'::jsonb)
                 from jsonb_array_elements(l->'recommended') r
                where r->>'id' not in ('pp221_lu01_r04','pp221_lu01_r05'))
              || $add$[{"id":"pp221_lu01_r04","url":"https://www.youtube.com/watch?v=tTJkCGlzQ8k","desc":"Video by Nitin Pai (referenced in the LU notes)","name":"Rise of Nations (video)"},{"id":"pp221_lu01_r05","url":"","desc":"Oxford Companion to Politics in India, Ch. 4 — Subrata K. Mitra and Malte Pehl (referenced in the LU notes)","name":"Federalism"}]$add$::jsonb)
            else l end)
        from jsonb_array_elements(s->'lus') l))
      else s end)
  from jsonb_array_elements(c.data->'subjects') s))
where c.id = 1;
