
# Booking + Reservations with Time Slots

## 1. What Our Subsystem Does?

This subsystem allows users to book services for specific dates and time slots. It manages user information, available services, scheduled time slots, and reservations.

Users can make reservations, cancel bookings, and track their booking status. The system prevents multiple active bookings for the same time slot while maintaining cancelled booking records for future reference.

This system can be used for doctor appointments, salon bookings, consultation sessions, and other reservation-based applications.

## 2. Table-by-Table Explanation

### Users
Stores registered user information, including a unique user ID (Primary Key), username, email address, and account creation timestamp.

This table is maintained separately because a single user can make multiple reservations.

### Services
Stores details about the services available for booking. It contains a unique service ID (Primary Key), service name, description, duration, and price.

This table avoids repeating the same service information across multiple booking slots.

### Time_Slots
Stores the available time slots for each service. It contains a unique slot ID (Primary Key), service ID (Foreign Key), booking date, start time, and end time.

This table allows multiple time slots to be created for a particular service.

### Reservations
Stores bookings made by users. It contains a unique reservation ID (Primary Key), user ID (Foreign Key), slot ID (Foreign Key), booking status, notes, and booking timestamp.

The status indicates whether a reservation is BOOKED, CANCELLED, or COMPLETED.

## 3. Relationships

- **Services to Time_Slots (1:M):** The `service_id` foreign key in the Time_Slots table establishes a one-to-many relationship because one service can have multiple booking slots.

- **Users to Reservations (1:M):** The `user_id` foreign key in the Reservations table establishes a one-to-many relationship because one user can make multiple reservations.

- **Time_Slots to Reservations (1:M):** The `slot_id` foreign key in the Reservations table connects each reservation to an existing time slot. A slot can have multiple historical reservations if previous bookings were cancelled, but only one non-cancelled reservation is permitted.

## 4. Design Choice

**Design Choice:** We created a separate Time_Slots table instead of storing the booking date and time directly inside the Reservations table.

Storing scheduling information separately reduces data duplication and allows services to have multiple predefined booking slots.

The alternative approach was to store service details, dates, and timings directly in each reservation record. We rejected this because scheduling information could be repeated, making data management difficult.

We also used a partial unique index to prevent double booking. This allows cancelled reservations to remain in the database while making their slots available for new bookings.

## 5. Indexing

We created indexes on foreign keys and frequently queried columns to improve data retrieval performance.

- `time_slots.service_id` - Retrieves time slots belonging to a particular service.

- `time_slots.(booking_date, start_time)` - A composite index that retrieves booking slots for a selected date in chronological order.

- `reservations.user_id` - Retrieves reservations made by a particular user.

- `reservations.slot_id` - Retrieves reservation records associated with a particular time slot.

- `reservations.status` - Retrieves reservations based on their booking status.

- `uq_reservations_active_slot` - A partial unique index that prevents multiple BOOKED or COMPLETED reservations for the same time slot.

Indexes improve searching and filtering performance. However, they require additional storage and may slightly slow down INSERT, UPDATE, and DELETE operations.

PostgreSQL automatically creates indexes for primary keys and unique constraints, but foreign-key columns are indexed separately when needed.

## 6. Normalisation

The database follows the basic principles of normalization.

### First Normal Form (1NF)
Every table contains atomic values, and each record is uniquely identified using a primary key.

### Second Normal Form (2NF)
All non-key attributes depend on the complete primary key. Each table uses a single-column primary key, avoiding partial dependencies.

### Third Normal Form (3NF)
User details, service information, time slot details, and reservation records are stored in separate tables.

This reduces redundant data and avoids unnecessary update anomalies.

Therefore, the database design follows Third Normal Form (3NF).

## 7. Constraints Used

- **PRIMARY KEY:** Uniquely identifies each record.
- **FOREIGN KEY:** Maintains relationships between tables.
- **NOT NULL:** Prevents missing mandatory values.
- **UNIQUE:** Prevents duplicate usernames, emails, service names, and service slots.
- **CHECK:** Ensures valid duration, price, timings, and reservation status.
- **DEFAULT:** Automatically assigns timestamps and initial booking status.
- **PARTIAL UNIQUE INDEX:** Prevents double booking while retaining cancelled reservation history.

## 8. Conclusion

The Booking and Reservations subsystem demonstrates relational database design using primary keys, foreign keys, constraints, indexes, and normalization.

It provides an organized structure for managing users, services, available time slots, and reservations while preventing duplicate active bookings and reducing unnecessary data duplication.