-- Add 3 resources from Sarthak's PP231 Microeconomics-I session to LU-05 (Government
-- Intervention in Markets), recommended list. Pure-ASCII (no special chars -> safe
-- through the clipboard). Id-based, so it's robust to subject/LU index shifts, and
-- idempotent: any existing lu05r06/07/08 are dropped first, so re-running won't dupe.
update public.catalog set data = jsonb_set(
  data, '{subjects}',
  (
    select jsonb_agg(
      case when s->>'id' = 'pp231' then jsonb_set(
        s, '{lus}',
        (
          select jsonb_agg(
            case when l->>'id' = 'lu05' then jsonb_set(
              l, '{recommended}',
              (
                select coalesce(jsonb_agg(r), '[]'::jsonb)
                from jsonb_array_elements(l->'recommended') r
                where r->>'id' not in ('lu05r06','lu05r07','lu05r08')
              )
              || jsonb_build_array(
                jsonb_build_object(
                  'id','lu05r06',
                  'name','In Service of the Republic: The Art and Science of Economic Policy',
                  'desc','Book by Vijay Kelkar and Ajay Shah',
                  'url',''
                ),
                jsonb_build_object(
                  'id','lu05r07',
                  'name','No Country for Dying Firms: Evidence from India',
                  'desc','NBER working paper by Chatterjee, Krishna, Padmakumar and Zhao',
                  'url','https://www.nber.org/papers/w33830'
                ),
                jsonb_build_object(
                  'id','lu05r08',
                  'name','Understanding Exit Barriers in India',
                  'desc','All Things Policy episode with Shoumitro Chatterjee and Sarthak Pradhan',
                  'url','https://open.spotify.com/episode/6MKlJ04x2IYrdyyv5V3UFJ'
                )
              )
            ) else l end
          )
          from jsonb_array_elements(s->'lus') l
        )
      ) else s end
    )
    from jsonb_array_elements(data->'subjects') s
  )
) where id = 1;
