-- Ajouter la base imposable sur Contribuable
-- Permet de renseigner manuellement une base d'imposition par contribuable
-- Si null, le système estimera la base à partir de l'activité
ALTER TABLE contribuable ADD COLUMN base_imposable NUMERIC(19,2);

-- Index pour filtrer les contribuables avec base imposable définie
CREATE INDEX idx_contribuable_base_imposable ON contribuable (base_imposable) WHERE base_imposable IS NOT NULL;
