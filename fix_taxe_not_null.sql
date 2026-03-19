-- Corriger la colonne taux pour qu'elle puisse être NULL
-- Car avec le type MONTANT, le taux doit être null

ALTER TABLE taxe 
ALTER COLUMN taux DROP NOT NULL;

-- Vérifier la structure après modification
\d taxe;
