-- Add profile fields to users table
alter table public.users
  add column if not exists birthdate date,
  add column if not exists home_type text,
  add column if not exists household_size integer,
  add column if not exists priorities jsonb; 