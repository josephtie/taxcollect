-- Phase 5: Audit Trail Extension + Territorial Scope

-- Extend audit_entry table with territorial scope and user tracking
ALTER TABLE audit_entry ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);
ALTER TABLE audit_entry ADD COLUMN IF NOT EXISTS user_role VARCHAR(30);
ALTER TABLE audit_entry ADD COLUMN IF NOT EXISTS zone_id BIGINT;
ALTER TABLE audit_entry ADD COLUMN IF NOT EXISTS quartier_id BIGINT;

-- Indexes for audit queries
CREATE INDEX IF NOT EXISTS idx_audit_user_id ON audit_entry(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_zone_id ON audit_entry(zone_id);
CREATE INDEX IF NOT EXISTS idx_audit_quartier_id ON audit_entry(quartier_id);
CREATE INDEX IF NOT EXISTS idx_audit_entity_type ON audit_entry(entity_type);
CREATE INDEX IF NOT EXISTS idx_audit_entity_id ON audit_entry(entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_type ON audit_entry(type);
CREATE INDEX IF NOT EXISTS idx_audit_created_at ON audit_entry(created_at);
