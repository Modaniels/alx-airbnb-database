-- Task 5: Table Partitioning for Performance Optimization
-- ALX Airbnb Database Project

-- Step 1: Create a partitioned version of the Booking table
-- Note: This assumes MySQL 5.1+ with partitioning support

-- First, let's create a backup of the original table structure
CREATE TABLE Booking_backup AS SELECT * FROM Booking LIMIT 0;

-- Create the new partitioned Booking table
-- Partitioning by RANGE on start_date column for better query performance on date ranges

DROP TABLE IF EXISTS Booking_partitioned;

CREATE TABLE Booking_partitioned (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    
    -- Indexes for optimal performance
    KEY idx_booking_property_id (property_id),
    KEY idx_booking_user_id (user_id),
    KEY idx_booking_status (status),
    KEY idx_booking_dates (start_date, end_date)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Alternative partitioning strategy: Monthly partitioning for more granular control
DROP TABLE IF EXISTS Booking_monthly_partitioned;

CREATE TABLE Booking_monthly_partitioned (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    
    KEY idx_booking_property_id (property_id),
    KEY idx_booking_user_id (user_id),
    KEY idx_booking_status (status)
)
PARTITION BY RANGE (TO_DAYS(start_date)) (
    PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
    PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
    PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
    PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
    PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
    PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
    PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
    PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
    PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
    PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Hash partitioning alternative for even distribution (when date ranges aren't the primary concern)
DROP TABLE IF EXISTS Booking_hash_partitioned;

CREATE TABLE Booking_hash_partitioned (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    
    KEY idx_booking_property_id (property_id),
    KEY idx_booking_user_id (user_id),
    KEY idx_booking_status (status),
    KEY idx_booking_start_date (start_date)
)
PARTITION BY HASH(CRC32(booking_id))
PARTITIONS 8;

-- Step 2: Migrate data from original table to partitioned table
-- (This would be done in production with proper data migration procedures)

-- Insert sample data for testing (replace with actual data migration)
INSERT INTO Booking_partitioned 
SELECT * FROM Booking;

-- Step 3: Performance testing queries for partitioned vs non-partitioned tables

-- Test Query 1: Date range query (should show partition pruning)
-- This query should only access relevant partitions
EXPLAIN PARTITIONS
SELECT COUNT(*) 
FROM Booking_partitioned 
WHERE start_date BETWEEN '2024-06-01' AND '2024-08-31';

-- Compare with non-partitioned table
EXPLAIN 
SELECT COUNT(*) 
FROM Booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-08-31';

-- Test Query 2: Single date lookup
EXPLAIN PARTITIONS
SELECT * 
FROM Booking_partitioned 
WHERE start_date = '2024-07-15';

-- Test Query 3: Complex query with joins on partitioned table
EXPLAIN PARTITIONS
SELECT 
    b.booking_id,
    b.start_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.name AS property_name
FROM Booking_partitioned b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.start_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND b.status = 'confirmed'
ORDER BY b.start_date;

-- Test Query 4: Aggregation query by partition key
EXPLAIN PARTITIONS
SELECT 
    YEAR(start_date) AS booking_year,
    COUNT(*) AS total_bookings,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS avg_booking_price
FROM Booking_partitioned
WHERE start_date >= '2020-01-01'
GROUP BY YEAR(start_date)
ORDER BY booking_year;

-- Step 4: Partition maintenance operations

-- Add new partition for future dates
ALTER TABLE Booking_partitioned 
ADD PARTITION (PARTITION p2026 VALUES LESS THAN (2027));

-- Drop old partition (be careful - this deletes data!)
-- ALTER TABLE Booking_partitioned DROP PARTITION p2020;

-- Reorganize partitions if needed
-- ALTER TABLE Booking_partitioned REORGANIZE PARTITION p_future INTO (
--     PARTITION p2026 VALUES LESS THAN (2027),
--     PARTITION p_future VALUES LESS THAN MAXVALUE
-- );

-- Step 5: Monitor partition usage
-- Check partition information
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    INDEX_LENGTH,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking_partitioned'
ORDER BY PARTITION_ORDINAL_POSITION;

-- Check query performance on partitions
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    DATA_LENGTH / 1024 / 1024 AS data_size_mb,
    INDEX_LENGTH / 1024 / 1024 AS index_size_mb
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking_partitioned'
  AND PARTITION_NAME IS NOT NULL;

-- Performance comparison query
-- Run this before and after partitioning to measure improvement
SET profiling = 1;

-- Query on original table
SELECT COUNT(*), AVG(total_price) 
FROM Booking 
WHERE start_date BETWEEN '2024-01-01' AND '2024-03-31';

-- Query on partitioned table  
SELECT COUNT(*), AVG(total_price) 
FROM Booking_partitioned 
WHERE start_date BETWEEN '2024-01-01' AND '2024-03-31';

SHOW PROFILES;

-- Step 6: Optimize queries for partition pruning
-- Ensure WHERE clauses include partition key for optimal performance

-- Good: Uses partition key in WHERE clause
SELECT * FROM Booking_partitioned 
WHERE start_date >= '2024-01-01' AND start_date < '2024-07-01'
  AND status = 'confirmed';

-- Good: Range query on partition key
SELECT * FROM Booking_partitioned 
WHERE start_date BETWEEN '2024-06-01' AND '2024-06-30';

-- Suboptimal: No partition key in WHERE clause (scans all partitions)
-- SELECT * FROM Booking_partitioned WHERE status = 'confirmed';

-- Better: Include partition key when possible
SELECT * FROM Booking_partitioned 
WHERE status = 'confirmed' 
  AND start_date >= '2024-01-01';

-- Step 7: Create views for easier access to partitioned data
CREATE VIEW Recent_Bookings AS
SELECT 
    booking_id,
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM Booking_partitioned
WHERE start_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

CREATE VIEW Current_Year_Bookings AS
SELECT 
    booking_id,
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM Booking_partitioned
WHERE YEAR(start_date) = YEAR(CURDATE());