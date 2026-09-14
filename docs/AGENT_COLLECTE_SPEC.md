# Spécification — Module Agent de Collecte (VerdenTax)

> **Objectif** : Concevoir l'Agent de collecte comme un profil terrain complet avec fonctionnement online + offline, géolocalisation, encaissement et preuve de collecte.
>
> **Dernière mise à jour** : 2026-09-11

---

## État de l'existant

| Composant | Statut | Fichier |
|-----------|--------|---------|
| Authentification | ✅ Existant | `lib/services/auth_service.dart` |
| Modèle Transaction | ✅ Existant | `lib/models/transaction.dart` |
| Modèle Contribuable | ✅ Existant | `lib/models/entities.dart` (ContribuableDto) |
| Modèle Agent | ✅ Existant | `lib/models/entities.dart` (AgentsDto) |
| Modèle User + rôles | ✅ Existant | `lib/models/user.dart` |
| Service Transaction (offline) | ✅ Existant | `lib/services/transaction_service.dart` |
| Service Agent | ✅ Existant | `lib/services/agent_service.dart` |
| Service Connectivité | ✅ Existant | `lib/services/connectivity_service.dart` |
| Service Stockage local | ✅ Existant | `lib/services/storage_service.dart` |
| Service Géolocalisation | ✅ Existant | `lib/services/geolocation_service.dart` |
| Écran Login | ✅ Existant | `lib/screens/login_screen.dart` |
| Écran Dashboard | ✅ Existant | `lib/screens/dashboard_screen.dart` |
| Écran Transaction | ✅ Existant | `lib/screens/transaction_screen.dart` |
| Écran Recensement | ✅ Existant | `lib/screens/recensement_screen.dart` |
| Écran Carte | ✅ Existant | `lib/screens/carte_screens.dart` |
| Écran Géolocalisation | ✅ Existant | `lib/screens/geolocation_screen.dart` |
| Tableau de bord agent dédié | ❌ Manquant | À créer |
| Fiche contribuable terrain | ❌ Manquant | À créer |
| Tournée de collecte | ❌ Manquant | À créer |
| Visite de terrain | ❌ Manquant | À créer |
| Encaissement (UI dédiée) | ❌ Manquant | À créer |
| Reçu + QR Code | ❌ Manquant | À créer |
| Gestion des impayés | ❌ Manquant | À créer |
| Promesse de paiement | ❌ Manquant | À créer |
| Nouveau contribuable (agent) | ❌ Manquant | À créer |
| Évaluation activité | ❌ Manquant | À créer |
| Synchronisation (UI dédiée) | ❌ Manquant | À créer |
| Gestion des conflits | ❌ Manquant | À créer |
| Notifications agent | ❌ Manquant | À créer |
| Messagerie superviseur | ❌ Manquant | À créer |
| Statistiques personnelles | ❌ Manquant | À créer |
| Journal d'activité | ❌ Manquant | À créer |
| Gestion de caisse | ❌ Manquant | À créer |
| Remise de caisse | ❌ Manquant | À créer |
| Carte de collecte (vue agent) | ❌ Manquant | À créer |
| Mode "proche de moi" | ❌ Manquant | À créer |

---

## 1. Tableau de bord de l'agent

### 1.1 Vue d'ensemble

À la connexion, l'agent voit immédiatement un récapitatif de sa mission du jour.

```
AGENT DE COLLECTE
────────────────────────────────
📍 Secteur : Quartier France
👤 Contribuables affectés : 126

Aujourd'hui
----------------
À visiter              24
Visités                17
Non rencontrés          4
À revoir                3

💰 Collecte
----------------
Montant attendu   485 000 F
Montant collecté  327 500 F
Taux recouvrement     67 %

🔄 Synchronisation
✓ Synchronisé
Dernière synchro : 10:24
```

### 1.2 KPIs à afficher

| KPI | Source | Offline |
|-----|--------|---------|
| Nombre de contribuables affectés | API `/api/taxcollect/contribuable?agentId=` | SQLite cache |
| Nombre à visiter aujourd'hui | Tournée locale | SQLite |
| Nombre de visites effectuées | Visites locales | SQLite |
| Nombre non rencontrés | Visites (statut) | SQLite |
| Nombre de taxes à recouvrer | API `/api/transactions?status=pending` | SQLite |
| Montant collecté aujourd'hui | Transactions locales | SQLite |
| Montant collecté sur la période | API ou SQLite | SQLite |
| Paiements en attente de sync | StorageService | SQLite |
| Alertes / anomalies | Visites + transactions | SQLite |
| État Online/Offline | ConnectivityService | N/A |
| Dernière synchronisation | StorageService | SQLite |

