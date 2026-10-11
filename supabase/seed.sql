-- ====================================================================
-- AMRITA UNIFIED CAMPUS HUB: DEMO SEED DATA
-- File: supabase/seed.sql
-- ====================================================================

-- 1. Departments
INSERT INTO public.departments (id, name, code, coordinator, description, status) VALUES
('dept_cse', 'Computer Science & Engineering', 'CSE', 'Prof. Senthil', 'Department of Computer Science and Engineering', 'active'),
('dept_ece', 'Electronics & Communication Engineering', 'ECE', 'Dr. Sunita Sharma', 'Department of Electronics and Communication Engineering', 'active'),
('dept_me', 'Mechanical Engineering', 'ME', 'Prof. Amit Patel', 'Department of Mechanical Engineering', 'active'),
('dept_ee', 'Electrical & Electronics Engineering', 'EE', 'Dr. Meera Singh', 'Department of Electrical Engineering', 'active'),
('dept_ce', 'Civil Engineering', 'CE', 'Prof. Karthik Verma', 'Department of Civil Engineering', 'active'),
('dept_math', 'Mathematics', 'MATH', 'Dr. Smitha Suresh', 'Department of Mathematics', 'active')
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, coordinator = EXCLUDED.coordinator;

-- 2. Campus Blocks
INSERT INTO public.campus_blocks (id, name, code, type, floors, location, classrooms, status) VALUES
('blk_a', 'Main Academic Block', 'BLK-A', 'Academic', 5, 'North Campus', 45, 'active'),
('blk_b', 'Engineering Block', 'BLK-B', 'Academic', 4, 'North Campus', 38, 'active'),
('blk_c', 'Science Block', 'BLK-C', 'Laboratory', 3, 'South Campus', 28, 'active'),
('blk_d', 'Administration Block', 'BLK-D', 'Administrative', 3, 'Central Campus', 12, 'active'),
('blk_e', 'Library Block', 'BLK-E', 'Library', 2, 'Central Campus', 8, 'active'),
('blk_ab1', 'Academic Block 1', 'AB-1', 'Academic', 4, 'West Campus', 24, 'active'),
('blk_ab2', 'Academic Block 2', 'AB-2', 'Academic & Labs', 5, 'Central Campus', 32, 'active'),
('blk_ab3', 'Academic Block 3', 'AB-3', 'Research & Labs', 4, 'East Campus', 20, 'active')
ON CONFLICT (code) DO NOTHING;

-- 3. Classrooms
INSERT INTO public.classrooms (number, block, floor, type, capacity, department, status) VALUES
('CR-101', 'BLK-A', '1st Floor', 'Lecture Hall', 120, 'CSE', 'Available'),
('CR-102', 'BLK-A', '1st Floor', 'Lecture Hall', 120, 'ECE', 'Available'),
('LAB-201', 'BLK-B', '2nd Floor', 'Laboratory', 40, 'CSE', 'Available'),
('SR-301', 'BLK-C', '3rd Floor', 'Seminar Room', 30, 'ME', 'Occupied'),
('CR-401', 'BLK-D', '4th Floor', 'Lecture Hall', 80, 'EE', 'Available'),
('AB1-102', 'AB-1', '1st Floor', 'Lecture Hall', 60, 'CSE', 'Available'),
('AB1-205', 'AB-1', '2nd Floor', 'Lecture Hall', 60, 'CSE', 'Available'),
('AB2-304', 'AB-2', '3rd Floor', 'Lecture Hall', 120, 'ECE', 'Available'),
('AB3-201', 'AB-3', '2nd Floor', 'Lecture Hall', 60, 'ME', 'Available'),
('AB3-402', 'AB-3', '4th Floor', 'Lecture Hall', 90, 'CSE', 'Available'),
('AB2-C303', 'AB-2', '3rd Floor', 'Lecture Hall', 60, 'ECE', 'Available'),
('AB2-B302', 'AB-2', '3rd Floor', 'Lecture Hall', 60, 'ECE', 'Available'),
('AB2-A401', 'AB-2', '4th Floor', 'Lecture Hall', 60, 'ECE', 'Available')
ON CONFLICT (number) DO NOTHING;

