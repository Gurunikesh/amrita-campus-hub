-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: DEDICATED COORDINATOR CREDENTIALS
-- Migration: 20261011_000008_coordinator_separate_credentials.sql
-- ====================================================================

-- 1. Ensure coordinator role is fully supported as a standalone role
-- (Already supported in initial schema, ensuring RLS policies are correct)

-- 2. Update coordinator function to include DEPT_COORDINATOR explicitly
DROP FUNCTION IF EXISTS public.is_coordinator CASCADE;

CREATE OR REPLACE FUNCTION public.is_coordinator()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'DEPT_COORDINATOR'
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 3. Ensure coordinators can be managed as independent users
-- The departments table coordinator field stores the coordinator's name/reference
-- This allows a coordinator to be a separate account from a faculty account

-- 4. Update departments table to allow coordinator assignment by profile ID instead of just name
-- (Adding column for better reference while keeping name for backward compatibility)
ALTER TABLE IF EXISTS public.departments
    ADD COLUMN IF NOT EXISTS coordinator_id UUID REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE SET NULL;

-- 5. Update existing coordinator assignments to populate coordinator_id
UPDATE public.departments d
SET coordinator_id = (SELECT id FROM public.profiles WHERE full_name = d.coordinator LIMIT 1)
WHERE coordinator_id IS NULL AND coordinator IS NOT NULL;

-- 6. Create index for coordinator-based lookups
CREATE INDEX IF NOT EXISTS idx_departments_coordinator_id ON public.departments(coordinator_id);

-- 7. Ensure coordinator-specific RLS policies work correctly
DROP POLICY IF EXISTS "Allow coordinator assign advisors" ON public.profiles;

CREATE POLICY "Allow coordinator assign advisors"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (public.is_coordinator() OR public.is_admin())
    WITH CHECK (public.is_coordinator() OR public.is_admin());

-- 8. Allow coordinators to manage their department's classrooms
DROP POLICY IF EXISTS "Allow coordinator update classroom department" ON public.classrooms;

CREATE POLICY "Allow coordinator update classroom department"
    ON public.classrooms FOR UPDATE
    TO authenticated
    USING (
        public.is_coordinator() AND 
        department = (SELECT department FROM public.profiles WHERE id = auth.uid())
    )
    WITH CHECK (
        public.is_coordinator() AND 
        department = (SELECT department FROM public.profiles WHERE id = auth.uid())
    );
