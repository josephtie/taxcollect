# Architecture de la Plateforme de Collecte de Taxes

## Structure du Projet

```
taxcollect/
├── backend/                          # Spring Boot API (port 9091)
│   ├── src/main/java/com/nectuxingenieries/collect/tax/
│   │   ├── TaxApplication.java       # Point d'entrée principal
│   │   ├── config/                   # Configuration
│   │   │   ├── SecurityConfig.java
│   │   │   ├── OpenApiConfig.java
│   │   │   └── ...
│   │   ├── controllers/               # API REST Controllers (40+)
│   │   │   ├── AuthController.java          # /auth (login, refresh, logout)
│   │   │   ├── TransactionController.java   # /api/transactions
│   │   │   ├── ClotureCaisseController.java # /api/cloture-caisse
│   │   │   ├── AgentController.java         # /api/taxcollect/agent
│   │   │   ├── ContribuableController.java  # /api/taxcollect/contribuable
│   │   │   ├── ZoneController.java          # /api/taxcollect/zone
│   │   │   ├── QuartierController.java      # /api/taxcollect/quartier
│   │   │   ├── SecteurController.java       # /api/taxcollect/secteur
│   │   │   ├── CommuneController.java      # /api/taxcollect/commune
│   │   │   ├── TaxeController.java          # /api/taxcollect/taxe
│   │   │   ├── RecensementController.java  # /api/recensement
│   │   │   ├── VisiteController.java        # /api/taxcollect/visite
│   │   │   ├── TourneeController.java      # /api/taxcollect/tournee
│   │   │   ├── SyncItemController.java     # /api/taxcollect/sync
│   │   │   ├── AuditEntryController.java   # /api/taxcollect/audit
│   │   │   ├── SignalementController.java  # /api/taxcollect/signalement
│   │   │   ├── MessageController.java      # /api/taxcollect/messagerie
│   │   │   ├── PromessePaiementController.java # /api/taxcollect/promesse
│   │   │   ├── CaisseController.java       # /api/taxcollect/caisse
│   │   │   ├── RemiseCaisseController.java # /api/taxcollect/remise-caisse
│   │   │   ├── SupervisionController.java  # /api/taxcollect/supervision
│   │   │   ├── ResponsableController.java  # /api/taxcollect/responsable
│   │   │   ├── CollectionOrderController.java # /api/collection-orders
│   │   │   ├── PaymentController.java      # /api/payments
│   │   │   ├── ReceiptController.java      # /api/receipts
│   │   │   ├── ReconciliationController.java # /api/reconciliation
│   │   │   ├── AssessmentController.java   # /api/assessments
│   │   │   ├── FileUploadController.java   # /api/taxcollect/upload
│   │   │   └── ...
│   │   ├── models/                    # Entités JPA + DTO + enums
│   │   ├── repositories/              # Spring Data JPA
│   │   ├── services/                  # Logique métier (interfaces + impl/)
│   │   ├── security/                  # Sécurité Keycloak/OAuth2
│   │   │   ├── WebSecurityConfig.java
│   │   │   ├── JwtAuthConverter.java       # Convertit realm_access.roles -> ROLE_<ROLE>
│   │   │   └── TerritorialScopeFilter.java # Lit zone_id/quartier_id/secteur_id du JWT
│   │   └── utils/
│   ├── src/main/resources/
│   │   ├── application.yml           # Configuration (port 9091)
│   │   └── db/migration/             # Flyway migrations
│   └── src/test/
├── frontend/                          # Vue.js 3 Dashboard (port 3000 en dev)
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   ├── services/                  # Services Axios (API client)
│   │   ├── router/
│   │   ├── store/                     # Pinia
│   │   └── assets/
│   ├── package.json
│   └── vite.config.js                 # Proxy vers localhost:9091
├── verdentax/                        # Application mobile Flutter
│   ├── lib/
│   │   ├── screens/
│   │   ├── services/                  # Services Dio (API client + offline)
│   │   ├── models/
│   │   ├── config/
│   │   │   └── app_config.dart        # URL de base configurable via --dart-define
│   │   ├── widgets/
│   │   └── utils/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── realm-mairie.json                 # Export du realm Keycloak (rôles + mappers)
├── docs/                             # Documentation
└── docker-compose.yml                # Configuration Docker
```

