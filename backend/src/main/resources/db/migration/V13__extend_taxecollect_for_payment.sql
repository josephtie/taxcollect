-- Étendre TaxeCollect pour le module de paiement
ALTER TABLE taxecollect ADD COLUMN reference VARCHAR(64);
ALTER TABLE taxecollect ADD COLUMN remaining_amount NUMERIC(19,2);
ALTER TABLE taxecollect ADD COLUMN currency VARCHAR(8) DEFAULT 'XOF';
ALTER TABLE taxecollect ADD COLUMN tax_type VARCHAR(64);

-- Contrainte unique sur reference
ALTER TABLE taxecollect ADD CONSTRAINT uk_taxecollect_reference UNIQUE (reference);

-- Index pour recherche par référence
CREATE INDEX idx_taxecollect_reference ON taxecollect(reference);

-- Initialiser remaining_amount = montant pour les enregistrements existants
UPDATE taxecollect SET remaining_amount = montant WHERE remaining_amount IS NULL;
