-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    birthdate DATE,
    home_type TEXT,
    household_size INTEGER,
    priorities TEXT[],
    rooms JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Homes table
CREATE TABLE homes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users NOT NULL,
    rooms JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Devices table
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    room_id UUID,
    status BOOLEAN DEFAULT false,
    power_consumption FLOAT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- MCP Messages table
CREATE TABLE mcp_messages (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    sender_id VARCHAR(100) NOT NULL,
    content JSONB NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Row Level Security Policies

-- Profiles table policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- Homes table policies
ALTER TABLE homes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own homes"
    ON homes FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own homes"
    ON homes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own homes"
    ON homes FOR UPDATE
    USING (auth.uid() = user_id);

-- Devices table policies
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view devices in their homes"
    ON devices FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM homes
            WHERE homes.user_id = auth.uid()
            AND homes.id = devices.room_id
        )
    );

CREATE POLICY "Users can insert devices in their homes"
    ON devices FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM homes
            WHERE homes.user_id = auth.uid()
            AND homes.id = devices.room_id
        )
    );

CREATE POLICY "Users can update devices in their homes"
    ON devices FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM homes
            WHERE homes.user_id = auth.uid()
            AND homes.id = devices.room_id
        )
    );

-- Functions

-- Function to create profiles table if it doesn't exist
CREATE OR REPLACE FUNCTION create_profiles_table()
RETURNS void AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles') THEN
        CREATE TABLE profiles (
            id UUID PRIMARY KEY REFERENCES auth.users,
            email TEXT UNIQUE NOT NULL,
            name TEXT,
            birthdate DATE,
            home_type TEXT,
            household_size INTEGER,
            priorities TEXT[],
            rooms JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update user profile
CREATE OR REPLACE FUNCTION update_user_profile(
    p_id UUID,
    p_name TEXT,
    p_birthdate DATE,
    p_home_type TEXT,
    p_household_size INTEGER,
    p_priorities TEXT[],
    p_rooms JSONB
)
RETURNS void AS $$
BEGIN
    UPDATE profiles
    SET
        name = p_name,
        birthdate = p_birthdate,
        home_type = p_home_type,
        household_size = p_household_size,
        priorities = p_priorities,
        rooms = p_rooms,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql; 