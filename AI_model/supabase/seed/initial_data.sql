-- Insert sample power consumption data
INSERT INTO power_consumption (device_id, timestamp, consumption)
SELECT
    'device_001',
    NOW() - INTERVAL '1 hour' * generate_series(0, 167),  -- Last 7 days of hourly data
    -- Generate random consumption values between 0.5 and 2.0 kWh
    -- with a daily pattern (higher during day, lower at night)
    0.5 + random() * 1.5 * (
        1 + 0.5 * sin(
            extract(hour from NOW() - INTERVAL '1 hour' * generate_series(0, 167))::float * pi() / 12
        )
    )
ORDER BY timestamp DESC;

-- Insert sample anomaly alerts
INSERT INTO anomaly_alerts (device_id, timestamp, value, deviation_percentage, type, severity)
VALUES
    ('device_001', NOW() - INTERVAL '2 hours', 2.8, 75.5, 'high_deviation', 'high'),
    ('device_001', NOW() - INTERVAL '12 hours', 0.2, 65.2, 'low_deviation', 'medium'),
    ('device_001', NOW() - INTERVAL '1 day', 2.5, 55.8, 'high_deviation', 'medium');

-- Insert sample model metrics
INSERT INTO model_metrics (device_id, timestamp, mse, rmse, mae, accuracy)
VALUES
    ('device_001', NOW(), 0.0225, 0.15, 0.12, 0.85); 