## Architecture Technique

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.5.0 / Java 17
- **Base de données**: PostgreSQL avec JPA/Hibernate
- **Migrations**: Flyway
- **Sécurité**: Spring Security OAuth2 Resource Server + Keycloak JWT
  - Les rôles sont extraits de `realm_access.roles` et exposés comme `ROLE_<ROLE>`
  - Le `TerritorialScopeFilter` lit les claims `zone_id`, `quartier_id`, `secteur_id`
- **Documentation API**: OpenAPI/Springdoc
- **Mapping**: MapStruct

### Frontend Web (Vue.js 3)
- **Framework**: Vue.js 3 avec Composition API
- **Build Tool**: Vite 5
- **State Management**: Pinia
- **HTTP Client**: Axios
- **UI**: TailwindCSS
- **Cartes**: Leaflet
- **Graphiques**: Chart.js
- **Dev server**: `http://localhost:3000` (proxy vers `http://localhost:9091`)

### Mobile (Flutter / verdentax)
- **Framework**: Flutter / Dart
- **HTTP Client**: Dio
- **State Management**: Provider
- **Stockage sécurisé**: Flutter Secure Storage (tokens, données utilisateur)
- **Stockage local**: Shared Preferences + cache hors-ligne
- **GPS**: Geolocator
- **QR Code**: mobile_scanner / qr_flutter
- **PDF/Impression**: printing + pdf
- **URL de base**: configurable via `--dart-define=API_BASE_URL=...`
  - Défaut: `http://83.171.249.150:9091`

### Keycloak
- **Realm**: `mairie`
- **Clients**: `tax-backend` (resource server), `tax-frontend` (web), `verdentax` (mobile)
- **Rôles**: `ADMIN`, `TRESOR`, `AGENT`, `SUPERVISEUR`, `RESPONSABLE_QUARTIER`, `CONTRIBUABLE`
- **Mappers territoriaux**: `zone_id`, `quartier_id`, `secteur_id` (sur `tax-backend` et `tax-frontend`)

## Rôles et Permissions

| Rôle | Description |
|------|-------------|
| `ADMIN` | Administration complète (utilisateurs, configuration, supervision) |
| `TRESOR` | Trésor public (validation clôtures, export, statistiques) |
| `AGENT` | Agent de collecte (transactions, visites, recensement) |
| `SUPERVISEUR` | Supervision de zone (affectation agents, anomalies, dashboard) |
| `RESPONSABLE_QUARTIER` | Responsable de quartier (suivi collectes, rapports) |
| `CONTRIBUABLE` | Contribuable (consultation, cartes) |

## Flux de Données

1. **Authentification**:
   - Login via `POST /auth/login` (Keycloak)
   - Token JWT stocké côté client (Secure Storage sur mobile, localStorage sur web)
   - Refresh via `POST /auth/refresh`
   - Logout via `POST /auth/logout`

2. **Collection de Taxe**:
   - Agent scanne QR code ou recherche manuelle
   - Saisie montant et mode de paiement
   - Génération reçu avec hash unique
   - Enregistrement GPS pour validation

3. **Mode Hors-ligne (mobile)**:
   - Stockage local (Shared Preferences / cache)
   - Synchronisation automatique au retour réseau
   - File d'attente des transactions via `PUT /api/transactions/{id}/sync`
   - Synchronisation globale via `POST /api/transactions/sync-all`

4. **Clôture de Caisse**:
   - Initier: `POST /api/cloture-caisse/initier`
   - Soumettre: `POST /api/cloture-caisse/{id}/soumettre`
   - Valider (Trésor): `POST /api/cloture-caisse/{id}/valider`
   - Rejeter: `POST /api/cloture-caisse/{id}/rejeter`
   - Confirmer dépôt: `POST /api/cloture-caisse/{id}/confirmer-depot`
   - Statistiques: `GET /api/cloture-caisse/stats`
   - Export: `GET /api/cloture-caisse/export`

