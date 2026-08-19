-- Migration : créer la table qr_code_contribuable et enrichir la table contribuable
-- pour le recensement avec QR code unique

-- Table qr_code_contribuable
CREATE TABLE IF NOT EXISTS qr_code_contribuable (
    id BIGSERIAL PRIMARY KEY,
    code_qr VARCHAR(255) NOT NULL UNIQUE,
    contribuable_id BIGINT NOT NULL,
    date_generation TIMESTAMP NOT NULL,
    actif BOOLEAN NOT NULL DEFAULT TRUE,
    date_expiration TIMESTAMP,
    utilise_par VARCHAR(255),
    created_at TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_qr_code_contribuable FOREIGN KEY (contribuable_id) REFERENCES contribuable(id)
);

-- Index pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_qr_code_contribuable_code_qr ON qr_code_contribuable(code_qr);
CREATE INDEX IF NOT EXISTS idx_qr_code_contribuable_contribuable_id ON qr_code_contribuable(contribuable_id);
CREATE INDEX IF NOT EXISTS idx_qr_code_contribuable_actif ON qr_code_contribuable(actif);

-- Enrichir la table contribuable avec les champs du recensement
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS numero_contribuable VARCHAR(50) UNIQUE;
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS type_contribuable VARCHAR(50);
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS activite VARCHAR(255);
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS marche VARCHAR(255);
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS quartier VARCHAR(255);
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS type_piece_identite VARCHAR(50);
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS numero_piece VARCHAR(100);
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS photo_piece TEXT;
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS photo_contribuable TEXT;
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS statut_contribuable VARCHAR(30) DEFAULT 'actif';
ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS necessite_validation BOOLEAN DEFAULT FALSE;

-- Générer les numéros contribuable pour les enregistrements existants
UPDATE contribuable SET numero_contribuable = 'VTX' || LPAD(id::TEXT, 8, '0')
WHERE numero_contribuable IS NULL;

-- Index pour la recherche par numéro contribuable
CREATE INDEX IF NOT EXISTS idx_contribuable_numero_contribuable ON contribuable(numero_contribuable);
CREATE INDEX IF NOT EXISTS idx_contribuable_telephone ON contribuable(telephone);
