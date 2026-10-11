-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: FAB LAB BOOKINGS, CREDENTIALS & SCHEMA UPDATES
-- Migration: 20261011_000003_fablab_and_auth_updates.sql
-- ====================================================================

-- 1. Remove CGPA column completely from profiles
ALTER TABLE IF EXISTS public.profiles DROP COLUMN IF EXISTS cgpa;

-- 2. Update equipment_bookings table for Fab Lab tracking & auto-cancellation
-- Add checked_in, checked_in_at, cancelled_reason, and booked_by_staff columns
ALTER TABLE IF EXISTS public.equipment_bookings
    ADD COLUMN IF NOT EXISTS checked_in BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS checked_in_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS cancelled_reason TEXT,
    ADD COLUMN IF NOT EXISTS booked_by_staff BOOLEAN NOT NULL DEFAULT FALSE;

-- Drop old check constraint on status and update with extended statuses
ALTER TABLE IF EXISTS public.equipment_bookings
    DROP CONSTRAINT IF EXISTS equipment_bookings_status_check;

ALTER TABLE IF EXISTS public.equipment_bookings
    ADD CONSTRAINT equipment_bookings_status_check
    CHECK (status IN ('CONFIRMED', 'CHECKED_IN', 'AUTO_CANCELLED', 'CANCELLED', 'COMPLETED'));

-- 3. Update RLS policies on equipment_bookings to grant lab staff & admin full management
DROP POLICY IF EXISTS "Allow student insert bookings" ON public.equipment_bookings;
DROP POLICY IF EXISTS "Allow student cancel own booking" ON public.equipment_bookings;
DROP POLICY IF EXISTS "Allow lab staff and admin manage bookings" ON public.equipment_bookings;

-- Allow students to book for themselves, and lab staff/admins to create bookings for any student
CREATE POLICY "Allow student and staff insert bookings"
    ON public.equipment_bookings FOR INSERT
    TO authenticated
    WITH CHECK (
        auth.uid() = student_id OR
        public.is_admin() OR
        public.is_lab_staff()
    );

-- Allow students to cancel their own bookings, and lab staff/admins to update (check-in, cancel, auto-cancel)
CREATE POLICY "Allow booking update and checkin"
    ON public.equipment_bookings FOR UPDATE
    TO authenticated
    USING (
        auth.uid() = student_id OR
        public.is_admin() OR
        public.is_lab_staff()
    )
    WITH CHECK (
        auth.uid() = student_id OR
        public.is_admin() OR
        public.is_lab_staff()
    );

-- Allow lab staff and admins to delete bookings if necessary
CREATE POLICY "Allow staff and admin delete bookings"
    ON public.equipment_bookings FOR DELETE
    TO authenticated
    USING (
        public.is_admin() OR
        public.is_lab_staff()
    );

-- 4. PostgreSQL Stored Procedure for Auto-Cancelling No-Shows (15-min grace period)
-- Slots format e.g. '8:00 am - 8:50 am' or '08:00 AM - 08:50 AM'
CREATE OR REPLACE FUNCTION public.auto_cancel_no_show_bookings()
RETURNS INTEGER AS $$
DECLARE
    cancelled_count INTEGER := 0;
    r RECORD;
    slot_time_str TEXT;
    start_time_val TIME;
    slot_start_timestamp TIMESTAMPTZ;
BEGIN
    FOR r IN
        SELECT id, date, slot
        FROM public.equipment_bookings
        WHERE status = 'CONFIRMED'
          AND checked_in = FALSE
          AND date = CURRENT_DATE
    LOOP
        -- Extract start time from string like '8:00 am - 8:50 am'
        slot_time_str := trim(split_part(r.slot, '-', 1));
        BEGIN
            start_time_val := to_timestamp(slot_time_str, 'HH:MI am')::time;
            slot_start_timestamp := (r.date + start_time_val) AT TIME ZONE 'Asia/Kolkata';

            -- Check if 15 minutes have passed since the slot start time
            IF now() > (slot_start_timestamp + interval '15 minutes') THEN
                UPDATE public.equipment_bookings
                SET status = 'AUTO_CANCELLED',
                    cancelled_reason = 'Auto-cancelled: Student did not show up within the 15-minute grace period.'
                WHERE id = r.id;

                cancelled_count := cancelled_count + 1;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            -- Ignore formatting parse errors for non-standard slots
            NULL;
        END;
    END LOOP;

    RETURN cancelled_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Optional pg_cron schedule if pg_cron extension is active (runs every 5 minutes)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        PERFORM cron.schedule(
            'fablab-auto-cancellation',
            '*/5 * * * *',
            'SELECT public.auto_cancel_no_show_bookings();'
        );
    END IF;
END $$;