### 1.3 Implémentation

- **Écran** : `lib/screens/agent_dashboard_screen.dart` (à créer)
- **Service** : Réutiliser `TransactionService`, `AgentService`, `ConnectivityService`, `StorageService`
- **Navigation** : Remplacer `DashboardScreen` par `AgentDashboardScreen` si `user.isAgent`

---

## 2. Gestion des contribuables

### 2.1 Consultation

L'agent consulte les contribuables **affectés à sa zone**.

**Champs affichés** :
- Nom / raison sociale
- Type de contribuable (`typeContribuable`)
- Activité (`activite`)
- Téléphone
- Adresse
- Quartier
- Secteur
- Zone
- Localisation GPS (latitude, longitude)
- Type de taxe (`taxeIds`)
- Montant dû
- Historique des paiements
- Situation fiscale
- Statut (`statut`)

### 2.2 Recherche

Recherche rapide par :
- Nom
- Numéro contribuable
- Téléphone
- Référence fiscale
- Activité
- Adresse

**Critique** : la recherche doit fonctionner **offline** dans SQLite.

### 2.3 Implémentation

- **Écran** : `lib/screens/contribuable_list_screen.dart` (à créer)
- **Service** : Étendre `AgentService` avec `getContribuablesByAgent(agentId)`
- **Offline** : `StorageService` stocke les contribuables synchronisés
- **Modèle** : `ContribuableDto` déjà existant, ajouter champs `montantDu`, `historiquePaiements`

---

## 3. Fiche contribuable terrain

### 3.1 UI

```
┌──────────────────────────────┐
│ CONTRIBUABLE                 │
│                              │
│ ETS KOUASSI                  │
│ Commerce                     │
│                              │
│ 📍 Quartier France           │
│ 📞 07 XX XX XX XX            │
│                              │
│ TAXE À PAYER                 │
│ 25 000 FCFA                  │
│                              │
│ Statut : À recouvrer         │
│                              │
│ [ ENCAISSER ]                │
│ [ VISITER ]                  │
│ [ ITINÉRAIRE ]               │
└──────────────────────────────┘
```

### 3.2 Actions

| Bouton | Action | Écran de destination |
|--------|--------|---------------------|
| ENCAISSER | Ouvre l'écran d'encaissement | `EncaissementScreen` |
| VISITER | Démarre une visite terrain | `VisiteScreen` |
| ITINÉRAIRE | Ouvre la carte avec navigation | `GeolocationScreen` |

### 3.3 Implémentation

- **Écran** : `lib/screens/contribuable_detail_screen.dart` (à créer)
- **Modèle** : `ContribuableDto` + nouveau modèle `ContribuableDetailDto` (avec montantDu, historique)

---

## 4. Géolocalisation

### 4.1 Fonctions

- Obtenir sa position GPS (`GeolocationService` déjà existant)
- Voir les contribuables proches
- Afficher les contribuables sur une carte (`carte_screens.dart` existant)
- Naviguer vers un contribuable
- Enregistrer la position du contribuable
- Détecter une position incohérente
- Enregistrer latitude/longitude lors de la visite

### 4.2 Mode "Contribuables autour de moi"

```
       📍 Agent

  🟢  ETS KOFFI       35 m
  🟡  MAQUIS LA PAIX  120 m
  🔴  ETS YAO         280 m
```

### 4.3 Implémentation

- **Service** : `GeolocationService` déjà existant, étendre avec `getNearbyContribuables(lat, lng, radius)`
- **Écran** : `lib/screens/nearby_contribuables_screen.dart` (à créer)
- **Calcul distance** : Formule de Haversine

---

## 5. Tournée de collecte

### 5.1 Structure

```
TOURNÉE DU 11/09/2026

1. ETS KOUASSI       ✓
2. MAQUIS LA PAIX    ✓
3. ETS YAO            →
4. GARAGE BÉDIÉ       →
5. BOUTIQUE N'GUESSAN →
```

### 5.2 Statuts de visite

| Statut | Code | Description |
|--------|------|-------------|
| À visiter | `A_VISITER` | Pas encore visité |
| En cours | `EN_COURS` | Visite en cours |
| Visité | `VISITE` | Visite effectuée |
| Payé | `PAYE` | Paiement effectué |
| Partiellement payé | `PAIEMENT_PARTIEL` | Paiement partiel |
| Refus | `REFUS` | Refus de payer |
| Absent | `ABSENT` | Contribuable absent |
| À revoir | `A_REVOIR` | Replanifier |
| Introuvable | `INTROUVABLE` | Adresse incorrecte |

