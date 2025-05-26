-- Add additional user fields for signup
alter table public.users
    add column if not exists first_name text,
    add column if not exists last_name text,
    add column if not exists phone_number text,
    add column if not exists address text,
    add column if not exists city text,
    add column if not exists country text,
    add column if not exists postal_code text,
    add column if not exists timezone text default 'UTC',
    add column if not exists language text default 'en',
    add column if not exists notification_preferences jsonb default '{
        "email": true,
        "push": true,
        "sms": false
    }'::jsonb,
    add column if not exists signup_source text,
    add column if not exists signup_date timestamp with time zone default timezone('utc'::text, now()),
    add column if not exists last_login timestamp with time zone,
    add column if not exists is_active boolean default true,
    add column if not exists updated_at timestamp with time zone default timezone('utc'::text, now());

-- Create a trigger to update the updated_at timestamp
create trigger set_users_updated_at
    before update on public.users
    for each row
    execute function public.handle_updated_at();

-- Create a function to handle user creation
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.users (id, email, first_name, last_name, signup_source)
    values (
        new.id,
        new.email,
        new.raw_user_meta_data->>'first_name',
        new.raw_user_meta_data->>'last_name',
        new.raw_user_meta_data->>'signup_source'
    );
    return new;
end;
$$ language plpgsql security definer;

-- Create a trigger to automatically create user profile
create trigger on_auth_user_created
    after insert on auth.users
    for each row
    execute function public.handle_new_user();

-- Create indexes for better query performance
create index if not exists idx_users_email on public.users(email);
create index if not exists idx_users_phone on public.users(phone_number);
create index if not exists idx_users_signup_date on public.users(signup_date); 