-- Task 1: Practice Subqueries
-- ALX Airbnb Database Project

-- Query 1: Find all properties where the average rating is greater than 4.0 using a subquery
SELECT 
    p.property_id,
    p.name,
    p.description,
    p.location,
    p.pricepernight,
    (SELECT AVG(r.rating) 
     FROM Review r 
     WHERE r.property_id = p.property_id) AS average_rating
FROM 
    Property p
WHERE 
    p.property_id IN (
        SELECT r.property_id
        FROM Review r
        GROUP BY r.property_id
        HAVING AVG(r.rating) > 4.0
    )
ORDER BY 
    average_rating DESC;

-- Query 2: Correlated subquery to find users who have made more than 3 bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS booking_count
FROM 
    User u
WHERE 
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) > 3
ORDER BY 
    booking_count DESC;

-- Alternative approach using EXISTS for better performance
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number
FROM 
    User u
WHERE 
    EXISTS (
        SELECT 1
        FROM Booking b
        WHERE b.user_id = u.user_id
        GROUP BY b.user_id
        HAVING COUNT(*) > 3
    );