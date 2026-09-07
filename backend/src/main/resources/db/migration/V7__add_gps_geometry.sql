-- V7: Add GPS geometry support for all territorial levels

-- 1. Enable PostGIS extension if not already enabled
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Add geometry column to commune (MultiPolygon for commune boundaries)
ALTER TABLE commune ADD COLUMN IF NOT EXISTS geometry geometry(MultiPolygon, 4326);

-- 3. Add geometry column to zone (MultiPolygon for zone boundaries)
ALTER TABLE zone ADD COLUMN IF NOT EXISTS geometry geometry(MultiPolygon, 4326);

-- 4. Add geometry column to quartier (MultiPolygon for quartier boundaries)
ALTER TABLE quartier ADD COLUMN IF NOT EXISTS geometry geometry(MultiPolygon, 4326);

-- 5. Add geometry column to secteur (MultiPolygon for sector boundaries)
ALTER TABLE secteur ADD COLUMN IF NOT EXISTS geometry geometry(MultiPolygon, 4326);

-- 6. Add precision_gps column to contribuable
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS precision_gps DOUBLE PRECISION;

-- 7. Add secteur_id column to contribuable
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS secteur_id BIGINT;

-- Add FK constraint for contribuable -> secteur (only if not already present)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_contribuable_secteur'
        AND table_name = 'contribuable'
    ) THEN
        ALTER TABLE contribuable 
        ADD CONSTRAINT fk_contribuable_secteur FOREIGN KEY (secteur_id) REFERENCES secteur(id);
    END IF;
END $$;

-- 8. Create spatial indexes (GiST) for fast ST_Contains queries
CREATE INDEX IF NOT EXISTS idx_commune_geometry ON commune USING GIST (geometry);
CREATE INDEX IF NOT EXISTS idx_zone_geometry ON zone USING GIST (geometry);
CREATE INDEX IF NOT EXISTS idx_quartier_geometry ON quartier USING GIST (geometry);
CREATE INDEX IF NOT EXISTS idx_secteur_geometry ON secteur USING GIST (geometry);

-- 9. Create spatial index on contribuable coordinates (for proximity searches)
CREATE INDEX IF NOT EXISTS idx_contribuable_gps ON contribuable USING GIST (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326));