### 5.3 Implémentation

- **Modèle** : `TourneeDto` (à créer dans `lib/models/tournee.dart`)
- **Service** : `TourneeService` (à créer dans `lib/services/tournee_service.dart`)
- **Écran** : `lib/screens/tournee_screen.dart` (à créer)
- **Offline** : Tournée stockée dans SQLite au début de journée

---

## 6. Visite de terrain

### 6.1 Début de visite

Le système enregistre :
- Date
- Heure
- GPS (latitude, longitude)
- Agent (id)
- Contribuable (id)
- Appareil (device id)
- Statut synchronisation

### 6.2 Résultat de visite

| Motif | Code |
|-------|------|
| Paiement effectué | `PAIEMENT_EFFECTUE` |
| Paiement partiel | `PAIEMENT_PARTIEL` |
| Promesse de paiement | `PROMESSE_PAIEMENT` |
| Contribuable absent | `ABSENT` |
| Refus de payer | `REFUS` |
| Activité fermée | `ACTIVITE_FERMEE` |
| Adresse incorrecte | `ADRESSE_INCORRECTE` |
| Contribuable introuvable | `INTROUVABLE` |
| Autre | `AUTRE` |

Avec observation libre possible.

### 6.3 Implémentation

- **Modèle** : `VisiteDto` (à créer dans `lib/models/visite.dart`)
- **Service** : `VisiteService` (à créer dans `lib/services/visite_service.dart`)
- **Écran** : `lib/screens/visite_screen.dart` (à créer)
- **Offline** : Visites stockées dans SQLite, sync au retour réseau

---

## 7. Encaissement

### 7.1 Modes de paiement

| Mode | Code | Offline autorisé |
|------|------|-------------------|
| Espèces | `ESPECE` | ✅ Oui |
| Orange Money | `ORANGE_MONEY` | ❌ Non |
| MTN Money | `MTN_MONEY` | ❌ Non |
| Moov Money | `MOOV_MONEY` | ❌ Non |
| Wave | `WAVE` | ❌ Non |
| Paiement QR | `QR_CODE` | ❌ Non |
| Paiement par lien | `LIEN_PAIEMENT` | ❌ Non |

### 7.2 Flow

1. Agent sélectionne un contribuable
2. Agent sélectionne la taxe à encaisser
3. Système affiche le montant dû
4. Agent sélectionne le mode de paiement
5. Si Mobile Money → vérification online obligatoire
6. Si Espèces → encaissement offline autorisé
7. Backend génère une référence de paiement unique
8. Reçu généré

### 7.3 Paiement partiel

```
Montant dû :       25 000 F
Montant payé :     10 000 F
Reste :            15 000 F

[ VALIDER ]
```

Le système conserve :
- Montant initial
- Montant payé
- Solde restant
- Historique des versements

### 7.4 Implémentation

- **Écran** : `lib/screens/encaissement_screen.dart` (à créer)
- **Service** : Étendre `TransactionService` avec `createPartialPayment()`
- **Modèle** : Étendre `TransactionDTO` avec `montantInitial`, `montantPaye`, `soldeRestant`
- **ModePaiement** : Étendre l'enum existant avec `ORANGE_MONEY`, `MTN_MONEY`, `MOOV_MONEY`, `WAVE`

---

## 8. Génération du reçu

### 8.1 Format

```
PAIEMENT CONFIRMÉ

Référence :
EC-2026-0004587

Contribuable :
ETS KOUASSI

Taxe :
Taxe communale

Montant :
25 000 FCFA

Date :
11/09/2026 10:18

Agent :
AG-0042
```

### 8.2 Actions sur reçu

| Action | Implémentation |
|--------|----------------|
| Reçu numérique | Widget Flutter avec QR Code |
| QR Code | Package `qr_flutter` |
| Impression Bluetooth | Package `esc_pos_printer` ou `bluetooth_print` |
| Partage WhatsApp | `share_plus` package |
| SMS | `url_launcher` avec `sms:` scheme |
| Téléchargement PDF | `pdf` package (online uniquement) |

### 8.3 Implémentation

- **Écran** : `lib/screens/recu_screen.dart` (à créer)
- **Widget** : `lib/widgets/recu_widget.dart` (à créer)
- **Service** : `RecuService` (à créer dans `lib/services/recu_service.dart`)

---

