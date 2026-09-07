# Plan de Tests Frontend — TaxCollect Dashboard

> **Objectif** : Valider l'interface web Vue 3 (Composition API, TailwindCSS, Vite).
>
> **Outils** : Vitest (unitaires), Vue Test Utils (composants), Playwright (E2E).
>
> **Dernière mise à jour** : 2026-09-06

---

## 1. Stratégie de test

### 1.1 Pyramide

```
        ┌────────────┐
        │  E2E (15%)  │  ← Playwright (navigateurs réels)
        ├────────────┤
        │ Intégr (25%)│  ← Vue Test Utils + mocks API
        ├────────────┤
        │  Unit (60%) │  ← Vitest (services, composants isolés)
        └────────────┘
```

### 1.2 Outils

| Outil | Usage | Installation |
|---|---|---|
| Vitest | Tests unitaires + intégration | `devDependencies` |
| @vue/test-utils | Montage composants Vue | `devDependencies` |
| @testing-library/vue | Queries DOM | `devDependencies` |
| Playwright | Tests E2E multi-navigateurs | `devDependencies` |
| msw (Mock Service Worker) | Mock API backend | `devDependencies` |

### 1.3 Structure des fichiers

```
frontend/
├── src/
│   ├── services/
│   │   └── __tests__/
│   │       ├── baseService.test.js
│   │       ├── transactionService.test.js
│   │       ├── assessmentService.test.js
│   │       └── contribuableService.test.js
│   ├── views/
│   │   └── __tests__/
│   │       ├── Login.test.jsx
│   │       ├── Dashboard.test.jsx
│   │       ├── Transactions.test.jsx
│   │       ├── Assessments.test.jsx
│   │       ├── Contribuables.test.jsx
│   │       └── Taxes.test.jsx
│   └── components/
│       └── __tests__/
│           └── Sidebar.test.jsx
├── tests/
│   └── e2e/
│       ├── auth.spec.ts
│       ├── dashboard.spec.ts
│       ├── transactions.spec.ts
│       ├── assessments.spec.ts
│       ├── contribuables.spec.ts
│       ├── taxes.spec.ts
│       └── export.spec.ts
└── playwright.config.ts
```

---

## 2. Tests unitaires — Services

### 2.1 BaseService

| ID | Test | Description | Priorité |
|---|---|---|---|
| BS-01 | `get_shouldReturnResponseData` | GET request retourne data | Haute |
| BS-02 | `post_shouldSendBodyAndReturnData` | POST avec body | Haute |
| BS-03 | `put_shouldUpdateResource` | PUT request | Moyenne |
| BS-04 | `delete_shouldReturn204` | DELETE request | Moyenne |
| BS-05 | `download_shouldSetBlobResponseType` | Download avec responseType blob | Haute |
| BS-06 | `get_shouldAttachAuthToken` | Header Authorization présent | Haute |
| BS-07 | `get_shouldHandle401AndRedirect` | 401 → redirect login | Haute |

### 2.2 AssessmentService

| ID | Test | Description | Priorité |
|---|---|---|---|
| AS-01 | `generateForTaxe_shouldCallCorrectEndpoint` | POST /generate/{taxeId} | Haute |
| AS-02 | `findByPeriod_shouldPassDatesAsParams` | GET /period avec dates | Haute |
| AS-03 | `exportAssessments_shouldCallDownload` | GET /export avec format + dates | Haute |

### 2.3 TransactionService

| ID | Test | Description | Priorité |
|---|---|---|---|
| TS-01 | `exportTransactions_shouldCallDownload` | Download avec format | Haute |
| TS-02 | `getTransactions_shouldPassPaginationParams` | Page + size | Haute |

### 2.4 pdfReportService

| ID | Test | Description | Priorité |
|---|---|---|---|
| PDF-01 | `generateProductivityReport_shouldReturnPdfBlob` | Génération PDF | Moyenne |
| PDF-02 | `formatCurrency_shouldFormatFCFA` | Formatage montant | Basse |

---

## 3. Tests d'intégration — Vues (composants montés)

### 3.1 Login.vue

| ID | Test | Description | Priorité |
|---|---|---|---|
| LG-01 | `shouldRenderLoginForm` | Email + password + bouton | Haute |
| LG-02 | `shouldCallAuthServiceOnSubmit` | Submit → login() | Haute |
| LG-03 | `shouldShowErrorOnInvalidCredentials` | 401 → message erreur | Haute |
| LG-04 | `shouldRedirectToDashboardOnSuccess` | 200 → router push | Haute |

### 3.2 Dashboard.vue

