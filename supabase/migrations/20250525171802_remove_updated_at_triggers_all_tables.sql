-- Drop all triggers that use handle_updated_at
DROP TRIGGER IF EXISTS set_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS set_updated_at ON public.users;
DROP TRIGGER IF EXISTS set_rooms_updated_at ON public.rooms;
DROP TRIGGER IF EXISTS set_devices_updated_at ON public.devices;
DROP TRIGGER IF EXISTS set_automations_updated_at ON public.automations;

-- Now drop the function
DROP FUNCTION IF EXISTS public.handle_updated_at(); 