-- 4. Sections
INSERT INTO public.sections (id, name, title, department_code, semester, advisor) VALUES
('CSE-S5-A', 'CSE - Sem 5 - Sec A', 'B.Tech CSE - Semester 5 (Section A)', 'CSE', 5, 'Gandhiraj'),
('CSE-S5-B', 'CSE - Sem 5 - Sec B', 'B.Tech CSE - Semester 5 (Section B)', 'CSE', 5, 'Karthika'),
('ECE-S7', 'ECE - Sem 7', 'B.Tech ECE - Semester 7', 'ECE', 7, 'Dr. Rajesh'),
('MECH-S3', 'MECH - Sem 3', 'B.Tech Mechanical - Semester 3', 'ME', 3, 'Prof. Meena')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, advisor = EXCLUDED.advisor;

-- 5. Labs
INSERT INTO public.labs (id, name, code, in_charge, department, location, capacity) VALUES
('lab_1', 'FabLab AB-2', 'AB2-B310', 'Dr. Anand Kumar', 'CSE', 'AB-2 Basement', 40),
('lab_2', 'CEN Lab AB-3', 'AB3-410', 'Gandhiraj', 'CSE', 'AB-3 4th Floor', 35),
('lab_3', 'Robotics Lab', 'AB1-102', 'Dr. Rajesh', 'ECE', 'AB-1 1st Floor', 30),
('lab_4', 'VLSI Design Lab', 'AB2-B410', 'Dr. S. R. Ramesh', 'ECE', 'AB-2 4th Floor', 30),
('lab_5', 'Microwave & RF Lab', 'AB2-B210', 'Dr. B. Sabarish', 'ECE', 'AB-2 2nd Floor', 25),
('lab_6', 'Electronics Lab', 'AB2-110', 'Mr. Sudheesh', 'ECE', 'AB-2 1st Floor', 35)
ON CONFLICT (name) DO UPDATE SET in_charge = EXCLUDED.in_charge, code = EXCLUDED.code;

-- 6. Equipment (FabLab & MakerSpace)
INSERT INTO public.equipment (id, lab_id, name, type, specs, status) VALUES
('eq_1', 'lab_1', 'Makerbot Z18', '3D Printer', 'Build volume: 300 x 305 x 457 mm | Nozzle: 0.4 mm', 'Available'),
('eq_2', 'lab_1', 'ULTIMAKER S5', '3D Printer', 'Build Volume: 330 x 240 x 300 mm | Materials: PLA, Nylon, ABS', 'Available'),
('eq_3', 'lab_1', 'FormLabs Form3', '3D Printer', 'Build Volume: 14.5 × 14.5 × 18.5 cm | Material: Clear Resin', 'Available'),
('eq_4', 'lab_1', 'CNC Milling Machine', 'CNC', 'Table Size: 650 x 350 mm | Controller: Fanuc', 'Available'),
('eq_5', 'lab_1', 'CNC Lathe', 'CNC', 'Max Turning Dia: 320 mm | Controller: Fanuc', 'Available'),
('eq_6', 'lab_1', 'Laser Cutter', 'CNC', 'Area: 1300 x 900 mm | Materials: Wood, Acrylic, Fabric', 'Available'),
('eq_7', 'lab_1', 'Chop Saw', 'Power Tool', 'Max Cut: 135x6mm | Rotary Angles: 0-45deg', 'Available'),
('eq_8', 'lab_1', 'Electric Die Grinder', 'Power Tool', '600W | Speed: 25000 rpm', 'Available'),
('eq_9', 'lab_1', 'Professional Drill Kit', 'Power Tool', '550W | 0-2700 rpm', 'Available'),
('eq_10', 'lab_1', 'Bench Grinder', 'Power Tool', '0.5 HP | 3000 RPM', 'Available'),
('eq_11', 'lab_1', 'Drill Press', 'Power Tool', '0.5 HP | Spindle: 16mm', 'Available'),
('eq_12', 'lab_1', 'Angle Grinder', 'Power Tool', 'Wheel Dia: 100mm | 11000 rpm', 'Available')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, specs = EXCLUDED.specs;

