-- Catalog: add subject "PP223: International Relations and Foreign Affairs" (LU-01), on TOP.
-- Newest subject goes first (prepended); existing subjects keep their order below it.
-- Idempotent append (won't rewrite existing subjects/readings; won't duplicate pp223).
-- Readings have no direct links yet (blank url -> the reading falls back to the LU's
-- OpenTakshashila page); links/PDFs can be backfilled later. Reading IDs are pp223-prefixed.
-- Paste the statement below into the Supabase SQL Editor and Run.
update public.catalog c
set data = jsonb_set(
  c.data,
  '{subjects}',
  (
    select jsonb_agg(q.s order by q.ord)
    from (
      select $pp${"id":"pp223","lus":[{"id":"pp223_lu01","url":"https://opentakshashila.net/posts/pgp10-lu-01-theories-and-worldviews","title":"LU-01: Theories and Worldviews","outcomes":["Appreciate the important modern approaches to understanding international relations","Explore how and to what extent schools of thought affect foreign affairs","Understand the difference between international relations and foreign policy","Appreciate how different civilisations see the world and how this affects their attitudes, motivations and policies in world politics","Learn the key assumptions, features and inferences of the Indian, Chinese, Islamic and Westphalian frameworks of international relations","Identify the fundamental tensions that arise from differences between these frameworks"],"mandatory":[{"id":"pp223_lu01_m01","url":"","desc":"Essay by Hedley Bull","name":"Hobbes and the International Anarchy"},{"id":"pp223_lu01_m02","url":"","desc":"Foreign Policy essay by Stephen M. Walt","name":"One World, Many Theories"}],"selfStudy":false,"recommended":[{"id":"pp223_lu01_r01","url":"","desc":"Georg Sørensen","name":"IR Theory After the Cold War"},{"id":"pp223_lu01_r02","url":"","desc":"Andrew Heywood and Ben Whitham","name":"Global Politics"},{"id":"pp223_lu01_r03","url":"","desc":"Book by Martin Jacques","name":"When China Rules the World"},{"id":"pp223_lu01_r04","url":"","desc":"Muhammad Haniff Hassan","name":"War, Peace or Neutrality"}]}],"code":"International Relations","icon":"🌍","name":"PP223: International Relations and Foreign Affairs","color":"#267336"}$pp$::jsonb as s, 0::numeric as ord
      union all
      select s, ord::numeric + 1
        from jsonb_array_elements(c.data->'subjects') with ordinality as t(s, ord)
    ) q
  )
) || jsonb_build_object('updatedAt', 1783414669621)
where c.id = 1
  and not exists (
    select 1 from jsonb_array_elements(c.data->'subjects') e where e->>'id' = 'pp223'
  );
