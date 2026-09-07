# Plan de Tests Backend — TaxCollect

> **Objectif** : Valider l'ensemble des fonctionnalités backend (Spring Boot 3.5.0, Java 17, PostgreSQL, Keycloak).
>
> **Dernière mise à jour** : 2026-09-06

---

## 1. Stratégie de test

### 1.1 Pyramide de tests

```
        ┌───────────┐
        │  E2E (5%)  │  ← Tests d'intégration complète (Testcontainers)
        ├───────────┤
        │ Intégr (20%)│  ← Repos + DB (H2/Testcontainers PostgreSQL)
        ├───────────┤
        │  Unit (75%) │  ← Services + Mappers + Utils (Mockito)
        └───────────┘
```

### 1.2 Outils

| Outil | Usage |
|---|---|
| JUnit 5 | Framework de test |
| Mockito | Mocks pour tests unitaires |
| AssertJ | Assertions fluent |
| H2 (mode PostgreSQL) | DB en mémoire pour tests d'intégration |
| Testcontainers | Kafka, Redis, PostgreSQL pour tests E2E |
| Spring Boot Test | Contexte Spring pour tests d'intégration |
| MockMvc | Tests de contrôleurs REST |

### 1.3 Convention de nommage

- `*Test.java` — Tests unitaires (Mockito, pas de contexte Spring)
- `*IntegrationTest.java` — Tests d'intégration (contexte Spring partiel, H2)
- `*E2ETest.java` — Tests de bout en bout (Testcontainers)

---

## 2. Tests unitaires — Services

### 2.1 Tests existants (à maintenir)

| Fichier | Couverture |
|---|---|
| `TransactionServiceTest` | Création transaction, mise à jour TaxeCollect, pagination |
| `AgentServiceImplTest` | CRUD agent, affectation zone |
| `ClotureCaisseServiceTest` | Clôture caisse, calcul total |
| `QRCodeContribuableServiceTest` | Génération QR code |
| `RecensementServiceTest` | Recensement contribuable |
| `ReceiptNumberGeneratorTest` | Génération numéro reçu |
| `TransactionHashUtilTest` | Hash transaction |
| `AssessmentServiceTest` | Génération avis, référence, lien Taxe, filtre période |

### 2.2 Tests à ajouter

#### TaxeService

| ID | Test | Description | Priorité |
|---|---|---|---|
| TS-01 | `createTaxe_shouldSucceed` | Création d'une taxe valide | Haute |
| TS-02 | `createTaxe_shouldThrowWhenNomDuplicate` | Nom en double → ConflictException | Haute |
| TS-03 | `updateTaxe_shouldUpdateFields` | Mise à jour partielle | Moyenne |
| TS-04 | `deleteTaxe_shouldSetDeletedAt` | Soft delete (Auditable) | Moyenne |
| TS-05 | `exportTaxes_csv_shouldReturnValidCsv` | Export CSV avec en-têtes corrects | Haute |
| TS-06 | `exportTaxes_xlsx_shouldReturnValidWorkbook` | Export XLSX avec Apache POI | Haute |
| TS-07 | `exportTaxes_shouldFilterByCategorie` | Filtrage par catégorie | Moyenne |

#### ContribuableService

| ID | Test | Description | Priorité |
|---|---|---|---|
| CS-01 | `createContribuable_shouldSucceed` | Création contribuable valide | Haute |
| CS-02 | `searchContribuables_shouldReturnPagedResults` | Recherche avec pagination | Haute |
| CS-03 | `exportContribuables_csv_shouldReturnValidCsv` | Export CSV | Haute |
| CS-04 | `exportContribuables_xlsx_shouldReturnValidWorkbook` | Export XLSX | Haute |
| CS-05 | `exportContribuables_shouldFilterByZone` | Filtrage par zone | Moyenne |

#### AssessmentService (compléter les existants)

| ID | Test | Description | Priorité |
|---|---|---|---|
| AS-01 | `generateForAll_shouldCreateAssessmentsForAllActiveTaxes` | Génération globale | Haute |
| AS-02 | `markOverdue_shouldUpdateStatus` | Marquage en retard | Haute |
| AS-03 | `exportAssessments_csv_shouldReturnValidCsv` | Export CSV | Haute |
| AS-04 | `exportAssessments_xlsx_shouldReturnValidWorkbook` | Export XLSX | Haute |
| AS-05 | `exportAssessments_shouldFilterByPeriod` | Filtrage par période | Moyenne |

#### PaymentService

| ID | Test | Description | Priorité |
|---|---|---|---|
| PS-01 | `initiatePayment_shouldCreateCollectionOrderAndAttempt` | Initiation paiement | Haute |
| PS-02 | `initiatePayment_shouldRejectOfflineDigitalPayment` | Refus paiement digital offline | Haute |
| PS-03 | `initiatePayment_shouldUseIdempotencyKey` | Idempotence (Redis) | Haute |
| PS-04 | `getPaymentStatus_shouldReturnCurrentStatus` | Consultation statut | Moyenne |
| PS-05 | `cancelPayment_shouldUpdateStatus` | Annulation paiement | Moyenne |
| PS-06 | `refundPayment_shouldCreateRefundRecord` | Remboursement | Basse |