-- 7. Inventory
INSERT INTO public.inventory (id, name, lab, total, defective, available) VALUES
('inv_1', 'NVIDIA Jetson Nano', 'Robotics Lab', 5, 0, 5),
('inv_2', 'ESP32 Wi-Fi Module', 'FabLab AB-2', 20, 2, 17),
('inv_3', 'Keysight Oscilloscope', 'CEN Lab AB-3', 10, 0, 9),
('inv_4', 'FPGA Artix-7 Board', 'VLSI Design Lab', 15, 1, 14),
('inv_5', 'Adafruit Sensor Kit', 'Electronics Lab', 30, 0, 29)
ON CONFLICT (id) DO UPDATE SET total = EXCLUDED.total, available = EXCLUDED.available;

-- 8. Resource Requests (Indents)
INSERT INTO public.resource_requests (id, student_name, component_id, item_name, lab_name, status, faculty_name, date_display, deadline, note, issue_time, return_time) VALUES
('REQ-01', 'Guruvisvesh S A (CSE)', 'inv_5', 'Adafruit Sensor Kit', 'Electronics Lab', 'APPROVED', 'Mr. Sudheesh', 'Today, 10:00 AM', 'Today, 5:00 PM', 'Ready for pickup.', NULL, NULL),
('REQ-02', 'Ananya Sharma', 'inv_2', 'ESP32 Wi-Fi Module', 'FabLab AB-2', 'ISSUED', 'Dr. Anand Kumar', 'Yesterday', '-', 'Currently in use.', '2026-10-10 10:30 AM', NULL),
('REQ-03', 'Rahul Nair', 'inv_3', 'Keysight Oscilloscope', 'CEN Lab AB-3', 'PENDING_FACULTY', 'Gandhiraj', 'Today, 11:30 AM', '-', 'Awaiting sign-off.', NULL, NULL)
ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

-- 9. Clubs
INSERT INTO public.clubs (id, name, category, faculty_name, lead_name, department, description, status, member_count) VALUES
('c1', 'Space Science Club', 'Technical', 'Dr. Rajesh', 'Varun S', 'CSE', 'Satellite payloads, Cansat, and astronomy.', 'active', 45),
('c2', 'IoT & Robotics', 'Technical', 'Dr. Rajesh Kumar', 'Karthik R', 'CSE', 'Hardware hackathons and automation.', 'active', 60),
('c3', 'Google Developer Student Club', 'Technical', 'Dr. Anand Kumar', 'Ananya M', 'CSE', 'Cloud, Web, and Android app development.', 'active', 120),
('c4', 'Shristi Club', 'Cultural', 'Prof. Meena', 'Meera P', 'ME', 'Literature, debate, and magazine creation.', 'active', 35),
('club_1', 'Robotics Club', 'Technical', 'Dr. R. Kumar', 'Arun Kumar', 'CSE', 'Robotics and automation club', 'active', 55),
('club_2', 'Debate Society', 'Cultural', 'Prof. S. Sharma', 'Priya Sharma', 'ECE', 'Debate and public speaking club', 'active', 40),
('club_3', 'Photography Club', 'Arts', 'Dr. A. Patel', 'Rahul Verma', 'ME', 'Photography and visual arts club', 'active', 30),
('club_4', 'Music Club', 'Cultural', 'Prof. M. Singh', 'Sneha Patel', 'EE', 'Music and performing arts club', 'pending', 25)
ON CONFLICT (name) DO UPDATE SET lead_name = EXCLUDED.lead_name, description = EXCLUDED.description;

