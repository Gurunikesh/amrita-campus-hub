-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: ROLE ACCESS, PERMISSIONS & SYNCHRONIZATION
-- Migration: 20261011_000004_role_transitions_and_access_control.sql
-- ====================================================================

-- 1. Ensure RLS policies on profiles:
-- Clean up any existing policies (including Strict admin full access profiles if previously applied)
DROP POLICY IF EXISTS "Strict admin full access profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow admin full access profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow coordinator assign advisors" ON public.profiles;

-- Admin has full access to add, edit, and delete any user profile
CREATE POLICY "Allow admin full access profiles"
    ON public.profiles FOR ALL
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- Coordinator and admin can update faculty advisory assignment fields
CREATE POLICY "Allow coordinator assign advisors"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (public.is_coordinator() OR public.is_admin())
    WITH CHECK (public.is_coordinator() OR public.is_admin());

-- 2. Allow coordinator & admin manage sections (assign advisors, update advisor field)
DROP POLICY IF EXISTS "Allow coordinator manage sections" ON public.sections;
CREATE POLICY "Allow coordinator manage sections"
    ON public.sections FOR ALL
    TO authenticated
    USING (public.is_coordinator() OR public.is_admin())
    WITH CHECK (public.is_coordinator() OR public.is_admin());

-- 3. Allow coordinator & admin manage labs (assign lab in-charge)
DROP POLICY IF EXISTS "Allow coordinator manage labs" ON public.labs;
CREATE POLICY "Allow coordinator manage labs"
    ON public.labs FOR ALL
    TO authenticated
    USING (public.is_coordinator() OR public.is_admin())
    WITH CHECK (public.is_coordinator() OR public.is_admin());

-- 4. Allow coordinator & admin manage classrooms (allot to departments, free rooms lookup)
DROP POLICY IF EXISTS "Allow coordinator manage classrooms" ON public.classrooms;
CREATE POLICY "Allow coordinator manage classrooms"
    ON public.classrooms FOR ALL
    TO authenticated
    USING (public.is_coordinator() OR public.is_admin())
    WITH CHECK (public.is_coordinator() OR public.is_admin());

-- 5. Seed dedicated coordinator portal user profile in profiles table
INSERT INTO public.profiles (
    id, email, full_name, role, department, designation, status
)
VALUES (
    '00000000-0000-0000-0000-000000000002',
    'coordinator@amrita.edu',
    'Department Coordinator',
    'DEPT_COORDINATOR',
    'CSE',
    'Department Academic Coordinator',
    'active'
)
ON CONFLICT (email) DO UPDATE
SET role = 'DEPT_COORDINATOR',
    full_name = EXCLUDED.full_name,
    department = EXCLUDED.department,
    status = 'active';

-- 6. Ensure admin profile exists with full rights
INSERT INTO public.profiles (
    id, email, full_name, role, department, designation, status
)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'admin@amrita.edu',
    'System Administrator',
    'ADMIN',
    'ADMIN',
    'System Administrator',
    'active'
)
ON CONFLICT (email) DO UPDATE
SET role = 'ADMIN',
    status = 'active';
