-- V33: Seed données de démonstration fictives Grand-Bassam
-- Basé sur le scénario E_CollecteTaxe_Demo_Grand_Bassam_Fictif_Bout_en_Bout.md
-- Toutes les données sont 100% fictives.

-- ============================================================
-- 1. QUARTIERS (Zone EST = id 3 sera la "Zone 03" de la démo)
-- ============================================================
INSERT INTO quartier (nom, zone_id, statut, created_at, updated_at, is_active)
VALUES
  ('France',    3, TRUE, NOW(), NOW(), TRUE),
  ('Impérial',  3, TRUE, NOW(), NOW(), TRUE),
  ('Mockeyville', 3, TRUE, NOW(), NOW(), TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 2. SECTEURS (S01-S07 répartis dans les 3 quartiers)
-- ============================================================
INSERT INTO secteur (nom, quartier_id, latitude, longitude, created_at, updated_at, is_active)
SELECT s.nom, q.id, s.lat, s.lng, NOW(), NOW(), TRUE
FROM (VALUES
  ('S01', 'France',     -3.7380, 5.1980),
  ('S02', 'France',     -3.7350, 5.2010),
  ('S03', 'France',     -3.7320, 5.1990),
  ('S04', 'Impérial',   -3.7280, 5.1950),
  ('S05', 'Impérial',   -3.7250, 5.1980),
  ('S06', 'Mockeyville',-3.7400, 5.1900),
  ('S07', 'Mockeyville',-3.7430, 5.1880)
) AS s(nom, quartier_nom, lat, lng)
JOIN quartier q ON q.nom = s.quartier_nom AND q.zone_id = 3
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. CONTRIBUABLES (350 fictifs, répartis par activité)
-- ============================================================
-- 40% commerce, 20% restaurants/maquis, 15% services, 15% artisans, 10% autres

-- 3.1 Commerce (140 contribuables)
INSERT INTO contribuable (nom, prenom, telephone, email, adresse, latitude, longitude, numero_contribuable, type_contribuable, activite, marche, quartier, quartier_id, secteur_id, zone_id, type_piece_identite, numero_piece, statut_contribuable, necessite_validation, is_active, base_imposable, created_at, updated_at)
SELECT
  CASE (n % 20)
    WHEN 0 THEN 'KOUASSI' WHEN 1 THEN 'N'GUESSAN' WHEN 2 THEN 'BROU' WHEN 3 THEN 'YAO' WHEN 4 THEN 'KONAN'
    WHEN 5 THEN 'TRAORE' WHEN 6 THEN 'DIABATE' WHEN 7 THEN 'COULIBALY' WHEN 8 THEN 'TOURE' WHEN 9 THEN 'CISSE'
    WHEN 10 THEN 'BAMBA' WHEN 11 THEN 'KONE' WHEN 12 THEN 'SORO' WHEN 13 THEN 'OUATTARA' WHEN 14 THEN 'Fofana'
    WHEN 15 THEN 'ZADI' WHEN 16 THEN 'TANO' WHEN 17 THEN 'ASSI' WHEN 18 THEN 'GBAGBO' WHEN 19 THEN 'AKE'
  END,
  CASE (n % 15)
    WHEN 0 THEN 'Marché Central' WHEN 1 THEN 'Boutique Alpha' WHEN 2 THEN ' Commerce Général' WHEN 3 THEN 'Shop Plus'
    WHEN 4 THEN 'Distributeur' WHEN 5 THEN 'Vente Gros' WHEN 6 THEN 'Superette' WHEN 7 THEN 'Quincaillerie'
    WHEN 8 THEN 'Librairie' WHEN 9 THEN 'Pharmacie' WHEN 10 THEN 'Papeterie' WHEN 11 THEN 'Magasin'
    WHEN 12 THEN 'Depot' WHEN 13 THEN 'Stock' WHEN 14 THEN 'Boutik'
  END,
  '07' || lpad((n + 100)::text, 8, '0'),
  'commerce' || n || '@demo.ci',
  'Rue ' || n || ', Quartier ' || CASE WHEN n % 3 = 0 THEN 'France' WHEN n % 3 = 1 THEN 'Impérial' ELSE 'Mockeyville' END,
  -3.7300 + (n % 100)::float / 1000,
  5.1950 + (n % 80)::float / 1000,
  'C-' || lpad((n + 100)::text, 6, '0'),
  'PARTICULIER',
  'Commerce',
  CASE WHEN n % 3 = 0 THEN 'Marché Central' WHEN n % 3 = 1 THEN 'Marché Impérial' ELSE 'Marché Mockeyville' END,
  CASE WHEN n % 3 = 0 THEN 'France' WHEN n % 3 = 1 THEN 'Impérial' ELSE 'Mockeyville' END,
  (SELECT id FROM quartier WHERE nom = CASE WHEN n % 3 = 0 THEN 'France' WHEN n % 3 = 1 THEN 'Impérial' ELSE 'Mockeyville' END AND zone_id = 3),
  (SELECT id FROM secteur WHERE nom = 'S0' || ((n % 3) + 1)),
  3,
  'CNI',
  'CNI' || lpad((n + 1000)::text, 8, '0'),
  'ACTIF', FALSE, TRUE,
  75000.00 + (n % 5) * 25000,
  NOW() - (n % 30)::int, NOW()
FROM generate_series(1, 140) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 3.2 Restaurants/Maquis (70 contribuables)
INSERT INTO contribuable (nom, prenom, telephone, email, adresse, latitude, longitude, numero_contribuable, type_contribuable, activite, marche, quartier, quartier_id, secteur_id, zone_id, type_piece_identite, numero_piece, statut_contribuable, necessite_validation, is_active, base_imposable, created_at, updated_at)
SELECT
  CASE (n % 10)
    WHEN 0 THEN 'Chez Mado' WHEN 1 THEN 'Maquis Lagune' WHEN 2 THEN 'Restaurant Bassam' WHEN 3 THEN 'Bar du Quartier'
    WHEN 4 THEN 'Chez Adjoa' WHEN 5 THEN 'Le Tropical' WHEN 6 THEN 'Restaurant La Lagune' WHEN 7 THEN 'Maquis du Port'
    WHEN 8 THEN 'Chez Koffi' WHEN 9 THEN 'Le Rivage'
  END,
  CASE n WHEN 1 THEN '' ELSE ' SARL' END,
  '05' || lpad((n + 200)::text, 8, '0'),
  'resto' || n || '@demo.ci',
  'Rue des Cocotiers lot ' || n,
  -3.7320 + (n % 50)::float / 1000,
  5.2000 + (n % 40)::float / 1000,
  'C-' || lpad((n + 240)::text, 6, '0'),
  'ENTREPRISE',
  'Restaurant',
  NULL,
  'France',
  (SELECT id FROM quartier WHERE nom = 'France' AND zone_id = 3),
  (SELECT id FROM secteur WHERE nom = 'S02'),
  3,
  'RC',
  'RC' || lpad((n + 2000)::text, 8, '0'),
  'ACTIF', FALSE, TRUE,
  150000.00,
  NOW() - (n % 25)::int, NOW()
FROM generate_series(1, 70) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 3.3 Services (52 contribuables)
INSERT INTO contribuable (nom, prenom, telephone, email, adresse, latitude, longitude, numero_contribuable, type_contribuable, activite, marche, quartier, quartier_id, secteur_id, zone_id, type_piece_identite, numero_piece, statut_contribuable, necessite_validation, is_active, base_imposable, created_at, updated_at)
SELECT
  CASE (n % 8)
    WHEN 0 THEN 'Salon Élégance' WHEN 1 THEN 'Pressing Lagune' WHEN 2 THEN 'Studio Photo' WHEN 3 THEN 'Cyber Café'
    WHEN 4 THEN 'Atelier Couture' WHEN 5 THEN 'Salon Beauté' WHEN 6 THEN 'Pressing Express' WHEN 7 THEN 'Service Informatique'
  END,
  CASE n WHEN 1 THEN '' ELSE ' Plus' END,
  '01' || lpad((n + 310)::text, 8, '0'),
  'service' || n || '@demo.ci',
  'Avenue ' || n,
  -3.7360 + (n % 30)::float / 1000,
  5.1970 + (n % 30)::float / 1000,
  'C-' || lpad((n + 310)::text, 6, '0'),
  'PARTICULIER',
  'Service',
  NULL,
  CASE WHEN n % 2 = 0 THEN 'Impérial' ELSE 'France' END,
  CASE WHEN n % 2 = 0 THEN (SELECT id FROM quartier WHERE nom = 'Impérial' AND zone_id = 3) ELSE (SELECT id FROM quartier WHERE nom = 'France' AND zone_id = 3) END,
  CASE WHEN n % 2 = 0 THEN (SELECT id FROM secteur WHERE nom = 'S04') ELSE (SELECT id FROM secteur WHERE nom = 'S01') END,
  3,
  'CNI',
  'CNI' || lpad((n + 3100)::text, 8, '0'),
  'ACTIF', FALSE, TRUE,
  100000.00,
  NOW() - (n % 20)::int, NOW()
FROM generate_series(1, 52) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 3.4 Artisans (52 contribuables)
INSERT INTO contribuable (nom, prenom, telephone, email, adresse, latitude, longitude, numero_contribuable, type_contribuable, activite, marche, quartier, quartier_id, secteur_id, zone_id, type_piece_identite, numero_piece, statut_contribuable, necessite_validation, is_active, base_imposable, created_at, updated_at)
SELECT
  CASE (n % 8)
    WHEN 0 THEN 'Atelier Kouamé' WHEN 1 THEN 'Menuiserie Bois' WHEN 2 THEN 'Soudure Express' WHEN 3 THEN 'Atelier Mécanique'
    WHEN 4 THEN 'Cordonnerie' WHEN 5 THEN 'Atelier Tissage' WHEN 6 THEN 'Ferronnerie' WHEN 7 THEN 'Atelier Vannerie'
  END,
  '',
  '05' || lpad((n + 362)::text, 8, '0'),
  'artisan' || n || '@demo.ci',
  'Rue des Artisans ' || n,
  -3.7410 + (n % 30)::float / 1000,
  5.1890 + (n % 30)::float / 1000,
  'C-' || lpad((n + 362)::text, 6, '0'),
  'PARTICULIER',
  'Artisan',
  NULL,
  'Mockeyville',
  (SELECT id FROM quartier WHERE nom = 'Mockeyville' AND zone_id = 3),
  (SELECT id FROM secteur WHERE nom = 'S06'),
  3,
  'CNI',
  'CNI' || lpad((n + 3620)::text, 8, '0'),
  'ACTIF', FALSE, TRUE,
  200000.00,
  NOW() - (n % 15)::int, NOW()
FROM generate_series(1, 52) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- 3.5 Autres (36 contribuables)
INSERT INTO contribuable (nom, prenom, telephone, email, adresse, latitude, longitude, numero_contribuable, type_contribuable, activite, marche, quartier, quartier_id, secteur_id, zone_id, type_piece_identite, numero_piece, statut_contribuable, necessite_validation, is_active, base_imposable, created_at, updated_at)
SELECT
  CASE (n % 6)
    WHEN 0 THEN 'Pharmacie Plus' WHEN 1 THEN 'Station Service' WHEN 2 THEN 'Télécentre' WHEN 3 THEN 'Agence Voyage'
    WHEN 4 THEN 'Bureau de Tabac' WHEN 5 THEN 'Auto-école'
  END,
  '',
  '07' || lpad((n + 414)::text, 8, '0'),
  'autre' || n || '@demo.ci',
  'Boulevard ' || n,
  -3.7280 + (n % 40)::float / 1000,
  5.1940 + (n % 50)::float / 1000,
  'C-' || lpad((n + 414)::text, 6, '0'),
  'ENTREPRISE',
  'Autre',
  NULL,
  CASE WHEN n % 2 = 0 THEN 'Impérial' ELSE 'Mockeyville' END,
  CASE WHEN n % 2 = 0 THEN (SELECT id FROM quartier WHERE nom = 'Impérial' AND zone_id = 3) ELSE (SELECT id FROM quartier WHERE nom = 'Mockeyville' AND zone_id = 3) END,
  CASE WHEN n % 2 = 0 THEN (SELECT id FROM secteur WHERE nom = 'S05') ELSE (SELECT id FROM secteur WHERE nom = 'S07') END,
  3,
  'RC',
  'RC' || lpad((n + 4140)::text, 8, '0'),
  'ACTIF', FALSE, TRUE,
  300000.00,
  NOW() - (n % 10)::int, NOW()
FROM generate_series(1, 36) AS n
ON CONFLICT (numero_contribuable) DO NOTHING;

-- ============================================================
-- 4. AFFECTATIONS D'AGENTS (5 agents assignés à Zone EST)
-- ============================================================
-- Utiliser les 5 premiers agents existants (id 1-5)
INSERT INTO agent_affectation (agent_id, territory_type, territory_id, date_debut, statut, is_active, created_at)
SELECT a.id, 'ZONE', 3, '2026-09-01', TRUE, TRUE, NOW()
FROM agent a
WHERE a.id IN (1, 2, 3, 4, 5)
ON CONFLICT (agent_id, territory_type, territory_id) DO NOTHING;

-- Affectations par secteur
INSERT INTO agent_affectation (agent_id, territory_type, territory_id, date_debut, statut, is_active, created_at)
SELECT 1, 'SECTEUR', id, '2026-09-01', TRUE, TRUE, NOW() FROM secteur WHERE nom = 'S01'
ON CONFLICT DO NOTHING;
INSERT INTO agent_affectation (agent_id, territory_type, territory_id, date_debut, statut, is_active, created_at)
SELECT 2, 'SECTEUR', id, '2026-09-01', TRUE, TRUE, NOW() FROM secteur WHERE nom = 'S02'
ON CONFLICT DO NOTHING;
INSERT INTO agent_affectation (agent_id, territory_type, territory_id, date_debut, statut, is_active, created_at)
SELECT 3, 'SECTEUR', id, '2026-09-01', TRUE, TRUE, NOW() FROM secteur WHERE nom = 'S03'
ON CONFLICT DO NOTHING;
INSERT INTO agent_affectation (agent_id, territory_type, territory_id, date_debut, statut, is_active, created_at)
SELECT 4, 'SECTEUR', id, '2026-09-01', TRUE, TRUE, NOW() FROM secteur WHERE nom = 'S04'
ON CONFLICT DO NOTHING;
INSERT INTO agent_affectation (agent_id, territory_type, territory_id, date_debut, statut, is_active, created_at)
SELECT 5, 'SECTEUR', id, '2026-09-01', TRUE, TRUE, NOW() FROM secteur WHERE nom = 'S06'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 5. TOURNÉES (10 tournées fictives sur 7 jours)
-- ============================================================
INSERT INTO tournee (date_tournee, agent_id, statut, montant_objectif, montant_collecte, nb_visites_prevues, nb_visites_effectuees, created_at, is_active)
SELECT
  CURRENT_DATE - (n % 7)::int,
  CASE (n % 5) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END,
  CASE WHEN n < 5 THEN 'TERMINEE' ELSE 'PLANIFIEE' END,
  50000 + (n % 5) * 10000,
  CASE WHEN n < 5 THEN 35000 + (n % 5) * 8000 ELSE 0 END,
  20 + (n % 10),
  CASE WHEN n < 5 THEN 15 + (n % 8) ELSE 0 END,
  NOW() - (n % 7)::int,
  TRUE
FROM generate_series(1, 10) AS n
ON CONFLICT DO NOTHING;

-- ============================================================
-- 6. VISITES (200 visites réparties sur les tournées terminées)
-- ============================================================
INSERT INTO visite (tournee_id, contribuable_id, date_visite, latitude, longitude, statut, motif, observation, ordre_passage, duree_minutes, sync_status, created_at, is_active)
SELECT
  (SELECT id FROM tournee WHERE agent_id = CASE (v.n % 5) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END ORDER BY date_tournee DESC LIMIT 1),
  c.id,
  NOW() - (v.n % 7)::int - (v.n % 5)::int * interval '1 hour',
  c.latitude,
  c.longitude,
  CASE (v.n % 7)
    WHEN 0 THEN 'REALISEE' WHEN 1 THEN 'REALISEE' WHEN 2 THEN 'REALISEE'
    WHEN 3 THEN 'ABSENT' WHEN 4 THEN 'REFUS'
    WHEN 5 THEN 'A_REVISITER' ELSE 'REALISEE'
  END,
  CASE (v.n % 4) WHEN 0 THEN 'CONTROLE' WHEN 1 THEN 'ENCAISSEMENT' WHEN 2 THEN 'RELANCE' ELSE 'RECONNAISSANCE' END,
  CASE (v.n % 7) WHEN 3 THEN 'Contribuable absent' WHEN 4 THEN 'Refus de paiement' ELSE NULL END,
  v.n,
  CASE (v.n % 5) WHEN 0 THEN 10 WHEN 1 THEN 15 WHEN 2 THEN 20 WHEN 3 THEN 5 ELSE 30 END,
  'SYNCED',
  NOW() - (v.n % 7)::int,
  TRUE
FROM generate_series(1, 200) AS v(n)
JOIN contribuable c ON c.id = (v.n % 350) + 1
WHERE c.id IS NOT NULL
ON CONFLICT DO NOTHING;

-- ============================================================
-- 7. TRANSACTIONS (140 transactions avec différents statuts)
-- 40% payés (VALIDE), 25% impayés, 10% promesses, reste divers
-- ============================================================
INSERT INTO transaction (date_transaction, montant, mode_paiement, statut, agent_id, contribuable_id, reference, transaction_reference, provider, currency, payment_method, initiated_at, completed_at, created_at, is_active)
SELECT
  NOW() - (t.n % 14)::int - (t.n % 10)::int * interval '1 hour',
  CASE (t.n % 5)
    WHEN 0 THEN 10000 WHEN 1 THEN 15000 WHEN 2 THEN 20000 WHEN 3 THEN 25000 ELSE 30000
  END,
  CASE (t.n % 3) WHEN 0 THEN 'ESPECE' WHEN 1 THEN 'MOBILE_MONEY' ELSE 'MOBILE_MONEY' END,
  CASE (t.n % 10)
    WHEN 0 THEN 'VALIDE' WHEN 1 THEN 'VALIDE' WHEN 2 THEN 'VALIDE' WHEN 3 THEN 'VALIDE'
    WHEN 4 THEN 'EN_ATTENTE' WHEN 5 THEN 'EN_ATTENTE_VALIDATION'
    WHEN 6 THEN 'REJETE' WHEN 7 THEN 'ANNULE'
    WHEN 8 THEN 'VALIDE' ELSE 'EN_ATTENTE'
  END,
  CASE (t.n % 5) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END,
  (t.n % 350) + 1,
  'PAY-202609' || lpad(t.n::text, 4, '0'),
  'TXN-DEMO-' || lpad(t.n::text, 5, '0'),
  CASE (t.n % 3) WHEN 0 THEN 'STUB' WHEN 1 THEN 'ORANGE_MONEY' ELSE 'MTN_MONEY' END,
  'XOF',
  CASE (t.n % 3) WHEN 0 THEN 'ESPECE' WHEN 1 THEN 'MOBILE_MONEY' ELSE 'MOBILE_MONEY' END,
  NOW() - (t.n % 14)::int,
  CASE WHEN (t.n % 10) < 4 THEN NOW() - (t.n % 14)::int + interval '1 hour' ELSE NULL END,
  NOW() - (t.n % 14)::int,
  TRUE
FROM generate_series(1, 140) AS t(n)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 8. CAISSES (5 caisses pour les 5 agents, jour J)
-- ============================================================
INSERT INTO caisse (agent_id, date_caisse, solde_initial, montant_espece, montant_mobile_money, montant_total, statut, date_ouverture, nombre_transactions, created_at, is_active)
SELECT
  a.id,
  CURRENT_DATE,
  0,
  CASE WHEN a.id = 1 THEN 35000 WHEN a.id = 2 THEN 42000 WHEN a.id = 3 THEN 28000 WHEN a.id = 4 THEN 15000 ELSE 31000 END,
  CASE WHEN a.id = 1 THEN 20000 WHEN a.id = 2 THEN 15000 WHEN a.id = 3 THEN 12000 WHEN a.id = 4 THEN 8000 ELSE 18000 END,
  CASE WHEN a.id = 1 THEN 55000 WHEN a.id = 2 THEN 57000 WHEN a.id = 3 THEN 40000 WHEN a.id = 4 THEN 23000 ELSE 49000 END,
  CASE WHEN a.id < 4 THEN 'OUVERTE' ELSE 'FERMEE' END,
  NOW() - interval '8 hours',
  CASE WHEN a.id = 1 THEN 8 WHEN a.id = 2 THEN 7 WHEN a.id = 3 THEN 5 WHEN a.id = 4 THEN 3 ELSE 6 END,
  NOW() - interval '8 hours',
  TRUE
FROM agent a
WHERE a.id IN (1, 2, 3, 4, 5)
ON CONFLICT (agent_id, date_caisse) DO NOTHING;

-- ============================================================
-- 9. NOTIFICATIONS (15 notifications fictives)
-- ============================================================
INSERT INTO notification (agent_id, type, message, lu, created_at, is_active)
SELECT
  (n % 5) + 1,
  CASE (n % 4)
    WHEN 0 THEN 'TOURNEE_ASSIGNEE' WHEN 1 THEN 'PAIEMENT_RECU'
    WHEN 2 THEN 'ANOMALIE_DETECTEE' ELSE 'RAPPEL_VISITE'
  END,
  CASE (n % 4)
    WHEN 0 THEN 'Une nouvelle tournée vous a été assignée'
    WHEN 1 THEN 'Paiement de ' || (n * 5000) || ' FCFA reçu'
    WHEN 2 THEN 'Anomalie détectée: montant inhabituel'
    ELSE 'Rappel: visite planifiée à 14h'
  END,
  CASE WHEN n < 8 THEN TRUE ELSE FALSE END,
  NOW() - (n % 5)::int * interval '1 hour',
  TRUE
FROM generate_series(1, 15) AS n
ON CONFLICT DO NOTHING;

-- ============================================================
-- 10. ANOMALIES (5 anomalies fictives)
-- ============================================================
INSERT INTO anomalie (quartier_id, secteur_id, contribuable_id, contribuable_nom, agent_id, agent_nom, type_anomalie, probleme, action, statut, cree_par_role, created_at, is_active)
SELECT
  (SELECT id FROM quartier WHERE nom = 'France' AND zone_id = 3),
  (SELECT id FROM secteur WHERE nom = 'S03'),
  c.id,
  c.nom || ' ' || c.prenom,
  3,
  'TRAORE Aminata',
  'MONTANT_INHABITUEL',
  'Montant de 150000 FCFA au lieu de 10000 FCFA habituel',
  'Vérification des arriérés demandée',
  CASE (a.n % 3) WHEN 0 THEN 'OUVERTE' WHEN 1 THEN 'EN_COURS' ELSE 'CLOTUREE' END,
  'SUPERVISEUR',
  NOW() - (a.n % 3)::int,
  TRUE
FROM generate_series(1, 5) AS a(n)
JOIN contribuable c ON c.id = (a.n * 50) + 10
ON CONFLICT DO NOTHING;

-- ============================================================
-- 11. AUDIT ENTRIES (30 entrées d'audit)
-- ============================================================
INSERT INTO audit_entry (agent_id, entity_type, entity_id, action, description, created_at, is_active)
SELECT
  (au.n % 5) + 1,
  CASE (au.n % 5)
    WHEN 0 THEN 'CONTRIBUABLE' WHEN 1 THEN 'VISITE' WHEN 2 THEN 'PAIEMENT'
    WHEN 3 THEN 'TOURNEE' ELSE 'CAISSE'
  END,
  au.n,
  CASE (au.n % 4)
    WHEN 0 THEN 'CREATE' WHEN 1 THEN 'UPDATE' WHEN 2 THEN 'VIEW' ELSE 'DELETE'
  END,
  CASE (au.n % 5)
    WHEN 0 THEN 'Création contribuable C-' || lpad(au.n::text, 6, '0')
    WHEN 1 THEN 'Visite effectuée - statut REALISEE'
    WHEN 2 THEN 'Paiement enregistré - ' || (au.n * 5000) || ' FCFA'
    WHEN 3 THEN 'Tournée démarrée'
    ELSE 'Caisse ouverte'
  END,
  NOW() - (au.n % 7)::int * interval '1 hour',
  TRUE
FROM generate_series(1, 30) AS au(n)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 12. SIGNALEMENTS (5 signalements fictifs)
-- ============================================================
INSERT INTO signalement (agent_id, type, message, contribuable_id, latitude, longitude, statut, created_at, is_active)
SELECT
  (s.n % 3) + 1,
  CASE (s.n % 3) WHEN 0 THEN 'PROBLEME_TECHNIQUE' WHEN 1 THEN 'CONTRIBUABLE_DIFFICILE' ELSE 'ERREUR_ENCAISSEMENT' END,
  CASE (s.n % 3)
    WHEN 0 THEN 'Application lente, saisie retardée'
    WHEN 1 THEN 'Contribuable refuse de fournir pièce identité'
    ELSE 'Erreur lors de la saisie du montant'
  END,
  (s.n * 30) + 5,
  -3.7300 + (s.n)::float / 100,
  5.1950 + (s.n)::float / 100,
  CASE WHEN s.n < 3 THEN 'OUVERT' ELSE 'TRAITE' END,
  NOW() - (s.n % 3)::int,
  TRUE
FROM generate_series(1, 5) AS s(n)
ON CONFLICT DO NOTHING;

-- Fin de la migration V33
