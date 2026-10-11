-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: MINIMAL TEST DATA SETUP
-- Migration: 20261011_000010_minimal_test_data.sql
-- ====================================================================
-- This script clears existing data and creates minimal test data
-- for demonstrating the faculty hierarchy system
-- ====================================================================

-- 1. DELETE ALL EXISTING DATA (in correct order to respect foreign keys)
DELETE FROM public.equipment_bookings;
DELETE FROM public.club_memberships;
DELETE FROM public.resource_requests;
DELETE FROM public.inventory;
DELETE FROM public.equipment;
DELETE FROM public.timetable;
DELETE FROM public.labs;
DELETE FROM public.sections;
DELETE FROM public.classrooms;
DELETE FROM public.departments;
DELETE FROM public.clubs;
DELETE FROM public.profiles;

-- 2. CREATE DEPARTMENT FIRST (no dependencies)
INSERT INTO public.departments (id, name, code, coordinator, coordinator_id, description, status) VALUES
('dept_cse', 'Computer Science & Engineering', 'CSE', 'Dr. Senthil Kumar', NULL, 'Department of Computer Science and Engineering', 'active');

-- 3. CREATE SECTIONS (depends on departments)
INSERT INTO public.sections (id, name, title, department_code, semester, advisor) VALUES
('CSE-S5-A', 'CSE - Sem 5 - Sec A', 'B.Tech CSE - Semester 5 (Section A)', 'CSE', 5, 'Dr. Gandhiraj'),
('CSE-S5-B', 'CSE - Sem 5 - Sec B', 'B.Tech CSE - Semester 5 (Section B)', 'CSE', 5, 'Dr. Karthika');

-- 4. CREATE PROFILES (depends on sections and departments)
-- Auth users must be created separately via Supabase Dashboard
-- Replace the UUIDs below with actual auth user IDs after creating them in Supabase.

-- ADMIN
INSERT INTO public.profiles (id, full_name, email, role, department, staff_id) VALUES
('00000000-0000-0000-0000-000000000001', 'System Administrator', 'admin@amrita.edu', 'ADMIN', 'CSE', 'ADM001');

-- CASE 1: Dept Coordinator (also a faculty)
INSERT INTO public.profiles (id, full_name, email, role, department, designation, staff_id) VALUES
('00000000-0000-0000-0000-000000000002', 'Dr. Senthil Kumar', 'senthil@amrita.edu', 'DEPT_COORDINATOR', 'CSE', 'Professor', 'STF001');

-- CASE 2: Class Advisor + Lab Incharge
INSERT INTO public.profiles (id, full_name, email, role, department, designation, is_advisor, advisory_section, is_incharge, staff_id) VALUES
('00000000-0000-0000-0000-000000000003', 'Dr. Gandhiraj', 'gandhiraj@amrita.edu', 'FACULTY', 'CSE', 'Associate Professor', true, 'CSE-S5-A', true, 'STF002');

-- CASE 3: Lab Incharge only
INSERT INTO public.profiles (id, full_name, email, role, department, designation, is_incharge, staff_id) VALUES
('00000000-0000-0000-0000-000000000004', 'Dr. Anand Kumar', 'anand@amrita.edu', 'FACULTY', 'CSE', 'Assistant Professor', true, 'STF003');

-- CASE 4: Class Advisor only
INSERT INTO public.profiles (id, full_name, email, role, department, designation, is_advisor, advisory_section, staff_id) VALUES
('00000000-0000-0000-0000-000000000005', 'Dr. Karthika', 'karthika@amrita.edu', 'FACULTY', 'CSE', 'Assistant Professor', true, 'CSE-S5-B', 'STF004');

-- CASE 5: Just a Faculty (also Club Incharge)
INSERT INTO public.profiles (id, full_name, email, role, department, designation, staff_id) VALUES
('00000000-0000-0000-0000-000000000006', 'Prof. Rajesh Kumar', 'rajesh@amrita.edu', 'FACULTY', 'CSE', 'Professor', 'STF005');

-- LAB STAFF 1: Component Management
INSERT INTO public.profiles (id, full_name, email, role, department, designation, staff_id) VALUES
('00000000-0000-0000-0000-000000000007', 'Mr. Ramesh', 'ramesh@amrita.edu', 'LAB_STAFF', 'CSE', 'Lab Technician', 'LAB001');

