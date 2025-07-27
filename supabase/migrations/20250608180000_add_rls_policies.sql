-- Devices table policies

-- Allow users to view their own devices
CREATE POLICY IF NOT EXISTS "Users can view their own devices"
ON public.devices
FOR SELECT
TO public
USING (auth.uid() = user_id);

-- Allow users to insert their own devices
CREATE POLICY IF NOT EXISTS "Users can insert their own devices"
ON public.devices
FOR INSERT
TO public
WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own devices
CREATE POLICY IF NOT EXISTS "Users can update their own devices"
ON public.devices
FOR UPDATE
TO public
USING (auth.uid() = user_id);

-- Allow users to delete their own devices
CREATE POLICY IF NOT EXISTS "Users can delete their own devices"
ON public.devices
FOR DELETE
TO public
USING (auth.uid() = user_id);

-- Allow anonymous read
CREATE POLICY IF NOT EXISTS "Allow anonymous read"
ON public.devices
FOR SELECT
TO anon
USING (true);

-- power_readings table policies

-- Allow authenticated users to insert power_readings
CREATE POLICY IF NOT EXISTS "Allow authenticated users to insert power_readings"
ON public.power_readings
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow anonymous insert
CREATE POLICY IF NOT EXISTS "Allow anonymous insert"
ON public.power_readings
FOR INSERT
TO anon
WITH CHECK (true);

-- Allow users to read their own data
CREATE POLICY IF NOT EXISTS "Allow users to read their own data"
ON public.power_readings
FOR SELECT
TO authenticated
USING (
  device_id IN (
    SELECT devices.id FROM devices WHERE devices.user_id = auth.uid()
  )
); 