## 9. Vérification du reçu

L'agent scanne un QR Code pour vérifier :
- Référence
- Contribuable
- Montant
- Date
- Statut du paiement

### 9.1 Implémentation

- **Écran** : `lib/screens/verif_recu_screen.dart` (à créer)
- **Scanner** : Package `mobile_scanner` (déjà dans le projet)
- **Service** : `RecuService.verifyByQr(qrData)`

---

## 10. Gestion des impayés

### 10.1 Liste

```
À recouvrer

ETS YAO             50 000 F
MAQUIS BONHEUR      25 000 F
GARAGE ABC          75 000 F
────────────────────────────
TOTAL               150 000 F
```

### 10.2 Actions

| Action | Description |
|--------|-------------|
| Visiter | Démarrer une visite |
| Relancer | Marquer comme relancé |
| Encaisser | Ouvrir l'écran d'encaissement |
| Enregistrer promesse | Créer une promesse de paiement |
| Constater refus | Enregistrer un refus |
| Programmer nouvelle visite | Ajouter à la tournée |

### 10.3 Implémentation

- **Écran** : `lib/screens/impayes_screen.dart` (à créer)
- **Service** : Étendre `TransactionService` avec `getImpayesByAgent(agentId)`

---

## 11. Promesse de paiement

### 11.1 Formulaire

```
PROMESSE DE PAIEMENT

Montant : 50 000 F

Promesse :
15/09/2026

Observation :
Paiement après encaissement client
```

### 11.2 Implémentation

- **Modèle** : `PromessePaiementDto` (à créer dans `lib/models/promesse_paiement.dart`)
- **Service** : `PromesseService` (à créer dans `lib/services/promesse_service.dart`)
- **Écran** : `lib/screens/promesse_screen.dart` (à créer)
- **Relance** : Le système crée automatiquement une entrée de relance dans la tournée

---

## 12. Nouveau contribuable (agent)

### 12.1 Formulaire

L'agent peut créer un nouveau contribuable terrain :

| Champ | Type | Requis |
|-------|------|--------|
| Nom | String | ✅ |
| Activité | String | ✅ |
| Téléphone | String | ✅ |
| Adresse | String | ✅ |
| Quartier | Dropdown | ✅ |
| Secteur | Dropdown | ✅ |
| Coordonnées GPS | Auto (GPS) | ✅ |
| Type d'activité | Dropdown | ✅ |
| Photo de l'activité | Image | Optionnel |
| Observation | Text | Optionnel |

**Important** : Le contribuable créé par l'agent a `necessiteValidation = true` et doit être validé par le superviseur.

### 12.2 Implémentation

- **Écran** : Réutiliser `RecensementScreen` existant avec adaptations
- **Modèle** : `ContribuableDto` déjà existant avec `necessiteValidation`
- **Service** : `RecensementService` déjà existant

---

## 13. Évaluation de l'activité

### 13.1 Flow

```
baseImposable renseignée
        ↓
sinon estimation selon activité
        ↓
calcul taxe
        ↓
proposition de montant
        ↓
validation selon règles
```

### 13.2 Champs

| Champ | Description |
|-------|-------------|
| Activité | Type d'activité |
| Base imposable | Saisie agent ou estimée |
| Montant taxe | Calculé automatiquement |
| Proposition | Soumise au superviseur si > seuil |

### 13.3 Implémentation

- **Écran** : `lib/screens/evaluation_activite_screen.dart` (à créer)
- **Service** : Étendre `RecensementService` avec `evaluateActivite()`

---

## 14. Collecte offline

### 14.1 Architecture

```
              MOBILE
                 │
          ┌──────▼──────┐
          │   SQLite     │
          └──────┬──────┘
                 │
              Sync
                 │
                 ▼
        Spring Boot API
                 │
                 ▼
             PostgreSQL
```

### 14.2 Fonctions offline

| Fonction | Offline | Online |
|----------|---------|--------|
| Consulter contribuables affectés | ✅ SQLite | ✅ API |
| Rechercher | ✅ SQLite | ✅ API |
| Enregistrer visite | ✅ SQLite | ✅ API |
| GPS | ✅ Natif | ✅ Natif |
| Saisir paiement espèces | ✅ SQLite | ✅ API |
| Saisir paiement mobile money | ❌ Refusé | ✅ API |
| Générer reçu provisoire | ✅ Local | ✅ API |
| Enregistrer nouveau contribuable | ✅ SQLite | ✅ API |
| Travailler sur tournée | ✅ SQLite | ✅ API |
| Synchronisation | ❌ | ✅ API |

