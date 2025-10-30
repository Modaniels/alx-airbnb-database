-- Task 2: Aggregations and Window Functions
-- ALX Airbnb Database Project

-- Query 1: Total number of bookings made by each user using COUNT function and GROUP BY clause
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    AVG(b.total_price) AS average_booking_price,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.start_date) AS latest_booking_date
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
ORDER BY 
    total_bookings DESC, total_spent DESC;

-- Query 2: Window function to rank properties based on the total number of bookings they have received
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_number,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_by_bookings,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank_by_bookings
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;

-- Additional window function example: Running total of bookings by date
SELECT 
    b.booking_id,
    b.start_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    SUM(b.total_price) OVER (ORDER BY b.start_date) AS running_total_revenue,
    AVG(b.total_price) OVER (ORDER BY b.start_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_price,
    LAG(b.total_price, 1) OVER (ORDER BY b.start_date) AS previous_booking_price,
    LEAD(b.total_price, 1) OVER (ORDER BY b.start_date) AS next_booking_price
FROM 
    Booking b
JOIN 
    User u ON b.user_id = u.user_id
JOIN 
    Property p ON b.property_id = p.property_id
ORDER BY 
    b.start_date;

-- Window function to partition by property and rank bookings within each property
SELECT 
    b.booking_id,
    p.property_id,
    p.name AS property_name,
    b.start_date,
    b.total_price,
    ROW_NUMBER() OVER (PARTITION BY p.property_id ORDER BY b.start_date) AS booking_sequence,
    RANK() OVER (PARTITION BY p.property_id ORDER BY b.total_price DESC) AS price_rank_within_property,
    FIRST_VALUE(b.total_price) OVER (PARTITION BY p.property_id ORDER BY b.start_date) AS first_booking_price,
    LAST_VALUE(b.total_price) OVER (PARTITION BY p.property_id ORDER BY b.start_date RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_booking_price
FROM 
    Booking b
JOIN 
    Property p ON b.property_id = p.property_id
ORDER BY 
    p.property_id, b.start_date;