-- 10. Incubation Schemes
INSERT INTO public.incubation_schemes (id, name, description, department, eligibility, start_date, deadline, status, application_link, last_updated) VALUES
(1, 'Startup Innovation Grant', 'Funding for student-led startup ideas', 'CSE', 'Students with innovative startup ideas', '2026-01-15', '2026-12-31', 'active', 'https://tbi.amrita.edu/startup-grant', '2026-01-20'),
(2, 'Research Incubation Program', 'Support for research-based projects', 'ECE', 'Final year students with research projects', '2026-02-01', '2026-11-30', 'active', 'https://tbi.amrita.edu/research-incubation', '2026-02-05'),
(3, 'Tech Entrepreneurship Bootcamp', 'Intensive bootcamp for aspiring entrepreneurs', 'ME', 'All students interested in entrepreneurship', '2026-05-01', '2026-10-15', 'active', 'https://tbi.amrita.edu/bootcamp', '2026-01-25'),
(4, 'NIDHI-PRAYAS', 'Grant up to 10 Lakhs for proof-of-concept and prototyping. Grants access to 3D printing and advanced labs.', 'CSE', 'Hardware and engineering prototypes', '2026-01-01', '2026-12-31', 'active', 'https://tbi.amrita.edu/prayas', '2026-03-01'),
(5, 'NIDHI-EIR', 'Subsistence stipend up to 30,000/month for 12 months for technology validation.', 'ECE', 'Graduating students and entrepreneurs', '2026-01-01', '2026-12-31', 'active', 'https://tbi.amrita.edu/eir', '2026-03-01'),
(6, 'Amrita PitchFest', 'Seed funding/equity investment up to $200,000, mentorship, and investor matchmaking.', 'ALL', 'Early-stage tech startups', '2026-01-01', '2026-12-31', 'active', 'https://tbi.amrita.edu/pitchfest', '2026-03-01')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description;

SELECT setval(pg_get_serial_sequence('public.incubation_schemes', 'id'), COALESCE((SELECT MAX(id) FROM public.incubation_schemes), 1));

-- 11. Incubation Permissions
INSERT INTO public.incubation_permissions (id, coordinator_id, coordinator_name, department, schemes, can_edit, can_delete, assigned_date) VALUES
(1, '1', 'Arun Kumar', 'CSE', ARRAY['Startup Innovation Grant', 'Research Incubation Program'], TRUE, FALSE, '2026-01-15'),
(2, '2', 'Priya Sharma', 'ECE', ARRAY['Tech Entrepreneurship Bootcamp'], TRUE, FALSE, '2026-01-16'),
(3, '3', 'Rahul Verma', 'ME', ARRAY['NIDHI-PRAYAS'], FALSE, FALSE, '2026-01-18')
ON CONFLICT (id) DO UPDATE SET schemes = EXCLUDED.schemes;

SELECT setval(pg_get_serial_sequence('public.incubation_permissions', 'id'), COALESCE((SELECT MAX(id) FROM public.incubation_permissions), 1));

-- 12. Hackathon Projects
INSERT INTO public.hackathon_projects (id, author_name, title, description, roles) VALUES
('hk_1', 'Arjun Krishna (CSE)', 'Smart India Hackathon - AgriTech AI', 'Developing IoT sensor nodes with edge ML for real-time crop disease detection.', ARRAY['Embedded Dev', 'ML Engineer', 'Frontend Dev']),
('hk_2', 'Divya R (ECE)', 'Cansat Telemetry & Flight System', 'Building sub-orbital rocket payload telemetry subsystem transmitting RF data to ground station.', ARRAY['RF Engineer', 'PCB Designer', 'Python Dev']),
('hk_3', 'Siddharth M (CSE)', 'InCTF / DefCon Collegiate Squad', 'Looking for reverse engineering and binary exploitation specialists for upcoming international CTF.', ARRAY['Binary Exploitation', 'Web Sec Tester', 'Cryptanalyst'])
ON CONFLICT (id) DO NOTHING;

