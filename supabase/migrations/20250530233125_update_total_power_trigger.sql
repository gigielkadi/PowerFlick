-- Migration: Update trigger to sum power_kwh into devices.total_power

CREATE OR REPLACE FUNCTION update_device_total_power()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE devices
  SET total_power = total_power + NEW.power_kwh
  WHERE id = NEW.device_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS power_reading_insert_trigger ON power_readings;
CREATE TRIGGER power_reading_insert_trigger
AFTER INSERT ON power_readings
FOR EACH ROW
EXECUTE FUNCTION update_device_total_power(); 