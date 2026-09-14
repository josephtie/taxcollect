-- Phase 4: Superviseur & Responsable de Quartier

-- Table: anomalie
CREATE TABLE IF NOT EXISTS anomalie (
    id BIGSERIAL PRIMARY KEY,
    quartier_id BIGINT,
    secteur_id BIGINT,
    secteur_nom VARCHAR(100),
    contribuable_id BIGINT,
    contribuable_nom VARCHAR(255),
    agent_id BIGINT,
    agent_nom VARCHAR(255),
    type_anomalie VARCHAR(50) NOT NULL,
    probleme VARCHAR(500) NOT NULL,
    action VARCHAR(500),
    statut VARCHAR(30) NOT NULL DEFAULT 'OUVERTE',
    cree_par_role VARCHAR(30),
    cree_par_id BIGINT,
    transmise_a VARCHAR(30),
    date_transmission TIMESTAMP,
    commentaire_superviseur VARCHAR(1000),
    date_cloture TIMESTAMP,
    cloturee_par BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_anomalie_quartier ON anomalie(quartier_id);
CREATE INDEX IF NOT EXISTS idx_anomalie_secteur ON anomalie(secteur_id);
CREATE INDEX IF NOT EXISTS idx_anomalie_agent ON anomalie(agent_id);
CREATE INDEX IF NOT EXISTS idx_anomalie_statut ON anomalie(statut);
CREATE INDEX IF NOT EXISTS idx_anomalie_contribuable ON anomalie(contribuable_id);

-- Table: proposition_affectation
CREATE TABLE IF NOT EXISTS proposition_affectation (
    id BIGSERIAL PRIMARY KEY,
    agent_id BIGINT NOT NULL,
    agent_nom VARCHAR(255),
    secteur_id BIGINT,
    secteur_nom VARCHAR(100),
    quartier_id BIGINT,
    propose_par_id BIGINT NOT NULL,
    propose_par_role VARCHAR(30),
    motif VARCHAR(500),
    statut VARCHAR(30) NOT NULL DEFAULT 'EN_ATTENTE',
    validee_par BIGINT,
    date_validation TIMESTAMP,
    commentaire_validation VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    updated_at TIMESTAMP,
    updated_by VARCHAR(255),
    deleted_at TIMESTAMP,
    deleted_by VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_proposition_quartier ON proposition_affectation(quartier_id);
CREATE INDEX IF NOT EXISTS idx_proposition_agent ON proposition_affectation(agent_id);
CREATE INDEX IF NOT EXISTS idx_proposition_statut ON proposition_affectation(statut);
CREATE INDEX IF NOT EXISTS idx_proposition_secteur ON proposition_affectation(secteur_id);
