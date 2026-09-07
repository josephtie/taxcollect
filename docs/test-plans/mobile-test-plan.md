# Plan de Tests Mobile — VerdenTax (Flutter)

> **Objectif** : Valider l'application mobile Flutter (contribuables + agents municipaux).
>
> **Outils** : flutter_test (unitaires + widgets), integration_test (E2E device), mockito.
>
> **Dernière mise à jour** : 2026-09-06

---

## 1. Stratégie de test

### 1.1 Pyramide

```
        ┌────────────────┐
        │  E2E Device(10%)│  ← integration_test (émulateur/device réel)
        ├────────────────┤
        │  Widget (30%)   │  ← flutter_test (montage widgets, interactions)
        ├────────────────┤
        │  Unit (60%)     │  ← flutter_test (services, models, utils)
        └────────────────┘
```

### 1.2 Outils

| Outil | Usage | Statut |
|---|---|---|
| `flutter_test` | Tests unitaires + widgets | Déjà dans `pubspec.yaml` |
| `integration_test` | Tests E2E sur device/émulateur | Déjà dans `pubspec.yaml` |
| `mockito` | Mocks pour services | Déjà dans `pubspec.yaml` |
| `flutter_lints` | Analyse statique | Déjà dans `pubspec.yaml` |

### 1.3 Structure des fichiers

```
verdentax/
├── test/
│   ├── unit/
│   │   ├── services/
│   │   │   ├── auth_service_test.dart
│   │   │   ├── api_service_test.dart
│   │   │   ├── transaction_service_test.dart
│   │   │   ├── recensement_service_test.dart
│   │   │   ├── connectivity_service_test.dart
│   │   │   ├── storage_service_test.dart
│   │   │   ├── agent_service_test.dart
│   │   │   ├── geolocation_service_test.dart
│   │   │   └── carte_contribuable_service_test.dart
│   │   └── models/
│   │       ├── transaction_test.dart
│   │       ├── recensement_test.dart
│   │       ├── entities_test.dart
│   │       └── user_test.dart
│   ├── widget/
│   │   ├── login_screen_test.dart
│   │   ├── dashboard_screen_test.dart
│   │   ├── transaction_screen_test.dart
│   │   ├── recensement_screen_test.dart
│   │   ├── carte_screens_test.dart
│   │   └── geolocation_screen_test.dart
│   └── widget_test.dart (existant — à étendre)
├── integration_test/
│   ├── auth_flow_test.dart
│   ├── transaction_flow_test.dart
│   ├── recensement_flow_test.dart
│   ├── offline_sync_test.dart
│   └── qr_scan_test.dart
```

---

## 2. Tests unitaires — Services

### 2.1 AuthService

| ID | Test | Description | Priorité |
|---|---|---|---|
| AU-01 | `login_shouldReturnToken_whenCredentialsValid` | Login réussi → token stocké | Haute |
| AU-02 | `login_shouldThrow_whenCredentialsInvalid` | Login échec → exception | Haute |
| AU-03 | `login_shouldStoreTokenInSecureStorage` | Token persisté via flutter_secure_storage | Haute |
| AU-04 | `logout_shouldClearToken` | Logout → token supprimé | Haute |
| AU-05 | `isLoggedIn_shouldReturnTrue_whenTokenExists` | Vérification token présent | Moyenne |
| AU-06 | `getToken_shouldReturnFromSecureStorage` | Récupération token | Moyenne |
| AU-07 | `refreshToken_shouldUpdateStoredToken` | Refresh token | Basse |

### 2.2 ApiService

| ID | Test | Description | Priorité |
|---|---|---|---|
| AP-01 | `get_shouldAttachAuthToken` | Header Authorization présent | Haute |
| AP-02 | `get_shouldHandle401_andRedirectLogin` | 401 → logout + redirect | Haute |
| AP-03 | `post_shouldSendJsonBody` | Body JSON envoyé correctement | Haute |
| AP-04 | `get_shouldHandleTimeout` | Timeout → exception gérée | Moyenne |
| AP-05 | `get_shouldRetryOnNetworkError` | Retry avec backoff | Basse |

### 2.3 TransactionService

