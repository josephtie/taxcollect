-- Phase 2 (suite): Notification, Signalement, AuditEntry

-- Notifications agent
CREATE TABLE IF NOT EXISTS notification (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT,
    type VARCHAR(50) NOT NULL,
    message VARCHAR(500) NOT NULL,
    lu BOOLEAN NOT NULL DEFAULT FALSE,
    date_lecture TIMESTAMP,
    reference_id BIGINT,
    reference_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- Signalements (messagerie agent ↔ superviseur)
CREATE TABLE IF NOT EXISTS signalement (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL,
    message VARCHAR(1000) NOT NULL,
    contribuable_id BIGINT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    statut VARCHAR(20) NOT NULL DEFAULT 'OUVERT',
    reponse VARCHAR(1000),
    traite_par BIGINT,
    date_traitement TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- Journal d'activité (audit trail)
CREATE TABLE IF NOT EXISTS audit_entry (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT,
    type VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id BIGINT,
    description VARCHAR(1000),
    ip_address VARCHAR(50),
    device_info VARCHAR(255),
    offline BOOLEAN NOT NULL DEFAULT FALSE,
    sync_status VARCHAR(20) DEFAULT 'SYNCED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_notification_agent ON notification(agent_id);
CREATE INDEX IF NOT EXISTS idx_notification_lu ON notification(agent_id, lu);
CREATE INDEX IF NOT EXISTS idx_signalement_agent ON signalement(agent_id);
CREATE INDEX IF NOT EXISTS idx_signalement_statut ON signalement(statut);
CREATE INDEX IF NOT EXISTS idx_audit_agent ON audit_entry(agent_id);
CREATE INDEX IF NOT EXISTS idx_audit_sync ON audit_entry(sync_status);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_entry(created_at);
