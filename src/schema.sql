/* ============================================================================
   Travel Agency Booking System (EN schema)
   Matches ERD (English):
     CLIENT (ClientID, FirstName, LastName, Email, Gender, MobileNumber, YearOfBirth)
       1..*  SELECTS
     PACKAGE (PackageCode, Destination, TransportType, AccommodationType)
       1..1  CONFIRMS
     RESERVATION (ReservationID, TravelDate, NumberOfPeople, Price)

   Key rule enforced:
   - One PACKAGE has exactly ONE RESERVATION (1:1) via UNIQUE on Reservation.PackageCode
   ============================================================================ */


CREATE DATABASE IF NOT EXISTS TravelAgencyDB CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;


SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Reservation`;
DROP TABLE IF EXISTS `Package`;
DROP TABLE IF EXISTS `Client`;

SET FOREIGN_KEY_CHECKS = 1;


-- Table: Client

CREATE TABLE `Client` (
  `ClientID`       VARCHAR(15)  NOT NULL,
  `FirstName`      VARCHAR(15)  NOT NULL,
  `LastName`       VARCHAR(15)  NOT NULL,
  `Email`          VARCHAR(30)  NOT NULL,
  `Gender`         CHAR(1)      NULL,
  `MobileNumber`   CHAR(9)      NULL,
  `YearOfBirth`    INT          NULL,
  CONSTRAINT `Client_pk` PRIMARY KEY (`ClientID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Table: Package

CREATE TABLE `Package` (
  `PackageCode`        CHAR(8)      NOT NULL,
  `Destination`        VARCHAR(25)  NOT NULL,
  `TransportType`      VARCHAR(25)  NOT NULL,
  `AccommodationType`  VARCHAR(25)  NOT NULL,
  `ClientID`           VARCHAR(15)  NOT NULL,
  CONSTRAINT `Package_pk` PRIMARY KEY (`PackageCode`),
  KEY `idx_Package_ClientID` (`ClientID`),
  CONSTRAINT `Package_Client_fk`
    FOREIGN KEY (`ClientID`) REFERENCES `Client` (`ClientID`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Table: Reservation

CREATE TABLE `Reservation` (
  `ReservationID`   VARCHAR(8)   NOT NULL,
  `TravelDate`      DATE         NOT NULL,
  `NumberOfPeople`  INT          NULL,
  `PackageCode`     CHAR(8)      NOT NULL,
  `Price`           DECIMAL(11,2) NOT NULL,

  CONSTRAINT `Reservation_pk` PRIMARY KEY (`ReservationID`),

  -- Enforces 1:1 (one reservation per package)
  CONSTRAINT `Reservation_one_per_package` UNIQUE (`PackageCode`),

  KEY `idx_Reservation_PackageCode` (`PackageCode`),

  CONSTRAINT `Reservation_Package_fk`
    FOREIGN KEY (`PackageCode`) REFERENCES `Package` (`PackageCode`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
