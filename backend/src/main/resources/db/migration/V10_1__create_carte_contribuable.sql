-- V10__create_carte_contribuable.sql
-- Table des cartes contribuables (cartes physiques ou numériques)

CREATE TABLE IF NOT EXISTS carte_contribuable (
    id              BIGSERIAL PRIMARY KEY,
    contribuable_id BIGINT       NOT NULL REFERENCES contribuable(id) ON DELETE CASCADE,
    numero_carte    VARCHAR(50)  NOT NULL UNIQUE,
    matricule_unique VARCHAR(50) NOT NULL UNIQUE,
    qr_code_data    TEXT,
    type            VARCHAR(20)  NOT NULL DEFAULT 'PVC',
    status          VARCHAR(20)  NOT NULL DEFAULT 'DRAFT',
    security_level  VARCHAR(20)  NOT NULL DEFAULT 'STANDARD',
    date_emission   TIMESTAMP    NOT NULL DEFAULT NOW(),
    date_expiration TIMESTAMP    NOT NULL,
    photo_url       VARCHAR(500),
    agent_id        VARCHAR(100),
    zone_id         VARCHAR(100),
    synced          BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP,
    created_by      VARCHAR(255),
    updated_by      VARCHAR(255)
);

-- Index pour les recherches fréquentes
CREATE INDEX IF NOT EXISTS idx_carte_contribuable_id ON carte_contribuable(contribuable_id);
CREATE INDEX IF NOT EXISTS idx_carte_status         ON carte_contribuable(status);
CREATE INDEX IF NOT EXISTS idx_carte_matricule       ON carte_contribuable(matricule_unique);
CREATE INDEX IF NOT EXISTS idx_carte_date_expiration ON carte_contribuable(date_expiration);
CREATE INDEX IF NOT EXISTS idx_carte_synced          ON carte_contribuable(synced);

-- Contrainte : un contribuable ne peut avoir qu'une seule carte ACTIVE
-- (vérifiée au niveau applicatif pour permettre l'historique)
