-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: INITIAL RELATIONAL SCHEMA
-- Migration: 20261011_000001_initial_schema.sql
-- ====================================================================

-- 1. Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Departments
CREATE TABLE IF NOT EXISTS public.departments (
    id TEXT PRIMARY KEY DEFAULT ('dept_' || gen_random_uuid()),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    coordinator TEXT,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3. Campus Blocks
CREATE TABLE IF NOT EXISTS public.campus_blocks (
    id TEXT PRIMARY KEY DEFAULT ('blk_' || gen_random_uuid()),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL DEFAULT 'Academic',
    floors INTEGER NOT NULL DEFAULT 1,
    location TEXT,
    classrooms INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 4. Classrooms
CREATE TABLE IF NOT EXISTS public.classrooms (
    id TEXT PRIMARY KEY DEFAULT ('cr_' || gen_random_uuid()),
    number TEXT NOT NULL UNIQUE,
    block TEXT NOT NULL,
    floor TEXT NOT NULL DEFAULT '1st Floor',
    type TEXT NOT NULL DEFAULT 'Lecture Hall',
    capacity INTEGER NOT NULL DEFAULT 60,
    department TEXT NOT NULL DEFAULT 'CSE',
    status TEXT NOT NULL DEFAULT 'Available' CHECK (status IN ('Available', 'Occupied', 'Maintenance')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 5. Sections
CREATE TABLE IF NOT EXISTS public.sections (
    id TEXT PRIMARY KEY, -- e.g. 'CSE-S5-A', 'CSE-S5-B', 'ECE-S7', 'MECH-S3'
    name TEXT NOT NULL,
    title TEXT NOT NULL,
    department_code TEXT REFERENCES public.departments(code) ON UPDATE CASCADE ON DELETE SET NULL,
    semester INTEGER DEFAULT 5,
    advisor TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 6. User Profiles (extending auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'STUDENT' CHECK (role IN ('ADMIN', 'STUDENT', 'FACULTY', 'DEPT_COORDINATOR', 'LAB_STAFF', 'WARDEN')),
    department TEXT DEFAULT 'CSE',
    staff_id TEXT,
    roll_number TEXT,
    section_id TEXT REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE SET NULL,
    designation TEXT,
    cabin TEXT,
    phone TEXT,
    batch TEXT DEFAULT '2023',
    sem INTEGER DEFAULT 5,
    cgpa NUMERIC(3,2) DEFAULT 8.50,
    is_advisor BOOLEAN NOT NULL DEFAULT FALSE,
    advisory_section TEXT,
    is_incharge BOOLEAN NOT NULL DEFAULT FALSE,
    is_rep BOOLEAN NOT NULL DEFAULT FALSE,
    skills TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 7. Labs
CREATE TABLE IF NOT EXISTS public.labs (
    id TEXT PRIMARY KEY DEFAULT ('lab_' || gen_random_uuid()),
    name TEXT NOT NULL UNIQUE,
    code TEXT NOT NULL,
    in_charge TEXT,
    department TEXT DEFAULT 'CSE',
    location TEXT,
    capacity INTEGER DEFAULT 30,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 8. Equipment (e.g. FabLab 3D printers, CNC)
CREATE TABLE IF NOT EXISTS public.equipment (
    id TEXT PRIMARY KEY DEFAULT ('eq_' || gen_random_uuid()),
    lab_id TEXT REFERENCES public.labs(id) ON UPDATE CASCADE ON DELETE SET NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    specs TEXT,
    status TEXT NOT NULL DEFAULT 'Available',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 9. Equipment Bookings
CREATE TABLE IF NOT EXISTS public.equipment_bookings (
    id TEXT PRIMARY KEY DEFAULT ('EB-' || floor(extract(epoch from now()) * 1000)::text),
    equipment_id TEXT NOT NULL REFERENCES public.equipment(id) ON DELETE CASCADE,
    equipment_name TEXT,
    student_id UUID REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    date DATE NOT NULL,
    slot TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'CONFIRMED' CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED')),
    purpose TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 10. Lab Inventory (Components)
CREATE TABLE IF NOT EXISTS public.inventory (
    id TEXT PRIMARY KEY DEFAULT ('inv_' || floor(extract(epoch from now()) * 1000)::text),
    name TEXT NOT NULL,
    lab TEXT NOT NULL,
    total INTEGER NOT NULL DEFAULT 0,
    defective INTEGER NOT NULL DEFAULT 0,
    available INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 11. Resource Requests (Indents)
CREATE TABLE IF NOT EXISTS public.resource_requests (
    id TEXT PRIMARY KEY DEFAULT ('REQ-' || floor(random() * 900 + 100)::text),
    student_id UUID REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE SET NULL,
    student_name TEXT NOT NULL,
    component_id TEXT REFERENCES public.inventory(id) ON DELETE CASCADE,
    item_name TEXT NOT NULL,
    lab_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING_FACULTY' CHECK (status IN ('PENDING_FACULTY', 'APPROVED', 'ISSUED', 'RETURNED', 'CANCELLED')),
    faculty_name TEXT,
    date_display TEXT NOT NULL DEFAULT 'Today',
    deadline TEXT DEFAULT '-',
    note TEXT,
    issue_time TEXT,
    return_time TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 12. Master Timetable
CREATE TABLE IF NOT EXISTS public.timetable (
    id TEXT PRIMARY KEY DEFAULT ('tt_' || floor(extract(epoch from now()) * 1000)::text),
    section_id TEXT NOT NULL REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE,
    day TEXT NOT NULL CHECK (day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')),
    slot TEXT NOT NULL,
    subject TEXT NOT NULL,
    faculty_id UUID REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE SET NULL,
    faculty_name TEXT NOT NULL,
    room TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 13. Clubs
CREATE TABLE IF NOT EXISTS public.clubs (
    id TEXT PRIMARY KEY DEFAULT ('club_' || gen_random_uuid()),
    name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL DEFAULT 'Technical',
    faculty_name TEXT,
    lead_name TEXT,
    department TEXT DEFAULT 'CSE',
    description TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
    member_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 14. Club Memberships
CREATE TABLE IF NOT EXISTS public.club_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    club_id TEXT NOT NULL REFERENCES public.clubs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_name TEXT,
    status TEXT NOT NULL DEFAULT 'joined' CHECK (status IN ('joined', 'pending', 'rejected')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(club_id, user_id)
);

-- 15. Hackathon Projects
CREATE TABLE IF NOT EXISTS public.hackathon_projects (
    id TEXT PRIMARY KEY DEFAULT ('hk_' || gen_random_uuid()),
    author_id UUID REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE SET NULL,
    author_name TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    roles TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 16. Hackathon Join Requests
CREATE TABLE IF NOT EXISTS public.hackathon_join_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hackathon_id TEXT NOT NULL REFERENCES public.hackathon_projects(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON UPDATE CASCADE ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED', 'ACCEPTED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(hackathon_id, student_id)
);

-- 17. Incubation Schemes
CREATE TABLE IF NOT EXISTS public.incubation_schemes (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    department TEXT NOT NULL,
    eligibility TEXT NOT NULL,
    start_date DATE NOT NULL,
    deadline DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'upcoming', 'expired')),
    application_link TEXT,
    image_url TEXT,
    last_updated TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 18. Incubation Coordinator Permissions
CREATE TABLE IF NOT EXISTS public.incubation_permissions (
    id SERIAL PRIMARY KEY,
    coordinator_id TEXT NOT NULL,
    coordinator_name TEXT NOT NULL,
    department TEXT,
    schemes TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    can_edit BOOLEAN NOT NULL DEFAULT FALSE,
    can_delete BOOLEAN NOT NULL DEFAULT FALSE,
    assigned_date TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 19. Admin Settings
CREATE TABLE IF NOT EXISTS public.admin_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 20. Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_section ON public.profiles(section_id);
CREATE INDEX IF NOT EXISTS idx_timetable_section ON public.timetable(section_id);
CREATE INDEX IF NOT EXISTS idx_timetable_day_slot ON public.timetable(day, slot);
CREATE INDEX IF NOT EXISTS idx_equipment_bookings_date ON public.equipment_bookings(equipment_id, date, slot);
CREATE INDEX IF NOT EXISTS idx_resource_requests_status ON public.resource_requests(status);
CREATE INDEX IF NOT EXISTS idx_resource_requests_lab ON public.resource_requests(lab_name);
CREATE INDEX IF NOT EXISTS idx_classrooms_block ON public.classrooms(block);

-- 21. Profile trigger on auth.users creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.profiles WHERE LOWER(email) = LOWER(NEW.email)) THEN
        UPDATE public.profiles
        SET id = NEW.id
        WHERE LOWER(email) = LOWER(NEW.email);
    ELSE
        INSERT INTO public.profiles (
            id,
            email,
            full_name,
            role,
            department
        )
        VALUES (
            NEW.id,
            NEW.email,
            COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
            COALESCE(NEW.raw_user_meta_data->>'role', 'STUDENT'),
            COALESCE(NEW.raw_user_meta_data->>'department', 'CSE')
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
