-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: SYNC AUTH USERS TO PROFILES
-- Migration: 20261011_000009_sync_auth_users_to_profiles.sql
-- ====================================================================

-- This migration creates profiles for existing Auth users who don't have profiles yet

-- Function to sync auth users to profiles
CREATE OR REPLACE FUNCTION public.sync_auth_users_to_profiles()
RETURNS void AS $$
BEGIN
    -- Insert profiles for auth users that don't have profiles
    INSERT INTO public.profiles (id, full_name, email, role, department, created_at)
    SELECT
        au.id,
        COALESCE(au.raw_user_meta_data->>'full_name', au.email, 'User'),
        au.email,
        COALESCE(au.raw_user_meta_data->>'role', 'STUDENT'),
        COALESCE(au.raw_user_meta_data->>'department', 'CSE'),
        au.created_at
    FROM auth.users au
    LEFT JOIN public.profiles p ON p.id = au.id
    WHERE p.id IS NULL;
END;
$$ LANGUAGE plpgsql;

-- Run the sync function
SELECT public.sync_auth_users_to_profiles();

-- Drop the function after use
DROP FUNCTION IF EXISTS public.sync_auth_users_to_profiles();