| ID | Test | Description | Priorité |
|---|---|---|---|
| TS-01 | `createTransaction_shouldSendCorrectPayload` | Payload avec montant, mode paiement | Haute |
| TS-02 | `createTransaction_shouldGenerateReceiptNumber` | Numéro reçu généré | Haute |
| TS-03 | `getTransactions_shouldReturnPagedList` | Pagination | Moyenne |
| TS-04 | `syncOfflineTransactions_shouldUploadPending` | Sync transactions offline | Haute |
| TS-05 | `createTransaction_espece_shouldAllowOffline` | Espèces = offline autorisé | Haute |
| TS-06 | `createTransaction_mobileMoney_shouldRejectOffline` | Mobile money offline = refusé | Haute |

### 2.4 RecensementService

| ID | Test | Description | Priorité |
|---|---|---|---|
| RS-01 | `createRecensement_shouldSendContribuableData` | Création contribuable | Haute |
| RS-02 | `generateQRCode_shouldReturnQRData` | Génération QR code contribuable | Moyenne |
| RS-03 | `getStats_shouldReturnCounts` | Statistiques recensement | Moyenne |
| RS-04 | `searchContribuable_shouldReturnResults` | Recherche par nom/téléphone | Moyenne |

### 2.5 ConnectivityService

| ID | Test | Description | Priorité |
|---|---|---|---|
| CO-01 | `isOnline_shouldReturnTrue_whenConnected` | État online | Haute |
| CO-02 | `isOnline_shouldReturnFalse_whenDisconnected` | État offline | Haute |
| CO-03 | `onConnectivityChanged_shouldEmitEvents` | Stream de changement | Moyenne |
| CO-04 | `shouldBlockDigitalPayment_whenOffline` | Vérification refus paiement digital offline | Haute |

### 2.6 StorageService

| ID | Test | Description | Priorité |
|---|---|---|---|
| ST-01 | `saveOfflineTransaction_shouldStoreInSQLite` | Stockage local offline | Haute |
| ST-02 | `getPendingTransactions_shouldReturnUnsynced` | Transactions en attente | Haute |
| ST-03 | `markAsSynced_shouldUpdateStatus` | Marquage synchronisé | Moyenne |
| ST-04 | `clearAll_shouldWipeData` | Nettoyage données | Basse |

### 2.7 GeolocationService

| ID | Test | Description | Priorité |
|---|---|---|---|
| GL-01 | `getCurrentLocation_shouldReturnLatLng` | Position courante | Moyenne |
| GL-02 | `requestPermission_shouldPromptUser` | Demande permission | Moyenne |
| GL-03 | `getLocation_shouldHandlePermissionDenied` | Permission refusée → erreur gérée | Moyenne |

---

## 3. Tests unitaires — Models

### 3.1 Transaction model

| ID | Test | Description | Priorité |
|---|---|---|---|
| TM-01 | `fromJson_shouldParseAllFields` | Désérialisation JSON | Haute |
| TM-02 | `toJson_shouldSerializeAllFields` | Sérialisation JSON | Haute |
| TM-03 | `isSynced_shouldReturnTrue_whenStatusIsSynced` | Statut sync | Moyenne |

### 3.2 Recensement model

| ID | Test | Description | Priorité |
|---|---|---|---|
| RM-01 | `fromJson_shouldParseContribuableData` | Désérialisation | Haute |
| RM-02 | `toJson_shouldSerializeContribuableData` | Sérialisation | Haute |

### 3.3 Entities (TaxeCollect, Taxe, Contribuable)

| ID | Test | Description | Priorité |
|---|---|---|---|
| EM-01 | `taxeCollectFromJson_shouldParseReference` | Champ reference | Haute |
| EM-02 | `taxeCollectFromJson_shouldParseRemainingAmount` | Champ remainingAmount | Moyenne |
| EM-03 | `contribuableFromJson_shouldParseAllFields` | Tous champs contribuable | Haute |

---

## 4. Tests Widget — Écrans

### 4.1 LoginScreen

