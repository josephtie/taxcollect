-- Phase 2 (fin): Caisse, RemiseCaisse, SyncItem

-- Caisse journalière agent
CREATE TABLE IF NOT EXISTS caisse (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT NOT NULL REFERENCES agent(id),
    date_caisse DATE NOT NULL,
    solde_initial DECIMAL(19, 2) NOT NULL DEFAULT 0,
    montant_espece DECIMAL(19, 2) NOT NULL DEFAULT 0,
    montant_mobile_money DECIMAL(19, 2) NOT NULL DEFAULT 0,
    montant_total DECIMAL(19, 2) NOT NULL DEFAULT 0,
    statut VARCHAR(20) NOT NULL DEFAULT 'FERMEE',
    date_ouverture TIMESTAMP,
    date_cloture TIMESTAMP,
    nombre_transactions INT NOT NULL DEFAULT 0,
    observation VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT uk_caisse_agent_date UNIQUE (agent_id, date_caisse)
);

-- Remise de caisse
CREATE TABLE IF NOT EXISTS remise_caisse (
    id BIGSERIAL PRIMARY KEY,
    caisse_id BIGINT NOT NULL REFERENCES caisse(id),
    montant DECIMAL(19, 2) NOT NULL,
    beneficiaire VARCHAR(255) NOT NULL,
    date_remise TIMESTAMP NOT NULL,
    reference VARCHAR(100),
    observation VARCHAR(1000),
    statut VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE',
    confirme_par BIGINT,
    date_confirmation TIMESTAMP,
    commentaire_confirmation VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- File de synchronisation
CREATE TABLE IF NOT EXISTS sync_item (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT,
    local_id VARCHAR(100),
    statut VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    action VARCHAR(20) NOT NULL,
    payload TEXT,
    error_message VARCHAR(1000),
    retry_count INT NOT NULL DEFAULT 0,
    last_sync_attempt TIMESTAMP,
    synced_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_caisse_agent ON caisse(agent_id);
CREATE INDEX IF NOT EXISTS idx_caisse_date ON caisse(date_caisse);
CREATE INDEX IF NOT EXISTS idx_caisse_statut ON caisse(statut);
CREATE INDEX IF NOT EXISTS idx_remise_caisse ON remise_caisse(caisse_id);
CREATE INDEX IF NOT EXISTS idx_remise_statut ON remise_caisse(statut);
CREATE INDEX IF NOT EXISTS idx_sync_agent ON sync_item(agent_id);
CREATE INDEX IF NOT EXISTS idx_sync_statut ON sync_item(statut);
CREATE INDEX IF NOT EXISTS idx_sync_entity ON sync_item(entity_type, entity_id);
