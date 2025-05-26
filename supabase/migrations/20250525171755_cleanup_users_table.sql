-- Clean up users table: remove unnecessary columns
alter table public.users
  drop column if exists connected_devices,
  drop column if exists number_of_rooms,
  drop column if exists full_name,
  drop column if exists address,
  drop column if exists city,
  drop column if exists country,
  drop column if exists postal_code,
  drop column if exists timezone,
  drop column if exists language,
  drop column if exists notification_preferences,
  drop column if exists signup_source,
  drop column if exists signup_date,
  drop column if exists last_login,
  drop column if exists is_active,
  drop column if exists updated_at; 