### 14.3 Implémentation

- **Service** : `StorageService` déjà existant, étendre avec tables SQLite supplémentaires
- **Tables SQLite à ajouter** : `visites`, `tournees`, `promesses`, `nouveaux_contribuables`, `recus_offline`
- **Sync** : `SyncService` (à créer dans `lib/services/sync_service.dart`)

---

## 15. Synchronisation

### 15.1 Écran

```
Synchronisation
Dernière synchronisation
10:24:32

À envoyer
✓ 12 visites
✓ 7 paiements
✓ 2 nouveaux contribuables

À recevoir
✓ 18 contribuables
✓ 4 nouvelles affectations

[ SYNCHRONISER ]
```

### 15.2 File locale

| Statut | Code | Description |
|--------|------|-------------|
| En attente | `PENDING` | Pas encore synchronisé |
| En cours | `SYNCING` | Synchronisation en cours |
| Synchronisé | `SYNCED` | Synchronisé avec succès |
| Échec | `FAILED` | Échec de synchronisation |
| Conflit | `CONFLICT` | Conflit détecté |

### 15.3 Implémentation

- **Écran** : `lib/screens/sync_screen.dart` (à créer)
- **Service** : `SyncService` (à créer)
- **Modèle** : `SyncItemDto` (à créer)

---

## 16. Gestion des conflits

### 16.1 Exemple

```
⚠ CONFLIT

Contribuable : ETS KOUASSI

Paiement local : 25 000 F
Paiement serveur : 25 000 F

Action :
[ Voir détail ]
```

### 16.2 Règles

- Le système **ne doit pas** écraser les données automatiquement
- L'agent ou le superviseur doit résoudre le conflit manuellement
- Si même montant → probablement doublon → marquer comme `SYNCED` avec warning
- Si montant différent → conserver les deux, signaler au superviseur

### 16.3 Implémentation

- **Écran** : `lib/screens/conflict_screen.dart` (à créer)
- **Service** : `SyncService.resolveConflict()`

---

## 17. Notifications agent

### 17.1 Types

| Type | Description |
|------|-------------|
| Nouvelle affectation | Nouveaux contribuables assignés |
| Nouvelle tournée | Tournée du jour disponible |
| Contribuable à revoir | Relance programmée |
| Promesse à échéance | Promesse de paiement arrivée à échéance |
| Paiement confirmé | Paiement mobile money confirmé |
| Sync échouée | Synchronisation en échec |
| Anomalie détectée | Position incohérente, doublon, etc. |
| Changement de secteur | Réaffectation de zone |
| Message superviseur | Communication du superviseur |

### 17.2 Implémentation

- **Service** : `NotificationService` (à créer dans `lib/services/notification_service.dart`)
- **Push** : Firebase Cloud Messaging (FCM) pour online
- **Local** : `flutter_local_notifications` pour offline

---

## 18. Messagerie avec superviseur

### 18.1 Signalement

```
SIGNALER UN PROBLÈME

○ Adresse incorrecte
○ Mauvaise affectation
○ Contribuable contestataire
○ Montant contesté
○ Activité fermée
○ Problème paiement
○ Problème application

Commentaire :
[......................]

[ ENVOYER ]
```

### 18.2 Implémentation

- **Écran** : `lib/screens/messagerie_screen.dart` (à créer)
- **Service** : `MessagerieService` (à créer)
- **Modèle** : `MessageDto`, `SignalementDto` (à créer)

---

## 19. Statistiques personnelles

### 19.1 Périodes

| Période | Métriques |
|---------|-----------|
| Aujourd'hui | Visites, paiements, montant collecté, taux recouvrement, contribuables visités |
| Semaine | Nombre de visites, montant collecté, nouveaux contribuables, taux réussite |
| Mois | Synthèse mensuelle |

L'agent **ne voit pas** les performances des autres agents.

### 19.2 Implémentation

- **Écran** : `lib/screens/agent_stats_screen.dart` (à créer)
- **Service** : Étendre `TransactionService` avec `getAgentStats(agentId, period)`

---

## 20. Journal d'activité

### 20.1 Format

```
10:21  Visite contribuable
10:23  Paiement enregistré
10:24  Reçu généré
10:25  Nouveau contribuable créé
10:28  Synchronisation
```

### 20.2 Implémentation

- **Modèle** : `AuditEntryDto` (à créer dans `lib/models/audit_entry.dart`)
- **Service** : `AuditService` (à créer dans `lib/services/audit_service.dart`)
- **Stockage** : SQLite local + sync vers backend
- **Écran** : `lib/screens/journal_screen.dart` (à créer)

