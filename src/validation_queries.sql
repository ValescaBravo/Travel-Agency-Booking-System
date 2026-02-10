-- R1) Reservations by month (volume trend)
SELECT
  TO_CHAR("TravelDate", 'YYYY-MM') AS year_month,
  COUNT(*) AS reservations
FROM "Reservation"
GROUP BY year_month
ORDER BY year_month;

-- R2) Revenue (sum of prices) by month
SELECT
  TO_CHAR("TravelDate", 'YYYY-MM') AS year_month,
  SUM("Price") AS total_revenue
FROM "Reservation"
GROUP BY year_month
ORDER BY year_month;

-- R3) Average booking value by month
SELECT
  TO_CHAR("TravelDate", 'YYYY-MM') AS year_month,
  AVG("Price") AS avg_booking_value
FROM "Reservation"
GROUP BY year_month
ORDER BY year_month;

-- R4) Packages per client (repeat purchasing distribution)
SELECT
  "ClientID",
  COUNT(*) AS packages_count
FROM "Package"
GROUP BY "ClientID"
ORDER BY packages_count DESC, "ClientID";

-- R5) Top destinations (by number of packages)
SELECT
  "Destination",
  COUNT(*) AS packages
FROM "Package"
GROUP BY "Destination"
ORDER BY packages DESC, "Destination";

-- R6) Destination revenue (sum of reservation prices by destination)
SELECT
  p."Destination",
  SUM(r."Price") AS total_revenue
FROM "Package" p
JOIN "Reservation" r ON r."PackageCode" = p."PackageCode"
GROUP BY p."Destination"
ORDER BY total_revenue DESC, p."Destination";

-- R7) Client booking history (public-safe: IDs only)
SELECT
  c."ClientID",
  p."PackageCode",
  p."Destination",
  p."TransportType",
  p."AccommodationType",
  r."ReservationID",
  r."TravelDate",
  r."NumberOfPeople",
  r."Price"
FROM "Client" c
JOIN "Package" p      ON p."ClientID" = c."ClientID"
JOIN "Reservation" r  ON r."PackageCode" = p."PackageCode"
ORDER BY c."ClientID", r."TravelDate";

-- R8) Data completeness snapshot (optional fields coverage)
SELECT
  COUNT(*) AS n_clients,
  SUM(CASE WHEN "Gender" IS NOT NULL THEN 1 ELSE 0 END) AS gender_filled,
  SUM(CASE WHEN "MobileNumber" IS NOT NULL THEN 1 ELSE 0 END) AS mobile_filled,
  SUM(CASE WHEN "YearOfBirth" IS NOT NULL THEN 1 ELSE 0 END) AS yob_filled,
  ROUND(100.0 * SUM(CASE WHEN "Gender" IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS gender_filled_pct,
  ROUND(100.0 * SUM(CASE WHEN "MobileNumber" IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS mobile_filled_pct,
  ROUND(100.0 * SUM(CASE WHEN "YearOfBirth" IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS yob_filled_pct
FROM "Client";