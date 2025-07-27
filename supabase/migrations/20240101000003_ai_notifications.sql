-- Create user FCM tokens table for push notifications
CREATE TABLE IF NOT EXISTS user_fcm_tokens (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, fcm_token)
);

-- Create energy spike logs table
CREATE TABLE IF NOT EXISTS energy_spike_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    current_power DOUBLE PRECISION NOT NULL,
    average_power DOUBLE PRECISION NOT NULL,
    spike_percentage INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create cost warning logs table
CREATE TABLE IF NOT EXISTS cost_warning_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    device_id TEXT NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    current_cost DOUBLE PRECISION NOT NULL,
    projected_cost DOUBLE PRECISION NOT NULL,
    threshold DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create notification preferences table
CREATE TABLE IF NOT EXISTS notification_preferences (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    energy_spike_threshold DOUBLE PRECISION DEFAULT 2.0,
    cost_threshold DOUBLE PRECISION DEFAULT 50.0,
    notifications_enabled BOOLEAN DEFAULT true,
    energy_spike_enabled BOOLEAN DEFAULT true,
    anomaly_detection_enabled BOOLEAN DEFAULT true,
    cost_threshold_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create alert history table
CREATE TABLE IF NOT EXISTS alert_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    alert_type TEXT NOT NULL CHECK (alert_type IN ('energy_spike', 'anomaly', 'cost_threshold')),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('low', 'medium', 'high')),
    data JSONB,
    acknowledged BOOLEAN DEFAULT false,
    acknowledged_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_energy_spike_logs_device_timestamp ON energy_spike_logs(device_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_cost_warning_logs_device_timestamp ON cost_warning_logs(device_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_notification_preferences_user_id ON notification_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_alert_history_user_device ON alert_history(user_id, device_id);
CREATE INDEX IF NOT EXISTS idx_alert_history_type_created ON alert_history(alert_type, created_at);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_fcm_tokens_updated_at
    BEFORE UPDATE ON user_fcm_tokens
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default notification preferences for existing users
INSERT INTO notification_preferences (user_id)
SELECT id FROM auth.users
WHERE id NOT IN (SELECT user_id FROM notification_preferences)
ON CONFLICT (user_id) DO NOTHING;

-- Enable Row Level Security (RLS)
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE energy_spike_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE cost_warning_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE alert_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only access their own FCM tokens
CREATE POLICY "Users can manage their own FCM tokens" ON user_fcm_tokens
    FOR ALL USING (auth.uid() = user_id);

-- Users can only access their own notification preferences
CREATE POLICY "Users can manage their own notification preferences" ON notification_preferences
    FOR ALL USING (auth.uid() = user_id);

-- Users can only access their own alert history
CREATE POLICY "Users can manage their own alert history" ON alert_history
    FOR ALL USING (auth.uid() = user_id);

-- Energy spike logs and cost warning logs can be accessed by authenticated users
-- (these might be accessed by system/admin users for analytics)
CREATE POLICY "Authenticated users can read energy spike logs" ON energy_spike_logs
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can read cost warning logs" ON cost_warning_logs
    FOR SELECT USING (auth.role() = 'authenticated');

-- Service role can insert into all tables (for system notifications)
CREATE POLICY "Service role can insert energy spike logs" ON energy_spike_logs
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service role can insert cost warning logs" ON cost_warning_logs
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service role can insert alert history" ON alert_history
    FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role; 