---

## 21. Sécurité de l'agent

### 21.1 Permissions

| Action | Autorisé | Refusé |
|--------|----------|--------|
| Consulter ses contribuables | ✅ | |
| Faire des visites | ✅ | |
| Enregistrer des paiements | ✅ | |
| Créer des prospects/contribuables | ✅ | |
| Consulter ses propres opérations | ✅ | |
| Synchroniser | ✅ | |
| Modifier les règles fiscales | | ❌ |
| Modifier les taux | | ❌ |
| Supprimer un paiement | | ❌ |
| Supprimer un contribuable | | ❌ |
| Modifier les paiements validés | | ❌ |
| Affecter un autre agent | | ❌ |
| Clôturer une caisse | | ❌ |
| Gérer les utilisateurs | | ❌ |
| Voir toutes les données de la commune | | ❌ |

### 21.2 Implémentation

- **RBAC** : Keycloak roles `AGENT`, `SUPERVISEUR`, `TRESOR`, `ADMIN`
- **Frontend** : `User.isAgent` déjà existant dans `lib/models/user.dart`
- **Backend** : `WebSecurityConfig` déjà existant avec `requestMatchers`

---

## 22. Gestion de caisse

### 22.1 Ouverture

```
Caisse du 11/09/2026

Solde initial : 0 F

[ OUVRIR LA CAISSE ]
```

### 22.2 Pendant la journée

```
Espèces collectées : 125 000 F
Mobile Money :        80 000 F
Total :              205 000 F
```

### 22.3 Clôture

```
Total attendu : 125 000 F
Total remis :   125 000 F

Écart : 0 F

[ CLÔTURER ]
```

### 22.4 Implémentation

- **Modèle** : `CaisseDto` (à créer dans `lib/models/caisse.dart`)
- **Service** : `CaisseService` (à créer dans `lib/services/caisse_service.dart`)
- **Écran** : `lib/screens/caisse_screen.dart` (à créer)
- **Backend** : `ClotureCaisseController` déjà existant

---

## 23. Remise de caisse

L'agent déclare la remise :
- Montant
- Bénéficiaire
- Date
- Heure
- Référence
- Observation

Le superviseur/trésorier confirme.

### 23.1 Implémentation

- **Modèle** : `RemiseCaisseDto` (à créer)
- **Service** : Étendre `CaisseService` avec `createRemise()`
- **Écran** : `lib/screens/remise_caisse_screen.dart` (à créer)

---

## 24. Mode "ma zone"

L'agent voit uniquement son périmètre :

```
COMMUNE
   ↓
ZONE
   ↓
QUARTIER
   ↓
SECTEUR
   ↓
AGENT
```

### 24.1 Implémentation

- **Filtrage API** : Tous les endpoints doivent accepter `agentId` en paramètre
- **Filtrage local** : SQLite ne stocke que les données de la zone de l'agent
- **Modèles** : `CommuneDto`, `QuartierDto`, `ZoneCollectDto` déjà existants

---

## 25. Carte de collecte

### 25.1 Vue

```
🗺️ Carte
```

Marqueurs :

| Couleur | Statut |
|---------|--------|
| 🟢 Vert | Payé |
| 🟠 Orange | À recouvrer |
| 🔴 Rouge | Impayé |
| 🔵 Bleu | Nouveau |
| ⚫ Noir | Introuvable |

### 25.2 Filtres

- Tous
- À visiter
- Impayés
- Payés
- Nouveaux
- Aujourd'hui

### 25.3 Implémentation

- **Écran** : Étendre `carte_screens.dart` existant avec vue agent
- **Service** : `CarteContribuableService` déjà existant

---

## 26. Mode "proche de moi"

### 26.1 Rayons

| Rayon | Valeur |
|-------|--------|
| 50 m | Très proche |
| 100 m | Proche |
| 250 m | Quartier |
| 500 m | Secteur |
| 1 km | Zone élargie |

### 26.2 Implémentation

- **Écran** : `lib/screens/nearby_contribuables_screen.dart` (à créer)
- **Service** : Étendre `GeolocationService` avec `getNearbyContribuables()`
- **Calcul** : Formule de Haversine sur les contribuables en cache SQLite

---

## 27. Architecture du module Agent

### 27.1 Navigation

