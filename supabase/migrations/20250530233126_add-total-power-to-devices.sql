-- Add the total_power column to the devices table
ALTER TABLE devices
ADD COLUMN total_power DOUBLE PRECISION DEFAULT 0;

-- Create a function that updates total_power
CREATE OR REPLACE FUNCTION update_device_total_power()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE devices
  SET total_power = total_power + NEW.power_watts
  WHERE id = NEW.device_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Trigger is created in migration 20250530233125_update_total_power_trigger.sql