| ID | Test | Description | Priorité |
|---|---|---|---|
| LW-01 | `shouldRenderLoginForm` | Email + password + bouton | Haute |
| LW-02 | `shouldShowError_whenFieldsEmpty` | Validation champs vides | Haute |
| LW-03 | `shouldCallAuthService_whenSubmit` | Submit → login() | Haute |
| LW-04 | `shouldNavigateToDashboard_onSuccess` | Succès → navigation | Haute |
| LW-05 | `shouldShowError_onInvalidCredentials` | Erreur affichée | Haute |
| LW-06 | `shouldSupportBiometricAuth` | local_auth (FaceID/fingerprint) | Moyenne |

### 4.2 DashboardScreen

| ID | Test | Description | Priorité |
|---|---|---|---|
| DW-01 | `shouldRenderKpiCards` | Cartes statistiques | Haute |
| DW-02 | `shouldRenderNavigationDrawer` | Menu latéral | Haute |
| DW-03 | `shouldLoadDashboardData_onInit` | Appel API au montage | Haute |
| DW-04 | `shouldNavigateToTransactions_whenTapped` | Navigation vers transactions | Moyenne |
| DW-05 | `shouldShowAgentInfo` | Info agent connecté | Moyenne |

### 4.3 TransactionScreen

| ID | Test | Description | Priorité |
|---|---|---|---|
| TW-01 | `shouldRenderTransactionList` | Liste transactions | Haute |
| TW-02 | `shouldRenderCreateButton` | Bouton nouvelle transaction | Haute |
| TW-03 | `shouldOpenCreateForm_whenButtonTapped` | Formulaire création | Haute |
| TW-04 | `shouldSelectContribuable_viaQRScan` | Scan QR → contribuable | Haute |
| TW-05 | `shouldSelectModePaiement` | Choix espèces/mobile money/QR | Haute |
| TW-06 | `shouldCreateTransaction_espece` | Création espèces | Haute |
| TW-07 | `shouldRejectMobileMoney_whenOffline` | Refus mobile money offline + dialog | Haute |
| TW-08 | `shouldShowReceipt_afterTransaction` | Reçu affiché après paiement | Moyenne |
| TW-09 | `shouldSyncOfflineTransactions_whenOnline` | Sync au retour réseau | Haute |
| TW-10 | `shouldShowPendingTransactions_badge` | Badge transactions en attente | Moyenne |

### 4.4 RecensementScreen

| ID | Test | Description | Priorité |
|---|---|---|---|
| RW-01 | `shouldRenderRecensementForm` | Formulaire recensement | Haute |
| RW-02 | `shouldValidateRequiredFields` | Validation champs obligatoires | Haute |
| RW-03 | `shouldCapturePhoto` | Photo contribuable (image_picker) | Moyenne |
| RW-04 | `shouldGetCurrentLocation` | Géolocalisation auto | Moyenne |
| RW-05 | `shouldGenerateQRCode_afterSave` | QR généré après création | Moyenne |
| RW-06 | `shouldShowSuccessMessage_onCreate` | Message succès | Haute |

### 4.5 CarteScreens (carte contribuable + carte territoriale)

| ID | Test | Description | Priorité |
|---|---|---|---|
| CW-01 | `shouldRenderMap` | Carte Leaflet/Google Maps rendue | Moyenne |
| CW-02 | `shouldShowContribuableMarkers` | Marqueurs contribuables | Moyenne |
| CW-03 | `shouldFilterByZone` | Filtrage par zone sur carte | Basse |

### 4.6 GeolocationScreen

| ID | Test | Description | Priorité |
|---|---|---|---|
| GW-01 | `shouldRequestLocationPermission` | Demande permission localisation | Moyenne |
| GW-02 | `shouldShowCurrentLocation` | Position actuelle sur carte | Moyenne |
| GW-03 | `shouldHandlePermissionDenied` | Gestion refus permission | Moyenne |

---

## 5. Tests E2E — integration_test

### 5.1 Flux d'authentification

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-AU-01 | Login agent réussi | Lancer app → écran login → saisir credentials → vérifier dashboard | Haute |
| E2E-AU-02 | Login échec | Credentials invalides → vérifier message erreur | Haute |
| E2E-AU-03 | Logout | Dashboard → menu → logout → vérifier écran login | Haute |
| E2E-AU-04 | Biometric auth | Login → fingerprint → vérifier dashboard | Basse |

