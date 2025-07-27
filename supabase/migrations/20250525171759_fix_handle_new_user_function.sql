-- Fix handle_new_user function to match current users table
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.users (id, email, first_name, last_name)
    values (
        new.id,
        new.email,
        new.raw_user_meta_data->>'first_name',
        new.raw_user_meta_data->>'last_name'
    );
    return new;
end;
$$ language plpgsql security definer; 