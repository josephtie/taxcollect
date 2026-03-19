-- Script pour mettre à jour la table taxe avec les nouvelles colonnes
-- Exécuter ce script manuellement dans PostgreSQL

-- 1. Ajouter la colonne type_calcul
ALTER TABLE taxe 
ADD COLUMN IF NOT EXISTS type_calcul VARCHAR(10) NOT NULL DEFAULT 'TAUX';

-- 2. Ajouter la colonne montant_fixe
ALTER TABLE taxe 
ADD COLUMN IF NOT EXISTS montant_fixe DECIMAL(15,2);

-- 3. Rendre la colonne taux nullable
ALTER TABLE taxe 
ALTER COLUMN taux DROP NOT NULL;

-- 4. Mettre à jour les enregistrements existants
UPDATE taxe 
SET type_calcul = 'TAUX' 
WHERE type_calcul IS NULL;

-- 5. Afficher la structure de la table pour vérification
\d taxe;

-- 6. Afficher quelques enregistrements pour vérification
SELECT * FROM taxe LIMIT 5;
