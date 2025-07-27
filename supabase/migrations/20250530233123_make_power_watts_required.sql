-- Make power_watts column required in power_readings table
ALTER TABLE public.power_readings
ALTER COLUMN power_watts SET NOT NULL; 