-- Add quartier_id FK to contribuable for proper territorial hierarchy link

ALTER TABLE contribuable ADD COLUMN IF NOT EXISTS quartier_id BIGINT;

ALTER TABLE contribuable
    ADD CONSTRAINT fk_contribuable_quartier
    FOREIGN KEY (quartier_id) REFERENCES quartier(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_contribuable_quartier_id ON contribuable(quartier_id);
