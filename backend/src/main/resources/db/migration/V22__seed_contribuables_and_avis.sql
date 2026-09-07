-- V21: Insérer 100 contribuables de test + générer leurs avis de taxe (TaxeCollect)
-- Répartition: 10 entreprises, 40 place de marché, 25 ambulants, 25 petit commerce détaillant

-- 1. Contribuables: 10 ENTREPRISE
INSERT INTO contribuable (nom, prenom, telephone, type_contribuable, activite, numero_contribuable, type_piece_identite, numero_piece, zone_id, secteur_id, statut_contribuable, necessite_validation, is_active, base_imposable, adresse, quartier, marche, created_at, updated_at)
SELECT
    'Entreprise' || n,
    'SARL',
    '07' || lpad(n::text, 8, '0'),
    'ENTREPRISE',
    'Entreprise générale',
    'ENT-' || lpad(n::text, 6, '0'),
    'RC',
    'RC' || lpad(n::text, 6, '0'),
    (n % 5) + 1,
    4,
    'ACTIF',
    false,
    true,
    5000000.00 + (n * 100000),
    'Rue ' || n || ' Zone Industrielle',
    'Zone Industrielle',
    NULL,
    NOW(),
    NOW()
FROM generate_series(1, 10) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 2. Contribuables: 40 MARCHE_PLACE
INSERT INTO contribuable (nom, prenom, telephone, type_contribuable, activite, numero_contribuable, type_piece_identite, numero_piece, zone_id, secteur_id, statut_contribuable, necessite_validation, is_active, base_imposable, adresse, quartier, marche, created_at, updated_at)
SELECT
    'Marchand' || n,
    'Komgna',
    '05' || lpad(n::text, 8, '0'),
    'MARCHE_PLACE',
    'Vente de produits agricoles',
    'MCH-' || lpad(n::text, 6, '0'),
    'CNI',
    'CNI' || lpad(n::text, 8, '0'),
    (n % 5) + 1,
    4,
    'ACTIF',
    false,
    true,
    50000.00 + (n * 1000),
    'Marché Central Allée ' || n,
    'Marché Central',
    'Marché Central',
    NOW(),
    NOW()
FROM generate_series(1, 40) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 3. Contribuables: 25 MARCHAND_AMBULANT
INSERT INTO contribuable (nom, prenom, telephone, type_contribuable, activite, numero_contribuable, type_piece_identite, numero_piece, zone_id, secteur_id, statut_contribuable, necessite_validation, is_active, base_imposable, adresse, quartier, marche, created_at, updated_at)
SELECT
    'Ambulant' || n,
    'Diallo',
    '01' || lpad(n::text, 8, '0'),
    'MARCHAND_AMBULANT',
    'Commerce ambulant',
    'AMB-' || lpad(n::text, 6, '0'),
    'CNI',
    'CNI' || lpad(n::text, 8, '0'),
    (n % 5) + 1,
    4,
    'ACTIF',
    false,
    true,
    20000.00 + (n * 500),
    'Rue ' || n || ' Quartier Populaire',
    'Quartier Populaire',
    NULL,
    NOW(),
    NOW()
FROM generate_series(1, 25) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 4. Contribuables: 25 COMMERCANT (petit commerce détaillant)
INSERT INTO contribuable (nom, prenom, telephone, type_contribuable, activite, numero_contribuable, type_piece_identite, numero_piece, zone_id, secteur_id, statut_contribuable, necessite_validation, is_active, base_imposable, adresse, quartier, marche, created_at, updated_at)
SELECT
    'Commercant' || n,
    'Traoré',
    '07' || lpad((n + 25)::text, 8, '0'),
    'COMMERCANT',
    'Petit commerce de détail',
    'COM-' || lpad(n::text, 6, '0'),
    'CNI',
    'CNI' || lpad((n + 50)::text, 8, '0'),
    (n % 5) + 1,
    4,
    'ACTIF',
    false,
    true,
    100000.00 + (n * 2000),
    'Boutique ' || n || ' Avenue Commerce',
    'Centre Ville',
    NULL,
    NOW(),
    NOW()
