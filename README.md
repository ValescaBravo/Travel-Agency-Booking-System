# Travel Agency Booking System (PostgreSQL) — BA Case Study

This repository presents a **Business Analysis case study** for a simplified travel agency booking workflow.

The focus is on *requirements → data modelling → integrity constraints → validation/reporting queries* using **PostgreSQL**.

## Quick links

- **Live case study (GitHub Pages):** https://valescabravo.github.io/Travel-Agency-Booking-System/
- **Case study (HTML source):** `index.html`
- **ERD (PNG):** `assets/ERD.pgerd.png`
- **pgAdmin ERD file (.pgerd):** `assets/ERD.pgerd`
- **Schema (PostgreSQL):** `src/schema.sql`
- **Queries (validation + reporting):** `src/validation_queries.sql`

> If your file locations differ (e.g., you kept `schema.sql` at the repository root), update the links above and in `index.html`.

## What this demonstrates (BA/DA skills)

- Translating a business workflow into a minimal relational model.
- Defining **business rules** and implementing them as **PK/FK/UNIQUE/NOT NULL** constraints.
- Creating a small traceability view (requirement → entity/table → constraint → test query).
- Building repeatable **reporting queries** (volume, revenue, client history, data completeness).

## Data model (summary)

Tables:

- `"Client"` — client profile and contact fields.
- `"Package"` — a package purchase linked to a client.
- `"Reservation"` — a booking record linked to a package.

Key relationships:

- A **client** can have **many packages** (`"Package"."ClientID"` → `"Client"."ClientID"`).
- A **package** can have **at most one reservation** (FK + `UNIQUE("Reservation"."PackageCode")`).

> Note on identifiers: the schema uses **quoted identifiers** (e.g., `"Client"`). In PostgreSQL, this makes names case-sensitive, so queries must include quotes.

## How to run locally (PostgreSQL)

### Option A — pgAdmin 4 (recommended)

1. Create a new database (e.g., `travel_agency`).
2. Open **Query Tool** and run: `src/schema.sql`.
3. Import the CSVs into the matching tables (pgAdmin: *Import/Export Data…*).
4. Run the query pack: `src/validation_queries.sql`.

### Option B — CLI (psql)

```bash
# 1) create database
createdb travel_agency

# 2) run schema
psql -d travel_agency -f src/schema.sql

# 3) load CSVs (example; adjust paths/names)
psql -d travel_agency -c "\\copy \"Client\"   FROM 'archive/data/Client.csv'      WITH (FORMAT csv, HEADER true)"
psql -d travel_agency -c "\\copy \"Package\"  FROM 'archive/data/Package.csv'     WITH (FORMAT csv, HEADER true)"
psql -d travel_agency -c "\\copy \"Reservation\" FROM 'archive/data/Reservation.csv' WITH (FORMAT csv, HEADER true)"

# 4) run queries
psql -d travel_agency -f src/validation_queries.sql
```

## Repository structure

```
.
├─ index.html                  # BA case study (GitHub Pages entry point)
├─ README.md
├─ assets/
│     ├─ ERD.pgerd.png         # ERD image (evidence)
│     └─ ERD.pgerd             # pgAdmin ERD file
├─ src/
│    ├─ schema.sql
│    └─ validation_queries.sql
│               
└─ archive/
     └─ data/          # CSVs      
```

# Query Outputs (CSV evidence)

This folder contains CSV exports of the SQL queries in `src/validation_queries.sql`.

These outputs are included as quick evidence for reviewers who may not run the database locally.

## Mapping (CSV → SQL query)

| File | Query | Purpose |
|---|---|---|
| `query1.csv` | R1 | Reservations by month (volume trend) |
| `query2.csv` | R2 | Revenue (sum of prices) by month |
| `query3.csv` | R3 | Average booking value by month |
| `query4.csv` | R4 | Packages per client (repeat purchasing distribution) |
| `query5.csv` | R5 | Top destinations (by number of packages) |
| `query6.csv` | R6 | Destination revenue (sum of reservation prices by destination) |
| `query7.csv` | R7 | Client booking history (join view) |
| `query8.csv` | R8 | Data completeness snapshot (optional fields coverage) |

## Notes
- Data is synthetic/demo.
- To reproduce these outputs, run the corresponding query from `src/validation_queries.sql` in pgAdmin and export the results to CSV.
