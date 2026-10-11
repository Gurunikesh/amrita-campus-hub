# Amrita Unified Campus Hub

A comprehensive university campus management portal built with vanilla HTML/JavaScript and Supabase backend.

## Features

### Authentication & Access Control
- **Student Login**: Email-based authentication for students
- **Staff Login**: Email-based authentication for faculty, coordinators, lab staff
- **Role-Based Access Control**: Strict separation between student and staff portals
- **Admin Portal**: Dedicated admin interface for user and resource management

### User Roles
- **ADMIN**: Full system administration
- **DEPT_COORDINATOR**: Department-level coordination, timetable management, advisor/lab assignments
- **FACULTY**: Teaching duties, advisory roles, lab incharge responsibilities
- **LAB_STAFF**: Component management, equipment booking support
- **STUDENT**: Course access, lab bookings, club participation, component requests

### Core Modules
- **Timetable Management**: Class scheduling, room allocation, conflict detection
- **FabLab Booking**: Equipment reservation with time slots, auto-cancellation for no-shows
- **Component/Inventory System**: Student requests, faculty approval, lab staff tracking
- **Club Management**: Club creation, event management, membership tracking
- **Advisory System**: Class advisor assignment, student directory access, class representative election
- **Admin Dashboard**: User CRUD, department management, settings

## Technology Stack

- **Frontend**: Vanilla HTML5, CSS3, JavaScript (ES6+)
- **Styling**: Tailwind CSS (CDN)
- **Icons**: Lucide Icons
- **Backend**: Supabase (PostgreSQL + Auth + RLS)
- **Hosting**: Netlify-compatible static hosting

## Project Structure

```
Genesis/
├── campus-portal.html        # Main portal (student/staff/coordinator)
├── admin.html                 # Admin dashboard
├── config.js                  # Supabase configuration
├── supabase-client.js        # Backend abstraction layer
├── supabase/
│   ├── migrations/           # Database migrations
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   ├── 003_fablab_and_auth_updates.sql
│   │   ├── 004_role_transitions_and_access_control.sql
│   │   ├── 005_lab_incharge_routing.sql
│   │   ├── 006_strict_admin_user_crud.sql
│   │   ├── 007_classroom_allocation_sync.sql
│   │   ├── 008_coordinator_separate_credentials.sql
│   │   ├── 009_sync_auth_users_to_profiles.sql
│   │   └── 010_minimal_test_data.sql
│   └── seed.sql               # Demo seed data
└── scratch/
    └── test_suite.js         # Integration tests
```

## Setup Instructions

### 1. Supabase Project Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Project Settings → API and copy:
   - Project URL
   - anon/public API key
3. Update `config.js` with your credentials:
   ```javascript
   window.APP_CONFIG = {
       SUPABASE_URL: "your-project-url",
       SUPABASE_ANON_KEY: "your-anon-key"
   };
   ```

### 2. Run Database Migrations

Run migrations in order in Supabase SQL Editor:

```sql
-- Run each file in order:
001_initial_schema.sql
002_rls_policies.sql
003_fablab_and_auth_updates.sql
004_role_transitions_and_access_control.sql
005_lab_incharge_routing.sql
006_strict_admin_user_crud.sql
007_classroom_allocation_sync.sql
008_coordinator_separate_credentials.sql
009_sync_auth_users_to_profiles.sql
010_minimal_test_data.sql
```

### 3. Create Auth Users

After running `010_minimal_test_data.sql`, create auth users in Supabase Dashboard → Authentication → Users:

**Admin:**
- Email: `admin@amrita.edu`
- Password: `admin123`
- User metadata: `{"role": "ADMIN"}`

**Faculty (5 users):**
- `senthil@amrita.edu` / `senthil123` (Dept Coordinator)
- `gandhiraj@amrita.edu` / `gandhiraj123` (Advisor + Lab Incharge)
- `anand@amrita.edu` / `anand123` (Lab Incharge)
- `karthika@amrita.edu` / `karthika123` (Class Advisor)
- `rajesh@amrita.edu` / `rajesh123` (Faculty/Club Incharge)

**Lab Staff (3 users):**
- `ramesh@amrita.edu` / `ramesh123` (Component Management)
- `sudheesh@amrita.edu` / `sudheesh123` (Equipment Booking)
- `meera@amrita.edu` / `meera123` (Club Coordinator)

**Students (10 users):**
- `cb.en.u4cse23001@cb.students.amrita.edu` / `student123`
- (all 10 students use password: `student123`)

### 4. Deploy

The application is a static site and can be deployed to:
- Netlify
- Vercel
- GitHub Pages
- Any static hosting service

## Faculty Hierarchy

The system implements the following faculty hierarchy:

1. **Dept Coordinator** (Case 1): Manages department, assigns advisors/lab incharges, creates timetables
2. **Class Advisor + Lab Incharge** (Case 2): Has both advisory and lab responsibilities
3. **Lab Incharge** (Case 3): Manages specific lab, approves component requests
4. **Class Advisor** (Case 4): Manages student directory, elects class representatives
5. **Faculty** (Case 5): Regular teaching duties, may also be Club Incharge

**Important:** Coordinator is a separate account from faculty. A faculty member who is also a coordinator must use different credentials for each role.

## Component Request Flow

1. Student requests component
2. Lab Incharge approves request
3. Lab Staff updates status (provided/returned)
4. Lab Staff maintains inventory count

## Fab Lab Booking

- Students can book equipment by time slot
- Lab staff can manage bookings
- Auto-cancellation after 15 minutes if not checked in
- Equipment availability tracked in real-time

## Row-Level Security (RLS)

The database uses Supabase RLS policies to enforce:
- Admin-only user CRUD operations
- Coordinator advisor assignment permissions
- Lab staff booking management
- Student self-service limits

## Testing

Run integration tests:
```bash
node scratch/test_suite.js
```

## License

© 2026 Amrita University. All rights reserved.