-- LAB STAFF 2: Equipment/Booking Management
INSERT INTO public.profiles (id, full_name, email, role, department, designation, staff_id) VALUES
('00000000-0000-0000-0000-000000000008', 'Mr. Sudheesh', 'sudheesh@amrita.edu', 'LAB_STAFF', 'CSE', 'Lab Assistant', 'LAB002');

-- CLUB STAFF
INSERT INTO public.profiles (id, full_name, email, role, department, designation, staff_id) VALUES
('00000000-0000-0000-0000-000000000009', 'Ms. Meera', 'meera@amrita.edu', 'LAB_STAFF', 'CSE', 'Club Coordinator', 'CLB001');

-- STUDENTS (Section A - Advisor: Gandhiraj)
INSERT INTO public.profiles (id, full_name, email, role, department, roll_number, section_id, sem, batch) VALUES
('00000000-0000-0000-0000-000000000010', 'Arjun Sharma', 'cb.en.u4cse23001@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23001', 'CSE-S5-A', 5, '2023'),
('00000000-0000-0000-0000-000000000011', 'Priya Nair', 'cb.en.u4cse23002@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23002', 'CSE-S5-A', 5, '2023'),
('00000000-0000-0000-0000-000000000012', 'Rahul Menon', 'cb.en.u4cse23003@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23003', 'CSE-S5-A', 5, '2023'),
('00000000-0000-0000-0000-000000000013', 'Ananya Reddy', 'cb.en.u4cse23004@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23004', 'CSE-S5-A', 5, '2023'),
('00000000-0000-0000-0000-000000000014', 'Vikram Pillai', 'cb.en.u4cse23005@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23005', 'CSE-S5-A', 5, '2023');

-- STUDENTS (Section B - Advisor: Karthika)
INSERT INTO public.profiles (id, full_name, email, role, department, roll_number, section_id, sem, batch) VALUES
('00000000-0000-0000-0000-000000000015', 'Divya Kumar', 'cb.en.u4cse23006@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23006', 'CSE-S5-B', 5, '2023'),
('00000000-0000-0000-0000-000000000016', 'Siddharth Verma', 'cb.en.u4cse23007@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23007', 'CSE-S5-B', 5, '2023'),
('00000000-0000-0000-0000-000000000017', 'Kavya Iyer', 'cb.en.u4cse23008@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23008', 'CSE-S5-B', 5, '2023'),
('00000000-0000-0000-0000-000000000018', 'Abhishek Singh', 'cb.en.u4cse23009@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23009', 'CSE-S5-B', 5, '2023'),
('00000000-0000-0000-0000-000000000019', 'Deepika Suresh', 'cb.en.u4cse23010@cb.students.amrita.edu', 'STUDENT', 'CSE', 'CB.EN.U4CSE23010', 'CSE-S5-B', 5, '2023');

-- 5. UPDATE DEPARTMENT WITH COORDINATOR_ID (now that profile exists)
UPDATE public.departments SET coordinator_id = '00000000-0000-0000-0000-000000000002' WHERE code = 'CSE';

-- 6. CREATE CLUB
INSERT INTO public.clubs (id, name, category, faculty_name, lead_name, department, description, status, member_count) VALUES
('c1', 'IoT & Robotics Club', 'Technical', 'Prof. Rajesh Kumar', 'Arjun Sharma', 'CSE', 'Hardware hackathons and automation projects', 'active', 5);

-- 7. CREATE CLASSROOMS
INSERT INTO public.classrooms (number, block, floor, type, capacity, department, status) VALUES
('CR-101', 'BLK-A', '1st Floor', 'Lecture Hall', 60, 'CSE', 'Available'),
('CR-102', 'BLK-A', '1st Floor', 'Lecture Hall', 60, 'CSE', 'Available'),
('LAB-201', 'BLK-B', '2nd Floor', 'Laboratory', 40, 'CSE', 'Available');

-- 8. CREATE LABS
INSERT INTO public.labs (id, name, code, in_charge, department, location, capacity) VALUES
('lab_1', 'CEN Lab', 'LAB-201', 'Dr. Anand Kumar', 'CSE', 'BLK-B 2nd Floor', 40),
('lab_2', 'FabLab', 'FAB-101', 'Dr. Gandhiraj', 'CSE', 'BLK-A Basement', 35);

-- 9. CREATE INVENTORY (for component management)
INSERT INTO public.inventory (id, name, lab, total, defective, available) VALUES
('inv_1', 'ESP32 Wi-Fi Module', 'CEN Lab', 20, 2, 18),
('inv_2', 'Arduino Uno Board', 'CEN Lab', 15, 1, 14),
('inv_3', 'Raspberry Pi 4', 'CEN Lab', 10, 0, 10);

