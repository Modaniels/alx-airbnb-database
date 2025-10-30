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
-- Composite index for location and price queries
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

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
CREATE INDEX idx_booking_status_date ON Booking(status, start_date);

-- Indexes for Review table
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);
-- Composite index for property reviews with ratings
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- Indexes for Payment table
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_status ON Payment(payment_status);
CREATE INDEX idx_payment_created_at ON Payment(payment_date);
-- Composite index for payment status and date
CREATE INDEX idx_payment_status_date ON Payment(payment_status, payment_date);

-- Indexes for Message table (if exists)
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);

-- Performance measurement queries
-- Before creating indexes, run these queries with EXPLAIN to see execution plans:

-- STEP 1: Measure performance BEFORE creating indexes
-- =====================================================

-- Query 1: Find all bookings for a specific user
-- Measure baseline performance
EXPLAIN ANALYZE SELECT * FROM Booking WHERE user_id = 'user123';

-- Query 2: Find all properties in a specific location with price range
-- Measure baseline performance
EXPLAIN ANALYZE SELECT * FROM Property WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300;

-- Query 3: Find all bookings within a date range
-- Measure baseline performance
EXPLAIN ANALYZE SELECT * FROM Booking WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- Query 4: Find average rating for properties
-- Measure baseline performance
EXPLAIN ANALYZE SELECT property_id, AVG(rating) FROM Review GROUP BY property_id;

-- Query 5: Complex join query
-- Measure baseline performance
EXPLAIN ANALYZE SELECT b.*, u.first_name, u.last_name, p.name 
FROM Booking b 
JOIN User u ON b.user_id = u.user_id 
JOIN Property p ON b.property_id = p.property_id 
WHERE b.status = 'confirmed' AND b.start_date >= '2024-01-01';

-- STEP 2: Create indexes
-- ======================
-- (Indexes are created above)

-- STEP 3: Measure performance AFTER creating indexes
-- ==================================================

-- Re-run the same queries to measure improvements

-- Query 1: Find all bookings for a specific user (should use idx_booking_user_id)
EXPLAIN ANALYZE SELECT * FROM Booking WHERE user_id = 'user123';

-- Query 2: Find properties by location and price (should use idx_property_location and idx_property_pricepernight)
EXPLAIN ANALYZE SELECT * FROM Property WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300;

-- Query 3: Find bookings by date range (should use idx_booking_date_range)
EXPLAIN ANALYZE SELECT * FROM Booking WHERE start_date >= '2024-01-01' AND end_date <= '2024-12-31';

-- Query 4: Property ratings (should use idx_review_property_id)
EXPLAIN ANALYZE SELECT property_id, AVG(rating) FROM Review GROUP BY property_id;

-- Query 5: Complex join query (should use multiple indexes)
EXPLAIN ANALYZE SELECT b.*, u.first_name, u.last_name, p.name 
FROM Booking b 
JOIN User u ON b.user_id = u.user_id 
JOIN Property p ON b.property_id = p.property_id 
WHERE b.status = 'confirmed' AND b.start_date >= '2024-01-01';

-- Additional performance analysis queries
-- ======================================

-- Check index usage statistics
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = DATABASE()
ORDER BY COUNT_FETCH DESC;

-- Monitor query performance improvements
SHOW STATUS LIKE 'Handler_read%';

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