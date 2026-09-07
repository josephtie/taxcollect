-- Unifier la gestion des périodes sur TaxeCollect
-- Remplacer periode_mensuelle (YearMonth) et periode_annuelle (Year) par period_start/period_end/due_date

-- 1. Ajouter les nouvelles colonnes (nullable pour la migration)
ALTER TABLE taxecollect ADD COLUMN period_start DATE;
ALTER TABLE taxecollect ADD COLUMN period_end DATE;
ALTER TABLE taxecollect ADD COLUMN due_date DATE;

-- 2. Migrer les données existantes
-- Les anciennes colonnes periode_mensuelle/periode_annuelle étaient stockées
-- en bytea (sérialisation Hibernate de YearMonth/Year) et ne sont plus utilisées
-- par l'entité. On utilise date_emission comme période par défaut.
UPDATE taxecollect
SET period_start = date_emission,
    period_end = date_emission,
    due_date = date_limite
WHERE period_start IS NULL;

-- 3. Rendre les colonnes NOT NULL
ALTER TABLE taxecollect ALTER COLUMN period_start SET NOT NULL;
ALTER TABLE taxecollect ALTER COLUMN period_end SET NOT NULL;
ALTER TABLE taxecollect ALTER COLUMN due_date SET NOT NULL;

-- 4. Supprimer les anciennes colonnes
ALTER TABLE taxecollect DROP COLUMN IF EXISTS periode_mensuelle;
ALTER TABLE taxecollect DROP COLUMN IF EXISTS periode_annuelle;

-- 5. Contrainte unique pour l'idempotence (un avis par contribuable + type taxe + période)
-- Note: tax_type stocke le nom de la taxe; on utilise contribuable_id + tax_type + period_start
ALTER TABLE taxecollect ADD CONSTRAINT uk_avis_period
    UNIQUE (contribuable_id, tax_type, period_start);

-- 6. Index pour accélérer la recherche des avis en retard
CREATE INDEX idx_taxecollect_overdue ON taxecollect (statut, due_date)
    WHERE statut = 'IMPAYE';

-- 7. Index pour la recherche par période
CREATE INDEX idx_taxecollect_period ON taxecollect (period_start, period_end);