-- 10. CREATE EQUIPMENT (for FabLab bookings)
INSERT INTO public.equipment (id, lab_id, name, type, specs, status) VALUES
('eq_1', 'lab_2', 'Makerbot Z18', '3D Printer', 'Build volume: 300 x 305 x 457 mm', 'Available'),
('eq_2', 'lab_2', 'ULTIMAKER S5', '3D Printer', 'Build Volume: 330 x 240 x 300 mm', 'Available'),
('eq_3', 'lab_2', 'Laser Cutter', 'CNC', 'Area: 1300 x 900 mm', 'Available');

-- 11. CREATE SAMPLE TIMETABLE ENTRY
INSERT INTO public.timetable (id, section_id, day, slot, subject, faculty_name, room) VALUES
('tt_1', 'CSE-S5-A', 'Monday', '9:00 am - 9:50 am', 'Data Structures', 'Dr. Gandhiraj', 'CR-101'),
('tt_2', 'CSE-S5-B', 'Monday', '10:00 am - 10:50 am', 'Operating Systems', 'Dr. Karthika', 'CR-102');

-- 12. CREATE SAMPLE RESOURCE REQUEST (component)
INSERT INTO public.resource_requests (id, student_id, student_name, component_id, item_name, lab_name, status, faculty_name, date_display, deadline, note) VALUES
('REQ-' || floor(random() * 900 + 100)::text, '00000000-0000-0000-0000-000000000010', 'Arjun Sharma', 'inv_1', 'ESP32 Wi-Fi Module', 'CEN Lab', 'PENDING_FACULTY', 'Dr. Anand Kumar', 'Today, 10:00 AM', 'Today, 5:00 PM', 'Project use');

-- 13. CREATE SAMPLE EQUIPMENT BOOKING
INSERT INTO public.equipment_bookings (id, equipment_id, equipment_name, student_id, student_name, date, slot, status, purpose) VALUES
('EB-' || floor(extract(epoch from now()) * 1000)::text, 'eq_1', 'Makerbot Z18', '00000000-0000-0000-0000-000000000010', 'Arjun Sharma', '2026-10-12', '9:00 am - 9:50 am', 'CONFIRMED', 'Project prototype');

-- 14. CREATE CLUB MEMBERSHIP
INSERT INTO public.club_memberships (id, club_id, user_id, user_name, status, joined_at) VALUES
(gen_random_uuid(), 'c1', '00000000-0000-0000-0000-000000000010', 'Arjun Sharma', 'joined', '2026-10-01'),
(gen_random_uuid(), 'c1', '00000000-0000-0000-0000-000000000011', 'Priya Nair', 'joined', '2026-10-01'),
(gen_random_uuid(), 'c1', '00000000-0000-0000-0000-000000000012', 'Rahul Menon', 'joined', '2026-10-01');

-- ====================================================================
-- AUTH USERS CREATION INSTRUCTIONS
-- ====================================================================
-- The above profiles reference auth user IDs. You MUST create the following
-- auth users in Supabase Dashboard (Authentication → Users → Add User)
-- with the emails and passwords below:
--
-- Email                          | Password      | Role (in user_metadata)
-- -----------------------------------------------------------------------
-- admin@amrita.edu              | admin123      | {"role": "ADMIN"}
-- senthil@amrita.edu            | senthil123    | {"role": "DEPT_COORDINATOR"}
-- gandhiraj@amrita.edu          | gandhiraj123  | {"role": "FACULTY"}
-- anand@amrita.edu              | anand123      | {"role": "FACULTY"}
-- karthika@amrita.edu           | karthika123   | {"role": "FACULTY"}
-- rajesh@amrita.edu             | rajesh123     | {"role": "FACULTY"}
-- ramesh@amrita.edu             | ramesh123     | {"role": "LAB_STAFF"}
-- sudheesh@amrita.edu           | sudheesh123   | {"role": "LAB_STAFF"}
-- meera@amrita.edu              | meera123      | {"role": "LAB_STAFF"}
-- cb.en.u4cse23001@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23002@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23003@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23004@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23005@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23006@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23007@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23008@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23009@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
-- cb.en.u4cse23010@cb.students.amrita.edu | student123 | {"role": "STUDENT"}
--
-- IMPORTANT: After creating auth users, you may need to update the UUIDs
-- in the profiles table above to match the actual auth.user IDs.
-- ====================================================================
