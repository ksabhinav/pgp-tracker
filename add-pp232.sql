-- Catalog: add / update subject "PP232: Microeconomics II" (LU-01..02), on TOP.
-- UPSERT: removes any existing pp232 and re-inserts at the top; existing subjects keep order below.
-- LU-01 Introduction to Market Failures · LU-02 Introduction to Market Structure.
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
       where s->>'id' <> 'pp232'
      union all
      select $pp${"id":"pp232","lus":[{"id":"pp232_lu01","url":"https://opentakshashila.net/posts/pgp10-introduction-to-market-failures-103328251","title":"LU-01: Introduction to Market Failures","outcomes":[],"mandatory":[{"id":"pp232_lu01_m01","url":"https://drive.google.com/file/d/1q0QRp2zlX20iOaUSJtbyOtDb74Kif0vO/view?usp=drive_link","desc":"Essay — an overview of the different types of market failures","name":"Is Market Failure a Sufficient Condition for Government Intervention?"},{"id":"pp232_lu01_m02","url":"https://drive.google.com/file/d/1hKEY7gzPucrjWF4L_H07e8BKCW_2MXTB/view?usp=sharing","desc":"Opinion piece by Anupam Manur — a market-failure lens on the Indira Canteens","name":"The Irony of Indira"}],"selfStudy":false,"recommended":[]},{"id":"pp232_lu02","url":"https://opentakshashila.net/posts/pgp10-introduction-to-market-structure","title":"LU-02: Introduction to Market Structure","outcomes":["Understand the different ways in which markets are structured","Learn the typical characteristics of a perfectly competitive market","Understand how a monopoly, oligopoly and monopolistic competition work","Understand how a government regulates uncompetitive markets"],"mandatory":[{"id":"pp232_lu02_m01","url":"https://drive.google.com/file/d/19qlwTdaGAWLDHTdmdhmKAvKdfsQmyDuM/view?usp=sharing","desc":"Book chapter on the characteristics of an oligopoly and measures of market concentration","name":"Oligopoly: Competition Among the Few"},{"id":"pp232_lu02_m02","url":"https://drive.google.com/file/d/1-iSYGbv1zGzpoHn22cMneom9Jl71dXT8/view?usp=sharing","desc":"Essay by George J. Stigler","name":"Monopoly"}],"selfStudy":false,"recommended":[{"id":"pp232_lu02_r01","url":"","desc":"Pindyck & Rubinfeld, Chapters 10–12 (textbook — covers these topics in more detail than needed at this stage)","name":"Microeconomics"},{"id":"pp232_lu02_r02","url":"https://drive.google.com/file/d/1qdQ6dY6cBma116DHLjIJsxVIxCdll0dr/view?usp=sharing","desc":"Grady Klein and Yoram Bauman (Chapter 10)","name":"The Cartoon Introduction to Economics, Volume One: Microeconomics"}]}],"code":"Microeconomics","icon":"📊","name":"PP232: Microeconomics II","color":"#7a4c1f"}$pp$::jsonb as s, 0::numeric as ord
    ) x
  )
) || jsonb_build_object('updatedAt', 1785432077050)
where c.id = 1;