#### SmsNotificationService

| ID | Test | Description | Priorité |
|---|---|---|---|
| SMS-01 | `sendPaymentConfirmationSms_shouldLogWhenDisabled` | SMS désactivé → log only | Moyenne |
| SMS-02 | `sendPaymentConfirmationSms_shouldCallProviderWhenEnabled` | SMS activé → appel API | Moyenne |
| SMS-03 | `sendOverdueReminderSms_shouldFormatMessageCorrectly` | Formatage message | Basse |

#### IdempotencyService

| ID | Test | Description | Priorité |
|---|---|---|---|
| ID-01 | `checkAndStore_shouldReturnTrueForNewKey` | Nouvelle clé → true | Haute |
| ID-02 | `checkAndStore_shouldReturnFalseForExistingKey` | Clé existante → false | Haute |
| ID-03 | `storeResult_andGetResult_shouldRoundTrip` | Stockage et récupération | Moyenne |

---

## 3. Tests unitaires — Mappers

| ID | Test | Description | Priorité |
|---|---|---|---|
| MP-01 | `TaxeCollectMapper_toDto_shouldMapAllFields` | Mapping entity → DTO | Haute |
| MP-02 | `TaxeCollectMapper_toDto_shouldMapTaxeId` | Mapping taxe.id → taxeId | Haute |
| MP-03 | `TaxeCollectMapper_toEntity_shouldIgnoreTaxe` | Ignorer relation Taxe | Moyenne |

---

## 4. Tests d'intégration — Contrôleurs REST (MockMvc)

### 4.1 Auth & Sécurité

| ID | Test | Description | Rôles | Priorité |
|---|---|---|---|---|
| AUTH-01 | `login_shouldReturnToken` | Authentification Keycloak | Public | Haute |
| AUTH-02 | `accessProtectedEndpoint_withoutToken_shouldReturn401` | Pas de JWT → 401 | — | Haute |
| AUTH-03 | `accessAdminEndpoint_asAgent_shouldReturn403` | Rôle insuffisant → 403 | AGENT | Haute |
| AUTH-04 | `accessAllEndpoints_asAdmin_shouldSucceed` | Admin = tous droits | ADMIN | Moyenne |

### 4.2 CRUD Contribuables

| ID | Test | Endpoint | Priorité |
|---|---|---|---|
| CT-01 | `createContribuable_shouldReturn201` | POST /api/taxcollect/contribuable | Haute |
| CT-02 | `getAllContribuables_shouldReturnPaged` | GET /api/taxcollect/contribuable/page | Haute |
| CT-03 | `searchContribuables_shouldReturnFiltered` | GET /api/taxcollect/contribuable/search | Haute |
| CT-04 | `updateContribuable_shouldReturn200` | PUT /api/taxcollect/contribuable/{id} | Moyenne |
| CT-05 | `deleteContribuable_shouldReturn204` | DELETE /api/taxcollect/contribuable/{id} | Moyenne |
| CT-06 | `exportContribuables_csv_shouldReturnFile` | GET /api/taxcollect/contribuable/export?format=csv | Haute |
| CT-07 | `exportContribuables_xlsx_shouldReturnFile` | GET /api/taxcollect/contribuable/export?format=xlsx | Haute |

### 4.3 CRUD Taxes

| ID | Test | Endpoint | Priorité |
|---|---|---|---|
| TX-01 | `createTaxe_shouldReturn201` | POST /api/taxcollect/taxe | Haute |
| TX-02 | `getAllTaxes_shouldReturnList` | GET /api/taxcollect/taxe/all | Haute |
| TX-03 | `exportTaxes_csv_shouldReturnFile` | GET /api/taxcollect/taxe/export?format=csv | Haute |
| TX-04 | `exportTaxes_xlsx_shouldReturnFile` | GET /api/taxcollect/taxe/export?format=xlsx | Haute |

### 4.4 Avis d'imposition (Assessments)

| ID | Test | Endpoint | Priorité |
|---|---|---|---|
| AV-01 | `generateForTaxe_shouldReturn200` | POST /api/assessments/generate/{taxeId} | Haute |
| AV-02 | `generateForAll_shouldReturn200` | POST /api/assessments/generate-all | Haute |
| AV-03 | `findByPeriod_shouldReturnList` | GET /api/assessments/period | Haute |
| AV-04 | `markOverdue_shouldReturn200` | POST /api/assessments/mark-overdue | Moyenne |
| AV-05 | `exportAssessments_csv_shouldReturnFile` | GET /api/assessments/export?format=csv | Haute |
| AV-06 | `exportAssessments_xlsx_shouldReturnFile` | GET /api/assessments/export?format=xlsx | Haute |

