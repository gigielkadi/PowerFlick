-- Rename 'name' to 'type' and add 'count' column to rooms table
alter table public.rooms
  rename column name to type;

alter table public.rooms
  add column if not exists count integer default 1; 