5. **Supervision**:
   - Dashboard par zone: `GET /api/taxcollect/supervision/dashboard/{zoneId}`
   - Affectation agents: `POST /api/taxcollect/supervision/assign-agent`
   - Anomalies: `GET /api/taxcollect/supervision/anomalies`

## Sécurité

- **Authentification**: Keycloak OAuth2 / JWT
- **Autorisation**: Rôles Spring Security (`ROLE_ADMIN`, `ROLE_TRESOR`, `ROLE_AGENT`, `ROLE_SUPERVISEUR`, `ROLE_RESPONSABLE_QUARTIER`, `ROLE_CONTRIBUABLE`)
- **Filtre territorial**: `TerritorialScopeFilter` restreint l'accès aux données selon `zone_id` / `quartier_id` / `secteur_id` du JWT
- **Intégrité**: Hash SHA-256 des transactions
- **Audit**: Traçabilité via `AuditEntryController` (`/api/taxcollect/audit`)

## API Endpoints principaux

### Authentification
- `POST /auth/login` - Connexion
- `POST /auth/refresh` - Rafraîchir le token
- `POST /auth/logout` - Déconnexion

### Transactions (`/api/transactions`)
- `POST` - Créer
- `GET` - Lister
- `GET /{id}` - Détails
- `GET /receipt/{numeroRecu}` - Reçu par numéro
- `GET /agent/{agentId}` - Par agent
- `GET /agent/{agentId}/range` - Par agent et période
- `PUT /{id}/sync` - Synchroniser
- `POST /sync-all` - Synchroniser tout
- `PUT /{id}/status` - Mettre à jour le statut
- `GET /{id}/verify` - Vérifier
- `GET /offline/count` - Compteur hors-ligne
- `GET /filter` - Filtrer (paginé, params: `debut`, `fin`, `agentId`, `paymentMethod`, `statut`)
- `GET /stats` - Statistiques (params: `debut`, `fin`)
- `GET /export` - Export CSV/XLSX
- `GET /zone/{zoneId}` - Par zone
- `GET /contribuable/{contribuableId}` - Par contribuable

### Clôture de Caisse (`/api/cloture-caisse`)
- `POST /initier` - Initier
- `POST /{id}/soumettre` - Soumettre
- `POST /{id}/valider` - Valider
- `POST /{id}/rejeter` - Rejeter
- `POST /{id}/confirmer-depot` - Confirmer dépôt
- `GET /{id}` - Détails
- `GET /agent/{agentId}` - Par agent
- `GET /range` - Par période
- `GET /stats` - Statistiques
- `GET /export` - Export

### Territorial (`/api/taxcollect/...`)
- `agent` - Agents
- `zone` - Zones (avec `/commune/{communeId}`, `/search`)
- `quartier` - Quartiers (avec `/zone/{zoneId}`, `/{quartierId}/secteurs`)
- `secteur` - Secteurs
- `commune` - Communes (avec `/{communeId}/zones`)
- `contribuable` - Contribuables (avec `/search`, `/zone/{zoneId}`, `/stats`, `/export`)
- `taxe` - Taxes (avec `/search`, `/stats`, `/export`)

### Recensement (`/api/recensement`)
- `POST /contribuables` - Créer
- `GET /contribuables` - Lister
- `GET /contribuables/agent/{agentId}` - Par agent
- `GET /contribuables/search` - Rechercher
- `GET /statistics` - Statistiques

### Synchronisation et Audit
- `/api/taxcollect/sync` - Items de synchronisation
- `/api/taxcollect/audit` - Entrées d'audit

### Supervision et Responsable
- `/api/taxcollect/supervision` - Routes superviseur
- `/api/taxcollect/responsable` - Routes responsable de quartier

### Autres
- `/api/collection-orders` - Ordres de collecte
- `/api/payments` - Paiements
- `/api/receipts` - Reçus
- `/api/reconciliation` - Réconciliation
- `/api/assessments` - Évaluations
- `/api/taxcollect/upload` - Upload de fichiers
