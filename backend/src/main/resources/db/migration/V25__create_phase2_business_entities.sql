-- Phase 2: Business entities for agent field operations

-- Tournée de collecte
CREATE TABLE IF NOT EXISTS tournee (
    id BIGSERIAL PRIMARY KEY,
    date_tournee DATE NOT NULL,
    agent_id BIGINT NOT NULL REFERENCES agent(id),
    statut VARCHAR(30) NOT NULL DEFAULT 'PLANIFIEE',
    montant_objectif DECIMAL(19, 2),
    montant_collecte DECIMAL(19, 2),
    nb_visites_prevues INT,
    nb_visites_effectuees INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- Visite de terrain
CREATE TABLE IF NOT EXISTS visite (
    id BIGSERIAL PRIMARY KEY,
    tournee_id BIGINT NOT NULL REFERENCES tournee(id),
    contribuable_id BIGINT NOT NULL REFERENCES contribuable(id),
    date_visite TIMESTAMP NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    statut VARCHAR(30) NOT NULL DEFAULT 'A_VISITER',
    motif VARCHAR(30),
    observation VARCHAR(1000),
    ordre_passage INT,
    duree_minutes INT,
    sync_status VARCHAR(20) DEFAULT 'SYNCED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- Portefeuille (affectation agent ↔ contribuable)
CREATE TABLE IF NOT EXISTS portefeuille (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT NOT NULL REFERENCES agent(id),
    contribuable_id BIGINT NOT NULL REFERENCES contribuable(id),
    date_affectation DATE NOT NULL,
    date_fin DATE,
    statut BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_portefeuille_agent_contribuable UNIQUE (agent_id, contribuable_id)
);

-- Promesse de paiement
CREATE TABLE IF NOT EXISTS promesse_paiement (
    id BIGSERIAL PRIMARY KEY,
    contribuable_id BIGINT NOT NULL REFERENCES contribuable(id),
    agent_id BIGINT NOT NULL REFERENCES agent(id),
    montant_promis DECIMAL(19, 2) NOT NULL,
    date_promesse DATE NOT NULL,
    date_echeance DATE NOT NULL,
    statut VARCHAR(30) NOT NULL DEFAULT 'EN_ATTENTE',
    observation VARCHAR(1000),
    relance_effectuee BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tournee_agent ON tournee(agent_id);
CREATE INDEX IF NOT EXISTS idx_tournee_date ON tournee(date_tournee);
CREATE INDEX IF NOT EXISTS idx_visite_tournee ON visite(tournee_id);
CREATE INDEX IF NOT EXISTS idx_visite_contribuable ON visite(contribuable_id);
CREATE INDEX IF NOT EXISTS idx_portefeuille_agent ON portefeuille(agent_id);
CREATE INDEX IF NOT EXISTS idx_portefeuille_contribuable ON portefeuille(contribuable_id);
CREATE INDEX IF NOT EXISTS idx_promesse_contribuable ON promesse_paiement(contribuable_id);
CREATE INDEX IF NOT EXISTS idx_promesse_agent ON promesse_paiement(agent_id);
CREATE INDEX IF NOT EXISTS idx_promesse_echeance ON promesse_paiement(date_echeance);
