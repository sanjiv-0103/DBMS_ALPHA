
-- BOOKING + RESERVATIONS WITH TIME SLOTS

-- 1. USERS TABLE
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SERVICES TABLE
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CHECK (duration_minutes > 0),
    CHECK (price >= 0)
);

-- 3. RESOURCES TABLE
CREATE TABLE resources (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    capacity INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    CHECK (capacity > 0)
);

-- 4. TIME SLOTS TABLE
CREATE TABLE time_slots (
    id SERIAL PRIMARY KEY,
    resource_id INTEGER NOT NULL,
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (resource_id)
        REFERENCES resources(id),

    UNIQUE (resource_id, slot_date, start_time),
    CHECK (end_time > start_time)
);

-- 5. RESERVATIONS TABLE
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    time_slot_id INTEGER NOT NULL,
    status VARCHAR(30) DEFAULT 'pending',
    total_amount DECIMAL(10,2),
    booked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(id),

    FOREIGN KEY (service_id)
        REFERENCES services(id),

    FOREIGN KEY (time_slot_id)
        REFERENCES time_slots(id),

    CHECK (status IN (
        'pending',
        'confirmed',
        'cancelled',
        'completed'
    )),

    CHECK (total_amount >= 0)
);

-- 6. PAYMENTS TABLE
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    reservation_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30) DEFAULT 'pending',
    transaction_reference VARCHAR(100) UNIQUE,
    paid_at TIMESTAMP,

    FOREIGN KEY (reservation_id)
        REFERENCES reservations(id),

    CHECK (amount >= 0),

    CHECK (payment_status IN (
        'pending',
        'completed',
        'failed',
        'refunded'
    ))
);

-- 7. VERIFY TABLE CREATION
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
    'users',
    'services',
    'resources',
    'time_slots',
    'reservations',
    'payments'
)
ORDER BY table_name;
