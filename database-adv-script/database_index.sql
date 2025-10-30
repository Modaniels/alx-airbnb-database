-- Task 3: Database Indexing for Performance Optimization
-- ALX Airbnb Database Project

-- Indexes for User table
-- Primary key index (usually created automatically)
-- CREATE INDEX idx_user_email ON User(email); -- If not already unique
CREATE INDEX idx_user_created_at ON User(created_at);
CREATE INDEX idx_user_role ON User(role);

-- Indexes for Property table
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_pricepernight ON Property(pricepernight);
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Indexes for Booking table
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_end_date ON Booking(end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Composite indexes for common query patterns
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);

-- Indexes for Review table
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Indexes for Payment table
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_status ON Payment(payment_status);
CREATE INDEX idx_payment_created_at ON Payment(payment_date);

-- Indexes for Message table (if exists)
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);

-- Performance measurement queries
-- Before creating indexes, run these queries with EXPLAIN to see execution plans:

-- Query 1: Find all bookings for a specific user
-- EXPLAIN SELECT * FROM Booking WHERE user_id = 1;

-- Query 2: Find all properties in a specific location with price range
-- EXPLAIN SELECT * FROM Property WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300;

-- Query 3: Find all bookings within a date range
-- EXPLAIN SELECT * FROM Booking WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- Query 4: Find average rating for properties
-- EXPLAIN SELECT property_id, AVG(rating) FROM Review GROUP BY property_id;

-- Query 5: Complex join query
-- EXPLAIN SELECT b.*, u.first_name, u.last_name, p.name 
-- FROM Booking b 
-- JOIN User u ON b.user_id = u.user_id 
-- JOIN Property p ON b.property_id = p.property_id 
-- WHERE b.status = 'confirmed' AND b.start_date >= '2024-01-01';

-- After creating indexes, run the same EXPLAIN queries to compare performance