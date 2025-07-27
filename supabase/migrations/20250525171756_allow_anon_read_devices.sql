-- Allow anonymous read access to the devices table
CREATE POLICY "Allow anonymous read" ON public.devices
FOR SELECT
TO anon
USING (true); 