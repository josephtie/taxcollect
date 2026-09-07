-- V10__create_agent_affectation.sql
-- Create the agent_affectation table for hierarchical territorial assignment

CREATE TABLE IF NOT EXISTS agent_affectation (
    id              BIGSERIAL PRIMARY KEY,
    agent_id        BIGINT       NOT NULL,
    territory_type  VARCHAR(20)  NOT NULL,
    territory_id    BIGINT       NOT NULL,
    date_debut      DATE,
    date_fin        DATE,
    statut          BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP,
    created_by      VARCHAR(255),
    updated_at      TIMESTAMP,
    updated_by      VARCHAR(255),
    deleted_at      TIMESTAMP,
    deleted_by      VARCHAR(255),
    is_active       BOOLEAN      DEFAULT TRUE,
    CONSTRAINT fk_agent_affectation_agent FOREIGN KEY (agent_id) REFERENCES agent (id) ON DELETE CASCADE,
    CONSTRAINT uk_agent_affectation UNIQUE (agent_id, territory_type, territory_id)
);

-- Migrate existing agent_zone data into agent_affectation
INSERT INTO agent_affectation (agent_id, territory_type, territory_id, statut, is_active, date_debut)
SELECT agent_id, 'ZONE', zone_id, TRUE, TRUE, CURRENT_DATE
FROM agent_zone
ON CONFLICT (agent_id, territory_type, territory_id) DO NOTHING;

-- Create indexes for efficient lookups
CREATE INDEX IF NOT EXISTS idx_agent_affectation_agent ON agent_affectation (agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_affectation_territory ON agent_affectation (territory_type, territory_id);
CREATE INDEX IF NOT EXISTS idx_agent_affectation_statut ON agent_affectation (statut);
