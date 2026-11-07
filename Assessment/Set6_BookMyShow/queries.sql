SELECT s.seat_id, s.seat_row, s.seat_number, s.tier, sp.price
FROM movie_show ms
JOIN seat s ON s.screen_id = ms.screen_id
JOIN show_price sp ON sp.show_id = ms.show_id AND sp.tier = s.tier
WHERE ms.show_id = $1
AND NOT EXISTS (
    SELECT 1 FROM booking_seat bs
    WHERE bs.show_id = ms.show_id AND bs.seat_id = s.seat_id
)
ORDER BY s.seat_row, s.seat_number;

SELECT ms.show_id, m.title, c.cinema_name, sc.screen_name, ms.starts_at
FROM movie_show ms
JOIN movie m ON m.movie_id = ms.movie_id
JOIN screen sc ON sc.screen_id = ms.screen_id
JOIN cinema c ON c.cinema_id = sc.cinema_id
WHERE ms.movie_id = $1 AND ms.starts_at > NOW()
ORDER BY ms.starts_at;

SELECT b.booking_no, b.show_id, m.title, ms.starts_at, b.status, b.created_at
FROM booking b
JOIN movie_show ms ON ms.show_id = b.show_id
JOIN movie m ON m.movie_id = ms.movie_id
WHERE b.user_id = $1
ORDER BY b.created_at DESC;

SELECT bs.show_id, bs.booking_no, s.seat_row, s.seat_number, s.tier, bs.booked_price
FROM booking_seat bs
JOIN seat s ON s.seat_id = bs.seat_id
WHERE bs.show_id = $1 AND bs.booking_no = $2
ORDER BY s.seat_row, s.seat_number;

INSERT INTO booking (show_id, booking_no, user_id)
VALUES ($1, $2, $3);

INSERT INTO booking_seat (show_id, seat_id, booking_no, booked_price)
VALUES ($1, $2, $3, $4);

UPDATE booking
SET status = 'CANCELLED'
WHERE show_id = $1 AND booking_no = $2 AND status = 'CONFIRMED';

EXPLAIN (ANALYZE, BUFFERS)
SELECT s.seat_id, s.seat_row, s.seat_number, s.tier
FROM movie_show ms
JOIN seat s ON s.screen_id = ms.screen_id
WHERE ms.show_id = $1
AND NOT EXISTS (
    SELECT 1 FROM booking_seat bs
    WHERE bs.show_id = ms.show_id AND bs.seat_id = s.seat_id
);