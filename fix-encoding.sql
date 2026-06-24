-- Fix catalog text: rename subject code to plain "Microeconomics", and repair two
-- mojibaked dashes (double-encoded UTF-8 -> Mac-Roman -> UTF-8).
-- Pure-ASCII: the dashes are rebuilt server-side with chr() so this SQL has no
-- non-ASCII bytes and cannot be mangled in transit.
--   chr(8211) = U+2013 en dash    (in "Trade Liberalisation - Why So Much Controversy")
--   chr(8212) = U+2014 em dash    (in "Reference list - The Decision Lab")
update public.catalog set data =
  jsonb_set(
    jsonb_set(
      jsonb_set(
        data,
        '{subjects,0,code}',
        to_jsonb('Microeconomics'::text)
      ),
      '{subjects,0,lus,3,recommended,2,name}',
      to_jsonb('Trade Liberalisation ' || chr(8211) || ' Why So Much Controversy')
    ),
    '{subjects,1,lus,0,recommended,1,desc}',
    to_jsonb('Reference list ' || chr(8212) || ' The Decision Lab')
  )
where id = 1;
