# PROMPT — EXTENSION DU MODULE DE PAIEMENT DIGITAL E-COLLECTTAXE

> **Prompt orienté intégration** : ce document adapte la spécification cible au **codebase existant** d'E-CollectTaxe.
> Il décrit ce qu'il faut **ajouter, étendre et refactorer** sans casser l'existant.
>
> Statut : spécification de référence — production-ready.
> Dernière mise à jour : 2026-09-04.

---

## 0. État de l'existant (À LIRE AVANT DE CODER)

Le backend E-CollectTaxe existe déjà. **Ne pas recréer** les entités ci-dessous : les **étendre**.

### 0.1 Stack technique actuelle

```text
Spring Boot 3.5.0
Java 17  (NE PAS passer à 21 sans accord)
PostgreSQL + Flyway (migrations V2 → V11 existantes)
Keycloak (OAuth2 resource server, JWT, realm "mairie")
OpenLDAP (via unboundid-ldapsdk)
Hibernate Spatial (PostGIS) pour Commune/Zone/Quartier
Lombok, MapStruct 1.5.5, Springdoc OpenAPI 2.6.0
Apache POI (export Excel)
```

> **Kafka et Redis ne sont PAS encore intégrés.** Leur ajout fait partie des livrables (cf. § 11).

### 0.2 Structure de packages

```text
com.nectuxingenieries.collect.tax
├── controllers      (REST, @PreAuthorize par rôle)
├── services         (+ services/impl pour certains)
├── repositories     (JPA + Specifications)
├── models           (entités JPA, extends Auditable)
│   ├── enums
│   └── mappers
├── dto
├── config           (ApplicationConfig, AuditConfig, Keycloak*, LDAP, OpenApi, WebMvc)
├── security         (JwtAuthConverter, WebSecurityConfig, LogicalDeletionPermissions, ...)
├── exceptions       (NotFoundException, InvalidOperationException, ConflictException, GlobalExceptionHandler)
└── utils            (ReceiptNumberGenerator, TransactionHashUtil)
```

### 0.3 Entités existantes à CONSERVER / ÉTENDRE

| Entité existante | Rôle dans le modèle cible | Action |
|---|---|---|
| `Auditable` | Base (createdAt/By, updatedAt/By, deletedAt/By, isActive) | **Conserver** — toute nouvelle entité l'étend |
| `Commune` | Municipalité | **Conserver** — ajouter `code` pour références fiscales |
| `Zone` | Secteur de collecte | **Conserver** |
| `Contribuable` | Taxpayer | **Conserver** — vérifier `numeroContribuable` comme référence citoyen |
| `Taxe` | Catalogue de taxes | **Conserver** |
| `TaxeCollect` | **= TaxAssessment** (créance fiscale) | **Étendre** : ajouter `reference` unique, `remainingAmount`, `currency`, `dueDate` existe déjà (`dateLimite`) |
| `Transaction` | **= PaymentTransaction (partiel)** | **Étendre** : ajouter champs provider, lifecycle paiement, idempotency key |
| `QRCodeContribuable` | QR existant (lié au contribuable) | **Conserver** — créer en parallèle `PaymentQRCode` lié à une `CollectionOrder` |
| `ClotureCaisse` | Clôture de caisse agent | **Conserver** — intégrer dans la réconciliation |
| `Agents` | Agent municipal | **Conserver** |
| `User` | Utilisateur Keycloak | **Conserver** |

### 0.4 Enums existants à ÉTENDRE

```java
// models/enums/ModePaiement.java  — ACTUEL
ESPECE, MOBILE_MONEY, QR_CODE

// models/enums/StatutTransaction.java  — ACTUEL
EN_ATTENTE, VALIDEE, ANNULEE, SYNCHRONISEE, EN_ERREUR

// models/enums/StatutPayment.java  — ACTUEL (sur TaxeCollect)
PAYE, PARTIEL, EN_RETARD, IMPAYE
```

> **Ne pas casser** les valeurs existantes. **Ajouter** les nouvelles valeurs à la fin des enums.

### 0.5 Comportements existants à PRÉSERVER

- `TransactionService.createTransaction` génère `numeroRecu` via `ReceiptNumberGenerator` et `hashTransaction` via `TransactionHashUtil`, puis met à jour `TaxeCollect.statut = PAYE` quand `taxeCollectId` est fourni.
- `TransactionController` expose `/api/transactions` avec rôles `AGENT`, `TRESOR`, `ADMIN`, `SUPERVISEUR`.
- La sécurité repose sur `@PreAuthorize` + JWT Keycloak (cf. `security/JwtAuthConverter`).
- Les migrations Flyway sont **strictes** (`ddl-auto=validate`). Toute nouvelle table = nouvelle migration `V12__...`, `V13__...`.
- API base path : `/api/...` (convention existante).

---

## 1. Contexte du projet

**E-CollectTaxe** est une plateforme numérique de collecte des taxes municipales destinée aux collectivités territoriales en Côte d'Ivoire. Le socle fonctionnel (contribuables, taxes, avis `TaxeCollect`, transactions agent, clôture de caisse, QR contribuable, mode offline) **existe déjà**.

L'objectif de cette extension est d'ajouter un **Payment & Collection Module** professionnel, indépendant des fournisseurs de paiement, supportant :

