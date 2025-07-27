-- Add relay_state column to devices table
ALTER TABLE public.devices
ADD COLUMN relay_state BOOLEAN DEFAULT FALSE; 