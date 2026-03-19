# Tableau de Bord - Tax Collect

Interface d'administration web pour la gestion de la collecte de taxes journalières.

## 🚀 Démarrage Rapide

### Prérequis
- Node.js 18+ 
- npm ou yarn
- Accès à l'API backend (port 8080)

### Installation

```bash
# Installer les dépendances
npm install

# Démarrer le serveur de développement
npm run dev

# Build pour production
npm run build

# Preview du build de production
npm run preview
```

L'application sera disponible sur `http://localhost:3000`

## 📋 Fonctionnalités

### 🏠 Dashboard Principal
- **KPIs en temps réel**: Total collecté, nombre de transactions, répartition des paiements
- **Graphiques d'évolution**: Visualisation des collectes sur 7 jours
- **Transactions récentes**: Vue rapide des dernières transactions
- **Rafraîchissement automatique**: Données mises à jour en temps réel

### 👥 Gestion des Agents
- **Liste des agents**: Vue complète avec statut en ligne/hors ligne
- **Performances individuelles**: Total collecté par agent par jour
- **Création/Modification**: Gestion complète des comptes agents
- **Assignation de zones**: Configuration des zones de collecte

### 💰 Gestion des Reversements
- **Validation des clôtures**: Interface de validation pour le Trésor Public
- **Suivi des dépôts**: Confirmation des dépôts bancaires
- **Export des bordereaux**: Génération PDF/Excel des rapports
- **Historique complet**: Traçabilité de toutes les validations

### 📊 Historique des Transactions
- **Filtrage avancé**: Par date, agent, mode de paiement
- **Détails complets**: Informations sur contribuable, localisation GPS
- **Export de données**: Export personnalisé des transactions
- **Vérification de sécurité**: Affichage des hash de transaction

### 🗺️ Gestion des Zones
- **Configuration des zones**: Définition des zones de collecte
- **Assignation d'agents**: Distribution des agents par zone
- **Statistiques par zone**: Performances de collecte par zone
- **Gestion des quartiers**: Organisation hiérarchique

### ⚙️ Paramètres
- **Configuration générale**: Informations de l'organisation
- **Paramètres de taxes**: Montants, types autorisés
- **Notifications**: Configuration email/SMS
- **Sécurité**: Sessions, authentification 2FA
- **Sauvegardes**: Automatisation et restauration

## 🎨 Design & UX

