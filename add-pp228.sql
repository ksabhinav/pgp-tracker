-- Catalog: add / update subject "PP228: Water Governance" (LU-01), on TOP.
-- UPSERT: removes any existing pp228 and re-inserts at the top; existing subjects keep order below.
-- LU-01 Urban Water Systems in the Overall Context of Water Resources in India (4 mandatory).
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
       where s->>'id' <> 'pp228'
      union all
      select $pp${"id":"pp228","lus":[{"id":"pp228_lu01","url":"https://opentakshashila.net/posts/pgp10-lu-01-urban-water-systems-in-the-overall-context-of-water-resources-in-india-103328220","title":"LU-01: Urban Water Systems in the Overall Context of Water Resources in India","outcomes":["Gain a comprehensive understanding of the complex challenges and frameworks surrounding water governance in India","Examine key issues like water scarcity, allocation rights and pollution management, and the roles of various stakeholders","Through analysis, discussion and case studies, develop strategies for sustainable and equitable water management in India"],"mandatory":[{"id":"pp228_lu01_m01","url":"https://drive.google.com/file/d/1LAN_b5rggBy2_PQXvkglYyC93YR1iGbK/view?usp=drive_link","desc":"Series of articles by Mihir Shah","name":"Series of Articles"},{"id":"pp228_lu01_m02","url":"https://drive.google.com/file/d/1JbWy6LXikecHMWbR-XrU8PHu9Omyy757/view?usp=sharing","desc":"Tirthankar Roy","name":"Water, Climate, and Economy in India from 1880 to the Present"},{"id":"pp228_lu01_m03","url":"https://drive.google.com/file/d/1YOV7_fWydvoe0RINEVVorTWSbNiOjOKj/view?usp=sharing","desc":"Akosua Sarpong Boakye-Ansah, Klaas Schwartz and Margreet Zwarteveen","name":"Unravelling pro-poor water services: what does it mean and why is it so popular?"},{"id":"pp228_lu01_m04","url":"https://drive.google.com/file/d/1LKOVaFzDd_crt7IVdLRa15bs2j2DWGiz/view?usp=sharing","desc":"ICRIER report","name":"Saving Punjab and Haryana from Ecological Disaster"}],"selfStudy":false,"recommended":[]}],"code":"Water Resources · Mr. Vishwanath","icon":"💧","name":"PP228: Water Governance","color":"#265d82"}$pp$::jsonb as s, 0::numeric as ord
    ) x
  )
) || jsonb_build_object('updatedAt', 1785432416337)
where c.id = 1;
