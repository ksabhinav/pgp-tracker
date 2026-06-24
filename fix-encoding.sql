-- Fix mojibake in catalog text (double-encoded UTF-8 -> Mac-Roman -> UTF-8).
-- Pure-ASCII: the special characters are rebuilt server-side with chr() so this
-- SQL itself has no non-ASCII bytes and cannot be mangled in transit.
--   chr(183)  = U+00B7 middle dot  "."  ->  really  ·
--   chr(8211) = U+2013 en dash      "-"  ->  really  –
--   chr(8212) = U+2014 em dash      "-"  ->  really  —
update public.catalog set data =
  jsonb_set(
    jsonb_set(
      jsonb_set(
        data,
        '{subjects,0,code}',
        to_jsonb('Economics ' || chr(183) || ' Microeconomics')
      ),
      '{subjects,0,lus,3,recommended,2,name}',
      to_jsonb('Trade Liberalisation ' || chr(8211) || ' Why So Much Controversy')
    ),
    '{subjects,1,lus,0,recommended,1,desc}',
    to_jsonb('Reference list ' || chr(8212) || ' The Decision Lab')
  )
where id = 1;
