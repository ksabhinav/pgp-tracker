-- Coordinate subject colours into one deep jewel-tone palette.
-- Pure data change (takes effect live as soon as you Run it) — paste into the Supabase SQL Editor.
update public.catalog
set data = jsonb_set(
  data, '{subjects}',
  (select jsonb_agg(
     case s->>'id'
       when 'pp231'              then jsonb_set(s, '{color}', '"#701a39"')   -- deep wine
       when 'pp221'              then jsonb_set(s, '{color}', '"#362c77"')   -- deep indigo
       when 'sub_ad-hoc-classes' then jsonb_set(s, '{color}', '"#2c6d6d"')   -- deep teal
       else s
     end)
   from jsonb_array_elements(data->'subjects') s)
)
where id = 1;
