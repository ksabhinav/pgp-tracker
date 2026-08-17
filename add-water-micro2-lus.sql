-- Add missing LUs to match the OT structure: PP228 (Water Governance) LU-02/03 and
-- PP232 (Microeconomics II) LU-05/06/07. Skeletons only (title + OT link; no readings yet).
-- Id-based + idempotent (re-running won't duplicate). Pure ASCII (safe through the clipboard).
update public.catalog set data = jsonb_set(
  data, '{subjects}',
  (
    select jsonb_agg(
      case
        when s->>'id' = 'pp228' then jsonb_set(s, '{lus}',
          (
            select coalesce(jsonb_agg(l), '[]'::jsonb)
            from jsonb_array_elements(s->'lus') l
            where l->>'id' not in ('pp228_lu02','pp228_lu03')
          )
          || jsonb_build_array(
            jsonb_build_object(
              'id','pp228_lu02',
              'title','LU-02: Groundwater Systems, Challenges and Opportunities',
              'url','https://opentakshashila.net/posts/pgp10-lu-02-groundwater-systems-challenges-and-opportunities-103328221',
              'selfStudy',false,'outcomes',jsonb_build_array(),'mandatory',jsonb_build_array(),'recommended',jsonb_build_array()
            ),
            jsonb_build_object(
              'id','pp228_lu03',
              'title','LU-03: Overall Water in India and its Governance Challenges',
              'url','https://opentakshashila.net/posts/pgp10-lu-03-overall-water-in-india-and-its-governance-challenges-103328222',
              'selfStudy',false,'outcomes',jsonb_build_array(),'mandatory',jsonb_build_array(),'recommended',jsonb_build_array()
            )
          )
        )
        when s->>'id' = 'pp232' then jsonb_set(s, '{lus}',
          (
            select coalesce(jsonb_agg(l), '[]'::jsonb)
            from jsonb_array_elements(s->'lus') l
            where l->>'id' not in ('pp232_lu05','pp232_lu06','pp232_lu07')
          )
          || jsonb_build_array(
            jsonb_build_object(
              'id','pp232_lu05',
              'title','LU-05: Market Failures: Externalities',
              'url','https://opentakshashila.net/posts/pgp10-lu-05-market-failures-externalities',
              'selfStudy',false,'outcomes',jsonb_build_array(),'mandatory',jsonb_build_array(),'recommended',jsonb_build_array()
            ),
            jsonb_build_object(
              'id','pp232_lu06',
              'title','LU-06: Market Failures: Public Goods',
              'url','https://opentakshashila.net/posts/pgp10-lu-06-market-failures-public-goods',
              'selfStudy',false,'outcomes',jsonb_build_array(),'mandatory',jsonb_build_array(),'recommended',jsonb_build_array()
            ),
            jsonb_build_object(
              'id','pp232_lu07',
              'title','LU-07: Market Failures: Information Asymmetry',
              'url','https://opentakshashila.net/posts/pgp10-lu-07-market-failures-information-asymmetry',
              'selfStudy',false,'outcomes',jsonb_build_array(),'mandatory',jsonb_build_array(),'recommended',jsonb_build_array()
            )
          )
        )
        else s
      end
    )
    from jsonb_array_elements(data->'subjects') s
  )
) where id = 1;
