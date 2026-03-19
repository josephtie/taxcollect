# Plateforme de Collecte de Taxes Journalières

## Vue d'ensemble

Solution FinTech Publique complète pour la digitalisation de la collecte des taxes de place de marché, comprenant une application mobile pour les agents de collecte et un tableau de bord web pour le Trésor Public.

## Architecture Technique

### Backend (Spring Boot)
- **Framework**: Spring Boot 3.5.0 avec Java 17
- **Base de données**: PostgreSQL avec JPA/Hibernate
- **Sécurité**: Spring Security avec JWT et Keycloak
- **Documentation**: OpenAPI/Swagger
- **Validation**: Hibernate Validator
- **Mapping**: MapStruct

### Frontend Web (Vue.js 3)
- **Framework**: Vue.js 3 avec Composition API
- **Build Tool**: Vite
- **UI**: TailwindCSS
- **State Management**: Pinia
- **HTTP Client**: Axios

### Mobile (Flutter)
- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: SQLite pour le mode hors-ligne
- **GPS**: Geolocator
- **QR Code**: mobile_scanner

## Fonctionnalités Implémentées

### ✅ Base de données & Schéma
- **Agents**: Gestion des agents avec zones géographiques
- **Contribuables**: Informations des contribuables avec QR codes
- **Transactions**: Collecte de taxes avec hash de sécurité
- **Clôture de caisse**: Validation journalière des encaissements
- **QR Codes**: Génération et scan des codes contribuables
- **Audit**: Traçabilité complète avec timestamps

### ✅ API REST Complète

#### Transactions
- `POST /api/transactions` - Créer une transaction
- `GET /api/transactions/{id}` - Détails transaction
- `GET /api/transactions/receipt/{numeroRecu}` - Recherche par reçu
- `GET /api/transactions/agent/{agentId}` - Transactions par agent
- `PUT /api/transactions/{id}/sync` - Synchronisation hors-ligne
- `GET /api/transactions/{id}/verify` - Vérification hash

#### Clôture de Caisse
- `POST /api/cloture-caisse/initier` - Initier clôture journalière
- `POST /api/cloture-caisse/{id}/soumettre` - Soumettre déclaration
- `POST /api/cloture-caisse/{id}/valider` - Validation Trésor
- `POST /api/cloture-caisse/{id}/rejeter` - Rejet Trésor
- `POST /api/cloture-caisse/{id}/confirmer-depot` - Confirmation dépôt

### ✅ Application Mobile Flutter

#### Écran Principal de Collecte
- **Scan QR Code**: Intégration avec mobile_scanner
- **Recherche Manuel**: Recherche de contribuables par nom/téléphone
- **Sélection Paiement**: Espèces ou Mobile Money
- **Validation GPS**: Capture automatique des coordonnées
- **Mode Hors-ligne**: Stockage SQLite avec synchronisation auto
- **Génération Reçu**: Numéro unique format TAX-YYYYMMDD-XXXX

#### Services Mobile
- **ApiService**: Gestion des appels API et synchronisation
- **GPSService**: Géolocalisation haute précision
- **Stockage Local**: SQLite pour transactions hors-ligne

## Sécurité

### 🔐 Authentification & Autorisation
- JWT tokens avec expiration
- Rôles: AGENT, TRESOR, ADMIN
- Validation par zone géographique

### 🔒 Intégrité des Données
- Hash SHA-256 pour chaque transaction
- Numéros de reçu uniques et infalsifiables
- Traçabilité GPS pour prévenir la fraude

### 🛡️ Mode Hors-ligne Sécurisé
- Chiffrement local des données
- Synchronisation sécurisée au retour réseau
- File d'attente avec priorité

## Installation

### Prérequis
- Java 17+
- Node.js 16+
- PostgreSQL 15+
- Docker (optionnel)

### Ports par défaut
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:9090
- **Base de données**: localhost:5440
- **Keycloak**: http://localhost:8080

### Backend
```bash
# Cloner le projet
git clone <repository-url>
cd taxcollect

# Démarrer PostgreSQL avec Docker
docker-compose up -d postgres

# Compiler et démarrer l'application
./mvnw spring-boot:run
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

### Documentation API
- Swagger UI: `http://localhost:9090/swagger-ui.html`
- OpenAPI JSON: `http://localhost:9090/v3/api-docs`

## Flux de Travail

### 1. Collecte de Taxe (Mobile)
1. Agent se connecte avec ses identifiants
2. Scan QR Code du contribuable OU recherche manuelle
3. Saisie du montant et sélection mode paiement
4. Validation GPS automatique
5. Génération reçu avec hash unique
6. Stockage local si hors-ligne

### 2. Synchronisation
- Détection automatique du retour réseau
- Synchronisation des transactions en attente
- Mise à jour des statuts en temps réel

### 3. Clôture de Caisse
1. Agent initie la clôture journalière
2. Calcul automatique des totaux par mode paiement
3. Déclaration du montant en main
4. Soumission pour validation Trésor
5. Validation après vérification du dépôt bancaire

### 4. Tableau de Bord (Web)
- Vue temps réel des collectes
- Statistiques par agent et zone
- Export PDF/Excel des bordereaux
- Gestion des validations

## Base de Données

### Schéma Principal
```sql
-- Agents et zones
agent (id, nom, prenom, email, telephone)
zone_collecte (id, nom, quartier_id)
agent_zone (agent_id, zone_id)

-- Contribuables et QR codes
contribuable (id, nom, prenom, telephone, email, adresse, latitude, longitude, zone_id)
qr_code_contribuable (id, code_qr, contribuable_id, date_generation, actif)

-- Transactions
transaction (id, numero_recu, montant, contribuable_id, agent_id, zone_id, 
            mode_paiement, statut, reference_paiement, hash_transaction,
            latitude, longitude, adresse_collecte, offline, date_creation)

-- Clôture de caisse
cloture_caisse (id, agent_id, date_cloture, montant_total_espece, 
                montant_total_mobile_money, montant_total, montant_declare,
                montant_depose, reference_depot_banque, statut, 
                commentaire_agent, commentaire_tresor, date_validation_tresor,
                valide_par_id, nombre_transactions)
```

## Tests

### Tests Backend
```bash
./mvnw test
```

### Tests Mobile
```bash
cd mobile
flutter test
```

## Déploiement

### Docker
```bash
# Build et déploiement complet
docker-compose up -d
```

### Production
- Backend: Serveur d'application avec PostgreSQL
- Mobile: Build APK/IPA pour distribution
- Frontend: Build statique sur serveur web

## Monitoring

### Logs
- Application logs avec SLF4J
- Métriques avec Prometheus
- Health checks Spring Boot Actuator

### Performance
- Connection pooling PostgreSQL
- Cache Redis pour les données fréquemment accédées
- Optimisation des requêtes JPA

## Support

### Documentation Technique
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Architecture détaillée
- API Documentation - Swagger UI
- Database Schema - Diagramme entité-relation

### Contact
- Support technique: [support@taxcollect.gov]
- Documentation: [docs.taxcollect.gov]

---

**Développé avec ❤️ pour la digitalisation des services publics**