### Design System
- **Palette de couleurs**: Bleu foncé professionnel (#1e40af) avec gris neutres
- **Typographie**: Inter pour une lisibilité optimale
- **Responsive**: Adaptation tablette et desktop
- **Animations**: Transitions fluides et micro-interactions

### Composants Réutilisables
- `StatsCard`: Cartes de statistiques avec icônes et variations
- `StatusBadge`: Badges de statut colorés et configurables
- `TransactionTable`: Tableau complet avec filtres et pagination
- `ChartComponent`: Graphiques réutilisables (barres/lignes)
- `Sidebar`: Navigation latérale responsive

## 🏗️ Architecture Technique

### Structure des Dossiers
```
src/
├── components/          # Composants réutilisables
│   ├── StatsCard.vue
│   ├── StatusBadge.vue
│   ├── TransactionTable.vue
│   ├── ChartComponent.vue
│   └── Sidebar.vue
├── views/               # Pages de l'application
│   ├── Dashboard.vue
│   ├── Agents.vue
│   ├── Reversements.vue
│   ├── Transactions.vue
│   ├── Zones.vue
│   └── Settings.vue
├── stores/              # Pinia state management
│   ├── transactions.js
│   ├── agents.js
│   └── cloture.js
├── services/            # Services API
│   ├── api.js
│   ├── transactionService.js
│   ├── agentService.js
│   └── clotureService.js
├── utils/               # Utilitaires
└── assets/              # Assets statiques
```

### State Management (Pinia)
- **transactions.js**: Gestion des transactions et filtres
- **agents.js**: Gestion des agents et leur statut
- **cloture.js**: Gestion des clôtures de caisse

### Services API
- **Intégration complète** avec l'API Spring Boot
- **Gestion d'erreurs** centralisée
- **Intercepteurs** pour authentification
- **Timeout** et retry automatique

## 🔧 Configuration

### Variables d'Environnement
```bash
# API Backend
VITE_API_BASE_URL=http://localhost:8080/api

# Timeout des requêtes (ms)
VITE_API_TIMEOUT=10000

# Mode développement
VITE_DEV_MODE=true
```

### Personnalisation
- **Thème**: Modification des couleurs dans `tailwind.config.js`
- **API**: Configuration des endpoints dans `services/api.js`
- **Routes**: Ajout de routes dans `src/main.js`

## 🧪 Tests

### Tests Unitaires
```bash
# Lancer les tests
npm run test

# Tests avec couverture
npm run test:coverage
```

### Tests E2E (Planifié)
- Tests Cypress pour les flux critiques
- Tests de navigation responsive
- Tests d'intégration API

## 📱 Responsive Design

### Desktop (1024px+)
- Layout complet avec sidebar
- Tableaux avec toutes les colonnes
- Graphiques en pleine taille

### Tablet (768px - 1023px)
- Sidebar repliable
- Tableaux adaptés
- Cartes en grille 2x2

### Mobile (< 768px)
- Navigation par menu hamburger
- Tableaux avec pagination horizontale
- Cartes en grille 1x1

## 🔐 Sécurité

### Authentification
- **JWT tokens** avec expiration
- **Rôles**: ADMIN, TRESOR, AGENT
- **Guard** sur les routes protégées
- **Logout automatique** sur expiration

### Validation
- **Validation formulaire** côté client
- **Sanitization** des entrées utilisateur
- **XSS protection** avec Vue.js
- **CSRF protection** avec tokens

## 🚀 Déploiement

### Build Production
```bash
# Build optimisé
npm run build

# Analyse du bundle
npm run build:analyze
```

### Configuration Serveur
- **Static files**: Servir le dossier `dist`
- **SPA routing**: Configurer fallback vers `index.html`
- **HTTPS**: Configuration SSL recommandée
- **Caching**: Configuration des en-têtes cache

## 🐛 Débogage

### Outils de Développement
- **Vue DevTools**: Extension navigateur recommandée
- **Console**: Logs détaillés des actions
- **Network**: Visualisation des requêtes API
- **Performance**: Analyse des temps de chargement

### Logs
- **Niveaux**: info, warn, error, debug
- **Format**: Structuré avec timestamps
- **Rotation**: Configuration automatique
- **Export**: Export des logs pour analyse

## 📈 Performance

### Optimisations
- **Code splitting**: Lazy loading des routes
- **Tree shaking**: Élimination du code inutilisé
- **Compression**: Gzip/Brotli activé
- **Caching**: Stratégie de cache intelligente

### Métriques
- **Lighthouse**: Score > 90
- **Core Web Vitals**: Optimisation des métriques
- **Bundle size**: < 500KB gzippé
- **Time to Interactive**: < 3 secondes

## 🤝 Contribution

### Guidelines
- **Conventions**: ESLint + Prettier configurés
- **Commits**: Messages conventionnels
- **Branches**: Gitflow recommandé
- **Reviews**: Code review obligatoire

### Développement
```bash
# Installer pre-commit hooks
npm run prepare

# Formatter le code
npm run lint:fix

# Type checking
npm run type-check
```

## 📞 Support

### Documentation
- **API Documentation**: `/docs/api`
- **Components Storybook**: `/storybook`
- **Architecture**: `/docs/architecture`

### Contact
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Email**: support@taxcollect.gov

---

**Développé avec Vue.js 3 + Tailwind CSS pour une expérience utilisateur moderne**
