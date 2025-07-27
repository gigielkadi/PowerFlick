-- Create power consumption table
CREATE TABLE IF NOT EXISTS power_consumption (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    consumption DOUBLE PRECISION NOT NULL,
    predicted_consumption DOUBLE PRECISION,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on device_id and timestamp
CREATE INDEX IF NOT EXISTS idx_power_consumption_device_timestamp 
ON power_consumption(device_id, timestamp);

-- Create anomaly alerts table
CREATE TABLE IF NOT EXISTS anomaly_alerts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    deviation_percentage DOUBLE PRECISION NOT NULL,
    type TEXT NOT NULL,
    severity TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on device_id and timestamp for anomaly alerts
CREATE INDEX IF NOT EXISTS idx_anomaly_alerts_device_timestamp 
ON anomaly_alerts(device_id, timestamp);

-- Create model metrics table
CREATE TABLE IF NOT EXISTS model_metrics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    mse DOUBLE PRECISION NOT NULL,
    rmse DOUBLE PRECISION NOT NULL,
    mae DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on device_id and timestamp for model metrics
CREATE INDEX IF NOT EXISTS idx_model_metrics_device_timestamp 
ON model_metrics(device_id, timestamp);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers to all tables
CREATE TRIGGER update_power_consumption_updated_at
    BEFORE UPDATE ON power_consumption
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_anomaly_alerts_updated_at
    BEFORE UPDATE ON anomaly_alerts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_model_metrics_updated_at
    BEFORE UPDATE ON model_metrics
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 