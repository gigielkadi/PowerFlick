-- Enable RLS on power_readings table
ALTER TABLE public.power_readings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow anonymous insert" ON public.power_readings;
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON public.power_readings;

-- Create new policy for anonymous insert
CREATE POLICY "Allow anonymous insert"
ON public.power_readings
FOR INSERT
TO anon
WITH CHECK (true);

-- Create policy for authenticated users to read their own data
CREATE POLICY "Allow users to read their own data"
ON public.power_readings
FOR SELECT
TO authenticated
USING (device_id IN (
    SELECT id FROM public.devices 
    WHERE user_id = auth.uid()
)); 