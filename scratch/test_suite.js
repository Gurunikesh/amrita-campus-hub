// Test Suite for Amrita Unified Campus Hub Supabase Integration
const fs = require('fs');
const path = require('path');

// Mock Browser Environment
const localStorageData = {};
global.localStorage = {
    getItem: (k) => localStorageData[k] || null,
    setItem: (k, v) => { localStorageData[k] = String(v); },
    removeItem: (k) => { delete localStorageData[k]; },
    clear: () => { Object.keys(localStorageData).forEach(k => delete localStorageData[k]); }
};

global.window = {
    localStorage: global.localStorage,
    APP_CONFIG: {
        SUPABASE_URL: "https://your-project-id.supabase.co",
        SUPABASE_ANON_KEY: "your-anon-key-here"
    }
};

// Load supabase-client.js
const clientCode = fs.readFileSync(path.join(__dirname, '..', 'supabase-client.js'), 'utf8');
eval(clientCode);

const HubService = window.HubService;

async function runTests() {
    console.log('====================================================');
    console.log(' AMRITA CAMPUS HUB - BACKEND INTEGRATION TEST SUITE');
    console.log('====================================================\n');

    let passed = 0;
    let failed = 0;

    function assert(condition, testName) {
        if (condition) {
            console.log(`[PASS] ${testName}`);
            passed++;
        } else {
            console.error(`[FAIL] ${testName}`);
            failed++;
        }
    }

    try {
        // Test 1: Service loaded
        assert(HubService !== undefined, 'HubService is defined on window');

        // Test 2: Admin Login
        const adminSession = await HubService.login('admin@amrita.edu', 'admin123');
        assert(adminSession && adminSession.profile.role === 'ADMIN', 'Admin login yields ADMIN role');

        // Test 3: Session persistence
        const sessionCheck = await HubService.getSession();
        assert(sessionCheck && sessionCheck.profile.email === 'admin@amrita.edu', 'Session restored from storage');

        // Test 4: Coordinator Login
        const coordSession = await HubService.login('coordinator@amrita.edu', 'coord123');
        assert(coordSession && coordSession.profile.role === 'DEPT_COORDINATOR', 'Coordinator login yields DEPT_COORDINATOR role');

        // Test 5: Lab Staff Login
        const labSession = await HubService.login('lab@amrita.edu', 'lab123');
        assert(labSession && labSession.profile.role === 'LAB_STAFF', 'Lab Staff login yields LAB_STAFF role');

        // Test 6: Faculty Advisor Login
        const advSession = await HubService.login('gandhiraj@amrita.edu', 'pass123');
        assert(advSession && advSession.profile.isAdvisor === true && advSession.profile.advisorySection === 'CSE-S5-A', 'Advisor login yields advisory section CSE-S5-A');

        // Test 7: Student Login by Roll Number
        const stdSession = await HubService.login('CB.EN.U4CSE23001', 'stud123');
        assert(stdSession && stdSession.profile.role === 'STUDENT' && stdSession.profile.roll === 'CB.EN.U4CSE23001', 'Student roll number login yields STUDENT profile');

        // Test 8: Logout
        await HubService.logout();
        const emptySession = await HubService.getSession();
        assert(emptySession === null, 'Logout successfully clears active session');

        // Test 9: Data Mutation - Student Skills
        const skillsRes = await HubService.updateStudentSkills('stud_1', ['Python', 'Docker', 'PostgreSQL']);
        assert(skillsRes === true, 'updateStudentSkills executes without error');

        // Test 10: Data Mutation - Class Rep Toggle
        const repRes = await HubService.toggleStudentRep('stud_1', true);
        assert(repRes === true, 'toggleStudentRep executes without error');

        // Test 11: Data Mutation - Class Advisor Assignment
        const advAssignRes = await HubService.assignClassAdvisor('CSE-S5-A', 'Gandhiraj', 'fac_1');
        assert(advAssignRes === true, 'assignClassAdvisor executes without error');

        // Test 12: Data Mutation - Class Advisor Removal
        const advRemoveRes = await HubService.removeClassAdvisor('CSE-S5-A', 'Gandhiraj');
        assert(advRemoveRes === true, 'removeClassAdvisor executes without error');

        // Test 13: Data Mutation - Lab In-Charge Assignment
        const labInChargeRes = await HubService.assignLabInCharge('lab_1', 'Dr. Anand Kumar');
        assert(labInChargeRes === true, 'assignLabInCharge executes without error');

        // Test 14: Data Mutation - Update Lab Details
        const labUpdateRes = await HubService.updateLabDetails('lab_1', 'FabLab AB-2 Updated', 'AB2-B310');
        assert(labUpdateRes === true, 'updateLabDetails executes without error');

        // Test 15: Timetable CRUD
        const ttSave = await HubService.saveTimetableEntry({
            id: 'tt_test_1',
            sectionId: 'CSE-S5-A',
            day: 'Monday',
            slot: '08:50 - 09:40',
            subject: 'Cloud Computing',
            faculty: 'Prof. Senthil',
            room: 'AB1-102'
        });
        assert(ttSave === true, 'saveTimetableEntry executes without error');

        const ttDel = await HubService.deleteTimetableEntry('tt_test_1');
        assert(ttDel === true, 'deleteTimetableEntry executes without error');

        // Test 16: Equipment Booking
        const eqBook = await HubService.bookEquipment({
            id: 'EB-TEST-1',
            eqId: 'eq_1',
            student: 'Guruvisvesh S A',
            date: '2026-10-15',
            slot: '10:00 - 11:00 AM'
        });
        assert(eqBook === true, 'bookEquipment executes without error');

        // Test 17: Resource Requests (Indents)
        const reqCreate = await HubService.createResourceRequest({
            id: 'REQ-TEST-1',
            studentName: 'Guruvisvesh S A',
            componentId: 'inv_1',
            itemName: 'NVIDIA Jetson Nano',
            labName: 'Robotics Lab',
            facultyName: 'Gandhiraj'
        });
        assert(reqCreate === true, 'createResourceRequest executes without error');

        const reqStatus = await HubService.updateResourceRequestStatus('REQ-TEST-1', { status: 'APPROVED' });
        assert(reqStatus === true, 'updateResourceRequestStatus executes without error');

        // Test 18: Inventory Management
        const invSave = await HubService.saveInventoryItem({
            id: 'inv_test_1',
            name: 'Raspberry Pi 5',
            lab: 'IoT Lab',
            total: 10,
            available: 10,
            defective: 0
        });
        assert(invSave === true, 'saveInventoryItem executes without error');

        const invDel = await HubService.deleteInventoryItem('inv_test_1');
        assert(invDel === true, 'deleteInventoryItem executes without error');

        // Test 19: Section Creation
        const secCreate = await HubService.createSection('CSE-S5-D', 'CSE - Sem 5 - Sec D');
        assert(secCreate === true, 'createSection executes without error');

        // Test 20: Clubs and Hackathons
        const clubJoin = await HubService.joinClub('c1', 'user_1', 'Guruvisvesh S A');
        assert(clubJoin === true, 'joinClub executes without error');

        const hkJoin = await HubService.joinHackathon('hk_1', 'user_1', 'Guruvisvesh S A');
        assert(hkJoin === true, 'joinHackathon executes without error');

        // Test 21: Admin CRUD operations
        const admStud = await HubService.adminSaveStudent({
            id: 'adm_s1',
            name: 'Test Student',
            rollNumber: 'CB.EN.U4CSE23999',
            email: 'test@students.amrita.edu',
            department: 'CSE',
            sectionId: 'CSE-S5-A'
        });
        assert(admStud === true, 'adminSaveStudent executes without error');

        const admStaff = await HubService.adminSaveStaff({
            id: 'adm_st1',
            name: 'Dr. Test Staff',
            email: 'teststaff@amrita.edu',
            department: 'CSE',
            staffId: 'STF999',
            designation: 'Professor'
        });
        assert(admStaff === true, 'adminSaveStaff executes without error');

        const admDept = await HubService.adminSaveDepartment({
            id: 'dept_ai',
            name: 'Artificial Intelligence',
            code: 'AI',
            coordinator: 'Dr. AI Coordinator'
        });
        assert(admDept === true, 'adminSaveDepartment executes without error');

        const admBlock = await HubService.adminSaveBlock({
            id: 'blk_test',
            name: 'Innovation Complex',
            code: 'IC-1',
            type: 'Research'
        });
        assert(admBlock === true, 'adminSaveBlock executes without error');

        const admCR = await HubService.adminSaveClassroom({
            number: 'CR-999',
            block: 'BLK-A',
            capacity: 60
        });
        assert(admCR === true, 'adminSaveClassroom executes without error');

        const admScheme = await HubService.adminSaveScheme({
            id: 99,
            name: 'Test Innovation Grant',
            department: 'CSE'
        });
        assert(admScheme === true, 'adminSaveScheme executes without error');

        const admPerm = await HubService.adminSavePermission({
            id: 99,
            coordinator_id: 'STF010',
            department: 'CSE',
            schemes: ['Test Innovation Grant']
        });
        assert(admPerm === true, 'adminSavePermission executes without error');

        const admSet = await HubService.adminSaveSettings({
            timezone: 'IST',
            maintenanceMode: false
        });
        assert(admSet === true, 'adminSaveSettings executes without error');

    } catch (e) {
        console.error('Unexpected error during test execution:', e);
        failed++;
    }

    console.log('\n----------------------------------------------------');
    console.log(`TOTAL TESTS: ${passed + failed} | PASSED: ${passed} | FAILED: ${failed}`);
    console.log('----------------------------------------------------');

    if (failed > 0) {
        process.exit(1);
    }
}

runTests();
