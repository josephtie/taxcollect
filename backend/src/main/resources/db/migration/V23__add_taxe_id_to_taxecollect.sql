-- V23: Add taxe_id foreign key to taxecollect and backfill from tax_type matching taxe.nom
ALTER TABLE taxecollect ADD COLUMN IF NOT EXISTS taxe_id BIGINT;

-- Backfill: match tax_type to taxe.nom
UPDATE taxecollect tc
SET taxe_id = t.id
FROM taxe t
WHERE tc.tax_type = t.nom
  AND tc.taxe_id IS NULL;

-- Add foreign key constraint (PostgreSQL doesn't support IF NOT EXISTS for ADD CONSTRAINT)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_taxecollect_taxe') THEN
        ALTER TABLE taxecollect ADD CONSTRAINT fk_taxecollect_taxe FOREIGN KEY (taxe_id) REFERENCES taxe(id);
    END IF;
END $$;

-- Generate references for existing avis that don't have one
UPDATE taxecollect
SET reference = 'AVIS-' || UPPER(SUBSTRING(tax_type FROM 1 FOR 3)) || '-' || REPLACE(period_start::text, '-', '') || '-' || LPAD(contribuable_id::text, 6, '0')
WHERE reference IS NULL OR reference = '';
