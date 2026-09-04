-- Rename member profiles (run in Supabase SQL Editor; bypasses RLS as admin).
update public.profiles set name = 'Mohit Somani', updated_at = now() where name = 'mohit.somani64';
update public.profiles set name = 'Hamza',        updated_at = now() where name = 'smhamza25';
update public.profiles set name = 'Sriya Misra',  updated_at = now() where name = 'sriyamisra05';
