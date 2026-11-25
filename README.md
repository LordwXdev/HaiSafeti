# HaiSafeti


Live, crowd-powered safety and road info for Haiti.

## Version 1
- PostgreSQL + PostGIS database
- Reports grouped into events, confirmed at 3+ reports
- Events expire after 3 hours with no new reports
- "Near me" search and alert matching

## Project structure
```
db/schema.sql    tables and indexes
db/queries.sql   queries used by the backend ($1, $2 placeholders)
db/seed.sql      fake test data and a test query
bot/             chat bot (coming in version 2)
```

## Run it locally
1. Start a PostGIS database with Docker:
   ```bash
   docker run --name haisafeti-db -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=haisafeti -p 5432:5432 -d postgis/postgis:16-3.4
   ```
2. Create the tables:
   ```bash
   docker exec -i haisafeti-db psql -U postgres -d haisafeti < db/schema.sql
   ```
3. Add test data and run the test query:
   ```bash
   docker exec -i haisafeti-db psql -U postgres -d haisafeti < db/seed.sql
   ```

## Rules
- Never show who made a report
- Store as little personal data as possible
- Always show how sure a report is
