-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: LAB INCHARGE REQUEST ROUTING
-- Migration: 20261011_000005_lab_incharge_routing.sql
-- ====================================================================

-- 1. Add lab_id foreign key to resource_requests for proper routing
ALTER TABLE IF EXISTS public.resource_requests
    ADD COLUMN IF NOT EXISTS lab_id TEXT REFERENCES public.labs(id) ON UPDATE CASCADE ON DELETE SET NULL;

-- 2. Update existing resource_requests to populate lab_id based on lab_name
UPDATE public.resource_requests rr
SET lab_id = (SELECT id FROM public.labs WHERE name = rr.lab_name LIMIT 1)
WHERE lab_id IS NULL AND lab_name IS NOT NULL;

-- 3. Create index for efficient lab-based queries
CREATE INDEX IF NOT EXISTS idx_resource_requests_lab_id ON public.resource_requests(lab_id);

-- 4. Update RLS policies to allow lab staff to see requests for their labs
DROP POLICY IF EXISTS "Allow faculty, staff, admin update resource requests" ON public.resource_requests;

CREATE POLICY "Allow faculty, staff, admin update resource requests"
    ON public.resource_requests FOR UPDATE
    TO authenticated
    USING (
        public.is_admin() OR 
        public.is_lab_staff() OR 
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('FACULTY', 'DEPT_COORDINATOR'))
    )
    WITH CHECK (
        public.is_admin() OR 
        public.is_lab_staff() OR 
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('FACULTY', 'DEPT_COORDINATOR'))
    );
