
-- BOOKING + RESERVATIONS WITH TIME SLOTS

-- Users Table
CREATE TABLE users (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Services Table
CREATE TABLE services (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);

-- Time Slots Table
CREATE TABLE time_slots (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id INT NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CHECK (end_time > start_time),
    UNIQUE (service_id, booking_date, start_time)
);

-- Reservations Table
CREATE TABLE reservations (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    slot_id INT NOT NULL REFERENCES time_slots(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'BOOKED',
    notes VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (status IN ('BOOKED', 'CANCELLED', 'COMPLETED'))
);

-- Indexes for Foreign Keys
CREATE INDEX idx_time_slots_service_id
ON time_slots(service_id);

CREATE INDEX idx_reservations_user_id
ON reservations(user_id);

CREATE INDEX idx_reservations_slot_id
ON reservations(slot_id);

-- Composite Index for Date and Time
CREATE INDEX idx_time_slots_date_start
ON time_slots(booking_date, start_time);

-- Index for Booking Status
CREATE INDEX idx_reservations_status
ON reservations(status);

-- Prevent Double Booking
-- Cancelled reservations are excluded so slots can be rebooked
CREATE UNIQUE INDEX uq_reservations_active_slot
ON reservations(slot_id)
WHERE status IN ('BOOKED', 'COMPLETED');