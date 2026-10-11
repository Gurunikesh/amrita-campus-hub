-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: CLASSROOM ALLOCATION COORDINATOR SYNC
-- Migration: 20261011_000007_classroom_allocation_sync.sql
-- ====================================================================

-- 1. Ensure classrooms table has proper department filtering support
-- (Already exists in initial schema, just ensuring index for performance)
CREATE INDEX IF NOT EXISTS idx_classrooms_department ON public.classrooms(department);

-- 2. Ensure coordinators can view classrooms allocated to their department
-- Note: This policy will be replaced with a more specific one in migration 000008
DROP POLICY IF EXISTS "Allow authenticated read classrooms" ON public.classrooms;

CREATE POLICY "Allow authenticated read classrooms"
    ON public.classrooms FOR SELECT
    TO authenticated
    USING (TRUE);

-- 3. Allow admins to update classroom department allocation
-- Note: Coordinator-specific policy will be added in migration 000008
DROP POLICY IF EXISTS "Allow admin update classrooms" ON public.classrooms;

CREATE POLICY "Allow admin update classrooms"
    ON public.classrooms FOR UPDATE
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());