-- 13. Master Timetable Entries
INSERT INTO public.timetable (id, section_id, day, slot, subject, faculty_name, room) VALUES
-- CSE-S5-A
('tt_1', 'CSE-S5-A', 'Monday', '08:50 - 09:40', 'Operating Systems', 'Gandhiraj', 'AB1-102'),
('tt_2', 'CSE-S5-A', 'Monday', '09:40 - 10:30', 'Data Structures', 'Karthika', 'AB1-102'),
('tt_3', 'CSE-S5-A', 'Monday', '10:45 - 11:35', 'Linear Algebra', 'Dr. Smitha Suresh', 'AB1-102'),
('tt_4', 'CSE-S5-A', 'Tuesday', '08:50 - 09:40', 'Computer Networks', 'Prof. Senthil', 'AB1-102'),
('tt_5', 'CSE-S5-A', 'Tuesday', '09:40 - 10:30', 'Machine Learning', 'Dr. Anand Kumar', 'AB1-102'),
('tt_6', 'CSE-S5-A', 'Wednesday', '13:15 - 14:05', 'OS Lab', 'Gandhiraj', 'LAB-201'),
('tt_7', 'CSE-S5-A', 'Wednesday', '14:05 - 14:55', 'OS Lab', 'Gandhiraj', 'LAB-201'),
('tt_8', 'CSE-S5-A', 'Thursday', '10:45 - 11:35', 'Data Structures', 'Karthika', 'AB1-102'),
('tt_9', 'CSE-S5-A', 'Friday', '08:50 - 09:40', 'Machine Learning', 'Dr. Anand Kumar', 'AB1-102'),
-- CSE-S5-B
('tt_10', 'CSE-S5-B', 'Monday', '08:50 - 09:40', 'Data Structures', 'Karthika', 'AB1-205'),
('tt_11', 'CSE-S5-B', 'Monday', '09:40 - 10:30', 'Operating Systems', 'Gandhiraj', 'AB1-205'),
('tt_12', 'CSE-S5-B', 'Tuesday', '10:45 - 11:35', 'Linear Algebra', 'Dr. Smitha Suresh', 'AB1-205'),
('tt_13', 'CSE-S5-B', 'Thursday', '13:15 - 14:05', 'Networks Lab', 'Prof. Senthil', 'LAB-201'),
-- ECE-S7
('tt_14', 'ECE-S7', 'Monday', '08:50 - 09:40', 'VLSI Design', 'Dr. S. R. Ramesh', 'AB2-304'),
('tt_15', 'ECE-S7', 'Tuesday', '09:40 - 10:30', 'Microwave Theory', 'Dr. B. Sabarish', 'AB2-304'),
('tt_16', 'ECE-S7', 'Wednesday', '10:45 - 11:35', 'Robotics Systems', 'Dr. Rajesh', 'AB2-304'),
-- MECH-S3
('tt_17', 'MECH-S3', 'Monday', '08:50 - 09:40', 'Thermodynamics', 'Prof. Meena', 'AB3-201'),
('tt_18', 'MECH-S3', 'Wednesday', '09:40 - 10:30', 'Fluid Mechanics', 'Prof. Amit Patel', 'AB3-201')
ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, faculty_name = EXCLUDED.faculty_name, room = EXCLUDED.room;

-- 14. Admin Settings
INSERT INTO public.admin_settings (key, value) VALUES
('system_preferences', '{
    "adminEmail": "admin@amrita.edu",
    "notificationEmail": "notifications@amrita.edu",
    "timezone": "IST (UTC+5:30)",
    "language": "English",
    "maintenanceMode": false
}'::jsonb)
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- 15. Student Profiles Seed (40 students across 4 sections, with Class Reps)
DO $$
DECLARE
    first_names TEXT[] := ARRAY['Rahul', 'Ananya', 'Aditya', 'Sneha', 'Kiran', 'Divya', 'Siddharth', 'Priya', 'Arjun', 'Nandana', 'Vishnu', 'Swathi', 'Rohan', 'Kavya', 'Abhishek', 'Meera', 'Tarun', 'Deepika', 'Vignesh', 'Harini'];
    last_names TEXT[] := ARRAY['Nair', 'Sharma', 'Menon', 'Pillai', 'Kumar', 'Ramesh', 'Rao', 'Sundar', 'Verma', 'Varma', 'Prasad', 'Suresh', 'Das', 'Iyer', 'Warrier', 'Nambiar', 'K.', 'S.', 'Reddy', 'Patel'];
    i INT;
    sec_id TEXT;
    roll_pfx TEXT;
    em_sfx TEXT;
    full_nm TEXT;
    roll_str TEXT;
    is_class_rep BOOLEAN;
    gen_uuid UUID;
