# TaxCollect — User Journeys

## 1. Recensement d'un nouveau contribuable (Agent)

```
┌─────────────────────────────────────────────────────────────────────┐
│  ACTEUR : Joseph (Agent)                                            │
│  OBJECTIF : Recenser un nouveau commerçant sur sa zone              │
│  CONTEXTE : Marché central, connexion 4G instable                  │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes

1. **Démarrage**
   - Joseph ouvre l'app mobile TaxCollect sur son smartphone
   - Il s'authentifie avec son compte Keycloak (JWT)
   - L'app vérifie la connectivité et passe en mode hors-ligne si nécessaire

2. **Accès au recensement**
   - Joseph tape sur l'onglet **Recensement**
   - Il sélectionne l'onglet **Nouveau** dans le wizard

3. **Saisie des informations**
   - **Étape 1 — Identité** : nom, prénoms, téléphone, type (personne physique/morale)
   - **Étape 2 — Activité** : type d'activité, marché, quartier
   - **Étape 3 — Zone** : sélection de la zone de collecte
   - **Étape 4 — Identification** : type et numéro de pièce d'identité, photo de la pièce
   - **Étape 5 — Géolocalisation** : capture automatique des coordonnées GPS

4. **Génération automatique**
   - L'app génère un **numéro contribuable unique** (`VTX00000042`)
   - L'app génère un **QR code unique** (`VTXQR_VTX00000042_A1B2C3D4`)
   - Le statut est défini sur `actif` (ou `en_validation` si validation requise)

5. **Sauvegarde et synchronisation**
   - **Hors-ligne** : les données sont chiffrées et stockées localement (SQLite)
   - **En ligne** : `POST /api/recensement/contribuables` → création en base + persistance du QR code
   - **Synchronisation différée** : les données hors-ligne sont poussées quand le réseau revient

6. **Confirmation**
   - L'app affiche le **QR code** à l'écran
   - Joseph peut l'imprimer ou le partager avec le contribuable
   - Un reçu de recensement est généré (PDF)

### Points de friction
- Connexion réseau perdue pendant la saisie → mode hors-ligne automatique
- Photo de la pièce floue → validation refusée par le superviseur
- GPS indisponible en intérieur → saisie manuelle possible

---

## 2. Encaissement d'une taxe avec QR code (Agent)

```
┌─────────────────────────────────────────────────────────────────────┐
│  ACTEUR : Joseph (Agent)                                            │
│  OBJECTIF : Encaisser une taxe rapidement via QR code               │
│  CONTEXTE : Contribuable déjà recensé, QR code en main              │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes

1. **Scan du QR code**
   - Joseph ouvre l'app et tape sur l'icône **Scanner QR Code**
   - La caméra s'active (`mobile_scanner`)
   - Augustin présente sa carte avec le QR code
   - Le scan est instantané (< 1 seconde) avec retour haptique

2. **Vérification du QR code**
   - `POST /api/recensement/qr-code/verify?qrCodeData=VTXQR_VTX00000042_A1B2C3D4`
   - Le backend vérifie : QR code actif ? Non expiré ? Contribuable existant ?
   - Retour : `QRCodeContribuableDTO` avec les infos du contribuable

3. **Sélection de la taxe**
   - L'app affiche le profil du contribuable (nom, activité, zone)
   - Joseph sélectionne la taxe à encaisser (ex: taxe de marché mensuelle)
   - Le montant est calculé automatiquement (taux ou montant fixe)

