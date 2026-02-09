/* ============================================================================
   validation_queries.sql — Validation Queries (MySQL)
   Schema: Client, Package, Reservation
   ============================================================================ */


-- A) Primary key integrity (duplicates / nulls)

-- A1) Duplicate ClientIDs 
SELECT ClientID, COUNT(*) AS n
FROM Client
GROUP BY ClientID
HAVING COUNT(*) > 1;

-- A2) Null ClientID
SELECT *
FROM Client
WHERE ClientID IS NULL;

-- A3) Duplicate PackageCodes
SELECT PackageCode, COUNT(*) AS n
FROM Package
GROUP BY PackageCode
HAVING COUNT(*) > 1;

-- A4) Duplicate ReservationIDs
SELECT ReservationID, COUNT(*) AS n
FROM Reservation
GROUP BY ReservationID
HAVING COUNT(*) > 1;



-- B) Foreign key integrity (orphans)


-- B1) Orphan packages (Package.ClientID not found in Client.ClientID)
SELECT p.*
FROM Package p
LEFT JOIN Client c ON c.ClientID = p.ClientID
WHERE c.ClientID IS NULL;

-- B2) Orphan reservations (Reservation.PackageCode not found in Package.PackageCode)
SELECT r.*
FROM Reservation r
LEFT JOIN Package p ON p.PackageCode = r.PackageCode
WHERE p.PackageCode IS NULL;


-- C) 1-to-1 enforcement (one reservation per package)
-- Expectation: one reservation per package (enforced by a UNIQUE constraint).
-- We still run this check to confirm the rule holds in the loaded dataset.
-- C1) More than one reservation per package (should return 0 rows)
SELECT PackageCode, COUNT(*) AS n
FROM Reservation
GROUP BY PackageCode
HAVING COUNT(*) > 1;

-- C2) Packages without a reservation (design-intent check)
-- If your process creates Package and Reservation together
SELECT p.PackageCode
FROM Package p
LEFT JOIN Reservation r ON r.PackageCode = p.PackageCode
WHERE r.PackageCode IS NULL;



-- D) Data quality checks 

-- D1) Email basic format check (flags obvious issues)
SELECT ClientID, Email
FROM Client
WHERE Email IS NOT NULL
  AND Email NOT LIKE '%_@_%._%';

-- D2) YearOfBirth plausible range (adjust bounds if required)
SELECT ClientID, YearOfBirth
FROM Client
WHERE YearOfBirth IS NOT NULL
  AND (YearOfBirth < 1900 OR YearOfBirth > YEAR(CURDATE()));

-- D3) TravelDate mandatory (should return 0 rows)
SELECT ReservationID, TravelDate
FROM Reservation
WHERE TravelDate IS NULL;

-- D4) Price mandatory and non-negative 
SELECT ReservationID, Price
FROM Reservation
WHERE Price IS NULL OR Price < 0;

-- D5) NumberOfPeople positive when present 
SELECT ReservationID, NumberOfPeople
FROM Reservation
WHERE NumberOfPeople IS NOT NULL
  AND NumberOfPeople <= 0;


-- E) Datatype alignment for foreign keys (audit)

-- Shows FK pairs where column types differ (should be empty ideally)

SELECT
  c1.TABLE_NAME  AS child_table,
  c1.COLUMN_NAME AS child_col,
  c1.COLUMN_TYPE AS child_type,
  c2.TABLE_NAME  AS parent_table,
  c2.COLUMN_NAME AS parent_col,
  c2.COLUMN_TYPE AS parent_type
FROM information_schema.COLUMNS c1
JOIN information_schema.KEY_COLUMN_USAGE k
  ON k.TABLE_SCHEMA = c1.TABLE_SCHEMA
 AND k.TABLE_NAME  = c1.TABLE_NAME
 AND k.COLUMN_NAME = c1.COLUMN_NAME
JOIN information_schema.COLUMNS c2
  ON c2.TABLE_SCHEMA = k.REFERENCED_TABLE_SCHEMA
 AND c2.TABLE_NAME  = k.REFERENCED_TABLE_NAME
 AND c2.COLUMN_NAME = k.REFERENCED_COLUMN_NAME
WHERE c1.TABLE_SCHEMA = DATABASE()
  AND k.REFERENCED_TABLE_NAME IS NOT NULL
  AND c1.COLUMN_TYPE <> c2.COLUMN_TYPE;


-- F) Summary scan (quick health dashboard)

SELECT
  (SELECT COUNT(*) FROM Client)      AS n_clients,
  (SELECT COUNT(*) FROM Package)     AS n_packages,
  (SELECT COUNT(*) FROM Reservation) AS n_reservations,

  (SELECT COUNT(*)
   FROM Package p LEFT JOIN Client c ON c.ClientID = p.ClientID
   WHERE c.ClientID IS NULL) AS orphan_packages,

  (SELECT COUNT(*)
   FROM Reservation r LEFT JOIN Package p ON p.PackageCode = r.PackageCode
   WHERE p.PackageCode IS NULL) AS orphan_reservations,

  (SELECT COUNT(*)
   FROM (SELECT PackageCode
         FROM Reservation
         GROUP BY PackageCode
         HAVING COUNT(*) > 1) x) AS packages_with_multiple_reservations,

  (SELECT COUNT(*)
   FROM Package p LEFT JOIN Reservation r ON r.PackageCode = p.PackageCode
   WHERE r.PackageCode IS NULL) AS packages_without_reservation;
