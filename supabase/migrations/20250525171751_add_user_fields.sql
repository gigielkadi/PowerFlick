-- Add additional user fields
alter table public.users
  add column if not exists full_name text,
  add column if not exists phone_number text,
  add column if not exists last_login timestamp with time zone,
  add column if not exists is_active boolean default true,
  add column if not exists updated_at timestamp with time zone default timezone('utc'::text, now());

-- Create an updated_at trigger
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$ language plpgsql;

create trigger set_updated_at
  before update on public.users
  for each row
  execute function public.handle_updated_at();

-- Add RLS policies
alter table public.users enable row level security;

create policy "Users can view their own data"
  on public.users for select
  using (auth.uid() = id);

create policy "Users can update their own data"
  on public.users for update
  using (auth.uid() = id); 