
# BookMyShow - PostgreSQL Database Design

## Scenario: BookMyShow - Movie Ticket Booking

Design a PostgreSQL schema for BookMyShow. Movies have multiple shows across cinemas and screens; each show is on one screen at one datetime. A screen has seats arranged by row & column with tier (gold, silver, platinum). Users book one or more seats for a show; a seat cannot be double-booked. Need: (a) prevent two users from booking the same seat for the same show, (b) show available seats for a given show in < 100ms, (c) cancel a booking within 1 hour of show start is disallowed.
Your answer must include ALL of the following, and will be marked on each:
(a) Entity list & table list with a short one-liner for each table (5 marks)
(b) Every foreign-key relationship, with ON DELETE behaviour chosen and justified (5 marks)
(c) Every index you propose, with the query it supports (5 marks)
(d) The normal form reached (1NF, 2NF, 3NF, BCNF) with ONE-LINE justification per form (10 marks)
(e) Full PostgreSQL DDL - CREATE TYPE / CREATE TABLE / CREATE INDEX statements (15 marks)

## A. Entity and Table List 

The database consists of nine tables.

| Table | Description |
|---|---|
| app_user | Stores user details including name, email and phone number. |
| movie | Stores movie information such as title, duration, language and release date. |
| cinema | Stores cinema name, location and address. |
| screen | Stores individual screens belonging to a cinema. |
| seat | Stores seat rows, numbers and tiers for each screen. |
| movie_show | Stores movie schedules with the assigned screen and start time. |
| show_price | Stores tier-wise pricing for each show. |
| booking | Stores user bookings and cancellation details. |
| booking_seat | Stores seats allocated to each booking. |

### Main Relationships

- One cinema has multiple screens.
- One screen contains multiple seats.
- One movie can have multiple shows.
- One screen can host multiple shows at different times.
- One user can make multiple bookings.
- One booking can contain multiple seats.
- One show has separate prices for different seat tiers.

## B. Foreign Keys and ON DELETE Behaviour 

| Child Table | Referenced Table | ON DELETE | Reason |
|---|---|---|---|
| screen | cinema | CASCADE | Screens depend on their cinema. |
| seat | screen | CASCADE | Seats belong to a specific screen. |
| movie_show | movie | RESTRICT | Prevents removing movies with scheduled shows. |
| movie_show | screen | RESTRICT | Prevents deleting screens with scheduled shows. |
| show_price | movie_show | CASCADE | Show-specific prices are removed with the show. |
| booking | movie_show | RESTRICT | Protects shows containing booking records. |
| booking | app_user | RESTRICT | Preserves booking references to users. |
| booking_seat | seat | RESTRICT | Protects seats referenced by active allocations. |
| booking_seat | booking | CASCADE | Seat allocations depend on their booking. |


CASCADE is used for dependent records, while RESTRICT protects records that are still referenced.

## C. Indexes and Supported Queries 

Indexes are created to improve frequently executed database queries.

| Index | Columns | Query Supported |
|---|---|---|
| idx_seat_screen | screen_id | Retrieve seats belonging to a screen. |
| idx_movie_show_movie_time | movie_id, starts_at | Find upcoming shows for a movie. |
| idx_movie_show_screen_time | screen_id, starts_at | Find shows scheduled on a screen. |
| idx_booking_user_created | user_id, created_at | Retrieve booking history for a user. |
| idx_booking_seat_booking | show_id, booking_no | Retrieve seats associated with a booking. |
| idx_cinema_city | city | Search cinemas by city. |

Primary keys and UNIQUE constraints also create supporting indexes automatically.

### Preventing Double Booking

The booking_seat table has the primary key:

```sql
PRIMARY KEY (show_id, seat_id)
```

This ensures that a seat can be allocated only once for a particular show.

For example:

| Show ID | Seat ID | Result |
|---|---|---|
| 101 | 5 | Allowed |
| 101 | 6 | Allowed |
| 102 | 5 | Allowed |
| 101 | 5 | Rejected |

The same physical seat can be booked for another show, but cannot be booked twice for the same show.

### Seat Availability

The availability query uses NOT EXISTS to exclude already booked seats.

```sql
SELECT s.seat_id, s.seat_row, s.seat_number, s.tier
FROM movie_show ms
JOIN seat s ON s.screen_id = ms.screen_id
WHERE ms.show_id = $1
AND NOT EXISTS (
    SELECT 1 FROM booking_seat bs
    WHERE bs.show_id = ms.show_id AND bs.seat_id = s.seat_id
);
```

The index on seat(screen_id) and the primary key index on booking_seat(show_id, seat_id) support efficient seat lookups.

The target response time is below 100 ms. Actual performance must be measured using EXPLAIN ANALYZE with representative test data.

## D. Database Normalisation 

The database is structured to minimise redundancy and maintain data consistency.

### First Normal Form (1NF)

All tables contain atomic values and do not store repeating groups.

For example, multiple seats in a booking are stored as separate rows in booking_seat rather than as a comma-separated list.

### Second Normal Form (2NF)

The tables satisfy 1NF, and non-key attributes depend on complete candidate keys rather than only part of a composite candidate key.

For example, in show_price, the ticket price depends on the combination of show_id and tier.

### Third Normal Form (3NF)

The tables satisfy 2NF and avoid transitive dependencies of non-prime attributes on candidate keys.

For example, cinema details are stored in cinema rather than repeated in screen or movie_show.

Similarly, movie information is stored in movie and referenced through movie_id.

### Boyce-Codd Normal Form (BCNF)

BCNF requires every determinant of a non-trivial functional dependency to be a superkey.

In the proposed design:

- Movie details depend on movie_id.
- Cinema details depend on cinema_id.
- Screen details depend on screen_id or the unique cinema-and-screen-name combination.
- Seat details depend on seat_id or the unique screen-and-seat-position combination.
- Show details depend on show_id.
- Show prices depend on (show_id, tier).
- Booking details depend on (show_id, booking_no).
- Active seat allocations depend on (show_id, seat_id).
