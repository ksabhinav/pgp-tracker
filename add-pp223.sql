-- Catalog: add / update subject "PP223: International Relations and Foreign Affairs" (LU-01), on TOP.
-- UPSERT: removes any existing pp223 and re-inserts the current definition at the top, so
-- re-running applies the latest readings/links. Existing OTHER subjects keep their order below.
-- Reading IDs are pp223-prefixed. LU-01 = 6 readings (2 required + 4 recommended) with Drive links.
-- Paste the statement below into the Supabase SQL Editor and Run.
update public.catalog c
set data = jsonb_set(
  c.data,
  '{subjects}',
  (
    select coalesce(jsonb_agg(x.s order by x.ord), '[]'::jsonb)
    from (
      select s, ord::numeric + 1 as ord
        from jsonb_array_elements(c.data->'subjects') with ordinality as t(s, ord)
       where s->>'id' <> 'pp223'
      union all
      select $pp${"id":"pp223","lus":[{"id":"pp223_lu01","url":"https://opentakshashila.net/posts/pgp10-lu-01-theories-and-worldviews","title":"LU-01: Theories and Worldviews","outcomes":["Appreciate the important modern approaches to understanding international relations","Explore how and to what extent schools of thought affect foreign affairs","Understand the difference between international relations and foreign policy","Appreciate how different civilisations see the world and how this affects their attitudes, motivations and policies in world politics","Learn the key assumptions, features and inferences of the Indian, Chinese, Islamic and Westphalian frameworks of international relations","Identify the fundamental tensions that arise from differences between these frameworks"],"mandatory":[{"id":"pp223_lu01_m01","url":"https://drive.google.com/file/d/1sbLpXhJdgt5DJvcpyIqrXCxzBjd6ECZI/view?usp=drive_link","desc":"Essay by Hedley Bull","name":"Hobbes and the International Anarchy"},{"id":"pp223_lu01_m02","url":"https://drive.google.com/file/d/1ElfpYxBAGXfblRs6mXJFJDZBOQz-5DOA/view?usp=drive_link","desc":"Foreign Policy essay by Stephen M. Walt","name":"One World, Many Theories"}],"selfStudy":false,"recommended":[{"id":"pp223_lu01_r01","url":"https://drive.google.com/file/d/1i_MqV9ygUfQmmNaa9z4KMtlJbfQbdDFa/view?usp=drive_link","desc":"Georg Sørensen","name":"IR Theory After the Cold War"},{"id":"pp223_lu01_r02","url":"https://drive.google.com/file/d/1WfoV3gUEyOLqicUU3M0uDWqiA4t9l5rk/view?usp=drive_link","desc":"Andrew Heywood and Ben Whitham","name":"Global Politics"},{"id":"pp223_lu01_r03","url":"https://drive.google.com/file/d/1xkPfz4gP6KdoPCsZHZMjEZDGSQLWW4LF/view?usp=drive_link","desc":"Book by Martin Jacques","name":"When China Rules the World"},{"id":"pp223_lu01_r04","url":"https://drive.google.com/file/d/1B5FphYUp6qTg7aZlGNrVoVvnXxgGhr7a/view?usp=drive_link","desc":"Muhammad Haniff Hassan","name":"War, Peace or Neutrality"}]}],"code":"International Relations","icon":"🌍","name":"PP223: International Relations and Foreign Affairs","color":"#267336"}$pp$::jsonb as s, 0::numeric as ord
    ) x
  )
) || jsonb_build_object('updatedAt', 1783415288829)
where c.id = 1;
