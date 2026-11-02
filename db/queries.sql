-- HaiSafeti: key queries for the Node.js backend
-- $1, $2... are values passed in from code. Do NOT run this file directly.
-- Note: ST_MakePoint takes (longitude, latitude), in that order!

-- 1) When a report comes in: is there already a matching event nearby?
--    Same type, within 300 m, still active.
SELECT id
FROM events
WHERE type = $1
  AND expires_at > now()
  AND ST_DWithin(location, ST_MakePoint($2, $3)::geography, 300)
ORDER BY ST_Distance(location, ST_MakePoint($2, $3)::geography)
LIMIT 1;

-- 2a) If found: add to it and push the expiry time forward
UPDATE events
SET report_count  = report_count + 1,
    last_reported = now(),
    expires_at    = now() + INTERVAL '3 hours'
WHERE id = $1;

-- 2b) If not found: create a new event
INSERT INTO events (type, location)
VALUES ($1, ST_MakePoint($2, $3)::geography)
RETURNING id;

-- 3) "What's happening near me?" Active events within 2 km
SELECT type,
       report_count,
       CASE WHEN report_count >= 3 THEN 'confirmed' ELSE 'unconfirmed' END AS status,
       ROUND(ST_Distance(location, ST_MakePoint($1, $2)::geography)) AS distance_m,
       last_reported
FROM events
WHERE expires_at > now()
  AND ST_DWithin(location, ST_MakePoint($1, $2)::geography, 2000)
ORDER BY distance_m;

-- 4) Who should get an alert for a new or updated event?
SELECT DISTINCT u.platform, u.chat_id, sp.name AS place_name
FROM saved_places sp
JOIN users u ON u.id = sp.user_id
WHERE u.is_blocked = FALSE
  AND ST_DWithin(sp.location,
                 (SELECT location FROM events WHERE id = $1),
                 sp.radius_m);
