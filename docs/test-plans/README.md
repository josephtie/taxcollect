# Stratégie de Tests — TaxCollect

> **Objectif global** : Valider l'ensemble de la plateforme TaxCollect (backend, frontend web, mobile Flutter).
>
> **Dernière mise à jour** : 2026-09-06

---

## 1. Vue d'ensemble

```
┌─────────────────────────────────────────────────┐
│              Plateforme TaxCollect               │
├──────────┬──────────────┬───────────────────────┤
│ Backend  │   Frontend   │   Mobile (VerdenTax)   │
│ Spring   │   Vue 3      │   Flutter              │
│ Boot     │   Vite       │                        │
├──────────┼──────────────┼───────────────────────┤
│ JUnit 5  │   Vitest     │   flutter_test         │
│ Mockito  │   Vue Test   │   integration_test     │
│ MockMvc  │   Utils      │   mockito              │
│ Testcont.│   Playwright │                        │
└──────────┴──────────────┴───────────────────────┘
```

## 2. Plans de test par client

| Client | Fichier | Tests | Statut |
|---|---|---|---|
| Backend | [backend-test-plan.md](./backend-test-plan.md) | 60+ cas de test | ✅ Plan défini |
| Frontend | [frontend-test-plan.md](./frontend-test-plan.md) | 50+ cas de test | ✅ Plan défini |
| Mobile | [mobile-test-plan.md](./mobile-test-plan.md) | 50+ cas de test | ✅ Plan défini |

## 3. Configuration Playwright (Frontend E2E)

### Fichiers créés

| Fichier | Description |
|---|---|
| `frontend/playwright.config.ts` | Config Playwright (Chromium, Firefox, WebKit) |
| `frontend/tests/e2e/auth.spec.ts` | Tests E2E authentification (4 scénarios) |
| `frontend/tests/e2e/dashboard.spec.ts` | Tests E2E dashboard (3 scénarios) |
| `frontend/tests/e2e/transactions.spec.ts` | Tests E2E transactions (4 scénarios) |
| `frontend/tests/e2e/assessments.spec.ts` | Tests E2E avis d'imposition (6 scénarios) |
| `frontend/tests/e2e/contribuables.spec.ts` | Tests E2E contribuables (5 scénarios) |
| `frontend/tests/e2e/taxes.spec.ts` | Tests E2E taxes (3 scénarios) |

### Installation et exécution

```bash
cd frontend

# Installer les dépendances de test
npm install

# Installer les navigateurs Playwright
npx playwright install

# Lancer tous les tests E2E
npx playwright test

# Lancer avec UI interactif
npx playwright test --ui

# Voir le rapport
npx playwright show-report
```

### Prérequis E2E

- Backend démarré sur `localhost:9091`
- Frontend démarré sur `localhost:3000` (Vite dev)
- Keycloak démarré sur `localhost:8080`
- Utilisaires de test dans Keycloak : `admin@mairie.ci` / `admin`

### data-testid requis

Pour que les tests Playwright fonctionnent, il faut ajouter des attributs `data-testid` sur les éléments clés des vues Vue :

| Élément | data-testid | Vue |
|---|---|---|
| Input email | `email-input` | Login.vue |
| Input password | `password-input` | Login.vue |
| Bouton login | `login-button` | Login.vue |
| Message erreur | `error-message` | Login.vue |
| Bouton logout | `logout-button` | Layout/Sidebar |
| Nav Transactions | `nav-transactions` | Sidebar.vue |
| Nav Contribuables | `nav-contribuables` | Sidebar.vue |
| Nav Assessments | `nav-assessments` | Sidebar.vue |
| Nav Taxes | `nav-taxes` | Sidebar.vue |
| Tableau transactions | `transactions-table` | Transactions.vue |
| Bouton export | `export-button` | Transactions/Assessments/Contribuables |
| Export CSV | `export-csv` | Transactions/Assessments/Contribuables |
| Export XLSX | `export-xlsx` | Transactions/Assessments/Contribuables |
| Tableau assessments | `assessments-table` | Assessments.vue |
| Bouton générer | `generate-button` | Assessments.vue |
| Modal génération | `generate-modal` | Assessments.vue |
| Tableau contribuables | `contribuables-table` | Contribuables.vue |
| Recherche | `search-input` | Contribuables.vue |
| Filtre type | `filter-type` | Contribuables.vue |
| Tableau taxes | `taxes-table` | Taxes.vue |
| Tableau avis | `avis-table` | Taxes.vue |

## 4. Configuration Vitest (Frontend unitaires)

### Fichiers créés

| Fichier | Description |
|---|---|
| `frontend/src/views/__tests__/Login.test.jsx` | Test unitaire Login.vue (2 cas) |
| `frontend/vite.config.js` | Config Vitest ajoutée (environment jsdom) |

### Exécution

```bash
cd frontend

# Tests unitaires
npm test

# Tests en mode watch
npm run test:watch
```

## 5. Configuration Flutter (Mobile)

### Fichiers créés

| Fichier | Description |
|---|---|
| `verdentax/integration_test/auth_flow_test.dart` | E2E authentification (2 scénarios) |
| `verdentax/integration_test/transaction_flow_test.dart` | E2E transactions (2 scénarios) |
| `verdentax/integration_test/recensement_flow_test.dart` | E2E recensement (1 scénario) |
| `verdentax/test/unit/services/connectivity_service_test.dart` | Test unitaire connectivity (3 cas) |

### Exécution

```bash
cd verdentax

# Tests unitaires
flutter test test/unit/

# Tests widget
flutter test test/widget/

# Tests E2E (émulateur requis)
flutter test integration_test/

# Analyse statique
flutter analyze
```

## 6. CI/CD — Pipeline de test recommandé

```yaml
# .github/workflows/test.yml (exemple)
stages:
  - backend-test
  - frontend-test
  - mobile-test
  - e2e-test

backend-test:
  - cd backend && mvn test
  - mvn test -Dtest="*IntegrationTest"

frontend-test:
  - cd frontend && npm install
  - npm test  # Vitest
  - npx playwright install
  - npx playwright test  # E2E

mobile-test:
  - cd verdentax && flutter test
  - flutter test integration_test/
```

## 7. Couverture cible globale

| Client | Unit | Intégration | E2E | Total |
|---|---|---|---|---|
| Backend | 75% | 20% | 5% | ≥ 80% |
| Frontend | 60% | 25% | 15% | ≥ 70% |
| Mobile | 60% | 30% | 10% | ≥ 70% |