```
┌───────────────────────────────┐
│       E-COLLECTE TAXE         │
├───────────────────────────────┤
│                               │
│ 🏠 Tableau de bord            │
│                               │
│ 🗺️ Carte                      │
│                               │
│ 👥 Contribuables              │
│                               │
│ 📋 Tournée                    │
│                               │
│ 💰 Encaissements              │
│                               │
│ 📄 Reçus                      │
│                               │
│ 🔄 Synchronisation            │
│                               │
│ 🔔 Notifications              │
│                               │
│ 📊 Mes statistiques           │
│                               │
│ 👤 Mon profil                 │
│                               │
└───────────────────────────────┘
```

### 27.2 Structure des fichiers à créer

```
verdentax/lib/
├── models/
│   ├── tournee.dart              (à créer)
│   ├── visite.dart               (à créer)
│   ├── promesse_paiement.dart    (à créer)
│   ├── caisse.dart               (à créer)
│   ├── audit_entry.dart         (à créer)
│   ├── sync_item.dart            (à créer)
│   └── notification.dart        (à créer)
├── services/
│   ├── tournee_service.dart      (à créer)
│   ├── visite_service.dart      (à créer)
│   ├── encaissement_service.dart (à créer)
│   ├── recu_service.dart        (à créer)
│   ├── promesse_service.dart    (à créer)
│   ├── caisse_service.dart      (à créer)
│   ├── sync_service.dart        (à créer)
│   ├── notification_service.dart (à créer)
│   ├── messagerie_service.dart  (à créer)
│   ├── audit_service.dart       (à créer)
│   └── nearby_service.dart      (à créer)
├── screens/
│   ├── agent_dashboard_screen.dart       (à créer)
│   ├── contribuable_list_screen.dart     (à créer)
│   ├── contribuable_detail_screen.dart   (à créer)
│   ├── tournee_screen.dart               (à créer)
│   ├── visite_screen.dart                (à créer)
│   ├── encaissement_screen.dart          (à créer)
│   ├── recu_screen.dart                  (à créer)
│   ├── verif_recu_screen.dart            (à créer)
│   ├── impayes_screen.dart               (à créer)
│   ├── promesse_screen.dart              (à créer)
│   ├── evaluation_activite_screen.dart   (à créer)
│   ├── sync_screen.dart                  (à créer)
│   ├── conflict_screen.dart              (à créer)
│   ├── nearby_contribuables_screen.dart  (à créer)
│   ├── caisse_screen.dart                (à créer)
│   ├── remise_caisse_screen.dart         (à créer)
│   ├── agent_stats_screen.dart           (à créer)
│   ├── journal_screen.dart               (à créer)
│   ├── messagerie_screen.dart            (à créer)
│   └── notifications_screen.dart         (à créer)
└── widgets/
    ├── recu_widget.dart                  (à créer)
    ├── kpi_card.dart                     (à créer)
    ├── contributable_card.dart           (à créer)
    └── sync_status_badge.dart            (à créer)
```

---

## 28. Priorisation du développement

### P0 — Critique (Sprint 1)

| # | Fonction | Dépendances |
|---|----------|-------------|
| 1 | Authentification / profil agent | ✅ Existant |
| 2 | Tableau de bord agent | Aucune |
| 3 | Contribuables affectés + recherche offline | Tableau de bord |
| 4 | Fiche contribuable terrain | Contribuables |
| 5 | Carte + GPS | ✅ Existant (à adapter) |
| 6 | Visite terrain | Fiche contribuable |
| 7 | Encaissement (espèces + mobile money) | Fiche contribuable |
| 8 | Reçu + QR Code | Encaissement |
| 9 | Offline SQLite | Tous les ci-dessus |
| 10 | Synchronisation | Offline |
| 11 | Historique / audit | Tous les ci-dessus |
| 12 | Gestion des impayés | Contribuables |

### P1 — Important (Sprint 2)

| # | Fonction | Dépendances |
|---|----------|-------------|
| 13 | Tournées | Visite terrain |
| 14 | Promesses de paiement | Visite terrain |
| 15 | Nouveau contribuable (agent) | ✅ RecensementScreen existant |
| 16 | Évaluation activité | Nouveau contribuable |
| 17 | Gestion de caisse | Encaissement |
| 18 | Notifications | SyncService |

### P2 — Amélioration (Sprint 3)

| # | Fonction | Dépendances |
|---|----------|-------------|
| 19 | Statistiques avancées | Transactions |
| 20 | Optimisation d'itinéraire | Tournées + GPS |
| 21 | Messagerie superviseur | Notifications |
| 22 | Mode "proche de moi" | GPS + SQLite |
| 23 | Vérification reçu par QR | Reçu + QR Code |
| 24 | Gestion des conflits | Synchronisation |

