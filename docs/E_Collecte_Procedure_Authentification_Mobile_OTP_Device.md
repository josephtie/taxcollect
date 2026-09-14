# E-Collecte Taxe Communale
## Procédure d’authentification mobile, OTP et enrôlement du terminal

**Version :** 1.0

## 1. Objectif

Cette procédure décrit la première connexion et les connexions suivantes des agents collecteurs, responsables de quartier.

Elle garantit que l’accès dépend de :

- un numéro de téléphone reconnu ;
- un code OTP à usage unique ;
- un mot de passe ;
- un terminal autorisé ;
- un rôle ;
- un périmètre territorial ou financier.

## 2. Parcours de première connexion

```text
Ouverture de l’application
        ↓
Saisie du numéro de téléphone
        ↓
Vérification du numéro par le backend
        ↓
Génération d’un OTP
        ↓
Stockage temporaire de l’OTP dans Redis
        ↓
Envoi du SMS par un prestataire SMS
        ↓
Saisie du code OTP
        ↓
Validation du code par le backend
        ↓
Enrôlement du téléphone
        ↓
Enregistrement du Device ID
        ↓
Création du mot de passe
        ↓
Activation du compte
        ↓
Chargement du rôle et du périmètre
        ↓
Accès à l’espace utilisateur
```

## 3. Étape 1 — Saisie du numéro

L’application affiche :

```text
E-COLLECTE TAXE COMMUNALE

Première connexion

Numéro de téléphone
[____________________]

[ Continuer ]
```

L’utilisateur ne choisit pas son rôle. Le rôle est déterminé par le backend.

Requête :

```http
POST /api/auth/first-login/request-otp
```

Exemple :

```json
{
  "phoneNumber": "+2250700000000",
  "deviceId": "device-generated-id"
}
```

Le backend vérifie :

- format du numéro ;
- existence du numéro ;
- compte actif ;
- autorisation de première connexion ;
- absence d’un autre terminal actif ;
- limitation des demandes OTP.

Si le numéro n’est pas reconnu, le système affiche :

> Ce numéro n’est pas reconnu. Veuillez contacter l’administrateur de la commune.

## 4. Étape 2 — Génération et envoi de l’OTP

Le backend génère un code aléatoire à usage unique.

Exemple :

```text
OTP : 583921
Validité : 5 minutes
```

Redis conserve temporairement les données nécessaires à la validation :

```text
ecollecte:otp:first-login:+2250700000000
```

Exemple logique :

```json
{
  "otpHash": "hash-du-code",
  "userId": 125,
  "deviceId": "device-generated-id",
  "attempts": 0,
  "expiresAt": "2026-09-11T13:05:00Z"
}
```

Le code OTP en clair ne doit pas être conservé durablement.

Redis ne transmet pas le SMS. Le flux est :

```text
Backend → Redis → Prestataire SMS → Téléphone
```

Le SMS peut contenir :

```text
E-Collecte : votre code de première connexion est 583921.
Ce code expire dans 5 minutes. Ne le communiquez à personne.
```

## 5. Étape 3 — Validation de l’OTP

L’application affiche :

```text
Un code a été envoyé par SMS.

Code OTP
[______]

[ Valider ]
[ Renvoyer le code ]
```

Requête :

```http
POST /api/auth/first-login/verify-otp
```

Exemple :

```json
{
  "phoneNumber": "+2250700000000",
  "otp": "583921",
  "deviceId": "device-generated-id"
}
```

Le backend vérifie :

- OTP existant ;
- OTP non expiré ;
- code correct ;
- nombre de tentatives ;
- correspondance du terminal ;
- compte toujours actif.

Si le code est correct :

```text
OTP validé
        ↓
OTP invalidé
        ↓
Enrôlement autorisé
```

Si le code est incorrect ou expiré :

> Code incorrect ou expiré.

## 6. Limites de sécurité OTP

Règles recommandées :

- maximum 5 tentatives par code ;
- blocage temporaire après dépassement ;
- maximum 3 demandes sur une période définie ;
- délai avant renvoi ;
- invalidation de l’ancien code lors d’un nouveau renvoi ;
- journalisation des tentatives ;
- alerte en cas de comportement anormal.

## 7. Étape 4 — Enrôlement du téléphone

Après validation de l’OTP, le backend associe le terminal au compte.

Informations recommandées :

```text
user_device
├── id
├── user_id
├── device_id
├── installation_id
├── imei éventuel
├── manufacturer
├── model
├── os
├── app_version
├── status
├── enrolled_at
├── last_seen_at
├── revoked_at
├── revoked_by
└── revocation_reason
```

Le système doit privilégier un Device ID applicatif et un identifiant d’installation sécurisé.

L’IMEI peut être enregistré lorsqu’il est accessible, mais il ne doit pas être l’unique mécanisme de sécurité.

## 8. Règle d’un seul téléphone

Pour un agent collecteur :

```text
1 compte agent = 1 terminal actif
```

Exemple :

```text
Agent KOFFI
├── Téléphone A → ACTIVE
└── Téléphone B → REFUSÉ
```

Si un deuxième téléphone est présenté :

> Ce compte est déjà associé à un autre appareil. Veuillez contacter l’administrateur.

Aucune association automatique ne doit être effectuée.

