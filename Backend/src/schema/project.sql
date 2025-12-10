--USER
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT,
    role TEXT CHECK(role IN ('student','teacher','admin')) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    isVerified BOOLEAN DEFAULT FALSE,
    isActive BOOLEAN DEFAULT TRUE
); 

--STUDENT
CREATE TABLE IF NOT EXISTS students ( 
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    roll_no TEXT UNIQUE NOT NULL,
    sname TEXT NOT NULL,
    semester INT CHECK(semester BETWEEN 1 AND 10),
    programme TEXT,
    batch INT,
    photo_url TEXT,
    isBlocked BOOLEAN DEFAULT FALSE
);

--TEACHER
CREATE TABLE IF NOT EXISTS teachers (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    abbr TEXT UNIQUE NOT NULL,
    tname TEXT NOT NULL,
    designation TEXT,
    dept TEXT,
    photo_url TEXT
);

--EMAIL VERIFICATION
CREATE TABLE IF NOT EXISTS email_verification_tokens (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL
);

--REFRESH TOKENS
CREATE TABLE IF NOT EXISTS refresh_tokens (
  token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
  token_hash TEXT,
  expires_at TIMESTAMP NOT NULL,
  revoked BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- SUBJECTS (Master Catalog)

CREATE TABLE IF NOT EXISTS subjects (
    code TEXT PRIMARY KEY,                 -- Subject code like CS101
    course_name TEXT NOT NULL,             -- Human-readable name
    teacher_id UUID REFERENCES teachers(user_id) 
                ON DELETE SET NULL         -- Optional subject coordinator
);


-- =====================================
-- COURSE OFFERINGS (Actual Class Running)
-- =====================================
CREATE TABLE IF NOT EXISTS course_offerings (
    course_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Link this offering to a subject
    code TEXT REFERENCES subjects(code)
                ON DELETE SET NULL,
    -- Teacher actually teaching this offering
    teacher_id UUID REFERENCES teachers(user_id)
                ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);


-- ================================
-- STUDENT ENROLLMENT IN OFFERINGS
-- ================================
CREATE TABLE IF NOT EXISTS student_enrollments (
    enrollment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Which student?
    student_id UUID REFERENCES students(user_id)
                ON DELETE CASCADE,

    -- Enrolled in which course offering?
    course_id UUID REFERENCES course_offerings(course_id)
                ON DELETE CASCADE,

    -- Prevent a student from joining the same course twice
    UNIQUE(student_id, course_id)
);

CREATE TABLE IF NOT EXISTS attendance (
    attendance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Which student?
    student_id UUID REFERENCES students(user_id)
                ON DELETE CASCADE,

    -- Which course offering?
    course_id UUID REFERENCES course_offerings(course_id)
                ON DELETE CASCADE,

    -- Attendance date
    attendance_date DATE NOT NULL,

    -- Present or Absent
    present BOOLEAN NOT NULL,

    -- Timestamp
    created_at TIMESTAMP DEFAULT NOW(),

    -- Prevent duplicate attendance for the same student on same date for the same course
    UNIQUE(student_id, course_id, attendance_date)
);

--QR SESSION
CREATE TABLE IF NOT EXISTS qr_sessions (
    qr_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES course_offerings(course_id),
    location_created_from TEXT,
    timespan_seconds INT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    scan_count INT DEFAULT 0
);

--ATTENDANCE 
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scan_id UUID UNIQUE REFERENCES scan_events(scan_id),
    student_id UUID REFERENCES students(user_id),
    course_id UUID REFERENCES course_offerings(course_id),
    status TEXT CHECK(status IN ('present','absent')),
    scanned_time TIMESTAMP,
    photo_url TEXT,
    location_scanned_from TEXT,
    date DATE NOT NULL
);

--SCAN EVENT
CREATE TABLE IF NOT EXISTS scan_events (
    scan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    qr_id UUID REFERENCES qr_sessions(qr_id),
    student_id UUID REFERENCES students(user_id),
    scan_time TIMESTAMP DEFAULT NOW(),
    device_fingerprint TEXT,
    device_meta JSONB,
    ip_address TEXT,
    geo TEXT,
    token_age_seconds INT,
    ml_score DOUBLE PRECISION,
    status TEXT DEFAULT 'new',
    created_at TIMESTAMP DEFAULT NOW()
);

--VERIFICATION LOGS
CREATE TABLE IF NOT EXISTS verification_logs (
    verify_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scan_id UUID REFERENCES scan_events(scan_id),
    teacher_id UUID REFERENCES teachers(user_id),
    verification_time TIMESTAMP DEFAULT NOW(),
    result TEXT CHECK(result IN ('accepted','rejected')),
    comment TEXT
);

--REPORTS
CREATE TABLE IF NOT EXISTS reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teachers(user_id),
    course_id UUID REFERENCES course_offerings(course_id),
    report_type TEXT,
    generated_at TIMESTAMP DEFAULT NOW(),
    file_url TEXT
);

--DELETED USERS
CREATE TABLE deleted_users (
    deleted_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    email TEXT,
    role TEXT,
    deleted_by UUID NOT NULL REFERENCES users(user_id),
    deleted_at TIMESTAMPTZ DEFAULT NOW()
);
