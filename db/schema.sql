-- HaiSafeti: database v1 (tables only)
-- Needs PostgreSQL with the PostGIS extension

CREATE EXTENSION IF NOT EXISTS postgis;

-- Types of things people can report
CREATE TYPE report_type AS ENUM (
  'blocked_road',
  'shooting',
  'protest',
  'flooding',
  'heavy_traffic',
  'all_clear'
);

-- Users: only what the bot needs to reply.
-- Never show user info next to a report.
CREATE TABLE users (
  id           SERIAL PRIMARY KEY,
  platform     TEXT NOT NULL,            -- 'telegram' or 'whatsapp'
  chat_id      TEXT NOT NULL,            -- needed to send replies and alerts
  trust_score  INT  NOT NULL DEFAULT 1,  -- grows when their reports get confirmed
  is_blocked   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (platform, chat_id)
);

-- Events: one real thing happening at one place.
-- Many reports can point to the same event.
CREATE TABLE events (
  id             SERIAL PRIMARY KEY,
  type           report_type NOT NULL,
  location       GEOGRAPHY(Point, 4326) NOT NULL,
  report_count   INT NOT NULL DEFAULT 1,
  first_reported TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_reported  TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at     TIMESTAMPTZ NOT NULL DEFAULT now() + INTERVAL '3 hours'
);

-- Reports: each single message from a user
CREATE TABLE reports (
  id          SERIAL PRIMARY KEY,
  user_id     INT NOT NULL REFERENCES users(id),
  event_id    INT NOT NULL REFERENCES events(id),
  type        report_type NOT NULL,
  location    GEOGRAPHY(Point, 4326) NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Places a user wants alerts for (home, school, work...)
CREATE TABLE saved_places (
  id         SERIAL PRIMARY KEY,
  user_id    INT NOT NULL REFERENCES users(id),
  name       TEXT NOT NULL,
  location   GEOGRAPHY(Point, 4326) NOT NULL,
  radius_m   INT NOT NULL DEFAULT 1000
);

-- Spatial indexes so "near me" searches stay fast
CREATE INDEX events_location_idx       ON events       USING GIST (location);
CREATE INDEX saved_places_location_idx ON saved_places USING GIST (location);
CREATE INDEX events_expires_idx        ON events (expires_at);
