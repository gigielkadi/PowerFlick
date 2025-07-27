-- Migration: Add power_kwh column to power_readings
ALTER TABLE power_readings
ADD COLUMN power_kwh DOUBLE PRECISION DEFAULT 0; 