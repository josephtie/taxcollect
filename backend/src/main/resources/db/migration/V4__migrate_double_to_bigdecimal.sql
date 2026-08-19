-- Migration : convertir les colonnes financières de DOUBLE PRECISION vers NUMERIC (BigDecimal)
-- Garantit la précision des calculs financiers en évitant les erreurs de virgule flottante

-- Table transaction : montant
ALTER TABLE transaction ALTER COLUMN montant TYPE DECIMAL(19, 2) USING montant::DECIMAL(19, 2);

-- Table taxe : taux (pourcentage, ex: 0.1234 = 12.34%) et montant_fixe
ALTER TABLE taxe ALTER COLUMN taux TYPE DECIMAL(5, 4) USING taux::DECIMAL(5, 4);
ALTER TABLE taxe ALTER COLUMN montant_fixe TYPE DECIMAL(19, 2) USING montant_fixe::DECIMAL(19, 2);

-- Table taxecollect : montant
ALTER TABLE taxecollect ALTER COLUMN montant TYPE DECIMAL(19, 2) USING montant::DECIMAL(19, 2);

-- Vérifier que les colonnes cloture_caisse sont déjà en NUMERIC (normalement oui)
-- Si elles étaient en DOUBLE PRECISION, les convertir aussi :
ALTER TABLE cloture_caisse ALTER COLUMN montant_total_espece TYPE DECIMAL(19, 2) USING montant_total_espece::DECIMAL(19, 2);
ALTER TABLE cloture_caisse ALTER COLUMN montant_total_mobile_money TYPE DECIMAL(19, 2) USING montant_total_mobile_money::DECIMAL(19, 2);
ALTER TABLE cloture_caisse ALTER COLUMN montant_total TYPE DECIMAL(19, 2) USING montant_total::DECIMAL(19, 2);
ALTER TABLE cloture_caisse ALTER COLUMN montant_declare TYPE DECIMAL(19, 2) USING montant_declare::DECIMAL(19, 2);
ALTER TABLE cloture_caisse ALTER COLUMN montant_depose TYPE DECIMAL(19, 2) USING montant_depose::DECIMAL(19, 2);