---

## 29. Architecture RBAC

### 29.1 Séparation des rôles

| Rôle | Périmètre | Keycloak Role |
|------|-----------|---------------|
| Agent | Terrain, collecte, visites | `AGENT` |
| Superviseur | Contrôle, validation, affectations | `SUPERVISEUR` |
| Trésorier | Encaissements, caisse, remises | `TRESOR` |
| Admin | Tout | `ADMIN` |

### 29.2 Endpoints backend par rôle

| Endpoint | Agent | Superviseur | Trésor | Admin |
|----------|-------|-------------|--------|-------|
| `GET /api/taxcollect/contribuable` | Ses contribuables uniquement | Tous | Lecture | Tous |
| `POST /api/transactions` | ✅ | ✅ | ✅ | ✅ |
| `DELETE /api/transactions` | ❌ | ❌ | ❌ | ✅ |
| `POST /api/taxcollect/contribuable` | ✅ (avec validation) | ✅ | ❌ | ✅ |
| `PUT /api/taxcollect/contribuable` | ❌ | ✅ (validation) | ❌ | ✅ |
| `GET /api/cloture-caisse` | Sa caisse | Toutes | Toutes | Tous |
| `POST /api/cloture-caisse` | ❌ | ❌ | ✅ | ✅ |
| `GET /api/taxcollect/agent` | Son profil | Tous | ❌ | Tous |

---

## 30. Configuration technique

### 30.1 Packages Flutter à ajouter

| Package | Usage | Version |
|---------|-------|---------|
| `qr_flutter` | Génération QR Code | ^4.1.0 |
| `mobile_scanner` | Scan QR Code | ^3.5.5 (déjà présent) |
| `share_plus` | Partage WhatsApp/SMS | ^7.2.1 |
| `pdf` | Génération PDF reçu | ^3.10.7 |
| `bluetooth_print` | Impression Bluetooth | ^4.3.0 |
| `flutter_local_notifications` | Notifications locales | ^17.0.0 |
| `firebase_messaging` | Push notifications | ^15.0.0 |
| `sqflite` | SQLite local | ^2.3.0 (déjà présent) |
| `path_provider` | Chemins fichiers | ^2.1.2 (déjà présent) |

### 30.2 Configuration app_config.dart

```dart
// Endpoints à ajouter
static const String tourneeEndpoint = '/api/taxcollect/tournee';
static const String visiteEndpoint = '/api/taxcollect/visite';
static const String promesseEndpoint = '/api/taxcollect/promesse';
static const String caisseEndpoint = '/api/cloture-caisse';
static const String syncEndpoint = '/api/sync';
static const String notificationEndpoint = '/api/notifications';
static const String messagerieEndpoint = '/api/messagerie';
```

### 30.3 Schéma SQLite

Tables à ajouter au `StorageService` existant :

```sql
CREATE TABLE visites (
  id TEXT PRIMARY KEY,
  contribuable_id INTEGER,
  agent_id INTEGER,
  date_visite TEXT,
  gps_lat REAL,
  gps_lng REAL,
  resultat TEXT,
  observation TEXT,
  sync_status TEXT DEFAULT 'PENDING',
  created_at TEXT
);

CREATE TABLE tournees (
  id TEXT PRIMARY KEY,
  date TEXT,
  agent_id INTEGER,
  contribuable_ids TEXT, -- JSON array
  statuts TEXT, -- JSON map
  sync_status TEXT DEFAULT 'PENDING',
  created_at TEXT
);

CREATE TABLE promesses (
  id TEXT PRIMARY KEY,
  contribuable_id INTEGER,
  montant REAL,
  date_promesse TEXT,
  observation TEXT,
  sync_status TEXT DEFAULT 'PENDING',
  created_at TEXT
);

CREATE TABLE recus_offline (
  id TEXT PRIMARY KEY,
  transaction_id TEXT,
  reference TEXT,
  qr_data TEXT,
  sync_status TEXT DEFAULT 'PENDING',
  created_at TEXT
);

CREATE TABLE audit_entries (
  id TEXT PRIMARY KEY,
  action TEXT,
  entity_type TEXT,
  entity_id TEXT,
  details TEXT,
  sync_status TEXT DEFAULT 'PENDING',
  created_at TEXT
);

CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  type TEXT,
  title TEXT,
  body TEXT,
  read INTEGER DEFAULT 0,
  created_at TEXT
);
```
