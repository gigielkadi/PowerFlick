-- Create rooms table
create table if not exists public.rooms (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    user_id uuid references public.users(id) on delete cascade,
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create devices table
create table if not exists public.devices (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    type text not null,
    status text not null default 'offline',
    room_id uuid references public.rooms(id) on delete set null,
    user_id uuid references public.users(id) on delete cascade,
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    last_connected timestamp with time zone,
    metadata jsonb default '{}'::jsonb
);

-- Create device_logs table for tracking device state changes
create table if not exists public.device_logs (
    id uuid primary key default gen_random_uuid(),
    device_id uuid references public.devices(id) on delete cascade,
    event_type text not null,
    event_data jsonb default '{}'::jsonb,
    created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create automations table
create table if not exists public.automations (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    user_id uuid references public.users(id) on delete cascade,
    trigger_type text not null,
    trigger_config jsonb default '{}'::jsonb,
    action_type text not null,
    action_config jsonb default '{}'::jsonb,
    is_active boolean default true,
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Create automation_logs table
create table if not exists public.automation_logs (
    id uuid primary key default gen_random_uuid(),
    automation_id uuid references public.automations(id) on delete cascade,
    status text not null,
    error_message text,
    created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Add updated_at triggers for all tables
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$ language plpgsql;

create trigger set_rooms_updated_at
    before update on public.rooms
    for each row
    execute function public.handle_updated_at();

create trigger set_devices_updated_at
    before update on public.devices
    for each row
    execute function public.handle_updated_at();

create trigger set_automations_updated_at
    before update on public.automations
    for each row
    execute function public.handle_updated_at();

-- Enable Row Level Security
alter table public.rooms enable row level security;
alter table public.devices enable row level security;
alter table public.device_logs enable row level security;
alter table public.automations enable row level security;
alter table public.automation_logs enable row level security;

-- Create RLS policies for rooms
create policy "Users can view their own rooms"
    on public.rooms for select
    using (auth.uid() = user_id);

create policy "Users can insert their own rooms"
    on public.rooms for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own rooms"
    on public.rooms for update
    using (auth.uid() = user_id);

create policy "Users can delete their own rooms"
    on public.rooms for delete
    using (auth.uid() = user_id);

-- Create RLS policies for devices
create policy "Users can view their own devices"
    on public.devices for select
    using (auth.uid() = user_id);

create policy "Users can insert their own devices"
    on public.devices for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own devices"
    on public.devices for update
    using (auth.uid() = user_id);

create policy "Users can delete their own devices"
    on public.devices for delete
    using (auth.uid() = user_id);

-- Create RLS policies for device_logs
create policy "Users can view their device logs"
    on public.device_logs for select
    using (exists (
        select 1 from public.devices
        where devices.id = device_logs.device_id
        and devices.user_id = auth.uid()
    ));

-- Create RLS policies for automations
create policy "Users can view their own automations"
    on public.automations for select
    using (auth.uid() = user_id);

create policy "Users can insert their own automations"
    on public.automations for insert
    with check (auth.uid() = user_id);

create policy "Users can update their own automations"
    on public.automations for update
    using (auth.uid() = user_id);

create policy "Users can delete their own automations"
    on public.automations for delete
    using (auth.uid() = user_id);

-- Create RLS policies for automation_logs
create policy "Users can view their automation logs"
    on public.automation_logs for select
    using (exists (
        select 1 from public.automations
        where automations.id = automation_logs.automation_id
        and automations.user_id = auth.uid()
    ));

-- Create indexes for better query performance
create index if not exists idx_devices_user_id on public.devices(user_id);
create index if not exists idx_devices_room_id on public.devices(room_id);
create index if not exists idx_rooms_user_id on public.rooms(user_id);
create index if not exists idx_device_logs_device_id on public.device_logs(device_id);
create index if not exists idx_automations_user_id on public.automations(user_id);
create index if not exists idx_automation_logs_automation_id on public.automation_logs(automation_id); 