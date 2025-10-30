-- Task 4: Complex Query Performance Optimization
-- ALX Airbnb Database Project

-- Initial Query: Retrieve all bookings with user details, property details, and payment details
-- This is the baseline query before optimization
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    b.created_at AS booking_created,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role AS user_role,
    u.created_at AS user_created,
    
    -- Property details  
    p.property_id,
    p.host_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created,
    
    -- Payment details
    py.payment_id,
    py.amount AS payment_amount,
    py.payment_date,
    py.payment_method,
    py.payment_status
FROM 
    Booking b
LEFT JOIN 
    User u ON b.user_id = u.user_id
LEFT JOIN 
    Property p ON b.property_id = p.property_id
LEFT JOIN 
    Payment py ON b.booking_id = py.booking_id
ORDER BY 
    b.created_at DESC;

-- Performance Analysis Query
-- Use this to analyze the above query's performance
-- EXPLAIN ANALYZE SELECT ... (above query)

-- Optimized Query Version 1: Selective Column Retrieval
-- Retrieve only essential columns to reduce data transfer
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Essential user details only
    u.first_name,
    u.last_name,
    u.email,
    
    -- Essential property details only
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    -- Essential payment details only
    py.amount AS payment_amount,
    py.payment_status
FROM 
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id
INNER JOIN 
    Property p ON b.property_id = p.property_id
LEFT JOIN 
    Payment py ON b.booking_id = py.booking_id
WHERE 
    b.status IN ('confirmed', 'completed')
ORDER BY 
    b.start_date DESC
LIMIT 1000;

-- Optimized Query Version 2: Using Indexes and Filtered Results
-- Add WHERE clauses to leverage indexes and reduce result set
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location,
    py.amount AS payment_amount,
    py.payment_status
FROM 
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id
INNER JOIN 
    Property p ON b.property_id = p.property_id
LEFT JOIN 
    Payment py ON b.booking_id = py.booking_id
WHERE 
    b.start_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    AND b.status = 'confirmed'
    AND p.pricepernight > 0
ORDER BY 
    b.start_date DESC;

-- Optimized Query Version 3: Subquery Optimization for Specific Use Cases
-- Use subqueries to pre-filter data before joins
SELECT 
    booking_data.booking_id,
    booking_data.start_date,
    booking_data.end_date,
    booking_data.total_price,
    booking_data.status,
    booking_data.first_name,
    booking_data.last_name,
    booking_data.email,
    booking_data.property_name,
    booking_data.location,
    py.amount AS payment_amount,
    py.payment_status
FROM (
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        u.first_name,
        u.last_name,
        u.email,
        p.name AS property_name,
        p.location
    FROM 
        Booking b
    INNER JOIN 
        User u ON b.user_id = u.user_id
    INNER JOIN 
        Property p ON b.property_id = p.property_id
    WHERE 
        b.start_date >= '2024-01-01'
        AND b.status = 'confirmed'
) booking_data
LEFT JOIN 
    Payment py ON booking_data.booking_id = py.booking_id
ORDER BY 
    booking_data.start_date DESC;

-- Optimized Query Version 4: Using Window Functions for Better Performance
-- Replace correlated subqueries with window functions where applicable
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    py.amount AS payment_amount,
    py.payment_status,
    
    -- Window functions for additional insights without additional queries
    ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY b.start_date DESC) as user_booking_rank,
    COUNT(*) OVER (PARTITION BY p.property_id) as total_property_bookings,
    AVG(b.total_price) OVER (PARTITION BY p.property_id) as avg_property_price
FROM 
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id
INNER JOIN 
    Property p ON b.property_id = p.property_id
LEFT JOIN 
    Payment py ON b.booking_id = py.booking_id
WHERE 
    b.status IN ('confirmed', 'completed')
    AND b.start_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY 
    b.start_date DESC;

-- Query for Performance Testing
-- Use this to compare execution times before and after optimization
SELECT 
    'Original Query' as query_type,
    COUNT(*) as result_count,
    NOW() as execution_time
FROM (
    -- Original complex query here
    SELECT b.booking_id
    FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN Payment py ON b.booking_id = py.booking_id
) original

UNION ALL

SELECT 
    'Optimized Query' as query_type,
    COUNT(*) as result_count,
    NOW() as execution_time
FROM (
    -- Optimized query here
    SELECT b.booking_id
    FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN Payment py ON b.booking_id = py.booking_id
    WHERE b.status = 'confirmed'
) optimized;