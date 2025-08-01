CREATE DATABASE transport_db;

USE transport_db;

-- Table: routes: route_id, bus_no, origin, destination, departure, arrival, status
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    bus_no VARCHAR(20),
    origin VARCHAR(100),
    destination VARCHAR(100),
    departure TIME,
    arrival TIME,
    status VARCHAR(20)
);

INSERT INTO routes (bus_no, origin, destination, departure, arrival, status) VALUES
('TN01AB1234', 'Coimbatore', 'Madurai', '07:00:00', '11:00:00', 'On Time'),
('TN02CD5678', 'Coimbatore', 'Chennai', '06:30:00', '13:00:00', 'Delayed'),
('TN03EF9101', 'Trichy', 'Sivaganga', '09:00:00', '12:00:00', NULL),
('TN04GH1213', 'Salem', 'Coimbatore', '05:30:00', '09:30:00', 'On Time'),
('TN05IJ1415', 'Coimbatore', 'Madurai', '08:15:00', '12:30:00', NULL),
('TN06KL1617', 'Madurai', 'Chidambaram', '10:00:00', '14:00:00', 'Cancelled'),
('TN07MN1819', 'Erode', 'Nagapattinam', '06:00:00', '10:30:00', 'On Time');

-- Select buses that go from "Coimbatore" to "Madurai".
SELECT bus_no, departure, arrival
FROM routes
WHERE origin = 'Coimbatore' AND destination = 'Madurai';

-- Show bus_no, departure, arrival.
SELECT bus_no, departure, arrival
FROM routes;


-- Use LIKE to match destinations ending in “pur”.
SELECT route_id, bus_no, origin, destination, departure, arrival, status
FROM routes
WHERE destination LIKE '%pur';

-- Use IN for multiple cities.
SELECT route_id, bus_no, origin, destination, departure, arrival, status
FROM routes
WHERE origin IN ('Coimbatore', 'Trichy', 'Salem');

-- Find routes where status IS NULL.
SELECT route_id, bus_no, origin, destination, departure, arrival
FROM routes
WHERE status IS NULL;

-- Sort by departure ASC.
SELECT route_id, bus_no, origin, destination, departure, arrival, status
FROM routes
ORDER BY departure ASC;
