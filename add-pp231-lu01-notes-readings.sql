-- Add the two textbooks mentioned in PP231 · LU-01 notes as recommended readings.
-- ("The Cartoon Introduction to Economics" is already listed, so only these two are new.)
-- Targeted + idempotent (re-running won't duplicate). Books -> blank url (falls back to LU page).
-- Paste into the Supabase SQL Editor and Run.
update public.catalog c
set data = jsonb_set(c.data, '{subjects}', (
  select jsonb_agg(
    case when s->>'id' = 'pp231'
      then jsonb_set(s, '{lus}', (
        select jsonb_agg(
          case when l->>'id' = 'lu01'
            then jsonb_set(l, '{recommended}',
              (select coalesce(jsonb_agg(r), '[]'::jsonb)
                 from jsonb_array_elements(l->'recommended') r
                where r->>'id' not in ('lu01r08','lu01r09'))
              || $add$[{"id":"lu01r08","url":"","desc":"Textbook by Robert Pindyck and David Rubinfeld (mentioned in the LU notes)","name":"Microeconomics"},{"id":"lu01r09","url":"","desc":"Book by Steven E. Landsburg (mentioned in the LU notes)","name":"The Armchair Economist: Economics and Everyday Life"}]$add$::jsonb)
            else l end)
        from jsonb_array_elements(s->'lus') l))
      else s end)
  from jsonb_array_elements(c.data->'subjects') s))
where c.id = 1;
