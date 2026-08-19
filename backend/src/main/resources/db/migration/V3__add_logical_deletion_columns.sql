-- Migration pour ajouter les colonnes de suppression logique à toutes les tables
-- Cette migration doit être appliquée à toutes les entités qui héritent de Auditable

-- Pour la table taxe
ALTER TABLE taxe 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Pour la table agents
ALTER TABLE agents 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Pour la table commune
ALTER TABLE commune 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Pour la table quartier
ALTER TABLE quartier 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Pour la table contribuable
ALTER TABLE contribuable 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Pour la table zone_collecte
ALTER TABLE zone_collecte 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Pour la table transaction
ALTER TABLE transaction 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Pour la table cloture_caisse
ALTER TABLE cloture_caisse 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Créer des index pour optimiser les performances sur les requêtes de suppression logique
CREATE INDEX IF NOT EXISTS idx_taxe_deleted_at ON taxe(deleted_at);
CREATE INDEX IF NOT EXISTS idx_taxe_is_active ON taxe(is_active);

CREATE INDEX IF NOT EXISTS idx_agents_deleted_at ON agents(deleted_at);
CREATE INDEX IF NOT EXISTS idx_agents_is_active ON agents(is_active);

CREATE INDEX IF NOT EXISTS idx_commune_deleted_at ON commune(deleted_at);
CREATE INDEX IF NOT EXISTS idx_commune_is_active ON commune(is_active);

CREATE INDEX IF NOT EXISTS idx_quartier_deleted_at ON quartier(deleted_at);
CREATE INDEX IF NOT EXISTS idx_quartier_is_active ON quartier(is_active);

CREATE INDEX IF NOT EXISTS idx_contribuable_deleted_at ON contribuable(deleted_at);
CREATE INDEX IF NOT EXISTS idx_contribuable_is_active ON contribuable(is_active);

CREATE INDEX IF NOT EXISTS idx_zone_collecte_deleted_at ON zone_collecte(deleted_at);
CREATE INDEX IF NOT EXISTS idx_zone_collecte_is_active ON zone_collecte(is_active);

CREATE INDEX IF NOT EXISTS idx_transaction_deleted_at ON transaction(deleted_at);
CREATE INDEX IF NOT EXISTS idx_transaction_is_active ON transaction(is_active);

CREATE INDEX IF NOT EXISTS idx_cloture_caisse_deleted_at ON cloture_caisse(deleted_at);
CREATE INDEX IF NOT EXISTS idx_cloture_caisse_is_active ON cloture_caisse(is_active);
