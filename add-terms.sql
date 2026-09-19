-- Tag each subject with its term: Term 2 = PP241, PP226; everything else Term 1.
-- Idempotent (re-running just overwrites the term); pure ASCII.
update public.catalog set data = jsonb_set(
  data, '{subjects}',
  (
    select jsonb_agg(
      s || jsonb_build_object('term', case when s->>'id' in ('pp241','pp226') then 2 else 1 end)
    )
    from jsonb_array_elements(data->'subjects') s
  )
) where id = 1;
