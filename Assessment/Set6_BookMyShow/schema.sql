CREATE TYPE seat_tier AS ENUM ('GOLD', 'SILVER', 'PLATINUM');
CREATE TYPE booking_status AS ENUM ('CONFIRMED', 'CANCELLED');

CREATE TABLE app_user (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE movie (
    movie_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    duration_minutes SMALLINT NOT NULL CHECK (duration_minutes > 0),
    language VARCHAR(50),
    certificate VARCHAR(10),
    release_date DATE
);

CREATE TABLE cinema (
    cinema_id BIGSERIAL PRIMARY KEY,
    cinema_name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE screen (
    screen_id BIGSERIAL PRIMARY KEY,
    cinema_id BIGINT NOT NULL REFERENCES cinema(cinema_id) ON DELETE CASCADE,
    screen_name VARCHAR(50) NOT NULL,
    UNIQUE (cinema_id, screen_name)
);

CREATE TABLE seat (
    seat_id BIGSERIAL PRIMARY KEY,
    screen_id BIGINT NOT NULL REFERENCES screen(screen_id) ON DELETE CASCADE,
    seat_row VARCHAR(5) NOT NULL,
    seat_number SMALLINT NOT NULL CHECK (seat_number > 0),
    tier seat_tier NOT NULL,
    UNIQUE (screen_id, seat_row, seat_number)
);

CREATE TABLE movie_show (
    show_id BIGSERIAL PRIMARY KEY,
    movie_id BIGINT NOT NULL REFERENCES movie(movie_id) ON DELETE RESTRICT,
    screen_id BIGINT NOT NULL REFERENCES screen(screen_id) ON DELETE RESTRICT,
    starts_at TIMESTAMPTZ NOT NULL,
    UNIQUE (screen_id, starts_at)
);

CREATE TABLE show_price (
    show_id BIGINT NOT NULL REFERENCES movie_show(show_id) ON DELETE CASCADE,
    tier seat_tier NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    PRIMARY KEY (show_id, tier)
);

CREATE TABLE booking (
    show_id BIGINT NOT NULL REFERENCES movie_show(show_id) ON DELETE RESTRICT,
    booking_no BIGINT NOT NULL CHECK (booking_no > 0),
    user_id UUID NOT NULL REFERENCES app_user(user_id) ON DELETE RESTRICT,
    status booking_status NOT NULL DEFAULT 'CONFIRMED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cancelled_at TIMESTAMPTZ,
    PRIMARY KEY (show_id, booking_no),
    CHECK ((status = 'CONFIRMED' AND cancelled_at IS NULL) OR (status = 'CANCELLED' AND cancelled_at IS NOT NULL))
);

CREATE TABLE booking_seat (
    show_id BIGINT NOT NULL,
    seat_id BIGINT NOT NULL REFERENCES seat(seat_id) ON DELETE RESTRICT,
    booking_no BIGINT NOT NULL,
    booked_price NUMERIC(10,2) NOT NULL CHECK (booked_price >= 0),
    PRIMARY KEY (show_id, seat_id),
    FOREIGN KEY (show_id, booking_no) REFERENCES booking(show_id, booking_no) ON DELETE CASCADE
);

CREATE INDEX idx_seat_screen ON seat(screen_id);
CREATE INDEX idx_movie_show_movie_time ON movie_show(movie_id, starts_at);
CREATE INDEX idx_movie_show_screen_time ON movie_show(screen_id, starts_at);
CREATE INDEX idx_booking_user_created ON booking(user_id, created_at DESC);
CREATE INDEX idx_booking_seat_booking ON booking_seat(show_id, booking_no);
CREATE INDEX idx_cinema_city ON cinema(city);

CREATE FUNCTION validate_booking_seat()
RETURNS TRIGGER AS $$
DECLARE
    booked_screen BIGINT;
    seat_screen BIGINT;
    booking_state booking_status;
BEGIN
    SELECT screen_id INTO booked_screen FROM movie_show WHERE show_id = NEW.show_id;
    SELECT screen_id INTO seat_screen FROM seat WHERE seat_id = NEW.seat_id;
    SELECT status INTO booking_state FROM booking WHERE show_id = NEW.show_id AND booking_no = NEW.booking_no;
    IF booked_screen IS DISTINCT FROM seat_screen THEN
        RAISE EXCEPTION 'Seat does not belong to the screen for this show';
    END IF;
    IF booking_state IS DISTINCT FROM 'CONFIRMED'::booking_status THEN
        RAISE EXCEPTION 'Seats can only be assigned to a confirmed booking';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_booking_seat
BEFORE INSERT OR UPDATE ON booking_seat
FOR EACH ROW EXECUTE FUNCTION validate_booking_seat();

CREATE FUNCTION validate_booking_cancellation()
RETURNS TRIGGER AS $$
DECLARE
    show_start TIMESTAMPTZ;
BEGIN
    IF OLD.status = 'CANCELLED' AND NEW.status <> 'CANCELLED' THEN
        RAISE EXCEPTION 'Cancelled bookings cannot be reactivated';
    END IF;
    IF OLD.status = 'CONFIRMED' AND NEW.status = 'CANCELLED' THEN
        SELECT starts_at INTO show_start FROM movie_show WHERE show_id = OLD.show_id;
        IF NOW() >= show_start - INTERVAL '1 hour' THEN
            RAISE EXCEPTION 'Cancellation not allowed within 1 hour of show start';
        END IF;
        NEW.cancelled_at := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_booking_cancellation
BEFORE UPDATE ON booking
FOR EACH ROW EXECUTE FUNCTION validate_booking_cancellation();

CREATE FUNCTION release_cancelled_booking_seats()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'CONFIRMED' AND NEW.status = 'CANCELLED' THEN
        DELETE FROM booking_seat WHERE show_id = NEW.show_id AND booking_no = NEW.booking_no;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_release_cancelled_booking_seats
AFTER UPDATE OF status ON booking
FOR EACH ROW EXECUTE FUNCTION release_cancelled_booking_seats();