| ID | Test | Description | Priorité |
|---|---|---|---|
| DB-01 | `shouldRenderStatsCards` | Cartes KPI visibles | Haute |
| DB-02 | `shouldLoadDataOnMount` | Appel API au montage | Haute |
| DB-03 | `shouldRenderCharts` | Chart.js rendu | Moyenne |

### 3.3 Transactions.vue

| ID | Test | Description | Priorité |
|---|---|---|---|
| TR-01 | `shouldRenderTransactionTable` | Tableau avec colonnes | Haute |
| TR-02 | `shouldLoadTransactionsOnMount` | Appel API au montage | Haute |
| TR-03 | `shouldFilterByDateRange` | Filtre période | Haute |
| TR-04 | `shouldExportCsv_whenExportClicked` | Bouton export CSV → download | Haute |
| TR-05 | `shouldExportXlsx_whenExportClicked` | Bouton export XLSX → download | Haute |
| TR-06 | `shouldPaginateCorrectly` | Navigation pages | Moyenne |

### 3.4 Assessments.vue

| ID | Test | Description | Priorité |
|---|---|---|---|
| AV-01 | `shouldRenderAssessmentsTable` | Tableau avec colonnes (Référence, Taxe, etc.) | Haute |
| AV-02 | `shouldDisplayReferenceColumn` | Colonne Référence visible | Haute |
| AV-03 | `shouldDisplayTaxTypeColumn` | Colonne Taxe affiche taxType | Haute |
| AV-04 | `shouldFilterByPeriod` | Filtre période début/fin | Haute |
| AV-05 | `shouldFilterByStatut` | Filtre statut (IMPAYE, PAYE, etc.) | Haute |
| AV-06 | `shouldExportCsv_whenExportClicked` | Export CSV → download | Haute |
| AV-07 | `shouldExportXlsx_whenExportClicked` | Export XLSX → download | Haute |
| AV-08 | `shouldOpenGenerateModal` | Bouton "Générer les avis" → modal | Moyenne |
| AV-09 | `shouldGenerateForSpecificTaxe` | Sélection taxe + génération | Moyenne |
| AV-10 | `shouldMarkOverdue_whenButtonClicked` | Bouton "Marquer en retard" | Moyenne |
| AV-11 | `shouldPaginateCorrectly` | Navigation pages | Moyenne |

### 3.5 Contribuables.vue

| ID | Test | Description | Priorité |
|---|---|---|---|
| CT-01 | `shouldRenderContribuablesTable` | Tableau avec colonnes | Haute |
| CT-02 | `shouldSearchByNameOrPhone` | Recherche texte | Haute |
| CT-03 | `shouldFilterByType` | Filtre type contribuable | Haute |
| CT-04 | `shouldPaginateViaBackend` | Pagination backend (page/size) | Haute |
| CT-05 | `shouldExportCsv_whenExportClicked` | Export CSV | Haute |
| CT-06 | `shouldExportXlsx_whenExportClicked` | Export XLSX | Haute |
| CT-07 | `shouldOpenCreateModal` | Bouton "Nouveau" → modal | Moyenne |
| CT-08 | `shouldCreateContribuable` | Formulaire → POST | Moyenne |

### 3.6 Taxes.vue

| ID | Test | Description | Priorité |
|---|---|---|---|
| TX-01 | `shouldRenderTaxesTable` | Tableau taxes | Haute |
| TX-02 | `shouldRenderAvisTable` | Tableau avis d'imposition | Haute |
| TX-03 | `shouldDisplayReferenceInAvisTable` | Colonne Référence dans avis | Haute |
| TX-04 | `shouldDisplayTaxTypeInAvisTable` | Colonne Taxe dans avis | Haute |
| TX-05 | `shouldExportTaxes` | Bouton export | Haute |
| TX-06 | `shouldCreateTaxe` | Formulaire création taxe | Moyenne |

### 3.7 Supervision.vue

| ID | Test | Description | Priorité |
|---|---|---|---|
| SP-01 | `shouldRenderAgentPerformanceTable` | Tableau performance agents | Moyenne |
| SP-02 | `shouldRenderZoneDistribution` | Distribution par zone | Moyenne |
| SP-03 | `shouldExportProductivityReport` | Export PDF rapport | Moyenne |

---

## 4. Tests E2E — Playwright

### 4.1 Scénarios d'authentification

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-AUTH-01 | Login admin réussi | Page login → saisir credentials → vérifier redirect Dashboard | Haute |
| E2E-AUTH-02 | Login échec | Credentials invalides → vérifier message erreur | Haute |
| E2E-AUTH-03 | Logout | Dashboard → clic logout → vérifier redirect login | Haute |
| E2E-AUTH-04 | Accès sans auth | URL /dashboard direct → redirect login | Haute |