## 9. Étape 5 — Création du mot de passe

L’application affiche :

```text
Créer votre mot de passe

Nouveau mot de passe
[____________________]

Confirmer le mot de passe
[____________________]

[ Enregistrer ]
```

Le système doit appliquer une politique comprenant :

- longueur minimale ;
- confirmation identique ;
- refus des mots de passe simples ;
- refus d’un mot de passe contenant le numéro de téléphone ;
- stockage sous forme de hash sécurisé ;
- absence de conservation en clair.

Le mot de passe doit être géré par Keycloak ou par le fournisseur d’identité retenu.

## 10. Étape 6 — Affichage du périmètre

Après activation, l’application affiche les informations déterminées par le backend.

### Agent collecteur

```text
Compte activé

Rôle : Agent collecteur
Zone : Zone 02
Quartier : Quartier 17
Secteur : Secteur 17-B

[ Accéder à mon espace ]
```

### Responsable de quartier

```text
Compte activé

Rôle : Responsable de quartier
Zone : Zone 02
Quartier : Quartier 17
```

### Superviseur de zone

```text
Compte activé

Rôle : Superviseur de zone
Zone : Zone 02
```

### Trésorier

```text
Compte activé

Rôle : Trésorier
Périmètre : Commune
```

L’utilisateur ne peut pas modifier lui-même son affectation. Il peut signaler une erreur à l’administrateur.

## 11. Connexions suivantes

Le parcours normal est :

```text
Ouverture application
        ↓
Identification du terminal
        ↓
Compte actif ?
        ↓
Terminal autorisé ?
        ↓
Authentification
        ↓
Vérification du rôle et du périmètre
        ↓
Accès au tableau de bord
```

Le mobile peut proposer un PIN local ou la biométrie pour déverrouiller rapidement une session déjà enrôlée.

La biométrie et le PIN ne remplacent pas l’authentification initiale.

## 12. Révocation d’un téléphone

Un administrateur habilité peut révoquer un terminal pour :

- perte ;
- vol ;
- panne ;
- changement de téléphone ;
- suspicion de compromission ;
- départ de l’agent ;
- suspension du compte.

Procédure :

```text
Recherche de l’agent
        ↓
Consultation des terminaux
        ↓
Sélection du terminal
        ↓
Révocation avec motif
        ↓
Terminal = REVOKED
        ↓
Invalidation des sessions selon la politique retenue
```

Exemple :

```text
Agent : KOFFI
Terminal : Samsung A25
Statut : REVOKED
Motif : Téléphone perdu
```

Message affiché :

> Cet appareil n’est plus autorisé. Veuillez contacter l’administrateur.

La révocation doit être contrôlée par le backend.

## 13. Réenrôlement d’un nouveau téléphone

```text
Ancien terminal révoqué
        ↓
Autorisation de réenrôlement
        ↓
Nouveau téléphone
        ↓
Numéro reconnu
        ↓
OTP validé
        ↓
Nouveau Device ID
        ↓
Nouveau terminal ACTIVE
```

Le compte, le rôle, l’affectation et l’historique métier sont conservés.

Seul le terminal autorisé est remplacé.

## 14. Modèle de données utilisateur

```text
app_user
├── id
├── keycloak_user_id
├── nom
├── prenom
├── telephone
├── role
├── commune_id
├── zone_id
├── quartier_id
├── secteur_id
├── statut
├── premiere_connexion
├── created_at
└── updated_at
```

## 15. Journalisation

Actions à enregistrer :

```text
OTP_REQUESTED
OTP_SENT
OTP_VERIFIED
OTP_FAILED
FIRST_LOGIN_COMPLETED
DEVICE_ENROLLED
DEVICE_REJECTED
DEVICE_REVOKED
LOGIN_SUCCESS
LOGIN_FAILED
PASSWORD_CREATED
PASSWORD_CHANGED
```

Le journal doit contenir notamment :

- utilisateur ;
- terminal ;
- date et heure ;
- résultat ;
- adresse IP éventuelle ;
- motif d’échec ou de révocation.

## 16. Contrôles backend obligatoires

À chaque demande sensible, vérifier :

```text
Compte actif
+
Rôle valide
+
Terminal autorisé
+
Terminal associé au bon utilisateur
+
Périmètre territorial valide
+
Session valide
+
Permission suffisante
```

Le backend doit protéger les données même si un utilisateur tente de modifier une URL ou d’appeler directement une API.

## 17. Règle finale

La sécurité repose sur la combinaison suivante :

```text
Numéro de téléphone
        +
OTP
        +
Mot de passe
        +
Terminal autorisé
        +
Rôle
        +
Périmètre
        =
Accès sécurisé à E-Collecte
```

Répartition des responsabilités :

```text
Keycloak
→ identité, authentification et rôles

Redis
→ stockage temporaire des OTP et limitations

Prestataire SMS
→ transmission des codes

PostgreSQL
→ utilisateurs, terminaux, affectations et règles métier

Spring Security
→ contrôle réel des autorisations

Application mobile
→ interface et expérience utilisateur
```

La règle métier principale est :

> Un agent ne peut accéder à E-Collecte que si son compte est actif, son authentification est valide, son terminal est autorisé et son affectation est déterminée par le backend.
