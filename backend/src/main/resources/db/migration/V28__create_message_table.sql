-- Phase 3: Messagerie agent ↔ superviseur

CREATE TABLE IF NOT EXISTS message (
    id BIGSERIAL PRIMARY KEY,
    expediteur_id BIGINT NOT NULL,
    expediteur_role VARCHAR(30) NOT NULL,
    destinataire_id BIGINT,
    destinataire_role VARCHAR(30),
    signalement_id BIGINT,
    contenu VARCHAR(2000) NOT NULL,
    lu BOOLEAN NOT NULL DEFAULT FALSE,
    date_lecture TIMESTAMP,
    offline BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_message_expediteur ON message(expediteur_id);
CREATE INDEX IF NOT EXISTS idx_message_destinataire ON message(destinataire_id);
CREATE INDEX IF NOT EXISTS idx_message_signalement ON message(signalement_id);
CREATE INDEX IF NOT EXISTS idx_message_lu ON message(destinataire_id, lu);
