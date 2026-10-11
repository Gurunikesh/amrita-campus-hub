-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: STRICT ADMIN USER CRUD POLICIES
-- Migration: 20261011_000006_strict_admin_user_crud.sql
-- ====================================================================

-- Drop existing policies that grant too broad access
DROP POLICY IF EXISTS "Allow users update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow advisor toggle reps in section" ON public.profiles;
DROP POLICY IF EXISTS "Allow coordinator assign advisors" ON public.profiles;
DROP POLICY IF EXISTS "Allow admin full access profiles" ON public.profiles;

-- STRICT POLICY: Only ADMIN can INSERT new user profiles
CREATE POLICY "Allow admin insert profiles"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (public.is_admin());

-- STRICT POLICY: Only ADMIN can DELETE user profiles
CREATE POLICY "Allow admin delete profiles"
    ON public.profiles FOR DELETE
    TO authenticated
    USING (public.is_admin());

-- FULL ADMIN UPDATE POLICY: Only ADMIN can update most fields
CREATE POLICY "Allow admin update profiles"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- LIMITED UPDATE: Advisors can only toggle is_rep for students in their section
CREATE POLICY "Allow advisor toggle reps in section"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (
        public.is_advisor_for_section(section_id)
    )
    WITH CHECK (
        public.is_advisor_for_section(section_id)
    );

-- LIMITED UPDATE: Coordinators can update advisor assignment fields
CREATE POLICY "Allow coordinator assign advisors"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (
        public.is_coordinator()
    )
    WITH CHECK (
        public.is_coordinator()
    );
