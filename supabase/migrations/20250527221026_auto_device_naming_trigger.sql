-- Migration: Auto device naming trigger and function

-- 1. Create or replace the function
CREATE OR REPLACE FUNCTION public.set_device_name()
RETURNS TRIGGER AS $$
DECLARE
  device_count INTEGER;
BEGIN
  -- Count existing devices of the same type in the same room
  SELECT COUNT(*) INTO device_count
  FROM public.devices
  WHERE type = NEW.type AND room_id = NEW.room_id;

  -- Set the name as "Type N"
  NEW.name := NEW.type || ' ' || (device_count + 1);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Drop the trigger if it exists (for idempotency)
DROP TRIGGER IF EXISTS before_insert_device ON public.devices;

-- 3. Create the trigger
CREATE TRIGGER before_insert_device
BEFORE INSERT ON public.devices
FOR EACH ROW
EXECUTE FUNCTION public.set_device_name(); 