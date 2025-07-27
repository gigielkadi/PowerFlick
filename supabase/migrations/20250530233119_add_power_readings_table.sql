CREATE TABLE public.power_readings (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    device_id uuid NOT NULL,
    power_watts double precision,
    energy_kwh double precision,
    timestamp timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    metadata jsonb,
    created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
    CONSTRAINT power_readings_pkey PRIMARY KEY (id),
    CONSTRAINT fk_device
        FOREIGN KEY (device_id)
        REFERENCES public.devices (id)
        ON DELETE CASCADE
);

ALTER TABLE public.power_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to insert power_readings" ON public.power_readings
FOR INSERT
TO authenticated
WITH CHECK (true);
