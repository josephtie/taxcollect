-- Ajouter MARCHE_PLACE à la contrainte CHECK de la colonne categorie de la table taxe
ALTER TABLE taxe DROP CONSTRAINT IF EXISTS taxe_categorie_check;

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
