create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  connected_devices integer not null default 0,
  number_of_rooms integer not null default 0
);