### 4.5 Transactions

| ID | Test | Endpoint | Priorité |
|---|---|---|---|
| TR-01 | `createTransaction_espece_shouldReturn201` | POST /api/transactions | Haute |
| TR-02 | `getTransactions_shouldReturnPaged` | GET /api/transactions | Haute |
| TR-03 | `exportTransactions_csv_shouldReturnFile` | GET /api/transactions/export?format=csv | Haute |
| TR-04 | `exportTransactions_xlsx_shouldReturnFile` | GET /api/transactions/export?format=xlsx | Haute |

### 4.6 Paiements

| ID | Test | Endpoint | Priorité |
|---|---|---|---|
| PAY-01 | `initiatePayment_shouldReturn202` | POST /api/payments | Haute |
| PAY-02 | `getPaymentStatus_shouldReturn200` | GET /api/payments/{reference} | Moyenne |
| PAY-03 | `webhook_shouldUpdateTransactionStatus` | POST /api/payments/webhooks/{provider} | Haute |
| PAY-04 | `webhook_withInvalidSignature_shouldReturn401` | Webhook falsifié | Haute |
| PAY-05 | `webhook_withReplay_shouldReturn409` | Replay attack (Redis idempotence) | Haute |

---

## 5. Tests d'intégration — Base de données (Flyway)

| ID | Test | Description | Priorité |
|---|---|---|---|
| DB-01 | `allMigrations_shouldApplySuccessfully` | V1 → V23 sans erreur | Haute |
| DB-02 | `seedData_shouldBeIdempotent` | Re-run V22 ne crée pas de doublons | Haute |
| DB-03 | `taxeCollect_shouldHaveReferenceAfterMigration` | V23 backfill reference | Haute |
| DB-04 | `taxeCollect_shouldHaveTaxeIdAfterMigration` | V23 backfill taxe_id | Haute |
| DB-05 | `jpaValidation_shouldNotFail` | ddl-auto=validate passe | Haute |

---

## 6. Tests E2E — Testcontainers

| ID | Test | Description | Priorité |
|---|---|---|---|
| E2E-01 | `fullPaymentFlow_stubProvider` | Initiation → webhook → Transaction SUCCESS → Receipt → TaxeCollect PAYE | Haute |
| E2E-02 | `kafkaEventPublished_onPaymentSucceeded` | Vérifier événement Kafka publié | Moyenne |
| E2E-03 | `idempotencyKey_preventsDuplicatePayment` | Double request → même transaction | Haute |
| E2E-04 | `offlineEspeceFlow_syncOnReconnect` | Agent offline → sync → TaxeCollect PAYE | Moyenne |

---

## 7. Tests de sécurité

| ID | Test | Description | Priorité |
|---|---|---|---|
| SEC-01 | `webhook_withInvalidSignature_shouldReturn401` | Signature HMAC invalide | Haute |
| SEC-02 | `webhook_withReplay_shouldReturn409` | Replay via Redis | Haute |
| SEC-03 | `paymentAmount_tampered_shouldReject` | Montant modifié vs TaxeCollect | Haute |
| SEC-04 | `jwtExpired_shouldReturn401` | JWT expiré | Haute |
| SEC-05 | `roleContribuable_cannotAccessAdminEndpoints` | Isolation des rôles | Haute |
| SEC-06 | `sqlInjection_shouldBePrevented` | JPA paramétrée = protection | Moyenne |

---

## 8. Tests de non-régression

| ID | Test | Description | Priorité |
|---|---|---|---|
| REG-01 | `existingTransactionEndpoint_stillWorks` | /api/transactions non cassé | Haute |
| REG-02 | `existingAgentEspeceOfflineFlow_stillWorks` | Flux agent espèces offline | Haute |
| REG-03 | `existingClotureCaisse_stillWorks` | Clôture de caisse | Moyenne |
| REG-04 | `existingQRCodeContribuable_stillWorks` | QR contribuable existant | Moyenne |

---

## 9. Commandes d'exécution

```bash
# Tous les tests
cd backend && mvn test

# Tests unitaires uniquement
mvn test -Dtest="*Test"

# Tests d'intégration
mvn test -Dtest="*IntegrationTest"

# Tests E2E (nécessite Docker pour Testcontainers)
mvn test -Dtest="*E2ETest"

# Coverage
mvn jacoco:report
```

---

## 10. Couverture cible

| Module | Couverture cible | Priorité |
|---|---|---|
| Services (payment, transaction, assessment) | ≥ 80% | Haute |
| Contrôleurs REST | ≥ 70% | Haute |
| Mappers | ≥ 90% | Moyenne |
| Utils | ≥ 80% | Moyenne |
| Config | ≥ 50% | Basse |
