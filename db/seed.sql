-- HaiSafeti: fake test data (Port-au-Prince)
-- Events expire 3 hours after insert. Run again if searches come back empty.

INSERT INTO users (platform, chat_id) VALUES ('telegram', 'test1');

INSERT INTO events (type, location, report_count) VALUES
  ('blocked_road', ST_MakePoint(-72.3390, 18.5440)::geography, 4),  -- near Champ de Mars
  ('flooding',     ST_MakePoint(-72.3360, 18.5460)::geography, 1),  -- near Champ de Mars
  ('protest',      ST_MakePoint(-72.2853, 18.5125)::geography, 2);  -- Petion-Ville

-- Test: standing at Champ de Mars, what's within 2 km?
-- Expect: blocked_road (confirmed) and flooding (unconfirmed). Not the protest.
SELECT type,
       report_count,
       CASE WHEN report_count >= 3 THEN 'confirmed' ELSE 'unconfirmed' END AS status,
       ROUND(ST_Distance(location, ST_MakePoint(-72.3390, 18.5440)::geography)) AS distance_m
FROM events
WHERE expires_at > now()
  AND ST_DWithin(location, ST_MakePoint(-72.3390, 18.5440)::geography, 2000)
ORDER BY distance_m;
