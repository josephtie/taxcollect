# Architecture des Services Frontend

## 📁 Structure

```
src/services/
├── baseService.js     # Service de base avec méthodes HTTP génériques
├── authService.js      # Service d'authentification Keycloak
├── userService.js       # Service de gestion des utilisateurs
├── agentService.js      # Service de gestion des agents
├── transactionService.js # Service de gestion des transactions
├── clotureService.js   # Service de gestion des clôtures de caisse
├── api.js             # Configuration Axios avec intercepteurs
└── index.js           # Export centralisé de tous les services
```

## 🏗️ BaseService

Classe de base qui fournit les méthodes HTTP standardisées :

### Méthodes disponibles
- `get(endpoint, params)` - Requêtes GET avec paramètres
- `post(endpoint, data, params)` - Requêtes POST avec corps
- `put(endpoint, data, params)` - Requêtes PUT avec corps  
- `delete(endpoint, params)` - Requêtes DELETE avec paramètres
- `upload(endpoint, formData)` - Upload de fichiers multipart
- `download(endpoint, params)` - Téléchargement de fichiers (blob)

### Avantages
- ✅ **Gestion centralisée des erreurs**
- ✅ **Logging automatique des requêtes**
- ✅ **Configuration CORS automatique**
- ✅ **Tokens JWT automatiques** (via api.js)

## 🔐 AuthService

Service spécialisé pour l'authentification Keycloak via le backend :

### Fonctionnalités
- Connexion via `/auth/login` (backend)
- Parsing automatique des tokens JWT
- Extraction des rôles et informations utilisateur
- Gestion du refresh token (à implémenter)
- Déconnexion propre

### Alignement Backend
- Endpoint : `POST /auth/login`
- Client ID : `tax-backend`
- Communication indirecte avec Keycloak

## 📊 Services Métier

### TransactionService
- **Base URL** : `/transactions`
- **Endpoints** : CRUD complet + statistiques + synchronisation

### AgentService  
- **Base URL** : `/agents`
- **Endpoints** : CRUD + gestion zones + statistiques

### ClotureService
- **Base URL** : `/cloture-caisse`
- **Endpoints** : Workflow complet de clôture de caisse

### UserService
- **Base URL** : `/users`
- **Endpoints** : CRUD utilisateurs + gestion rôles

## 🔄 Utilisation

```javascript
// Import depuis l'index centralisé
import { transactionService, agentService, userService } from '@/services'

// Utilisation dans les composants/stores
const transactions = await transactionService.getAllTransactions()
const agents = await agentService.getAllAgents()
const users = await userService.getAllUsers()
```

## 🎯 Avantages de cette Architecture

1. **Standardisation** : Tous les services suivent le même pattern
2. **Maintenabilité** : Modification centralisée de la configuration
3. **Réutilisabilité** : BaseService peut être étendu facilement
4. **Cohérence** : Alignement parfait avec les contrôleurs Spring Boot
5. **Gestion d'erreurs** : Centralisée et uniforme
6. **Logging** : Automatique et structuré

## 📝 Conventions

### Nomenclature
- **Méthodes** : Verbes d'action (get, create, update, delete)
- **Endpoints** : Noms RESTful pluriels
- **Paramètres** : `camelCase` pour le JavaScript
- **Retours** : Toujours `response` complet (pas `.data`)

### Gestion d'erreurs
- Try/catch dans chaque méthode du BaseService
- Logging console.error avec contexte
- Propagation des erreurs aux appelants
- Messages d'erreur explicites

Cette architecture assure une parfaite alignement entre le frontend Vue.js et le backend Spring Boot ! 🚀
