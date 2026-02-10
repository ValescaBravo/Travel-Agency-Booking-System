/* ============================================================================
   03_reporting_queries.sql — Reporting Queries (MySQL)
   Schema: Client, Package, Reservation
   ============================================================================ */

-- R1) Reservations by month (volume trend)
SELECT
  DATE_FORMAT(r.TravelDate, '%Y-%m') AS year_month,
  COUNT(*) AS reservations
FROM Reservation r
GROUP BY 1
ORDER BY 1;

-- R2) Revenue (sum of prices) by month
SELECT
  DATE_FORMAT(r.TravelDate, '%Y-%m') AS year_month,
  SUM(r.Price) AS total_revenue
FROM Reservation r
GROUP BY 1
ORDER BY 1;

-- R3) Average booking value by month
SELECT
  DATE_FORMAT(r.TravelDate, '%Y-%m') AS year_month,
  AVG(r.Price) AS avg_booking_value
FROM Reservation r
GROUP BY 1
ORDER BY 1;

-- R4) Packages per client (repeat purchasing distribution)
SELECT
  p.ClientID,
  COUNT(*) AS packages_count
FROM Package p
GROUP BY p.ClientID
ORDER BY packages_count DESC, p.ClientID;

-- R5) Top destinations (by number of packages)
SELECT
  p.Destination,
  COUNT(*) AS packages
FROM Package p
GROUP BY p.Destination
ORDER BY packages DESC, p.Destination;

-- R6) Destination revenue (sum of reservation prices by destination)
SELECT
  p.Destination,
  SUM(r.Price) AS total_revenue
FROM Package p
JOIN Reservation r ON r.PackageCode = p.PackageCode
GROUP BY p.Destination
ORDER BY SUM(r.Price) DESC, p.Destination;

-- R7) Client booking history (join view)
SELECT
  c.ClientID,
  c.FirstName,
  c.LastName,
  c.Email,
  p.PackageCode,
  p.Destination,
  p.TransportType,
  p.AccommodationType,
  r.ReservationID,
  r.TravelDate,
  r.NumberOfPeople,
  r.Price
FROM Client c
JOIN Package p       ON p.ClientID = c.ClientID
JOIN Reservation r   ON r.PackageCode = p.PackageCode
ORDER BY c.ClientID, r.TravelDate;

-- R8) Data completeness snapshot (optional fields coverage)
SELECT
  COUNT(*) AS n_clients,
  SUM(CASE WHEN c.Gender IS NOT NULL THEN 1 ELSE 0 END) AS gender_filled,
  SUM(CASE WHEN c.MobileNumber IS NOT NULL THEN 1 ELSE 0 END) AS mobile_filled,
  SUM(CASE WHEN c.YearOfBirth IS NOT NULL THEN 1 ELSE 0 END) AS yob_filled,
  ROUND(100 * SUM(CASE WHEN c.Gender IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS gender_filled_pct,
  ROUND(100 * SUM(CASE WHEN c.MobileNumber IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS mobile_filled_pct,
  ROUND(100 * SUM(CASE WHEN c.YearOfBirth IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS yob_filled_pct
FROM Client c;
