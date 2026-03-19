-- Corriger la contrainte CHECK pour inclure MARCHE_PLACE
-- D'abord supprimer l'ancienne contrainte
ALTER TABLE taxe DROP CONSTRAINT IF EXISTS taxe_categorie_check;

-- Puis recréer la contrainte avec toutes les valeurs
ALTER TABLE taxe 
ADD CONSTRAINT taxe_categorie_check 
CHECK (categorie IN (
  'MARCHAND_AMBULANT',
  'COMMERCANT', 
  'PROPRIETAIRE_FONCIER',
  'ENTREPRISE',
  'AUTRE',
  'MARCHE_PLACE'
));

-- Vérifier la contrainte
\d taxe;
