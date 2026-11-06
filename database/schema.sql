-- 1. PARENTS / CLIENTS TABLE
CREATE TABLE parents (
    parent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    emergency_contact VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. NANNIES / CAREGIVERS TABLE (DoD IC & ER Nurse Credentials)
CREATE TABLE nannies (
    nanny_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(50) NOT NULL,
    rn_license_number VARCHAR(100), -- Verified by ER Nurse Co-Founder
    cpr_certified_until DATE,
    background_check_status VARCHAR(50) DEFAULT 'PASSED',
    security_clearance_level VARCHAR(100) DEFAULT 'DoD Intelligence Vetted',
    is_on_call BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. MDM HARDWARE FLEET TABLE
CREATE TABLE mdm_devices (
    device_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    asset_tag VARCHAR(50) UNIQUE NOT NULL,
    assigned_nanny_id UUID REFERENCES nannies(nanny_id) ON DELETE SET NULL,
    mdm_enrolled_status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. SHIFTS / DISPATCH REQUESTS TABLE
CREATE TABLE shifts (
    shift_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES parents(parent_id) ON DELETE CASCADE,
    nanny_id UUID REFERENCES nannies(nanny_id) ON DELETE CASCADE,
    shift_type VARCHAR(50) DEFAULT 'URGENT_BACKUP', -- URGENT_BACKUP, GUARDIAN_SECURE
    status VARCHAR(50) DEFAULT 'DISPATCHED', -- DISPATCHED, IN_PROGRESS, COMPLETED
    scheduled_start TIMESTAMP WITH TIME ZONE NOT NULL,
    scheduled_end TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. SHIFT SESSIONS & QR CHECK-IN AUDIT TABLE
CREATE TABLE shift_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shift_id UUID REFERENCES shifts(shift_id) ON DELETE CASCADE,
    device_id UUID REFERENCES mdm_devices(device_id),
    actual_check_in TIMESTAMP WITH TIME ZONE,
    actual_check_out TIMESTAMP WITH TIME ZONE,
    qr_token_hash VARCHAR(255),
    session_status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. REAL-TIME LOCATION & MILESTONE AUDIT LOGS
CREATE TABLE location_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES shift_sessions(session_id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    milestone_tag VARCHAR(100), -- e.g., 'ARRIVED_QR_SCANNED', 'FIRST_AID_CHECK', 'BEDTIME'
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shifts_parent ON shifts(parent_id);
CREATE INDEX idx_location_logs_session ON location_logs(session_id, recorded_at);
