// ====================================================================
// AMRITA UNIFIED CAMPUS HUB: SUPABASE CLIENT & BACKEND INTEGRATION
// File: supabase-client.js
// ====================================================================

(function(window) {
    'use strict';

    // 1. Resolve Supabase Configuration
    const defaultConfig = {
        url: 'https://placeholder-project.supabase.co',
        anonKey: 'placeholder-anon-key'
    };

    // Check if configuration exists in window.APP_CONFIG, HTML DOM, or localStorage
    function getSupabaseConfig() {
        const domUrl = typeof document !== 'undefined' ? document.getElementById('supabase-url')?.textContent?.trim() : null;
        const domKey = typeof document !== 'undefined' ? document.getElementById('supabase-anon-key')?.textContent?.trim() : null;

        const url = window.APP_CONFIG?.SUPABASE_URL ||
                    localStorage.getItem('AMRITA_SUPABASE_URL') ||
                    (domUrl && !domUrl.includes('your-project-id') ? domUrl : null) ||
                    defaultConfig.url;

        const anonKey = window.APP_CONFIG?.SUPABASE_ANON_KEY ||
                        localStorage.getItem('AMRITA_SUPABASE_ANON_KEY') ||
                        (domKey && !domKey.includes('your-anon-key') ? domKey : null) ||
                        defaultConfig.anonKey;

        return { url, anonKey };
    }

    const config = getSupabaseConfig();
    const isConfigured = config.url && !config.url.includes('placeholder') &&
                         config.anonKey && !config.anonKey.includes('placeholder');

    let client = null;
    if (window.supabase && typeof window.supabase.createClient === 'function') {
        try {
            client = window.supabase.createClient(config.url, config.anonKey, {
                auth: {
                    persistSession: true,
                    autoRefreshToken: true,
                    detectSessionInUrl: true
                }
            });
        } catch (e) {
            console.warn('[SupabaseClient] Initialization warning:', e.message);
        }
    }

    // Exported HubService
    const HubService = {
        client: client,
        isConfigured: isConfigured,

        // Configuration update helper
        setCredentials: function(url, anonKey) {
            if (!url || !anonKey) return false;
            localStorage.setItem('AMRITA_SUPABASE_URL', url);
            localStorage.setItem('AMRITA_SUPABASE_ANON_KEY', anonKey);
            if (window.supabase) {
                this.client = window.supabase.createClient(url, anonKey, {
                    auth: { persistSession: true, autoRefreshToken: true }
                });
                this.isConfigured = true;
            }
            return true;
        },

        // ------------------------------------------------------------
        // AUTHENTICATION
        // ------------------------------------------------------------
        login: async function(email, password) {
            let normalizedEmail = (email || '').trim();

            if (!this.client || !this.isConfigured) {
                // Offline fallback authentication for local demo
                return this._fallbackLogin(email, password);
            }

            const { data, error } = await this.client.auth.signInWithPassword({
                email: normalizedEmail,
                password: password
            });
            if (error) throw error;

            // Fetch user profile from database
            const profile = await this.getProfile(data.user.id, data.user.email);
            return { user: data.user, profile: profile };
        },

        logout: async function() {
            if (this.client && this.isConfigured) {
                await this.client.auth.signOut();
            }
            localStorage.removeItem('amrita_session_user');
            return true;
        },

        getSession: async function() {
            if (!this.client || !this.isConfigured) {
                const stored = localStorage.getItem('amrita_session_user');
                return stored ? JSON.parse(stored) : null;
            }
            const { data: { session }, error } = await this.client.auth.getSession();
            if (error || !session) return null;
            const profile = await this.getProfile(session.user.id, session.user.email);
            return { user: session.user, profile: profile };
        },

        getProfile: async function(userId, email) {
            if (!this.client || !this.isConfigured) return null;
            let profile = null;
            if (userId) {
                const { data, error } = await this.client
                    .from('profiles')
                    .select('*')
                    .eq('id', userId)
                    .maybeSingle();
                if (data) profile = data;
            }
            if (!profile && email) {
                const { data, error } = await this.client
                    .from('profiles')
                    .select('*')
                    .ilike('email', email)
                    .maybeSingle();
                if (data) profile = data;
            }
            if (!profile) {
                console.warn('[HubService] getProfile: No profile found for', userId, email);
            }
            return profile;
        },

        // ------------------------------------------------------------
        // DATA READS
        // ------------------------------------------------------------
        fetchSections: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('sections').select('*').order('id');
            if (error) throw error;
            return data;
        },

        fetchDepartments: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('departments').select('*').order('name');
            if (error) throw error;
            return data;
        },

        fetchBlocks: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('campus_blocks').select('*').order('code');
            if (error) throw error;
            return data;
        },

        fetchClassrooms: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('classrooms').select('*').order('number');
            if (error) throw error;
            return data;
        },

        fetchLabs: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('labs').select('*').order('name');
            if (error) throw error;
            return data;
        },

        fetchEquipment: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('equipment').select('*').order('name');
            if (error) throw error;
            return data;
        },

        fetchEquipmentBookings: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('equipment_bookings').select('*').order('created_at', { ascending: false });
            if (error) throw error;
            return data;
        },

        fetchInventory: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('inventory').select('*').order('name');
            if (error) throw error;
            return data;
        },

        fetchResourceRequests: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('resource_requests').select('*').order('created_at', { ascending: false });
            if (error) throw error;
            return data;
        },

        fetchTimetable: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('timetable').select('*').order('day');
            if (error) throw error;
            return data;
        },

        fetchClubs: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('clubs').select('*').order('name');
            if (error) throw error;
            return data;
        },

        fetchClubMemberships: async function(userId) {
            if (!this.client || !this.isConfigured) return null;
            let query = this.client.from('club_memberships').select('*');
            if (userId) query = query.eq('user_id', userId);
            const { data, error } = await query;
            if (error) throw error;
            return data;
        },

        fetchHackathons: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('hackathon_projects').select('*').order('created_at', { ascending: false });
            if (error) throw error;
            return data;
        },

        fetchHackathonRequests: async function(studentId) {
            if (!this.client || !this.isConfigured) return null;
            let query = this.client.from('hackathon_join_requests').select('*');
            if (studentId) query = query.eq('student_id', studentId);
            const { data, error } = await query;
            if (error) throw error;
            return data;
        },

        fetchSchemes: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('incubation_schemes').select('*').order('id');
            if (error) throw error;
            return data;
        },

        fetchPermissions: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('incubation_permissions').select('*').order('id');
            if (error) throw error;
            return data;
        },

        fetchStudents: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('profiles').select('*').eq('role', 'STUDENT').order('roll_number');
            if (error) throw error;
            return data;
        },

        fetchStaff: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('profiles').select('*').in('role', ['FACULTY', 'DEPT_COORDINATOR', 'LAB_STAFF']).order('full_name');
            if (error) throw error;
            return data;
        },

        fetchFaculty: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('profiles').select('*').eq('role', 'FACULTY').order('full_name');
            if (error) throw error;
            return data;
        },

        fetchSettings: async function() {
            if (!this.client || !this.isConfigured) return null;
            const { data, error } = await this.client.from('admin_settings').select('*');
            if (error) throw error;
            return data;
        },

        // ------------------------------------------------------------
        // MUTATIONS
        // ------------------------------------------------------------
        // 1. Student Skills
        updateStudentSkills: async function(userId, skills) {
            if (!this.client || !this.isConfigured) return true;
            const { data, error } = await this.client.from('profiles').update({ skills }).eq('id', userId);
            if (error) throw error;
            return true;
        },

        // 2. Class Rep toggle
        toggleStudentRep: async function(studentId, isRep) {
            if (!this.client || !this.isConfigured) return true;
            // Find student profile by id or roll_number
            let query = this.client.from('profiles').update({ is_rep: isRep });
            if (typeof studentId === 'number' || !studentId.includes('-')) {
                // Lookup student id
                query = query.or(`id.eq.${studentId},roll_number.ilike.%${studentId}%`);
            } else {
                query = query.eq('id', studentId);
            }
            const { error } = await query;
            if (error) throw error;
            return true;
        },

        // 3. Class Advisor Assignment
        assignClassAdvisor: async function(sectionId, advisorName, facultyId) {
            if (!this.client || !this.isConfigured) return true;

            // 1. Get current advisor for this section (if any)
            const { data: sectionData } = await this.client
                .from('sections')
                .select('advisor')
                .eq('id', sectionId)
                .single();

            const oldAdvisor = sectionData?.advisor;

            // 2. Remove advisor status from old advisor if different
            if (oldAdvisor && oldAdvisor !== advisorName) {
                await this.client
                    .from('profiles')
                    .update({ is_advisor: false, advisory_section: null })
                    .eq('full_name', oldAdvisor);
            }

            // 3. Update sections table with new advisor
            const { error: secErr } = await this.client
                .from('sections')
                .update({ advisor: advisorName })
                .eq('id', sectionId);
            if (secErr) throw secErr;

            // 4. Update profiles for the new faculty member
            if (advisorName) {
                const { error: profErr } = await this.client
                    .from('profiles')
                    .update({ is_advisor: true, advisory_section: sectionId })
                    .eq('full_name', advisorName);
                if (profErr) console.warn('Advisor profile update warning:', profErr.message);
            }
            return true;
        },

        removeClassAdvisor: async function(sectionId, currentAdvisorName) {
            if (!this.client || !this.isConfigured) return true;

            // 1. Update sections table to remove advisor
            const { error: secErr } = await this.client
                .from('sections')
                .update({ advisor: null })
                .eq('id', sectionId);
            if (secErr) throw secErr;

            // 2. Remove advisor status from the faculty profile
            if (currentAdvisorName) {
                const { error: profErr } = await this.client
                    .from('profiles')
                    .update({ is_advisor: false, advisory_section: null })
                    .eq('full_name', currentAdvisorName);
                if (profErr) console.warn('Advisor profile update warning:', profErr.message);
            }
            return true;
        },

        // 4. Lab In-Charge Assignment
        assignLabInCharge: async function(labId, facultyName) {
            if (!this.client || !this.isConfigured) return true;

            // 1. Get current incharge for this lab (if any)
            const { data: labData } = await this.client
                .from('labs')
                .select('in_charge, name')
                .eq('id', labId)
                .single();

            const oldInCharge = labData?.in_charge;
            const labName = labData?.name;

            // 2. Remove incharge status from old incharge if different
            if (oldInCharge && oldInCharge !== facultyName) {
                await this.client
                    .from('profiles')
                    .update({ is_incharge: false })
                    .eq('full_name', oldInCharge);
            }

            // 3. Update labs table with new incharge
            const { error: labErr } = await this.client
                .from('labs')
                .update({ in_charge: facultyName })
                .eq('id', labId);
            if (labErr) throw labErr;

            // 4. Update profiles for the new faculty member
            if (facultyName) {
                const { error: profErr } = await this.client
                    .from('profiles')
                    .update({ is_incharge: true })
                    .eq('full_name', facultyName);
                if (profErr) console.warn('Lab incharge profile update warning:', profErr.message);
            }

            // 5. Route pending resource requests to new incharge
            if (labName && facultyName) {
                await this.client
                    .from('resource_requests')
                    .update({ faculty_name: facultyName })
                    .eq('lab_name', labName)
                    .eq('status', 'PENDING_FACULTY');
            }

            return true;
        },

        updateLabDetails: async function(labId, name, code) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client
                .from('labs')
                .update({ name, code })
                .eq('id', labId);
            if (error) throw error;
            return true;
        },

        // 5. Timetable CRUD
        saveTimetableEntry: async function(entry) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: entry.id || ('tt_' + Date.now()),
                section_id: entry.sectionId,
                day: entry.day,
                slot: entry.slot,
                subject: entry.subject,
                faculty_name: entry.faculty,
                room: entry.room
            };
            const { data, error } = await this.client
                .from('timetable')
                .upsert(payload, { onConflict: 'id' });
            if (error) throw error;
            return true;
        },

        deleteTimetableEntry: async function(entryId) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('timetable').delete().eq('id', entryId);
            if (error) throw error;
            return true;
        },

        // 6. FabLab Equipment Booking
        bookEquipment: async function(booking) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: booking.id || ('EB-' + Date.now()),
                equipment_id: booking.eqId,
                equipment_name: booking.equipment_name,
                student_id: booking.student_id,
                student_name: booking.student,
                date: booking.date,
                slot: booking.slot,
                status: 'CONFIRMED',
                purpose: booking.purpose || 'Project use'
            };
            const { error } = await this.client.from('equipment_bookings').insert(payload);
            if (error) throw error;
            return true;
        },

        updateEquipmentBooking: async function(bookingId, updates) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('equipment_bookings').update(updates).eq('id', bookingId);
            if (error) throw error;
            return true;
        },

        // 7. Resource Requests (Component Indents)
        createResourceRequest: async function(req) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: req.id || ('REQ-' + Math.floor(Math.random() * 900 + 100)),
                student_name: req.student,
                component_id: req.componentId,
                item_name: req.item,
                lab_name: req.lab,
                status: req.status || 'PENDING_FACULTY',
                faculty_name: req.faculty,
                date_display: req.date || 'Today',
                deadline: req.deadline || '-',
                note: req.note || ''
            };
            const { error } = await this.client.from('resource_requests').insert(payload);
            if (error) throw error;
            return true;
        },

        updateResourceRequestStatus: async function(id, updates) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('resource_requests').update(updates).eq('id', id);
            if (error) throw error;
            return true;
        },

        // 8. Inventory CRUD
        saveInventoryItem: async function(item) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: item.id || ('inv_' + Date.now()),
                name: item.name,
                lab: item.lab,
                total: item.total || 0,
                defective: item.defective || 0,
                available: item.available !== undefined ? item.available : (item.total - (item.defective || 0))
            };
            const { error } = await this.client.from('inventory').upsert(payload, { onConflict: 'id' });
            if (error) throw error;
            return true;
        },

        deleteInventoryItem: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('inventory').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        // 9. Sections CRUD
        createSection: async function(sectionId, sectionName) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: sectionId,
                name: sectionName,
                title: sectionName,
                department_code: sectionId.split('-')[0] || 'CSE',
                semester: 5
            };
            const { error } = await this.client.from('sections').insert(payload);
            if (error) throw error;
            return true;
        },

        // 10. Club Join Request
        joinClub: async function(clubId, userId, userName) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                club_id: clubId,
                user_id: userId,
                user_name: userName,
                status: 'joined'
            };
            const { error } = await this.client.from('club_memberships').upsert(payload, { onConflict: 'club_id,user_id' });
            if (error) throw error;
            return true;
        },

        // 11. Hackathon Join Request
        joinHackathon: async function(hackathonId, studentId, studentName) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                hackathon_id: hackathonId,
                student_id: studentId,
                student_name: studentName,
                status: 'REQUESTED'
            };
            const { error } = await this.client.from('hackathon_join_requests').upsert(payload, { onConflict: 'hackathon_id,student_id' });
            if (error) throw error;
            return true;
        },

        // ------------------------------------------------------------
        // ADMIN SPECIFIC CRUD OPERATIONS
        // ------------------------------------------------------------
        adminSaveStudent: async function(student) {
            if (!this.client || !this.isConfigured) return true;

            const payload = {
                full_name: student.name,
                roll_number: student.roll,
                email: student.email,
                department: student.department,
                batch: student.year?.includes('2021') ? '2021' : '2023',
                status: student.status || 'active',
                role: 'STUDENT'
            };
            if (student.id && typeof student.id === 'string' && student.id.includes('-')) {
                payload.id = student.id;
            }

            // Save or update profile
            const { error: profileError } = await this.client.from('profiles').upsert(payload, { onConflict: 'email' });
            if (profileError) throw profileError;

            // If it's a new student with a password, create auth user
            if (!student.id && student.password) {
                const { error: authError } = await this.client.auth.signUp({
                    email: student.email,
                    password: student.password,
                    options: {
                        data: {
                            full_name: student.name,
                            role: 'STUDENT'
                        }
                    }
                });
                if (authError && !authError.message.includes('already registered')) {
                    throw authError;
                }
            }

            // If it's an existing student with a new password, update auth user
            if (student.id && student.password) {
                // Note: Supabase doesn't allow updating passwords directly from client side
                // This would need to be done via admin API or server-side function
                console.warn('Password update for existing user requires admin privileges');
            }

            return true;
        },

        adminDeleteStudent: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('profiles').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminSaveStaff: async function(staffMember) {
            if (!this.client || !this.isConfigured) return true;

            const payload = {
                full_name: staffMember.name,
                staff_id: staffMember.staffId,
                email: staffMember.email,
                department: staffMember.department,
                designation: staffMember.designation,
                status: staffMember.status || 'active',
                role: staffMember.role || 'FACULTY'
            };
            if (staffMember.id && typeof staffMember.id === 'string' && staffMember.id.includes('-')) {
                payload.id = staffMember.id;
            }

            // Save or update profile
            const { error: profileError } = await this.client.from('profiles').upsert(payload, { onConflict: 'email' });
            if (profileError) throw profileError;

            // If it's a new staff member with a password, create auth user
            if (!staffMember.id && staffMember.password) {
                const { error: authError } = await this.client.auth.signUp({
                    email: staffMember.email,
                    password: staffMember.password,
                    options: {
                        data: {
                            full_name: staffMember.name,
                            role: staffMember.role || 'FACULTY'
                        }
                    }
                });
                if (authError && !authError.message.includes('already registered')) {
                    throw authError;
                }
            }

            // If it's an existing staff member with a new password, update auth user
            if (staffMember.id && staffMember.password) {
                // Note: Supabase doesn't allow updating passwords directly from client side
                // This would need to be done via admin API or server-side function
                console.warn('Password update for existing user requires admin privileges');
            }

            return true;
        },

        adminDeleteStaff: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('profiles').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminSaveDepartment: async function(dept) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: dept.id ? String(dept.id) : ('dept_' + dept.code.toLowerCase()),
                name: dept.name,
                code: dept.code,
                coordinator: dept.coordinator,
                description: dept.description,
                status: dept.status || 'active'
            };
            const { error } = await this.client.from('departments').upsert(payload, { onConflict: 'code' });
            if (error) throw error;
            return true;
        },

        adminDeleteDepartment: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('departments').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminAssignCoordinator: async function(deptCode, staffName) {
            if (!this.client || !this.isConfigured) return true;
            const { error: deptErr } = await this.client.from('departments').update({ coordinator: staffName }).eq('code', deptCode);
            if (deptErr) throw deptErr;

            // Do NOT change the staff's role - coordinator is a separate account
            // This just records who the coordinator is for this department
            return true;
        },

        adminSaveClub: async function(club) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: club.id ? String(club.id) : ('club_' + Date.now()),
                name: club.name,
                category: club.category,
                faculty_name: club.faculty,
                lead_name: club.lead,
                department: club.department,
                description: club.description,
                status: club.status || 'active'
            };
            const { error } = await this.client.from('clubs').upsert(payload, { onConflict: 'name' });
            if (error) throw error;
            return true;
        },

        adminDeleteClub: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('clubs').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminSaveBlock: async function(block) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: block.id ? String(block.id) : ('blk_' + block.code.toLowerCase()),
                name: block.name,
                code: block.code,
                type: block.type,
                floors: parseInt(block.floors) || 1,
                location: block.location,
                classrooms: parseInt(block.classrooms) || 0,
                status: block.status || 'active'
            };
            const { error } = await this.client.from('campus_blocks').upsert(payload, { onConflict: 'code' });
            if (error) throw error;
            return true;
        },

        adminDeleteBlock: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('campus_blocks').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminSaveClassroom: async function(cr) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                id: cr.id ? String(cr.id) : ('cr_' + cr.number.toLowerCase()),
                number: cr.number,
                block: cr.block,
                floor: cr.floor,
                type: cr.type,
                capacity: parseInt(cr.capacity) || 60,
                department: cr.department,
                status: cr.status || 'Available'
            };
            const { error } = await this.client.from('classrooms').upsert(payload, { onConflict: 'number' });
            if (error) throw error;
            return true;
        },

        adminDeleteClassroom: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('classrooms').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminSaveScheme: async function(scheme) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                name: scheme.name,
                description: scheme.description,
                department: scheme.department,
                eligibility: scheme.eligibility,
                start_date: scheme.startDate,
                deadline: scheme.deadline,
                status: scheme.status || 'active',
                application_link: scheme.applicationLink || '',
                image_url: scheme.imageUrl || '',
                last_updated: scheme.lastUpdated || new Date().toISOString().split('T')[0]
            };
            if (scheme.id && !isNaN(parseInt(scheme.id))) {
                payload.id = parseInt(scheme.id);
            }
            const { error } = await this.client.from('incubation_schemes').upsert(payload);
            if (error) throw error;
            return true;
        },

        adminDeleteScheme: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('incubation_schemes').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminSavePermission: async function(perm) {
            if (!this.client || !this.isConfigured) return true;
            const payload = {
                coordinator_id: String(perm.coordinatorId),
                coordinator_name: perm.coordinatorName,
                department: perm.department,
                schemes: perm.schemes || [],
                can_edit: !!perm.canEdit,
                can_delete: !!perm.canDelete,
                assigned_date: perm.assignedDate || new Date().toISOString().split('T')[0]
            };
            if (perm.id && !isNaN(parseInt(perm.id))) {
                payload.id = parseInt(perm.id);
            }
            const { error } = await this.client.from('incubation_permissions').upsert(payload);
            if (error) throw error;
            return true;
        },

        adminDeletePermission: async function(id) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client.from('incubation_permissions').delete().eq('id', id);
            if (error) throw error;
            return true;
        },

        adminSaveSettings: async function(settingsObj) {
            if (!this.client || !this.isConfigured) return true;
            const { error } = await this.client
                .from('admin_settings')
                .upsert({ key: 'system_preferences', value: settingsObj }, { onConflict: 'key' });
            if (error) throw error;
            return true;
        },

        // Fallback login logic for development without active internet/mock demo testing
        _fallbackLogin: async function(identifier, password) {
            const id = identifier.trim().toLowerCase();
            const demoUsers = {
                'admin@amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000001',
                    email: 'admin@amrita.edu',
                    name: 'System Administrator',
                    role: 'ADMIN'
                },
                'coordinator@amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000002',
                    email: 'coordinator@amrita.edu',
                    name: 'Prof. Senthil',
                    role: 'DEPT_COORDINATOR',
                    dept: 'CSE'
                },
                'lab@amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000003',
                    email: 'lab@amrita.edu',
                    name: 'Mr. Ramesh (Lab Staff)',
                    role: 'LAB_STAFF',
                    dept: 'CSE',
                    isIncharge: true
                },
                'gandhiraj@amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000004',
                    email: 'gandhiraj@amrita.edu',
                    name: 'Gandhiraj',
                    role: 'FACULTY',
                    dept: 'CSE',
                    isAdvisor: true,
                    advisorySection: 'CSE-S5-A',
                    isIncharge: true
                },
                'karthika@amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000005',
                    email: 'karthika@amrita.edu',
                    name: 'Karthika',
                    role: 'FACULTY',
                    dept: 'CSE',
                    isAdvisor: true,
                    advisorySection: 'CSE-S5-B',
                    isIncharge: false
                },
                'anand@amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000006',
                    email: 'anand@amrita.edu',
                    name: 'Dr. Anand Kumar',
                    role: 'FACULTY',
                    dept: 'CSE',
                    isAdvisor: false,
                    isIncharge: true
                },
                'smitha@amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000007',
                    email: 'smitha@amrita.edu',
                    name: 'Dr. Smitha Suresh',
                    role: 'FACULTY',
                    dept: 'MATH',
                    isAdvisor: false,
                    isIncharge: false
                },
                'cb.en.u4cse23001@cb.students.amrita.edu': {
                    id: '00000000-0000-0000-0000-000000000020',
                    email: 'cb.en.u4cse23001@cb.students.amrita.edu',
                    name: 'Guruvisvesh S A',
                    roll: 'CB.EN.U4CSE23001',
                    dept: 'CSE',
                    batch: '2023',
                    sem: 5,
                    section: 'CSE-S5-A',
                    role: 'STUDENT',
                    skills: ['Python', 'React', 'Embedded C', 'IoT']
                }
            };

            const user = demoUsers[id];
            if (!user) {
                throw new Error('User account not found. Please verify your email.');
            }

            const session = {
                user: { id: user.id, email: user.email },
                profile: user
            };
            localStorage.setItem('amrita_session_user', JSON.stringify(session));
            return session;
        }
    };

    window.HubService = HubService;
})(window);
