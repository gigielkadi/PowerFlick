-- Add a 'name' column for unique room names per user
alter table public.rooms add column if not exists name text not null default '';
create unique index if not exists idx_rooms_userid_name on public.rooms(user_id, name); 