### 4.2 Scénarios Transactions

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-TR-01 | Liste transactions | Login → menu Transactions → vérifier tableau chargé | Haute |
| E2E-TR-02 | Filtrage par date | Transactions → saisir dates → vérifier filtre appliqué | Haute |
| E2E-TR-03 | Export CSV | Transactions → clic Export CSV → vérifier download | Haute |
| E2E-TR-04 | Export XLSX | Transactions → clic Export Excel → vérifier download | Haute |
| E2E-TR-05 | Pagination | Transactions → naviguer pages → vérifier contenu change | Moyenne |

### 4.3 Scénarios Avis d'imposition

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-AV-01 | Liste avis | Login → menu Avis → vérifier tableau avec colonnes Référence + Taxe | Haute |
| E2E-AV-02 | Filtrage par période | Avis → saisir période → vérifier filtre | Haute |
| E2E-AV-03 | Filtrage par statut | Avis → sélectionner statut → vérifier filtre | Haute |
| E2E-AV-04 | Export CSV | Avis → clic Export → CSV → vérifier download | Haute |
| E2E-AV-05 | Export XLSX | Avis → clic Export → Excel → vérifier download | Haute |
| E2E-AV-06 | Génération avis | Avis → clic Générer → modal → sélectionner taxe → générer → vérifier message succès | Moyenne |

### 4.4 Scénarios Contribuables

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-CT-01 | Liste contribuables | Login → menu Contribuables → vérifier tableau | Haute |
| E2E-CT-02 | Recherche contribuable | Contribuables → saisir nom → vérifier résultats filtrés | Haute |
| E2E-CT-03 | Filtrage par type | Contribuables → sélectionner type → vérifier filtre | Haute |
| E2E-CT-04 | Export CSV | Contribuables → clic Export → CSV → vérifier download | Haute |
| E2E-CT-05 | Création contribuable | Contribuables → clic Nouveau → remplir formulaire → sauvegarder → vérifier dans liste | Moyenne |
| E2E-CT-06 | Pagination backend | Contribuables → naviguer pages → vérifier appel API avec page/size | Moyenne |

### 4.5 Scénarios Taxes

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-TX-01 | Liste taxes | Login → menu Taxes → vérifier tableau taxes | Haute |
| E2E-TX-02 | Tableau avis | Taxes → vérifier tableau avis avec colonne Référence | Haute |
| E2E-TX-03 | Export taxes | Taxes → clic Export → vérifier download | Haute |

### 4.6 Scénarios Supervision

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-SP-01 | Dashboard supervision | Login → menu Supervision → vérifier KPIs | Moyenne |
| E2E-SP-02 | Export PDF rapport | Supervision → clic Export PDF → vérifier download | Moyenne |

### 4.7 Scénarios multi-rôles

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-RL-01 | Rôle AGENT | Login agent → vérifier menus visibles (Transactions, Contribuables) | Haute |
| E2E-RL-02 | Rôle SUPERVISEUR | Login superviseur → vérifier accès Supervision + Dashboard | Haute |
| E2E-RL-03 | Rôle ADMIN | Login admin → vérifier accès tous menus (Users, Settings, Taxes) | Haute |
| E2E-RL-04 | Rôle TRESOR | Login trésor → vérifier accès Reversements + ClotureCaisse | Moyenne |

---

## 5. Configuration Playwright

### 5.1 Navigateurs testés

- Chromium (Chrome)
- Firefox
- WebKit (Safari)

### 5.2 Environnement

- Backend démarré sur `localhost:9091`
- Frontend démarré sur `localhost:5173` (Vite dev)
- Keycloak démarré sur `localhost:8080`
- Utilisateurs de test: admin/test, agent/test, superviseur/test, tresor/test

### 5.3 Commandes

```bash
# Installation
cd frontend && npx playwright install

# Tous les tests E2E
npx playwright test

# Tests avec navigateur spécifique
npx playwright test --project=chromium

# Tests avec UI interactif
npx playwright test --ui

# Génération rapport
npx playwright show-report
```

---

## 6. Couverture cible

| Module | Couverture cible | Priorité |
|---|---|---|
| Services (API calls) | ≥ 80% | Haute |
| Vues principales (Login, Dashboard, Transactions, Assessments, Contribuables) | ≥ 70% | Haute |
| Composants partagés (Sidebar) | ≥ 60% | Moyenne |
| E2E (scénarios critiques) | 100% des flux critiques | Haute |
