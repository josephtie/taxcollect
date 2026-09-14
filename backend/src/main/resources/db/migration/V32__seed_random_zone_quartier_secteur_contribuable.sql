-- Assign random zone_id, quartier_id, secteur_id to existing contribuables

-- 1. Assign random zone_id (zone is NOT NULL, so all contribuables must get one)
UPDATE contribuable c
SET zone_id = sub.random_zone_id
FROM (
    SELECT id AS contribuable_id,
           (SELECT id FROM zone ORDER BY RANDOM() LIMIT 1) AS random_zone_id
    FROM contribuable
) sub
WHERE c.id = sub.contribuable_id;

-- 2. Assign random quartier_id (nullable — linked to the zone for consistency)
UPDATE contribuable c
SET quartier_id = sub.random_quartier_id
FROM (
    SELECT c2.id AS contribuable_id,
           (SELECT q.id FROM quartier q WHERE q.zone_id = c2.zone_id ORDER BY RANDOM() LIMIT 1) AS random_quartier_id
    FROM contribuable c2
) sub
WHERE c.id = sub.contribuable_id;

-- 3. Assign random secteur_id (nullable — linked to the quartier for consistency)
UPDATE contribuable c
SET secteur_id = sub.random_secteur_id
FROM (
    SELECT c2.id AS contribuable_id,
           (SELECT s.id FROM secteur s WHERE s.quartier_id = c2.quartier_id ORDER BY RANDOM() LIMIT 1) AS random_secteur_id
    FROM contribuable c2
) sub
WHERE c.id = sub.contribuable_id;

-- 4. For contribuables whose zone has no quartiers, pick any quartier
UPDATE contribuable c
SET quartier_id = (SELECT id FROM quartier ORDER BY RANDOM() LIMIT 1)
WHERE c.quartier_id IS NULL;

-- 5. For contribuables whose quartier has no secteurs, pick any secteur
UPDATE contribuable c
SET secteur_id = (SELECT id FROM secteur ORDER BY RANDOM() LIMIT 1)
WHERE c.secteur_id IS NULL;
