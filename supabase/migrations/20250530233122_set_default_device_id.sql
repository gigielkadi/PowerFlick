-- Set default device_id for power_readings table
ALTER TABLE public.power_readings
ALTER COLUMN device_id SET DEFAULT 'f75ddda7-4495-473c-8ac4-9a0b3aed11ad'; 