FROM generate_series(1, 25) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 5. Générer les avis de taxe (TaxeCollect)
-- Pour chaque contribuable, on crée un avis basé sur son type

-- 5a. Entreprises → Taxe Entreprise (montant fixe 100 000 FCFA, annuelle)
INSERT INTO taxecollect (montant, date_emission, date_limite, paye, contribuable_id, zone_id, statut, offline, period_start, period_end, due_date, tax_type, currency, created_at, updated_at)
SELECT
    100000.00,
    DATE '2026-01-01',
    DATE '2026-12-31',
    false,
    c.id,
    c.zone_id,
    'IMPAYE',
    false,
    DATE '2026-01-01',
    DATE '2026-12-31',
    DATE '2026-12-31',
    'Taxe Entreprise',
    'XOF',
    NOW(),
    NOW()
FROM contribuable c
WHERE c.type_contribuable = 'ENTREPRISE'
AND NOT EXISTS (
    SELECT 1 FROM taxecollect t
    WHERE t.contribuable_id = c.id
    AND t.tax_type = 'Taxe Entreprise'
    AND t.period_start = DATE '2026-01-01'
);

-- 5b. Place de marché → Taxe Marchande Journalière (500 FCFA, journalière - avis pour le mois en cours)
INSERT INTO taxecollect (montant, date_emission, date_limite, paye, contribuable_id, zone_id, statut, offline, period_start, period_end, due_date, tax_type, currency, created_at, updated_at)
SELECT
    500.00,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '1 day',
    false,
    c.id,
    c.zone_id,
    'IMPAYE',
    false,
    CURRENT_DATE,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '1 day',
    'Taxe Marchande Journalière',
    'XOF',
    NOW(),
    NOW()
FROM contribuable c
WHERE c.type_contribuable = 'MARCHE_PLACE'
AND NOT EXISTS (
    SELECT 1 FROM taxecollect t
    WHERE t.contribuable_id = c.id
    AND t.tax_type = 'Taxe Marchande Journalière'
    AND t.period_start = CURRENT_DATE
);

-- 5c. Ambulants → Taxe Ambulants (3 000 FCFA, mensuelle)
INSERT INTO taxecollect (montant, date_emission, date_limite, paye, contribuable_id, zone_id, statut, offline, period_start, period_end, due_date, tax_type, currency, created_at, updated_at)
SELECT
    3000.00,
    DATE_TRUNC('month', CURRENT_DATE)::date,
    (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date,
    false,
    c.id,
    c.zone_id,
    'IMPAYE',
    false,
    DATE_TRUNC('month', CURRENT_DATE)::date,
    (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date,
    (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date,
    'Taxe Ambulants',
    'XOF',
    NOW(),
    NOW()
FROM contribuable c
WHERE c.type_contribuable = 'MARCHAND_AMBULANT'
AND NOT EXISTS (
    SELECT 1 FROM taxecollect t
    WHERE t.contribuable_id = c.id
    AND t.tax_type = 'Taxe Ambulants'
    AND t.period_start = DATE_TRUNC('month', CURRENT_DATE)::date
);

-- 5d. Petit commerce détaillant → Patente Commerciale (2% de la base imposable, annuelle)
INSERT INTO taxecollect (montant, date_emission, date_limite, paye, contribuable_id, zone_id, statut, offline, period_start, period_end, due_date, tax_type, currency, remaining_amount, created_at, updated_at)
SELECT
    ROUND(c.base_imposable * 0.02, 2),
    DATE '2026-01-01',
    DATE '2026-12-31',
    false,
    c.id,
    c.zone_id,
    'IMPAYE',
    false,
    DATE '2026-01-01',
    DATE '2026-12-31',
    DATE '2026-12-31',
    'Patente Commerciale',
    'XOF',
    ROUND(c.base_imposable * 0.02, 2),
    NOW(),
    NOW()
FROM contribuable c
WHERE c.type_contribuable = 'COMMERCANT'
AND NOT EXISTS (
    SELECT 1 FROM taxecollect t
    WHERE t.contribuable_id = c.id
    AND t.tax_type = 'Patente Commerciale'
    AND t.period_start = DATE '2026-01-01'
);