BEGIN
    FOR i IN 1..40 LOOP
        IF i <= 10 THEN
            sec_id := 'CSE-S5-A';
            roll_pfx := 'CB.EN.U4CSE23';
            em_sfx := 'a@cb.students.amrita.edu';
        ELSIF i <= 20 THEN
            sec_id := 'CSE-S5-B';
            roll_pfx := 'CB.EN.U4CSE23';
            em_sfx := 'b@cb.students.amrita.edu';
        ELSIF i <= 30 THEN
            sec_id := 'ECE-S7';
            roll_pfx := 'CB.EN.U4ECE22';
            em_sfx := '@cb.students.amrita.edu';
        ELSE
            sec_id := 'MECH-S3';
            roll_pfx := 'CB.EN.U4MEE24';
            em_sfx := '@cb.students.amrita.edu';
        END IF;

        roll_str := roll_pfx || LPAD(((i - 1) % 10 + 1)::text, 3, '0');
        full_nm := first_names[((i - 1) % array_length(first_names, 1)) + 1] || ' ' || last_names[((i * 3) % array_length(last_names, 1)) + 1];
        is_class_rep := i IN (2, 5, 12, 15, 22, 25, 32, 35);
        gen_uuid := ('00000000-0000-0000-0001-' || LPAD(i::text, 12, '0'))::UUID;

        -- Specific for Student 1: Guruvisvesh S A
        IF i = 1 THEN
            full_nm := 'Guruvisvesh S A';
            roll_str := 'CB.EN.U4CSE23001';
            gen_uuid := '00000000-0000-0000-0000-000000000020'::UUID;
        END IF;

        INSERT INTO public.profiles (
            id, email, full_name, role, department, roll_number, section_id,
            phone, is_rep, skills, status, sem, batch, cgpa
        ) VALUES (
            gen_uuid,
            LOWER(roll_str) || em_sfx,
            full_nm,
            'STUDENT',
            split_part(sec_id, '-', 1),
            roll_str,
            sec_id,
            '+91 9' || SUBSTRING((800000000 + i * 12345)::text, 1, 9),
            is_class_rep,
            CASE WHEN i = 1 THEN ARRAY['Python', 'React', 'Embedded C', 'IoT'] ELSE ARRAY['Python', 'Java'] END,
            'active',
            CASE WHEN sec_id = 'ECE-S7' THEN 7 WHEN sec_id = 'MECH-S3' THEN 3 ELSE 5 END,
            CASE WHEN sec_id = 'ECE-S7' THEN '2022' WHEN sec_id = 'MECH-S3' THEN '2024' ELSE '2023' END,
            8.25
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            roll_number = EXCLUDED.roll_number,
            section_id = EXCLUDED.section_id,
            is_rep = EXCLUDED.is_rep;
    END LOOP;
END $$;

-- 16. Demo Staff & Faculty Profiles Seed
INSERT INTO public.profiles (id, email, full_name, role, department, staff_id, designation, cabin, is_advisor, advisory_section, is_incharge, status) VALUES
-- Admin
('00000000-0000-0000-0000-000000000001'::UUID, 'admin@amrita.edu', 'System Administrator', 'ADMIN', 'CSE', 'ADM001', 'Chief Administrator', 'AB1-001', FALSE, NULL, FALSE, 'active'),
-- Department Coordinator: Prof. Senthil
('00000000-0000-0000-0000-000000000002'::UUID, 'coordinator@amrita.edu', 'Prof. Senthil', 'DEPT_COORDINATOR', 'CSE', 'STF010', 'Dept. Coordinator & Professor', 'AB1-101', FALSE, NULL, FALSE, 'active'),
-- Lab Staff
('00000000-0000-0000-0000-000000000003'::UUID, 'lab@amrita.edu', 'Mr. Ramesh (Lab Staff)', 'LAB_STAFF', 'CSE', 'STF020', 'Senior Lab Technical Officer', 'AB2-B310', FALSE, NULL, TRUE, 'active'),
-- Faculty Case 1: Gandhiraj (Advisor CSE-S5-A & Lab Incharge CEN Lab)
('00000000-0000-0000-0000-000000000004'::UUID, 'gandhiraj@amrita.edu', 'Gandhiraj', 'FACULTY', 'CSE', 'STF011', 'Associate Professor', 'AB1-201', TRUE, 'CSE-S5-A', TRUE, 'active'),
-- Faculty Case 2: Karthika (Advisor CSE-S5-B Only)
('00000000-0000-0000-0000-000000000005'::UUID, 'karthika@amrita.edu', 'Karthika', 'FACULTY', 'CSE', 'STF012', 'Assistant Professor', 'AB1-202', TRUE, 'CSE-S5-B', FALSE, 'active'),
-- Faculty Case 3: Dr. Anand Kumar (Lab Incharge FabLab AB-2 Only)
('00000000-0000-0000-0000-000000000006'::UUID, 'anand@amrita.edu', 'Dr. Anand Kumar', 'FACULTY', 'CSE', 'STF013', 'Professor', 'AB3-401', FALSE, NULL, TRUE, 'active'),
-- Faculty Case 4: Dr. Smitha Suresh (General Faculty)
('00000000-0000-0000-0000-000000000007'::UUID, 'smitha@amrita.edu', 'Dr. Smitha Suresh', 'FACULTY', 'MATH', 'STF014', 'Professor', 'AB1-405', FALSE, NULL, FALSE, 'active'),
-- Dr. Rajesh (Advisor ECE-S7 & Lab Incharge Robotics Lab)
('00000000-0000-0000-0000-000000000008'::UUID, 'rajesh@amrita.edu', 'Dr. Rajesh', 'FACULTY', 'ECE', 'STF015', 'Professor', 'AB2-101', TRUE, 'ECE-S7', TRUE, 'active'),
-- Prof. Meena (Advisor MECH-S3)
('00000000-0000-0000-0000-000000000009'::UUID, 'meena@amrita.edu', 'Prof. Meena', 'FACULTY', 'ME', 'STF016', 'Assistant Professor', 'AB3-301', TRUE, 'MECH-S3', FALSE, 'active'),
-- Mr. Sudheesh (Lab Incharge Electronics Lab)
('00000000-0000-0000-0000-000000000010'::UUID, 'sudheesh@amrita.edu', 'Mr. Sudheesh', 'FACULTY', 'ECE', 'STF017', 'Assistant Professor', 'AB2-307', FALSE, NULL, TRUE, 'active'),
-- Dr. S. R. Ramesh (Lab Incharge VLSI Lab)
('00000000-0000-0000-0000-000000000011'::UUID, 'ramesh_ece@amrita.edu', 'Dr. S. R. Ramesh', 'FACULTY', 'ECE', 'STF018', 'Professor', 'AB2-411', FALSE, NULL, TRUE, 'active'),
-- Dr. E. Prabhu
('00000000-0000-0000-0000-000000000012'::UUID, 'prabhu@amrita.edu', 'Dr. E. Prabhu', 'FACULTY', 'ECE', 'STF019', 'Associate Professor', 'AB2-308', FALSE, NULL, FALSE, 'active'),
-- Dr. B. Sabarish (Lab Incharge Microwave & RF Lab)
('00000000-0000-0000-0000-000000000013'::UUID, 'sabarish@amrita.edu', 'Dr. B. Sabarish', 'FACULTY', 'ECE', 'STF021', 'Professor', 'AB2-311', FALSE, NULL, TRUE, 'active'),
-- Additional Staff for admin.html mock compatibility
('00000000-0000-0000-0000-000000000014'::UUID, 'r.kumar@university.edu', 'Dr. Rajesh Kumar', 'FACULTY', 'CSE', 'STF001', 'Professor', 'AB1-105', FALSE, NULL, FALSE, 'active'),
('00000000-0000-0000-0000-000000000015'::UUID, 's.sharma@university.edu', 'Dr. Sunita Sharma', 'FACULTY', 'ECE', 'STF002', 'Associate Professor', 'AB2-205', FALSE, NULL, FALSE, 'active'),
('00000000-0000-0000-0000-000000000016'::UUID, 'a.patel@university.edu', 'Prof. Amit Patel', 'FACULTY', 'ME', 'STF003', 'Assistant Professor', 'AB3-105', FALSE, NULL, FALSE, 'active'),
('00000000-0000-0000-0000-000000000017'::UUID, 'm.singh@university.edu', 'Dr. Meera Singh', 'FACULTY', 'EE', 'STF004', 'Professor', 'AB2-108', FALSE, NULL, FALSE, 'active'),
('00000000-0000-0000-0000-000000000018'::UUID, 'k.verma@university.edu', 'Prof. Karthik Verma', 'FACULTY', 'CE', 'STF005', 'Assistant Professor', 'AB3-208', FALSE, NULL, FALSE, 'active')
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    is_advisor = EXCLUDED.is_advisor,
    advisory_section = EXCLUDED.advisory_section,
    is_incharge = EXCLUDED.is_incharge;
