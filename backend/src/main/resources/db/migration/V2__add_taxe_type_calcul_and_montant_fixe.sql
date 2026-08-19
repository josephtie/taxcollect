-- Ajouter les colonnes type_calcul et montant_fixe à la table taxe
ALTER TABLE taxe 
ADD COLUMN type_calcul VARCHAR(10) NOT NULL DEFAULT 'TAUX',
ADD COLUMN montant_fixe DECIMAL(15,2);

-- Mettre à jour les enregistrements existants pour avoir un type_calcul
UPDATE taxe SET type_calcul = 'TAUX' WHERE type_calcul IS NULL;

-- Rendre la colonne taux nullable (puisqu'on peut avoir soit taux soit montant_fixe)
ALTER TABLE taxe ALTER COLUMN taux DROP NOT NULL;

-- Ajouter une contrainte CHECK pour s'assurer qu'un seul des deux est rempli
ALTER TABLE taxe ADD CONSTRAINT chk_taxe_value 
CHECK (
    (type_calcul = 'TAUX' AND taux IS NOT NULL AND montant_fixe IS NULL) OR
    (type_calcul = 'MONTANT' AND montant_fixe IS NOT NULL AND taux IS NULL)
);
