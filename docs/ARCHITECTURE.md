# Architecture de la Plateforme de Collecte de Taxes

## Structure du Projet

```
taxcollect/
├── backend/                          # Spring Boot API
│   ├── src/main/java/com/nectuxingenieries/collect/tax/
│   │   ├── TaxApplication.java       # Point d'entrée principal
│   │   ├── config/                   # Configuration de l'application
│   │   │   ├── SecurityConfig.java
│   │   │   ├── JpaConfig.java
│   │   │   └── SwaggerConfig.java
│   │   ├── controllers/               # API REST Controllers
│   │   │   ├── TransactionController.java
│   │   │   ├── ClotureCaisseController.java
│   │   │   ├── AgentController.java
│   │   │   ├── ContribuableController.java
│   │   │   └── DashboardController.java
│   │   ├── models/                    # Entités JPA
│   │   │   ├── Agents.java
│   │   │   ├── Contribuable.java
│   │   │   ├── Transaction.java
│   │   │   ├── ClotureCaisse.java
│   │   │   ├── ZoneCollecte.java
│   │   │   ├── QRCodeContribuable.java
│   │   │   ├── Auditable.java
│   │   │   ├── enums/
│   │   │   │   ├── ModePaiement.java
│   │   │   │   ├── StatutTransaction.java
│   │   │   │   └── StatutCloture.java
│   │   │   ├── dto/                   # Data Transfer Objects
│   │   │   │   ├── TransactionDTO.java
│   │   │   │   ├── ClotureCaisseDTO.java
│   │   │   │   └── DashboardDTO.java
│   │   │   └── mappers/               # MapStruct mappers
│   │   ├── repositories/              # Spring Data JPA
│   │   │   ├── TransactionRepository.java
│   │   │   ├── ClotureCaisseRepository.java
│   │   │   ├── AgentRepository.java
│   │   │   └── ContribuableRepository.java
│   │   ├── services/                  # Logique métier
│   │   │   ├── TransactionService.java
│   │   │   ├── ClotureCaisseService.java
│   │   │   ├── QRCodeService.java
│   │   │   ├── DashboardService.java
│   │   │   └── SecurityService.java
│   │   ├── security/                  # Sécurité
│   │   │   ├── JwtAuthenticationFilter.java
│   │   │   └── CustomUserDetailsService.java
│   │   └── utils/                     # Utilitaires
│   │       ├── TransactionHashUtil.java
│   │       ├── QRCodeGenerator.java
│   │       └── ReceiptNumberGenerator.java
│   ├── src/main/resources/
│   │   ├── application.yml           # Configuration
│   │   └── db/migration/             # Flyway migrations
│   └── src/test/                     # Tests
├── frontend/                          # Vue.js 3 Dashboard
│   ├── src/
│   │   ├── components/
│   │   │   ├── Dashboard.vue
│   │   │   ├── TransactionList.vue
│   │   │   ├── ClotureCaisse.vue
│   │   │   └── AgentManagement.vue
│   │   ├── views/
│   │   ├── services/
│   │   ├── router/
│   │   ├── store/
│   │   └── assets/
│   ├── package.json
│   └── vite.config.js
├── mobile/                           # Flutter Application
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── collection_screen.dart
│   │   │   ├── qr_scanner_screen.dart
│   │   │   └── closure_screen.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── offline_service.dart
│   │   │   └── gps_service.dart
│   │   ├── models/
│   │   ├── widgets/
│   │   └── utils/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── database/                         # Scripts et documentation
│   ├── schema.sql
│   └── documentation/
└── docker-compose.yml               # Configuration Docker
```

## Architecture Technique

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.5.0
- **Base de données**: PostgreSQL avec JPA/Hibernate
- **Sécurité**: Spring Security avec JWT
- **Documentation**: OpenAPI/Swagger
- **Validation**: Hibernate Validator
- **Mapping**: MapStruct

### Frontend Web (Vue.js 3)
- **Framework**: Vue.js 3 avec Composition API
- **Build Tool**: Vite
- **UI**: TailwindCSS ou Element Plus
- **State Management**: Pinia
- **HTTP Client**: Axios

### Mobile (Flutter)
- **Framework**: Flutter
- **State Management**: Provider ou Riverpod
- **Local Storage**: SQLite pour le mode hors-ligne
- **GPS**: Geolocator
- **QR Code**: qr_flutter et mobile_scanner

## Flux de Données

1. **Collection de Taxe**:
   - Agent scanne QR code ou recherche manuelle
   - Saisie montant et mode de paiement
   - Génération reçu avec hash unique
   - Enregistrement GPS pour validation

2. **Mode Hors-ligne**:
   - Stockage local SQLite
   - Synchronisation automatique au retour réseau
   - File d'attente des transactions

3. **Clôture de Caisse**:
   - Calcul automatique du total par mode de paiement
   - Déclaration cash par agent
   - Validation par le Trésor après dépôt bancaire

4. **Tableau de Bord**:
   - Vue temps réel des collectes
   - Export PDF/Excel des bordereaux
   - Statistiques par agent et zone

## Sécurité

- **Authentification**: JWT tokens
- **Autorisation**: Rôles (Agent, Trésor, Admin)
- **Intégrité**: Hash SHA-256 des transactions
- **Audit**: Traçabilité complète des actions

## API Endpoints

### Transactions
- `POST /api/transactions` - Créer une transaction
- `GET /api/transactions` - Lister les transactions
- `GET /api/transactions/{id}` - Détails transaction
- `PUT /api/transactions/{id}/sync` - Synchroniser transaction

### Clôture de Caisse
- `POST /api/cloture-caisse` - Initier clôture
- `PUT /api/cloture-caisse/{id}/validate` - Valider clôture
- `GET /api/cloture-caisse/agent/{agentId}` - Historique agent

### Dashboard
- `GET /api/dashboard/stats` - Statistiques temps réel
- `GET /api/dashboard/export` - Exporter bordereaux