4. **Encaissement**
   - Joseph sélectionne le **mode de paiement** : Espèces ou Mobile Money
   - Saisie de la référence Mobile Money (si applicable)
   - Validation → `POST /api/transactions` avec :
     - `contribuableId`, `agentId`, `zoneId`, `montant`, `modePaiement`
     - `latitude`, `longitude` (GPS de l'encaissement)
     - `hashTransaction` (SHA-256 pour intégrité)

5. **Reçu numérique**
   - Génération d'un **numéro de reçu** (`TAX-20260727-0001`)
   - Le reçu contient : numéro, montant, agent, contribuable, mode, statut, date
   - Hash de transaction pour la traçabilité
   - Reçu envoyé par SMS au contribuable (si numéro disponible)

### Points de friction
- QR code endommagé → saisie manuelle du numéro contribuable
- QR code expiré → proposition de régénération
- Mobile Money indisponible → bascule en espèces

---

## 3. Clôture de caisse en fin de journée (Agent → Trésorier)

```
┌─────────────────────────────────────────────────────────────────────┐
│  ACTEUR : Joseph (Agent) → Marie (Trésorier)                        │
│  OBJECTIF : Clôturer la caisse et faire valider par le trésorier    │
│  CONTEXTE : Fin de journée, 17h00                                   │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes — Agent

1. **Initiation**
   - Joseph ouvre l'onglet **Clôture de caisse**
   - Il sélectionne la date du jour
   - `POST /api/cloture-caisse/initier` avec `agentId` et `dateCloture`
   - Le backend récupère automatiquement toutes les transactions du jour
   - Calcul : `montantTotalEspece`, `montantTotalMobileMoney`, `montantTotal`, `nombreTransactions`

2. **Vérification**
   - Joseph compare le montant total affiché avec son espèce en caisse
   - Il saisit le **montant déclaré** (comptage physique)
   - Il ajoute un **commentaire agent** si écart

3. **Soumission**
   - `PUT /api/cloture-caisse/{id}/soumettre` avec `montantDeclare` et `commentaireAgent`
   - Le statut passe de `EN_COURS` → `SOUMISE`
   - Notification envoyée au trésorier

### Étapes — Trésorier

4. **Révision**
   - Marie consulte les clôtures en attente (`GET /api/cloture-caisse?statut=SOUMISE`)
   - Elle examine le détail : transactions, montants par mode, éventuel écart
   - Elle compare avec les dépôts Mobile Money reçus

5. **Validation ou rejet**
   - **Validation** : `PUT /api/cloture-caisse/{id}/valider` avec commentaire
     - Statut → `VALIDEE`, horodaté
   - **Rejet** : `PUT /api/cloture-caisse/{id}/rejeter` avec motif
     - Statut → `REJETEE`, l'agent doit corriger

6. **Confirmation de dépôt en banque**
   - Marie dépose l'espèce en banque
   - `PUT /api/cloture-caisse/{id}/confirmer-depot` avec `montantDepose` et `referenceDepotBanque`
   - Statut → `DEPOSEE`

### Points de friction
- Écart entre montant déclaré et montant calculé → commentaire obligatoire
- Clôture rejetée → l'agent doit revoir ses transactions
- Réseau indisponible à la soumission → sauvegarde locale + sync différée

---

## 4. Suivi des performances (Superviseur)

```
┌─────────────────────────────────────────────────────────────────────┐
│  ACTEUR : Esther (Superviseur)                                      │
│  OBJECTIF : Analyser la productivité des agents et la couverture    │
│  CONTEXTE : Bilan hebdomadaire, lundi matin                         │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes

1. **Tableau de bord**
   - Esther se connecte au frontend web (Vue.js)
   - Elle accède au **tableau de bord superviseur**
   - Vue d'ensemble : total recettes, nombre de transactions, agents actifs

2. **Analyse par agent**
   - `GET /api/transactions/stats?debut=...&fin=...&agentId=...`
   - Comparaison des montants collectés par agent
   - Nombre de transactions, montant moyen, répartition par mode de paiement

3. **Analyse par zone**
   - `GET /api/recensement/statistics`
   - Répartition des contribuables par zone
   - Taux de recensement, contribuables en validation

4. **Carte de recensement**
   - Visualisation GPS des recensements du jour
   - Vérification de la conformité (photo présente, GPS valide)
   - Détection des recensements sans GPS (potentiels faux)

5. **Affectation des agents aux zones**
   - Esther assigne un agent à une zone de collecte
   - `POST /api/taxcollect/agent/{agentId}/zones/{zoneId}`
   - Le backend vérifie que la zone n'est pas déjà assignée à cet agent (`InvalidOperationException` si doublon)
   - L'agent reçoit la zone dans son app après synchronisation

6. **Retrait d'un agent d'une zone**
   - Esther retire un agent d'une zone (réaffectation, congé, départ)
   - `DELETE /api/taxcollect/agent/{agentId}/zones/{zoneId}`
   - Le backend vérifie que la zone était bien assignée (`InvalidOperationException` sinon)
   - L'agent ne voit plus la zone dans son app après synchronisation

7. **Consultation des agents par zone**
   - Esther visualise les agents assignés à une zone donnée
   - `GET /api/taxcollect/agent/zone/{zoneId}`
   - Permet d'identifier les zones sous-effectuées ou sureffectuées

8. **Rapport**
   - Export CSV/Excel des transactions et recensements
   - `GET /api/transactions/export?format=csv&debut=...&fin=...`
   - Génération d'un rapport PDF de productivité

---

## 5. Contrôle d'un contribuable (Agent → Contribuable)

```
┌─────────────────────────────────────────────────────────────────────┐
│  ACTEUR : Joseph (Agent) + Augustin (Contribuable)                 │
│  OBJECTIF : Vérifier la situation fiscale d'un contribuable         │
│  CONTEXTE : Contrôle de routine sur le marché                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes

1. **Présentation du QR code**
   - Augustin présente sa carte contribuable avec le QR code
   - Joseph scanne le QR code avec l'app mobile

2. **Vérification**
   - `POST /api/recensement/qr-code/verify`
   - L'app affiche : nom, activité, zone, statut, historique des paiements

3. **Contrôle des paiements**
   - L'app liste les taxes dues vs payées pour la période en cours
   - Si taxes impayées → proposition d'encaissement immédiat
   - Si tout est à jour → confirmation visuelle "À jour"

4. **Traçabilité**
   - Chaque contrôle est tracé (agent, date, GPS, résultat)
   - Le QR code est marqué comme `utilisé par` l'agent

---

## 6. Gestion des taxes et configuration (Admin)

```
┌─────────────────────────────────────────────────────────────────────┐
│  ACTEUR : Patrick (Admin)                                           │
│  OBJECTIF : Configurer une nouvelle taxe et l'affecter à une zone   │
│  CONTEXTE : Nouvelle taxe sur l'occupation du domaine public        │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes

1. **Création de la taxe**
   - Patrick accède au module **Taxes** (frontend web)
   - Il crée une nouvelle taxe :
     - Nom : "Taxe d'occupation du domaine public"
     - Catégorie : `OCCUPATION_DOMAINE_PUBLIC`
     - Périodicité : `MENSUELLE`
     - Type de calcul : `MONTANT_FIXE`
     - Montant fixe : `5 000 FCFA`
   - `POST /api/taxcollect/taxes`

2. **Affectation aux zones**
   - Patrick affecte la taxe aux zones concernées
   - Les agents voient la nouvelle taxe apparaître dans leur app après synchronisation

3. **Suivi**
   - Patrick consulte les statistiques de collecte pour cette taxe
   - Il ajuste le montant si nécessaire (mise à jour avec historique)

---

## 7. Affectation et retrait d'agents aux zones (Superviseur)

```
┌─────────────────────────────────────────────────────────────────────┐
│  ACTEUR : Esther (Superviseur)                                      │
│  OBJECTIF : Affecter ou retirer des agents sur les zones            │
│  CONTEXTE : Réorganisation mensuelle des secteurs de collecte       │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes

1. **Consultation des agents disponibles**
   - Esther accède au module **Agents** (frontend web)
   - `GET /api/taxcollect/agent/active` — liste des agents actifs
   - `GET /api/taxcollect/agent/page` — liste paginée avec filtres
   - Elle vérifie le statut de chaque agent (`ACTIF`, `INACTIF`, `SUSPENDU`)

2. **Affectation d'un agent à une zone**
   - Esther sélectionne un agent et une zone de collecte
   - `POST /api/taxcollect/agent/{agentId}/zones/{zoneId}`
   - Le backend vérifie :
     - L'agent existe (`NotFoundException` sinon)
     - La zone existe (`NotFoundException` sinon)
     - La zone n'est pas déjà assignée à cet agent (`InvalidOperationException` sinon)
   - L'agent reçoit la zone dans son app mobile après synchronisation

3. **Retrait d'un agent d'une zone**
   - Esther retire un agent d'une zone (réaffectation, congé, Performance)
   - `DELETE /api/taxcollect/agent/{agentId}/zones/{zoneId}`
   - Le backend vérifie :
     - L'agent existe (`NotFoundException` sinon)
     - La zone était bien assignée (`InvalidOperationException` sinon)
   - L'agent ne voit plus la zone après synchronisation

4. **Consultation des agents par zone**
   - `GET /api/taxcollect/agent/zone/{zoneId}`
   - Permet d'identifier les zones sous-effectuées ou sureffectuées
   - Esther peut rééquilibrer les affectations

5. **Changement de statut d'un agent**
   - `PUT /api/taxcollect/agent/{id}/status?status=SUSPENDU`
   - Suspendre un agent (sanction, congé prolongé)
   - Réactiver un agent (`status=ACTIF`)

6. **Vérification post-affectation**
   - Esther consulte les performances de l'agent sur sa nouvelle zone
   - `GET /api/taxcollect/agent/{id}/stats?startDate=...&endDate=...`
   - Si les résultats sont insuffisants, elle peut réaffecter

### Points de friction
- Agent déjà assigné à la zone → `InvalidOperationException` (409 Conflict)
- Zone non assignée à l'agent au moment du retrait → `InvalidOperationException` (409 Conflict)
- Agent suspendu tentant de se connecter → blocage côté Keycloak
- Synchronisation mobile différée → l'agent travaille sur d'anciennes zones jusqu'à la sync

---

## Matrice des parcours par rôle

| Parcours | Agent | Trésorier | Admin | Superviseur | Contribuable |
|----------|:-----:|:---------:|:-----:|:-----------:|:------------:|
| Recensement | ✅ Actif | — | — | 👁️ Contrôle | 📋 Sujet |
| Encaissement QR | ✅ Actif | — | — | 👁️ Contrôle | 📋 Sujet |
| Clôture de caisse | ✅ Actif | ✅ Actif | — | 👁️ Contrôle | — |
| Suivi performances | — | 👁️ Lecture | — | ✅ Actif | — |
| Affectation agents/zones | — | — | ✅ Actif | ✅ Actif | — |
| Contrôle contribuable | ✅ Actif | — | — | — | 📋 Sujet |
| Configuration taxes | — | — | ✅ Actif | — | — |
