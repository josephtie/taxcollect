-- V6: Restructure territorial hierarchy from Commune -> Quartier -> Zone to Commune -> Zone -> Quartier -> Secteur

-- 1. Rename zone_collecte table to zone and change quartier_id to commune_id
ALTER TABLE IF EXISTS zone_collecte RENAME TO zone;

-- Change FK from quartier_id to commune_id in zone table
ALTER TABLE IF EXISTS zone DROP CONSTRAINT IF EXISTS fk_zone_quartier;
ALTER TABLE IF EXISTS zone DROP COLUMN IF EXISTS quartier_id;
ALTER TABLE IF EXISTS zone ADD COLUMN IF EXISTS commune_id BIGINT;

-- Add FK constraint for zone -> commune
ALTER TABLE IF EXISTS zone 
ADD CONSTRAINT fk_zone_commune FOREIGN KEY (commune_id) REFERENCES commune(id);

-- 2. Change quartier FK from commune_id to zone_id
ALTER TABLE IF EXISTS quartier DROP CONSTRAINT IF EXISTS fk_quartier_commune;
ALTER TABLE IF EXISTS quartier DROP COLUMN IF EXISTS commune_id;
ALTER TABLE IF EXISTS quartier ADD COLUMN IF EXISTS zone_id BIGINT;

-- Add FK constraint for quartier -> zone
ALTER TABLE IF EXISTS quartier 
ADD CONSTRAINT fk_quartier_zone FOREIGN KEY (zone_id) REFERENCES zone(id);

-- Add statut column to quartier table
ALTER TABLE IF EXISTS quartier ADD COLUMN IF EXISTS statut BOOLEAN DEFAULT TRUE;

-- 3. Create secteur table
CREATE TABLE IF NOT EXISTS secteur (
    id BIGSERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    quartier_id BIGINT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    rue VARCHAR(255),
    numero_lot VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    CONSTRAINT fk_secteur_quartier FOREIGN KEY (quartier_id) REFERENCES quartier(id)
);

-- 4. Update agent_zone join table (already references zone_id, table name stays the same)
-- No changes needed for agent_zone since the column was already named zone_id