1. **Paiement direct** (depuis l'app mobile contribuable)
2. **Request-to-Pay (RTP)**
3. **Paiement par QR Code** (lié à une créance, pas seulement au contribuable)
4. **Paiement initié par un agent municipal** (cas existant à étendre)
5. **Paiement depuis l'application mobile du contribuable**

L'architecture doit permettre l'intégration de **PI-SPI** (infrastructure de paiement interopérable CI) et de **PSP** (CinetPay, etc.), ainsi que d'autres prestataires à l'avenir.

> **Règle absolue** : ne jamais coupler le domaine métier E-CollectTaxe directement à une API particulière.

---

## 2. Objectif du module

Concevoir et implémenter un **Payment & Collection Module** qui **s'imbrique** sur l'existant :

- `TaxeCollect` (créance) reste la source du montant dû.
- `Transaction` (existante) devient la **transaction financière confirmée** — on l'enrichit, on ne la remplace pas.
- On ajoute les entités manquantes : `CollectionOrder`, `PaymentAttempt`, `PaymentRequest` (RTP), `PaymentProviderConfig`, `PaymentQRCode`, `Receipt`, `Refund`, `Reconciliation`, `Settlement`.
- On ajoute l'abstraction `PaymentProvider` + implémentations `PISPIProvider`, `PSPProvider`, et une `PaymentProviderFactory`.

---

## 3. Principe architectural fondamental

Le domaine métier doit être indépendant du fournisseur de paiement.

Créer une abstraction `PaymentProvider` dans un nouveau sous-package `payment` :

```text
com.nectuxingenieries.collect.tax.payment
├── PaymentProvider.java          (interface)
├── PaymentProviderFactory.java
├── dto/                          (request/response internes au module)
├── provider/
│   ├── pisp/
│   │   └── PISPIProvider.java
│   ├── psp/
│   │   └── PSPProvider.java
│   └── stub/
│       └── StubPaymentProvider.java   (pour tests/sandbox)
└── config/
    └── PaymentProviderProperties.java
```

Interface :

```java
public interface PaymentProvider {

    PaymentInitiationResponse initiatePayment(PaymentInitiationRequest request);

    PaymentStatusResponse getPaymentStatus(String providerTransactionId);

    PaymentRefundResponse refund(RefundRequest request);

    PaymentRequestResponse createPaymentRequest(PaymentRequest request); // RTP

    PaymentRequestStatusResponse getPaymentRequestStatus(String providerRequestId);
}
```

> Le code métier (`TransactionService`, futurs `PaymentService`, `CollectionOrderService`) **ne doit jamais** appeler directement `PISPIService` ou `CinetPayService`. Il appelle toujours `PaymentProvider` (résolu via `PaymentProviderFactory.resolve(request)`).

---

## 4. Architecture fonctionnelle (intégrée à l'existant)

```text
CONTRIBUABLE (existant)
     │
     ▼
TAXECOLLECT  (existant = créance fiscale, à étendre avec reference + remainingAmount)
     │
     ▼
COLLECTION ORDER  (NOUVEAU)
     │
     ├───────────────┬───────────────┐
     ▼               ▼               ▼
PAIEMENT DIRECT    RTP           QR CODE
(AGENT existant    (NOUVEAU)     (PaymentQRCode NOUVEAU,
 + app mobile)                    QRCodeContribuable conservé)
     │               │               │
     └───────────────┼───────────────┘
                     ▼
            PaymentProvider  (NOUVEAU, abstrait)
             │           │
             ▼           ▼
          PI-SPI        PSP
             │           │
             └─────┬─────┘
                   ▼
         PAYMENT ATTEMPT  (NOUVEAU)
                   │
                   ▼
         TRANSACTION  (existante, ÉTENDUE)
                   │
                   ▼
         CONFIRMATION (webhook serveur-to-serveur)
                   │
             ┌─────┴─────┐
             ▼           ▼
           REÇU      RÉCONCILIATION
         (NOUVEAU)     (NOUVEAU)
                         │
                         ▼
                  CLOTURE CAISSE (existante) + SETTLEMENT (NOUVEAU)
                         │
                         ▼
                  Dashboard mairie
```

---

## 5. Extensions d'entités existantes

### 5.1 `TaxeCollect` (= TaxAssessment) — ÉTENDRE

Ajouter (migration `V12__`) :

```sql
ALTER TABLE taxecollect ADD COLUMN reference VARCHAR(64);
ALTER TABLE taxecollect ADD COLUMN remaining_amount NUMERIC(19,2);
ALTER TABLE taxecollect ADD COLUMN currency VARCHAR(8) DEFAULT 'XOF';
ALTER TABLE taxecollect ADD COLUMN tax_type VARCHAR(64);
-- unique constraint sur reference
ALTER TABLE taxecollect ADD CONSTRAINT uk_taxecollect_reference UNIQUE (reference);
-- index pour recherche par référence
CREATE INDEX idx_taxecollect_reference ON taxecollect(reference);
```

Format de référence (généré côté backend, jamais trusté du mobile) :

```text
TAX-{CODE_COMMUNE}-{ANNEE}-{SEQUENCE}
ex: TAX-COC-2026-000125
```

> `dateLimite` existe déjà (= dueDate). `montant` existe déjà (= amount). `statut` (StatutPayment) existe déjà.

### 5.2 `Transaction` (= PaymentTransaction) — ÉTENDRE

Ajouter (migration `V13__`) :

```sql
ALTER TABLE transaction ADD COLUMN transaction_reference VARCHAR(64);      -- référence interne paiement
ALTER TABLE transaction ADD COLUMN provider VARCHAR(32);                   -- PISPI | PSP | STUB
ALTER TABLE transaction ADD COLUMN provider_transaction_id VARCHAR(128);   -- id chez le provider
ALTER TABLE transaction ADD COLUMN provider_request_id VARCHAR(128);       -- id RTP chez le provider
ALTER TABLE transaction ADD COLUMN currency VARCHAR(8) DEFAULT 'XOF';
ALTER TABLE transaction ADD COLUMN payment_method VARCHAR(32);             -- ORANGE_MONEY, MTN_MONEY, MOOV, CARD, ...
ALTER TABLE transaction ADD COLUMN initiated_at TIMESTAMP;
ALTER TABLE transaction ADD COLUMN completed_at TIMESTAMP;
ALTER TABLE transaction ADD COLUMN failure_reason VARCHAR(255);
ALTER TABLE transaction ADD COLUMN idempotency_key VARCHAR(128);
ALTER TABLE transaction ADD COLUMN collection_order_id BIGINT;

ALTER TABLE transaction ADD CONSTRAINT uk_transaction_reference UNIQUE (transaction_reference);
ALTER TABLE transaction ADD CONSTRAINT uk_transaction_idempotency UNIQUE (idempotency_key);
ALTER TABLE transaction ADD CONSTRAINT fk_transaction_collection_order
    FOREIGN KEY (collection_order_id) REFERENCES collection_order(id);
CREATE INDEX idx_transaction_provider_tid ON transaction(provider_transaction_id);
```

> `numeroRecu`, `hashTransaction`, `referencePaiement` (existant) sont conservés.
> `referencePaiement` existant peut rester pour compat ; `provider_transaction_id` est le nouvel identifiant officiel chez le provider.

### 5.3 `ModePaiement` — ÉTENDRE (sans casser)

```java
public enum ModePaiement {
    ESPECE,        // existant
    MOBILE_MONEY,  // existant
    QR_CODE,       // existant
    // --- ajouts ---
    RTP,
    CARD,
    BANK_TRANSFER,
    DIRECT_PAYMENT
}
```

### 5.4 `StatutTransaction` — ÉTENDRE (sans casser)

```java
public enum StatutTransaction {
    EN_ATTENTE,     // existant
    VALIDEE,        // existant
    ANNULEE,        // existant
    SYNCHRONISEE,   // existant (offline sync)
    EN_ERREUR,      // existant
    // --- ajouts (lifecycle paiement digital) ---
    INITIATED,
    PENDING,
    SUCCESS,
    FAILED,
    EXPIRED,
    REFUNDED,
    PARTIALLY_REFUNDED
}
```

> **Important** : `StatutPayment` (sur `TaxeCollect`) reste orienté créance (PAYE/PARTIEL/EN_RETARD/IMPAYE). `StatutTransaction` (sur `Transaction`) gère le lifecycle paiement. **Ne pas fusionner.**

---

## 6. Nouvelles entités (toutes `extends Auditable`)

Toutes dans `com.nectuxingenieries.collect.tax.models` (ou un sous-package `models.payment`).

### 6.1 `CollectionOrder`

Entité intermédiaire entre `TaxeCollect` et le paiement.

```text
CollectionOrder
-----------------------------
id
reference                     -- ex: CO-TAX-COC-2026-000125-01
taxeCollectId (FK)
contribuableId (FK, dénormalisé pour perf)
amount (NUMERIC 19,2)
currency (XOF)
channel (enum PaymentChannel)
status (enum CollectionOrderStatus)
expiresAt (TIMESTAMP)
createdAt / updatedAt (via Auditable)
```

```java
public enum PaymentChannel {
    DIRECT_PAYMENT, RTP, QR_CODE, AGENT, MOBILE_APP
}

public enum CollectionOrderStatus {
    OPEN, PENDING_PAYMENT, PAID, PARTIALLY_PAID, EXPIRED, CANCELLED, FAILED
}
```

### 6.2 `PaymentAttempt`

Une même `CollectionOrder` peut avoir plusieurs tentatives.

```text
PaymentAttempt
-----------------------------
id
collectionOrderId (FK)
attemptNumber (int)
provider (VARCHAR)
providerTransactionId (VARCHAR)
amount (NUMERIC 19,2)
status (StatutTransaction)
failureReason (VARCHAR)
createdAt / updatedAt
```

> **Règle** : ne jamais considérer une tentative comme un paiement définitif. Seule la `Transaction` confirmée via webhook l'est.

### 6.3 `PaymentRequest` (RTP)

```text
PaymentRequest
-----------------------------
id
reference                     -- ex: RTP-TAX-COC-2026-000125-01
collectionOrderId (FK)
taxpayerId (FK)
amount
currency
provider (VARCHAR)
providerRequestId (VARCHAR)
status (enum RTPStatus)
expiresAt
sentAt
acceptedAt
paidAt
createdAt / updatedAt
```

```java
public enum RTPStatus {
    RTP_CREATED, RTP_SENT, RTP_PENDING, RTP_ACCEPTED,
    RTP_REJECTED, RTP_EXPIRED, RTP_PAID, RTP_CANCELLED
}
```

### 6.4 `PaymentProviderConfig`

Configuration externalisée (par commune / par canal).

```text
PaymentProviderConfig
-----------------------------
id
providerCode (PISPI | PSP_CINETPAY | PSP_FEDAPAY | STUB | ...)
displayName
communeId (FK, nullable = config globale si null)
channel (PaymentChannel, nullable = tous si null)
priority (int)
enabled (boolean)
sandbox (boolean)
baseUrlsandbox / baseUrlProd (chiffrés si secrets)
credentialsRef (VARCHAR)      -- référence vers Vault / env var, JAMAIS la valeur
createdAt / updatedAt
```

> **JAMAIS** stocker un secret en clair dans cette table. `credentialsRef` pointe vers Vault ou une variable d'environnement.

### 6.5 `PaymentQRCode`

QR Code lié à une `CollectionOrder` (différent du `QRCodeContribuable` existant qui est lié au citoyen).

```text
PaymentQRCode
-----------------------------
id
token (VARCHAR, unique, signé)
collectionOrderId (FK)
payload (TEXT)               -- ex: https://pay.ecollecttaxe.ci/q/{token}
generatedAt
expiresAt
usedAt
actif (boolean)
```

> Le QR ne contient **pas** d'info sensible : seulement un token signé qui résout côté backend vers la `CollectionOrder`.

### 6.6 `Receipt`

Reçu officiel (distinct du `numeroRecu` porté par `Transaction`).

```text
Receipt
-----------------------------
id
receiptNumber (unique)       -- peut réutiliser ReceiptNumberGenerator
transactionId (FK)
taxeCollectId (FK, dénormalisé)
taxpayerId (FK, dénormalisé)
amount
currency
provider
providerTransactionId
issuedAt
pdfUrl / pdfContent (TEXT, nullable)
createdAt / updatedAt
```

### 6.7 `Refund`

```text
Refund
-----------------------------
id
reference
transactionId (FK)
amount
currency
provider
providerRefundId
status (enum RefundStatus)
reason
initiatedAt
completedAt
createdAt / updatedAt
```

```java
public enum RefundStatus { INITIATED, PENDING, SUCCESS, FAILED, PARTIAL }
```

### 6.8 `Reconciliation` & `Settlement`

```text
Reconciliation
-----------------------------
id
reference
transactionId (FK, nullable)
providerTransactionId (nullable)
internalStatus
providerStatus
amountInternal
amountProvider
discrepancyType (enum DiscrepancyType)
status (enum ReconciliationStatus)
detectedAt
resolvedAt
createdAt / updatedAt

Settlement
-----------------------------
id
reference
reconciliationId (FK)
communeId (FK)
amount
currency
settledAt
referenceBank
createdAt / updatedAt
```

```java
public enum DiscrepancyType {
    NONE, PAID_INTERNAL_NOT_PROVIDER, PAID_PROVIDER_NOT_INTERNAL,
    AMOUNT_MISMATCH, DUPLICATE_TRANSACTION, UNKNOWN_TRANSACTION,
    PENDING_TOO_LONG, REFUND_MISMATCH
}
public enum ReconciliationStatus { MATCHED, DISCREPANCY, RESOLVED, ESCALATED }
```

---

## 7. Référence unique (colonne vertébrale)

La référence fiscale (`TaxeCollect.reference`, format `TAX-{CODE_COMMUNE}-{ANNEE}-{SEQ}`) doit être retrouvable depuis :

- l'application mobile ;
- le QR Code (`PaymentQRCode` → `CollectionOrder` → `TaxeCollect.reference`) ;
- le RTP ;
- le backend ;
- le PSP / PI-SPI ;
- le reçu ;
- la réconciliation ;
- le dashboard financier.

> **Ne pas** utiliser la référence fiscale comme identifiant technique de transaction chez un PSP si le protocole impose un identifiant différent. Conserver séparément :
>
> ```text
> TaxeCollect.reference            (référence fiscale)
> Transaction.transactionReference (référence interne paiement)
> Transaction.providerTransactionId
> Transaction.providerRequestId
> ```

---

## 8. Paiement direct (extension du flux agent existant + app mobile)

```text
Contribuable (app mobile) OU Agent (existant)
    ↓
Sélection d'une TaxeCollect
    ↓
Payer
    ↓
Choix du moyen de paiement (ModePaiement étendu)
    ↓
Création CollectionOrder (backend)
    ↓
PaymentProvider (résolu via factory)
    ↓
PI-SPI / PSP
    ↓
Paiement
    ↓
Webhook de confirmation (serveur-to-serveur)
    ↓
Transaction (existante, étendue) → statut SUCCESS
    ↓
Receipt (NOUVEAU)
    ↓
TaxeCollect.statut = PAYE  (comportement existant à conserver)
```

> **Règle** : le backend doit être responsable de la création de la transaction et **récupérer le montant depuis `TaxeCollect`**, jamais truster le montant envoyé par le mobile.
>
> Le service existant `TransactionService.createTransaction` doit être **refactoré** pour déléguer l'initiation digitale au `PaymentProvider` quand `modePaiement ∈ {MOBILE_MONEY, QR_CODE, RTP, DIRECT_PAYMENT, ...}`. Le cas `ESPECE` (agent offline) reste le chemin rapide existant.

---

## 9. Request-to-Pay (RTP)

```text
Mairie / Agent
   │
   ▼
TaxeCollect
   │
   ▼
CollectionOrder (channel = RTP)
   │
   ▼
PaymentRequest  (NOUVEAU)
   │
   ▼
PaymentProvider.createPaymentRequest(...)
   │
   ▼
PI-SPI / PSP
   │
   ▼
Contribuable (notification/push)
   │
   ▼
Acceptation → Paiement
   │
   ▼
Webhook → Transaction SUCCESS → Receipt
```

Statuts RTP : `RTP_CREATED, RTP_SENT, RTP_PENDING, RTP_ACCEPTED, RTP_REJECTED, RTP_EXPIRED, RTP_PAID, RTP_CANCELLED`.

Fonctionnalités : expiration, annulation, refus, paiement, notification, consultation du statut.

---

## 10. QR Code

Deux QR coexistent :

1. **`QRCodeContribuable` (existant)** : lié au citoyen, pour identification. **Conserver tel quel.**
2. **`PaymentQRCode` (NOUVEAU)** : lié à une `CollectionOrder`, pour payer une créance précise.

Le `PaymentQRCode` contient uniquement un token signé :

```text
https://pay.ecollecttaxe.ci/q/{token}
```

Traitement backend :

```text
QR (token)
 ↓
Validation signature / expiration
 ↓
Résolution → CollectionOrder
 ↓
Vérification montant / statut / expiration
 ↓
Création PaymentAttempt
 ↓
PaymentProvider
```

Utilisable par : contribuable, agent municipal, sur avis de taxe, facture, support imprimé.

---

## 11. Intégration PI-SPI & PSP

### 11.1 Adaptateurs

```text
PaymentProvider
       │
       ├── PISPIProvider        (infrastructure interopérable CI)
       ├── PSPProvider          (CinetPay / Fedapay / ...)
       └── StubPaymentProvider  (tests/sandbox, aucune IO réelle)
```

### 11.2 Règle absolue pour PI-SPI

> **Ne pas inventer les endpoints ou paramètres PI-SPI.**
>
> Avant d'implémenter `PISPIProvider`, analyser la documentation officielle PI-SPI disponible et identifier précisément : endpoints, méthodes HTTP, authentification, certificats, formats JSON/XML, headers, identifiants, statuts, codes d'erreur, webhooks/callbacks, exigences de signature, mécanisme d'idempotence, sandbox, production.
>
> Si une information officielle n'est pas disponible, laisser explicitement :
>
> ```java
> // TODO — À CONFIRMER DANS LA DOCUMENTATION PI-SPI
> ```
>
> **Ne jamais inventer une spécification financière.**

### 11.3 Sélection du provider

```java
PaymentProvider provider = paymentProviderFactory.resolve(request);
```

Critères de résolution : `commune`, `channel`, `paymentMethod`, `amount`, `availability`, `PaymentProviderConfig`.

### 11.4 Ajout Kafka & Redis (NOUVELLES dépendances)

Le projet n'a **pas encore** Kafka ni Redis. Les ajouter via `pom.xml` :

```xml
<!-- Kafka -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-kafka</artifactId> <!-- ou spring-kafka -->
</dependency>
<!-- Redis (cache + idempotency + locks) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

> Kafka transporte les événements métier. **PostgreSQL reste la source de vérité.**
> Redis est utilisé pour : idempotency keys, locks distribués, cache de statut provider.

---

## 12. Webhooks / callbacks

Endpoint sécurisé :

```text
POST /api/payments/webhooks/{provider}
```

Traitement obligatoire :

1. authentifier la notification ;
2. vérifier la signature ;
3. vérifier l'identifiant du provider ;
4. vérifier l'idempotence (Redis) ;
5. retrouver la `Transaction` / `PaymentRequest` ;
6. vérifier le montant vs `TaxeCollect` ;
7. vérifier la référence ;
8. mettre à jour le statut (`StatutTransaction`) ;
9. publier un événement Kafka ;
10. générer le `Receipt` si paiement confirmé ;
11. mettre à jour `TaxeCollect.statut = PAYE` (comportement existant) ;
12. déclencher la réconciliation.

> **Règle absolue** : ne jamais considérer qu'une redirection mobile vers une page « succès » constitue une preuve de paiement. La confirmation serveur-to-serveur doit être privilégiée.

---

## 13. Idempotence

Chaque opération critique a une clé d'idempotence (stockée dans `Transaction.idempotency_key`, doublonnée dans Redis pour la vérification rapide).

```text
Idempotency-Key: PAY-TAX-COC-2026-000125-001
```

Comportement :

```text
Request #1 → création transaction
Request #2 → retourner la transaction existante
```

> Ne jamais créer deux paiements pour une seule demande à cause d'un retry réseau.

---

## 14. Machine d'état (Transaction)

```text
INITIATED
    │
    ▼
PENDING
   ┌┴───────────────┐
   ▼                ▼
SUCCESS           FAILED
   │
   ▼
RECEIPT_GENERATED
   │
   ▼
RECONCILED
```

Statuts supplémentaires : `CANCELLED, EXPIRED, REFUNDED, PARTIALLY_REFUNDED`.

> Interdire les transitions incohérentes (ex : `SUCCESS → PENDING` impossible).
> Créer une classe `PaymentStateMachine` avec transitions valides explicites.
> **Coexistence** avec les statuts existants (`EN_ATTENTE`, `VALIDEE`, `ANNULEE`, `SYNCHRONISEE`, `EN_ERREUR`) : ces derniers restent utilisés pour le flux agent espèces/offline historique.

---

## 15. Kafka (événements)

Topics (préfixe `ecollecttaxe.payment.`) :

```text
PaymentInitiated
PaymentPending
PaymentSucceeded
PaymentFailed
PaymentCancelled
PaymentRefunded
ReceiptGenerated
ReconciliationCompleted
```

Exemple de payload `PaymentSucceeded` :

```json
{
  "transactionReference": "...",
  "taxReference": "TAX-COC-2026-000125",
  "taxpayerId": 42,
  "amount": 15000,
  "currency": "XOF",
  "provider": "PISPI",
  "providerTransactionId": "...",
  "paidAt": "2026-09-04T10:30:00Z"
}
```

Consommateurs possibles : Notification, Receipt, Accounting, Reconciliation, Dashboard, Audit.

> **PostgreSQL reste la source de vérité.** Kafka = bus d'événements uniquement.

---

## 16. Réconciliation

```text
Transaction interne
       ↕
Transaction PI-SPI / PSP
       ↕
Settlement
       ↕
Compte municipal / ClotureCaisse (existant)
```

Anomalies : `PAID_INTERNAL_NOT_PROVIDER, PAID_PROVIDER_NOT_INTERNAL, AMOUNT_MISMATCH, DUPLICATE_TRANSACTION, UNKNOWN_TRANSACTION, PENDING_TOO_LONG, REFUND_MISMATCH`.

Créer un dashboard de réconciliation (endpoint `/api/reconciliation`).

---

## 17. Sécurité (conforme à l'existant Keycloak + LDAP)

L'existant utilise déjà Keycloak (OAuth2 resource server, JWT) + LDAP + `@PreAuthorize`. **Conserver ce socle.**

Ajouts spécifiques paiement :

- signature des webhooks (HMAC ou asymétrique selon provider) ;
- validation stricte des montants (côté backend, depuis `TaxeCollect`) ;
- audit trail (déjà partiellement via `Auditable`) ;
- protection contre replay attacks (Redis + nonce/timestamp) ;
- idempotence (Redis) ;
- rate limiting sur endpoints paiement ;
- journalisation sécurisée — **aucune** donnée bancaire sensible (PIN, OTP, mot de passe) dans les logs ;
- secrets provider via Vault / env vars, jamais en clair en base (`PaymentProviderConfig.credentialsRef`).

---

## 18. API REST (à ajouter, sans casser `/api/transactions` existant)

Conserver `/api/transactions` (existant). Ajouter :

```http
# Paiements
POST   /api/payments                          -- initier un paiement
GET    /api/payments/{reference}              -- statut par référence interne
POST   /api/payments/{reference}/cancel
POST   /api/payments/{reference}/refund

# Collection orders
POST   /api/collection-orders
GET    /api/collection-orders/{reference}

# RTP
POST   /api/payment-requests
GET    /api/payment-requests/{reference}
POST   /api/payment-requests/{reference}/cancel

# QR
GET    /api/qr/{token}                        -- résoudre un PaymentQRCode
POST   /api/qr/generate                       -- générer un PaymentQRCode pour une CollectionOrder

# Webhooks
POST   /api/payments/webhooks/{provider}

# Réconciliation
GET    /api/reconciliation
GET    /api/reconciliation/{reference}

# Reçus
GET    /api/receipts/{receiptNumber}
GET    /api/receipts/{receiptNumber}/pdf
```

> Rôles : étendre `@PreAuthorize` avec les rôles Keycloak existants (`AGENT`, `TRESOR`, `ADMIN`, `SUPERVISEUR`). Le contribuable mobile s'authentifie via Keycloak avec un rôle dédié (ex : `CONTRIBUABLE`) à ajouter au realm `mairie`.

---

## 19. Mode offline (extension de l'existant)

### 19.1 Principe fondamental

Un paiement digital (Mobile Money, QR Code vers un provider, RTP, carte) est par nature une **opération serveur-à-serveur** :

```text
Backend ──HTTPS──► PI-SPI / PSP ──► Compte du payeur
                ◄──webhook/callback──
```

Le provider est le **seul** à pouvoir :
- débiter réellement le compte du contribuable ;
- émettre un identifiant de transaction officiel (`providerTransactionId`) ;
- confirmer le succès ou l'échec.

Aucune de ces étapes ne peut se faire sans réseau côté backend. Le mobile peut être offline, mais **le backend doit être online** au moment de la confirmation.

> **RÈGLE ABSOLUE** : un paiement digital ne peut **jamais** être confirmé offline.
> Une opération financière n'est définitivement payée qu'après confirmation du backend **et** du provider.

### 19.2 Politique offline par mode de paiement

| Mode de paiement | Offline possible ? | Justification |
|---|---|---|
| **ESPECE** (agent encaisse cash) | ✅ Oui | L'argent a déjà physiquement changé de main au moment de l'enregistrement. La transaction backend n'est qu'une trace comptable a posteriori. |
| **MOBILE_MONEY** | ❌ Non | Le provider doit débiter le compte du contribuable → réseau obligatoire. |
| **QR_CODE** (vers un provider) | ❌ Non | Le QR résout vers une `CollectionOrder` qui déclenche un paiement digital via provider. |
| **RTP** | ❌ Non | La demande de paiement est créée côté provider → réseau obligatoire. |
| **CARD / BANK_TRANSFER / DIRECT_PAYMENT** | ❌ Non | Opération digitale serveur-à-serveur. |
| **Consultation** (lire créances, historique, reçus déjà générés) | ✅ Oui | Lecture seule depuis le cache SQLite local, aucun engagement financier. |
| **Préparation** (pré-remplir un formulaire, scanner un QR pour consultation) | ✅ Oui | Brouillon jamais marqué payé, jamais reçu généré. |

### 19.3 Ce qu'on retient offline = espèces uniquement

Le mode offline a un sens **uniquement** pour les paiements en **espèces** effectués par un agent municipal sur le terrain. C'est déjà ce que le codebase fait aujourd'hui :

```java
// Transaction.java (existant)
@Column(name = "offline", nullable = false)
private Boolean offline = false;

// StatutTransaction (existant) : EN_ATTENTE → SYNCHRONISEE au retour réseau
```

Flux agent espèces offline (conserver tel quel) :

```text
Agent sur le terrain, sans réseau
  │
  ▼
Contribuable paie en ESPÈCES
  │
  ▼
Agent enregistre Transaction (offline=true, statut=EN_ATTENTE)
  │
  ▼
Génération d'un reçu local PROVISOIRE (marqué "à synchroniser")
  │
  ▼
[Retour réseau]
  │
  ▼
Sync → statut=SYNCHRONISEE → TaxeCollect.statut=PAYE → reçu définitif
```

> Le reçu offline espèces est **valable** parce que l'argent est déjà là physiquement.
> Mais il doit être marqué "à synchroniser" jusqu'à confirmation backend, pour éviter qu'un contribuable présente un reçu que le backend ne connaît pas encore.
> C'est le rôle de `StatutTransaction.EN_ATTENTE` → `SYNCHRONISEE` dans le code actuel.

### 19.4 Refus explicite du paiement digital offline

Côté Flutter (`verdentax/`), l'app doit **refuser** d'initier un paiement digital sans réseau :

```dart
if (modePaiement != ModePaiement.ESPECE && !connectivityService.isOnline) {
  return _showOfflinePaymentBlockedDialog(
    title: "Connexion requise",
    message: "Le paiement par ${modePaiement.label} nécessite une connexion "
             "internet. Veuillez réessayer lorsque le réseau sera disponible.",
  );
}
```

Côté backend, l'API doit également rejeter toute initiation de paiement digital provenant d'une opération marquée offline :

```java
if (request.getChannel() != PaymentChannel.AGENT
        && Boolean.TRUE.equals(request.getOffline())) {
    throw new InvalidOperationException(
        "Un paiement digital ne peut pas être initié en mode offline");
}
```

### 19.5 Ce qui est légitimement faisable offline (préparation uniquement)

L'app mobile (Flutter, dossier `verdentax/`) peut, en mode offline :

- consulter les `TaxeCollect` déjà synchronisées (cache SQLite) ;
- consulter l'historique des transactions déjà synchronisées ;
- consulter les reçus déjà générés ;
- scanner un QR pour **consultation** (résolution locale si déjà en cache) ;
- **préparer** une `CollectionOrder` en brouillon (statut `DRAFT`, jamais `PAID`) ;
- enregistrer l'opération dans une Sync Queue.

Au retour réseau :

```text
SQLite
   ↓
Sync Queue
   ↓
API
   ↓
Validation serveur
   ↓
PaymentProvider.initiatePayment(...)   ← c'est ici que le paiement devient réel
   ↓
PostgreSQL
   ↓
Kafka
```

> **IMPORTANT** : la `CollectionOrder` préparée offline reste en `DRAFT` tant que le provider n'a pas confirmé. Aucun reçu n'est généré offline pour un paiement digital. Aucune `TaxeCollect` n'est marquée `PAYE` offline pour un paiement digital.

### 19.6 Pièges à éviter absolument

Si on permettait à l'app de marquer une `TaxeCollect` comme payée sur la base d'une opération digitale locale offline, on créerait :

1. **Risque de double paiement** — le contribuable croit avoir payé, l'agent aussi, mais le provider n'a rien reçu.
2. **Risque de faux reçu** — un reçu généré offline n'a aucune valeur comptable pour un paiement digital.
3. **Risque de fraude** — un agent pourrait fabriquer des "paiements offline" sans débit réel.
4. **Réconciliation cauchemardesque** — impossible à rapprocher avec le provider.

### 19.7 Nuance : Store-and-Forward (avancé, hors périmètre V1)

Il existe un pattern plus sophistiqué appelé **Store-and-Forward** où l'agent initie un paiement Mobile Money offline via un **canal USSD local** (SDP du téléphone), puis rapproche au retour réseau.

**Cependant** :
- cela nécessite un accord technique avec l'opérateur (Orange/MTN/Moov CI) ;
- un identifiant USSD traçable ;
- ça reste fragile (pas de webhook garanti) ;
- ça complexifie énormément la réconciliation.

> **Décision V1** : Store-and-Forward **hors périmètre**. Le paiement digital exige le réseau au moment de la confirmation. Une éventuelle V2 pourra l'étudier si un accord opérateur est obtenu.

### 19.8 Récapitulatif

```text
[Offline]
  ├─ Espèces (agent)         → AUTORISÉ (déjà géré, reçu provisoire)
  ├─ Mobile Money / QR / RTP → REFUSÉ ("Connexion requise")
  ├─ Consultation            → AUTORISÉ (lecture cache SQLite)
  └─ Préparation brouillon   → AUTORISÉ (DRAFT, jamais PAYE)

[En ligne]
  └─ Tous modes              → AUTORISÉ (confirmation provider obligatoire)
```

---

## 20. Gestion des erreurs

Codes à prévoir (réutiliser `exceptions/` existant : `NotFoundException`, `InvalidOperationException`, `ConflictException`, `BusinessException` + `GlobalExceptionHandler`) :

```text
NETWORK_ERROR
TIMEOUT
PROVIDER_UNAVAILABLE
PAYMENT_DECLINED
PAYMENT_PENDING
INVALID_REFERENCE
AMOUNT_MISMATCH
DUPLICATE_REQUEST       -- via idempotency
EXPIRED_REQUEST
INVALID_SIGNATURE
WEBHOOK_REPLAY
UNKNOWN_TRANSACTION
```

Stratégie de retry avec backoff. **Ne jamais** retryer un paiement sans idempotence.

---

## 21. Observabilité

Ajouter (MDC / structured logging) :

- `correlationId` (généré à l'entrée API, propagé) ;
- `transactionReference` ;
- `providerTransactionId` ;
- `taxReference`.

Propagation : `API → PaymentService → PaymentProvider → Kafka → Receipt → Reconciliation`.

Métriques + alertes sur transactions bloquées (à brancher sur le `prometheus.yml` existant à la racine du repo).

---

## 22. Tests

### Tests unitaires

- `PaymentService`
- `PaymentProviderFactory`
- `PaymentStateMachine`
- `IdempotencyService` (Redis)
- `ReconciliationService`
- `ReceiptService`

### Tests d'intégration

- PostgreSQL (H2 déjà en scope test)
- Kafka (embedded ou Testcontainers)
- Redis (embedded ou Testcontainers)
- Keycloak (realm de test)
- `StubPaymentProvider` (sandbox, aucune IO réelle)

### Tests de sécurité

- webhook falsifié ;
- replay ;
- montant modifié ;
- référence modifiée ;
- double paiement ;
- JWT invalide ;
- accès non autorisé (rôles).

### Tests métier

```text
1 TaxeCollect → 1 paiement
1 TaxeCollect → plusieurs PaymentAttempt
1 TaxeCollect → plusieurs paiements partiels (remainingAmount)
paiement échoué → nouveau paiement
paiement réussi → Receipt → TaxeCollect.statut = PAYE
paiement réussi → réconciliation
paiement doublonné (idempotency)
remboursement
expiration CollectionOrder / RTP / QR
flux agent espèces offline (existant) toujours fonctionnel
```

> **Régression** : vérifier que les endpoints `/api/transactions` existants et le flux agent espèces offline continuent de fonctionner après refactor.

---

## 23. Livrables attendus (ordre)

### Étape 1 — Architecture

- diagramme du module Payment intégré à l'existant ;
- diagramme de séquence : Paiement direct, RTP, QR Code, Webhook PI-SPI ;
- diagramme de classes (entités nouvelles + extensions) ;
- modèle de données (extensions `TaxeCollect`/`Transaction` + nouvelles tables).

### Étape 2 — Base de données

- migrations Flyway `V12__` (TaxeCollect), `V13__` (Transaction), `V14__` (CollectionOrder + PaymentAttempt), `V15__` (PaymentRequest), `V16__` (PaymentProviderConfig + PaymentQRCode), `V17__` (Receipt + Refund), `V18__` (Reconciliation + Settlement) ;
- contraintes, index, clés uniques.

### Étape 3 — Backend Spring Boot (extensions)

- étendre `TaxeCollect`, `Transaction` (champs + getters/setters) ;
- étendre `ModePaiement`, `StatutTransaction` ;
- créer les nouvelles entités (toutes `extends Auditable`) ;
- créer repositories + DTO ;
- **ne pas** casser `TransactionService` / `TransactionController` existants.

### Étape 4 — Payment Provider

- `PaymentProvider` + `PaymentProviderFactory` ;
- `PISPIProvider` (avec `TODO` tant que la doc officielle PI-SPI n'est pas confirmée) ;
- `PSPProvider` ;
- `StubPaymentProvider` ;
- `PaymentProviderProperties` (config externalisée `application*.properties`).

### Étape 5 — API REST

- nouveaux controllers `PaymentController`, `CollectionOrderController`, `PaymentRequestController`, `PaymentQRCodeController`, `WebhookController`, `ReconciliationController`, `ReceiptController` ;
- `@PreAuthorize` avec rôles Keycloak existants + `CONTRIBUABLE`.

### Étape 6 — Webhooks

- `WebhookController` sécurisé (signature, idempotence, replay).

### Étape 7 — Kafka & Redis

- ajouter dépendances `pom.xml` ;
- producteurs d'événements ;
- `IdempotencyService` (Redis) ;
- config `application*.properties` (profiles `dev`, `docker`, `local`).

### Étape 8 — Flutter (`verdentax/`)

- écran détail `TaxeCollect` ;
- écran paiement (choix `ModePaiement` étendu) ;
- écran RTP ;
- scanner QR (`PaymentQRCode`) ;
- statut du paiement ;
- reçu ;
- historique.

### Étape 9 — Offline (extension)

- SQLite + Sync Queue côté Flutter ;
- conserver le flux agent espèces offline existant.

### Étape 10 — Tests

- unitaires + intégration + sécurité + métier + régression flux existant.

---

## 24. Règles impératives

1. **Ne pas recréer** les entités existantes (`TaxeCollect`, `Transaction`, `Contribuable`, `QRCodeContribuable`, `ClotureCaisse`) — les **étendre**.
2. **Ne pas casser** les endpoints `/api/transactions` ni le flux agent espèces/offline existant.
3. Toute nouvelle table = nouvelle migration Flyway (`V12__` et au-delà). `ddl-auto=validate` reste actif.
4. Toute nouvelle entité `extends Auditable` (cohérence avec l'existant).
5. Ne jamais inventer les spécifications PI-SPI — laisser `TODO` si la doc officielle n'est pas confirmée.
6. Séparer le domaine métier de l'intégration paiement (`PaymentProvider` abstraction).
7. Ne jamais considérer une redirection frontend comme preuve de paiement — webhooks serveur-to-serveur.
8. Implémenter l'idempotence (Redis + colonne `idempotency_key`).
9. Conserver séparément `TaxeCollect.reference`, `Transaction.transactionReference`, `providerTransactionId`, `providerRequestId`.
10. PostgreSQL est la source de vérité. Kafka = bus d'événements uniquement.
11. Ne jamais stocker de secrets en clair (`PaymentProviderConfig.credentialsRef` → Vault / env).
12. Ne jamais permettre au mobile de déterminer seul le montant dû — toujours relire depuis `TaxeCollect`.
13. Toutes les opérations financières doivent être auditables (`Auditable` + logs + Kafka).
14. Prévoir plusieurs PSP/providers dès le départ (`PaymentProviderFactory`).
15. Prévoir paiements partiels (`TaxeCollect.remainingAmount`), remboursements, annulations, échecs, doublons.
16. Compatible mobile offline **uniquement pour les paiements espèces** (extension de l'existant, pas refonte). Tout paiement digital (Mobile Money, QR, RTP, carte) exige le réseau au moment de la confirmation. L'app doit refuser d'initier un paiement digital offline. La préparation offline (brouillon `CollectionOrder` en `DRAFT`) est autorisée mais ne marque jamais une `TaxeCollect` comme `PAYE` et ne génère jamais de reçu tant que le provider n'a pas confirmé.
17. Toute opération financière doit être atomique et traçable.
18. **Java 17** (ne pas passer à 21 sans accord). Spring Boot 3.5.0.
19. Conserver la sécurité Keycloak + LDAP existante ; ajouter le rôle `CONTRIBUABLE` au realm `mairie` pour l'app mobile.
20. Respecter la structure de packages existante (`controllers`, `services`, `repositories`, `models`, `dto`, `config`, `security`, `utils`, `exceptions`) — sous-package `payment` pour le module paiement.

---

## 25. Résultat attendu

À la fin, fournir une solution complète permettant ce parcours, **en s'appuyant sur l'existant** :

```text
Mairie / Agent
   │
   ▼
TaxeCollect (existant, étendu avec reference + remainingAmount)
   │
   ▼
CollectionOrder (NOUVEAU)
   │
   ├───────────────┬───────────────┐
   ▼               ▼               ▼
Paiement direct    RTP           QR Code
(agent existant    (NOUVEAU)     (PaymentQRCode NOUVEAU,
 + app mobile)                    QRCodeContribuable conservé)
   │               │               │
   └───────────────┼───────────────┘
                   ▼
            PaymentProvider (NOUVEAU, abstrait)
             │           │
             ▼           ▼
          PI-SPI        PSP
             │           │
             └─────┬─────┘
                   ▼
         PaymentAttempt (NOUVEAU)
                   │
                   ▼
         Transaction (existante, ÉTENDUE)
                   │
                   ▼
         Confirmation (webhook serveur-to-serveur)
                   │
             ┌─────┴─────┐
             ▼           ▼
         Receipt      Reconciliation
         (NOUVEAU)       (NOUVEAU)
                         │
                         ▼
                  ClotureCaisse (existante) + Settlement (NOUVEAU)
                         │
                         ▼
                  Dashboard mairie
```

Le résultat doit être **production-ready**, sécurisé, testable, observable, extensible, et **rétro-compatible** avec le socle E-CollectTaxe existant.

> **Ordre de production** : commencer par **l'architecture détaillée du module Payment intégré à l'existant**, puis le **modèle de données (extensions + nouvelles tables)**, puis les **diagrammes de séquence des scénarios Paiement direct, RTP, QR Code et Webhook PI-SPI**, avant d'écrire le code.
