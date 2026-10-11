-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: ROW LEVEL SECURITY (RLS) POLICIES
-- Migration: 20261011_000002_rls_policies.sql
-- ====================================================================

-- 1. Helper Security Functions (SECURITY DEFINER to avoid RLS recursion)
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'ADMIN'
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_coordinator()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND (role = 'DEPT_COORDINATOR' OR role = 'ADMIN')
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_advisor_for_section(target_sec TEXT)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND is_advisor = TRUE AND advisory_section = target_sec
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_lab_staff()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND (role = 'LAB_STAFF' OR role = 'ADMIN')
    );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 2. Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campus_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classrooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.labs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timetable ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.club_memberships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hackathon_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hackathon_join_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incubation_schemes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.incubation_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- --------------------------------------------------------------------
-- PROFILES POLICIES
-- --------------------------------------------------------------------
-- Anyone authenticated can view user profiles (needed for student directory, faculty lists, lab in-charges)
CREATE POLICY "Allow authenticated read profiles"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (TRUE);

-- Admin can insert, update, delete any profile
CREATE POLICY "Allow admin full access profiles"
    ON public.profiles FOR ALL
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- Users can update their own profile (skills, phone)
CREATE POLICY "Allow users update own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Class Advisors can update is_rep flag for students in their assigned section
CREATE POLICY "Allow advisor toggle reps in section"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (
        public.is_advisor_for_section(section_id)
    )
    WITH CHECK (
        public.is_advisor_for_section(section_id)
    );

-- Coordinators can update faculty advisory assignment fields
CREATE POLICY "Allow coordinator assign advisors"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (public.is_coordinator())
    WITH CHECK (public.is_coordinator());

-- --------------------------------------------------------------------
-- DEPARTMENTS, BLOCKS, CLASSROOMS POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read departments"
    ON public.departments FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin manage departments"
    ON public.departments FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Allow coordinator update department"
    ON public.departments FOR UPDATE TO authenticated
    USING (public.is_coordinator()) WITH CHECK (public.is_coordinator());

CREATE POLICY "Allow authenticated read blocks"
    ON public.campus_blocks FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin manage blocks"
    ON public.campus_blocks FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Allow authenticated read classrooms"
    ON public.classrooms FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin manage classrooms"
    ON public.classrooms FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

-- --------------------------------------------------------------------
-- SECTIONS POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read sections"
    ON public.sections FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin manage sections"
    ON public.sections FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Allow coordinator manage sections"
    ON public.sections FOR ALL TO authenticated
    USING (public.is_coordinator()) WITH CHECK (public.is_coordinator());

-- --------------------------------------------------------------------
-- LABS & EQUIPMENT POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read labs"
    ON public.labs FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin manage labs"
    ON public.labs FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Allow coordinator manage labs"
    ON public.labs FOR ALL TO authenticated
    USING (public.is_coordinator()) WITH CHECK (public.is_coordinator());

CREATE POLICY "Allow authenticated read equipment"
    ON public.equipment FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin and staff manage equipment"
    ON public.equipment FOR ALL TO authenticated
    USING (public.is_admin() OR public.is_lab_staff())
    WITH CHECK (public.is_admin() OR public.is_lab_staff());

-- --------------------------------------------------------------------
-- EQUIPMENT BOOKINGS POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read bookings"
    ON public.equipment_bookings FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow student insert bookings"
    ON public.equipment_bookings FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = student_id OR public.is_admin());

CREATE POLICY "Allow student cancel own booking"
    ON public.equipment_bookings FOR UPDATE TO authenticated
    USING (auth.uid() = student_id OR public.is_admin() OR public.is_lab_staff())
    WITH CHECK (auth.uid() = student_id OR public.is_admin() OR public.is_lab_staff());

-- --------------------------------------------------------------------
-- INVENTORY & RESOURCE REQUESTS (INDENTS) POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read inventory"
    ON public.inventory FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin, staff and faculty manage inventory"
    ON public.inventory FOR ALL TO authenticated
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

CREATE POLICY "Allow authenticated read resource requests"
    ON public.resource_requests FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow student insert resource requests"
    ON public.resource_requests FOR INSERT TO authenticated
    WITH CHECK (TRUE);

CREATE POLICY "Allow faculty, staff, admin update resource requests"
    ON public.resource_requests FOR UPDATE TO authenticated
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

-- --------------------------------------------------------------------
-- TIMETABLE POLICIES (All faculty categories can view complete timetable)
-- --------------------------------------------------------------------
CREATE POLICY "Allow all authenticated read timetable"
    ON public.timetable FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow coordinator, admin, faculty manage timetable"
    ON public.timetable FOR ALL TO authenticated
    USING (
        public.is_admin() OR 
        public.is_coordinator() OR 
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'FACULTY')
    )
    WITH CHECK (
        public.is_admin() OR 
        public.is_coordinator() OR 
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'FACULTY')
    );

-- --------------------------------------------------------------------
-- CLUBS & MEMBERSHIPS POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read clubs"
    ON public.clubs FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin manage clubs"
    ON public.clubs FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Allow authenticated read club memberships"
    ON public.club_memberships FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow user manage own club membership"
    ON public.club_memberships FOR ALL TO authenticated
    USING (auth.uid() = user_id OR public.is_admin())
    WITH CHECK (auth.uid() = user_id OR public.is_admin());

-- --------------------------------------------------------------------
-- HACKATHON PROJECTS & JOIN REQUESTS POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read hackathons"
    ON public.hackathon_projects FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow students create hackathons"
    ON public.hackathon_projects FOR INSERT TO authenticated
    WITH CHECK (TRUE);

CREATE POLICY "Allow author manage hackathon"
    ON public.hackathon_projects FOR ALL TO authenticated
    USING (auth.uid() = author_id OR public.is_admin())
    WITH CHECK (auth.uid() = author_id OR public.is_admin());

CREATE POLICY "Allow authenticated read hackathon requests"
    ON public.hackathon_join_requests FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow student create join request"
    ON public.hackathon_join_requests FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = student_id OR public.is_admin());

-- --------------------------------------------------------------------
-- INCUBATION SCHEMES & PERMISSIONS POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow authenticated read incubation schemes"
    ON public.incubation_schemes FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin and permitted coordinators manage schemes"
    ON public.incubation_schemes FOR ALL TO authenticated
    USING (
        public.is_admin() OR 
        EXISTS (
            SELECT 1 FROM public.incubation_permissions ip
            JOIN public.profiles p ON p.full_name = ip.coordinator_name
            WHERE p.id = auth.uid() AND (ip.can_edit = TRUE OR ip.can_delete = TRUE)
        )
    )
    WITH CHECK (
        public.is_admin() OR 
        EXISTS (
            SELECT 1 FROM public.incubation_permissions ip
            JOIN public.profiles p ON p.full_name = ip.coordinator_name
            WHERE p.id = auth.uid() AND ip.can_edit = TRUE
        )
    );

CREATE POLICY "Allow authenticated read incubation permissions"
    ON public.incubation_permissions FOR SELECT TO authenticated USING (TRUE);

CREATE POLICY "Allow admin manage incubation permissions"
    ON public.incubation_permissions FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());

-- --------------------------------------------------------------------
-- ADMIN SETTINGS POLICIES
-- --------------------------------------------------------------------
CREATE POLICY "Allow admin manage settings"
    ON public.admin_settings FOR ALL TO authenticated
    USING (public.is_admin()) WITH CHECK (public.is_admin());