### 5.2 Flux transaction (espèces)

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-TR-01 | Transaction espèces complète | Dashboard → Transactions → Nouvelle → scan QR contribuable → sélection taxe → montant → espèces → valider → vérifier reçu | Haute |
| E2E-TR-02 | Transaction espèces offline | Couper réseau → transaction espèces → vérifier statut EN_ATTENTE → remettre réseau → vérifier sync | Haute |
| E2E-TR-03 | Historique transactions | Transactions → vérifier liste chargée → filtrer par date | Moyenne |

### 5.3 Flux transaction (digital — refus offline)

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-TR-04 | Refus mobile money offline | Couper réseau → nouvelle transaction → mobile money → vérifier dialog "Connexion requise" | Haute |
| E2E-TR-05 | Mobile money online | Réseau actif → mobile money → vérifier initiation paiement | Moyenne |

### 5.4 Flux recensement

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-RS-01 | Recensement complet | Dashboard → Recensement → remplir formulaire → photo → localisation → sauvegarder → vérifier QR code généré | Haute |
| E2E-RS-02 | Recherche contribuable | Recensement → recherche par nom → vérifier résultats | Moyenne |

### 5.5 Flux QR Code

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-QR-01 | Scan QR contribuable | Transactions → scan QR → vérifier contribuable identifié | Haute |
| E2E-QR-02 | QR code invalide | Scan QR invalide → vérifier message erreur | Moyenne |

### 5.6 Flux offline / sync

| ID | Scénario | Étapes | Priorité |
|---|---|---|---|
| E2E-OF-01 | Mode offline complet | Couper réseau → créer transaction espèces → vérifier stockage local → remettre réseau → vérifier sync automatique | Haute |
| E2E-OF-02 | Consultation offline | Couper réseau → consulter historique → vérifier données locales affichées | Moyenne |
| E2E-OF-03 | Préparation brouillon offline | Couper réseau → préparer transaction mobile money (brouillon) → vérifier statut DRAFT (jamais PAYE) | Moyenne |

---

## 6. Tests de sécurité mobile

| ID | Test | Description | Priorité |
|---|---|---|---|
| SEC-01 | `tokenStoredInSecureStorage` | flutter_secure_storage (Keychain/Keystore) | Haute |
| SEC-02 | `noSensitiveDataInLogs` | Aucune donnée bancaire/PIN dans logs | Haute |
| SEC-03 | `sslPinning_shouldRejectSelfSigned` | Refus certificat non valide | Moyenne |
| SEC-04 | `localAuth_requiredOnAppResume` | Biométrie au retour en arrière-plan | Moyenne |

---

## 7. Tests de performance

| ID | Test | Description | Priorité |
|---|---|---|---|
| PER-01 | `dashboardLoad_under2Seconds` | Chargement dashboard < 2s | Moyenne |
| PER-02 | `transactionList_scroll60fps` | Scroll fluide liste transactions | Basse |
| PER-03 | `offlineStorage_100transactions` | 100 transactions offline sans lag | Basse |

---

## 8. Tests de compatibilité

| Plateforme | Version min | Priorité |
|---|---|---|
| Android | 8.0 (API 26) | Haute |
| iOS | 14.0 | Moyenne |
| Web (Flutter) | Chrome, Safari | Basse |

---

## 9. Commandes d'exécution

```bash
# Tests unitaires
cd verdentax && flutter test test/unit/

# Tests widget
flutter test test/widget/

# Tous les tests
flutter test

# Tests E2E (nécessite émulateur ou device)
flutter test integration_test/

# Tests E2E sur device spécifique
flutter test integration_test/ -d <device_id>

# Analyse statique
flutter analyze

# Coverage
flutter test --coverage
```

---

## 10. Couverture cible

| Module | Couverture cible | Priorité |
|---|---|---|
| Services (auth, api, transaction, connectivity) | ≥ 80% | Haute |
| Models (transaction, recensement, entities) | ≥ 80% | Haute |
| Screens (login, dashboard, transaction, recensement) | ≥ 60% | Haute |
| E2E (flux critiques) | 100% des flux critiques | Haute |
| Sécurité (token, biométrie, offline) | ≥ 90% | Haute |
