# E-Collecte Taxe Communale --- Distinction des fonctionnalités

## Superviseur de Zone vs Chef d'Équipe / Responsable de Quartier

**Version :** 1.0\
**Projet :** E-Collecte Taxe Communale\
**Périmètre :** Organisation territoriale, supervision, collecte et
contrôle

------------------------------------------------------------------------

## 1. Objectif

Ce document définit explicitement la séparation des responsabilités
entre :

-   **Superviseur de Zone** : responsable du pilotage et du contrôle
    d'une zone comprenant plusieurs quartiers.
-   **Chef d'Équipe / Responsable de Quartier** : responsable de
    l'organisation opérationnelle et du suivi quotidien d'un quartier.
-   **Agent Collecteur** : exécutant terrain affecté à un ou plusieurs
    secteurs selon les règles définies par la hiérarchie.

L'objectif est d'éviter qu'un superviseur ait à gérer directement
plusieurs centaines de contribuables et de créer une chaîne de
responsabilité claire :

> **ZONE → SUPERVISEUR → QUARTIERS → CHEFS D'ÉQUIPE → SECTEURS → AGENTS
> → CONTRIBUABLES**

------------------------------------------------------------------------

# 2. Principes de séparation

  -----------------------------------------------------------------------
  Dimension               Superviseur de Zone     Chef d'Équipe /
                                                  Responsable de Quartier
  ----------------------- ----------------------- -----------------------
  Périmètre               Toute sa zone           Un seul quartier

  Niveau                  Pilotage / supervision  Management opérationnel
                                                  terrain

  Quartiers visibles      Tous les quartiers de   Son quartier uniquement
                          sa zone                 

  Secteurs visibles       Tous les secteurs de sa Secteurs de son
                          zone                    quartier

  Contribuables visibles  Tous ceux de sa zone    Ceux de son quartier

  Agents visibles         Tous les agents de sa   Agents de son quartier
                          zone                    

  Affectation des agents  Autorité principale     Proposition /
                                                  organisation
                                                  opérationnelle

  Contrôle des activités  Global                  Quotidien et local

  Statistiques            Zone + comparaison      Quartier + secteurs
                          quartiers               

  Gestion des anomalies   Arbitrage et suivi      Détection et remontée

  Modification de la      Non                     Non
  structure territoriale                          

  Gestion globale des     Non                     Non
  utilisateurs                                    
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 3. SUPERVISEUR DE ZONE

## 3.1 Mission

Le Superviseur de Zone est responsable de la **performance globale de sa
zone**.

Il ne doit pas être considéré comme un agent collecteur supérieur chargé
de manipuler individuellement tous les contribuables.

Son rôle est principalement de :

1.  planifier ;
2.  affecter ;
3.  superviser ;
4.  contrôler ;
5.  analyser ;
6.  arbitrer ;
7.  corriger les dysfonctionnements ;
8.  rendre compte à la hiérarchie.

------------------------------------------------------------------------

## 3.2 Périmètre d'accès

Le Superviseur est rattaché à une zone.

Exemple :

``` text
Superviseur : SUP-Z02
Zone : ZONE 02

ZONE 02
├── Quartier A
│   ├── Secteur A1
│   ├── Secteur A2
│   └── Secteur A3
├── Quartier B
│   ├── Secteur B1
│   └── Secteur B2
└── Quartier C
    ├── Secteur C1
    └── Secteur C2
```

Il peut consulter l'ensemble de cette arborescence.

Il ne peut pas accéder aux données opérationnelles d'une autre zone,
sauf autorisation explicite d'un administrateur.

------------------------------------------------------------------------

## 3.3 Fonctionnalités du Superviseur

### A. Tableau de bord de zone

Le superviseur peut consulter :

-   nombre de quartiers ;
-   nombre de secteurs ;
-   nombre d'agents ;
-   nombre de contribuables ;
-   nombre de contribuables visités ;
-   nombre de contribuables non visités ;
-   nombre de nouveaux contribuables ;
-   montant des taxes encaissées ;
-   montant restant à recouvrer ;
-   taux de recouvrement ;
-   taux de couverture terrain ;
-   performance des quartiers ;
-   performance des équipes ;
-   anomalies signalées.

------------------------------------------------------------------------

### B. Gestion des quartiers de sa zone

Le superviseur peut :

-   consulter les quartiers ;
-   consulter les responsables de quartier ;
-   suivre l'activité de chaque quartier ;
-   comparer les performances des quartiers ;
-   identifier les quartiers en retard ;
-   suivre les objectifs de collecte ;
-   demander une action corrective.

Le superviseur **ne crée pas et ne supprime pas librement un quartier**.

La modification de la structure administrative doit relever de
l'administrateur habilité.

------------------------------------------------------------------------

### C. Affectation des responsables de quartier

Le superviseur peut, selon la politique retenue :

-   proposer un responsable ;
-   affecter un responsable à un quartier ;
-   remplacer un responsable ;
-   consulter l'historique des affectations.

Exemple :

``` text
ZONE 02
│
├── Quartier A → Responsable KOFFI
├── Quartier B → Responsable AMANI
└── Quartier C → Responsable YAO
```

------------------------------------------------------------------------

### D. Gestion opérationnelle des agents

Le superviseur peut :

-   consulter les agents de sa zone ;
-   consulter leur affectation ;
-   affecter un agent à un quartier ;
-   affecter ou réaffecter un agent à un secteur ;
-   contrôler les changements d'affectation ;
-   suivre la charge de travail ;
-   contrôler la performance des agents.

------------------------------------------------------------------------

### E. Contrôle des contribuables

Le superviseur peut consulter :

-   la liste des contribuables de sa zone ;
-   les contribuables par quartier ;
-   les contribuables par secteur ;
-   les nouveaux contribuables ;
-   les contribuables non visités ;
-   les contribuables en situation d'impayé ;
-   les contribuables présentant des anomalies.

Il peut effectuer des contrôles et demander une correction.

La suppression définitive d'un contribuable doit rester une fonction
administrative protégée.

------------------------------------------------------------------------

### F. Suivi de la collecte

Le superviseur peut suivre :

-   nombre de visites ;
-   nombre de recensements ;
-   nombre de déclarations ;
-   nombre de taxes émises ;
-   nombre de paiements ;
-   montant encaissé ;
-   montant restant ;
-   taux de recouvrement ;
-   évolution quotidienne, hebdomadaire et mensuelle.

------------------------------------------------------------------------

### G. Contrôle des paiements

Le superviseur peut :

-   consulter les paiements de sa zone ;
-   vérifier les encaissements ;
-   rechercher une opération ;
-   contrôler les écarts ;
-   identifier les opérations suspectes ;
-   suivre les paiements par agent ;
-   suivre les paiements par quartier.

Il ne doit pas pouvoir modifier silencieusement une transaction
financière.

Toute correction financière doit laisser une trace d'audit et,
idéalement, être soumise à une autorisation spécifique.

------------------------------------------------------------------------

### H. Gestion des anomalies

Le superviseur peut :

-   consulter les anomalies ;
-   affecter une anomalie à un responsable ;
-   demander une vérification ;
-   suivre le traitement ;
-   clôturer une anomalie après contrôle ;
-   escalader une anomalie à la hiérarchie.

Exemples :

-   contribuable introuvable ;
-   activité non déclarée ;
-   doublon ;
-   mauvais secteur ;
-   montant incohérent ;
-   paiement non rapproché ;
-   agent n'ayant pas effectué ses visites ;
-   contribuable contestant une taxation.

------------------------------------------------------------------------

# 4. CHEF D'ÉQUIPE / RESPONSABLE DE QUARTIER

## 4.1 Mission

Le Chef d'Équipe / Responsable de Quartier est responsable de la **mise
en œuvre opérationnelle dans son quartier**.

Il est le relais direct entre le Superviseur de Zone et les agents
collecteurs.

Son rôle est principalement :

> **Organiser → accompagner → contrôler → signaler → rendre compte**

Il ne pilote pas toute la zone.

------------------------------------------------------------------------

## 4.2 Périmètre d'accès

Le Responsable est rattaché à un quartier.

Exemple :

``` text
Responsable : CHEF-Q17
Quartier : Q17

QUARTIER Q17
├── Secteur Q17-A
├── Secteur Q17-B
└── Secteur Q17-C
```

Il ne doit voir que les données nécessaires à l'exécution de ses
missions dans ce quartier.

------------------------------------------------------------------------

# 5. Fonctionnalités du Responsable de Quartier

## A. Tableau de bord du quartier

Il peut consulter :

-   nombre de secteurs ;
-   nombre d'agents ;
-   nombre de contribuables ;
-   contribuables visités ;
-   contribuables non visités ;
-   nouveaux contribuables ;
-   paiements enregistrés ;
-   montant collecté ;
-   impayés ;
-   anomalies ;
-   progression quotidienne ;
-   performance de ses agents.

------------------------------------------------------------------------

## B. Organisation des agents

Le responsable peut :

-   consulter les agents de son quartier ;
-   connaître leur secteur ;
-   organiser leur planning ;
-   suivre leur activité ;
-   distribuer les tâches ;
-   contrôler les visites ;
-   signaler les absences ou insuffisances.

### Affectation

Selon la politique de sécurité choisie :

**Option recommandée :**

Le responsable peut **proposer** une affectation ou une réaffectation.

La validation définitive reste au Superviseur.

Exemple :

``` text
Responsable Q17
      │
      ├── Proposition
      │     Agent A → Secteur Q17-B
      │
      ▼
Superviseur Zone
      │
      └── Validation
```

Cette séparation évite qu'un responsable puisse déplacer librement les
agents et modifier la couverture territoriale sans contrôle.

------------------------------------------------------------------------

## C. Suivi des contribuables

Le responsable peut :

-   rechercher un contribuable ;
-   consulter sa fiche ;
-   consulter son historique de visites ;
-   consulter sa situation de paiement ;
-   identifier les contribuables non visités ;
-   identifier les nouveaux contribuables ;
-   signaler une erreur d'affectation ;
-   demander une correction.

Il ne doit pas pouvoir supprimer un contribuable.

------------------------------------------------------------------------

## D. Suivi des visites terrain

Le responsable peut contrôler :

-   qui a effectué la visite ;
-   quand la visite a été effectuée ;
-   le secteur concerné ;
-   le contribuable concerné ;
-   le résultat de la visite ;
-   les observations ;
-   les anomalies éventuelles.

Il peut également identifier les secteurs insuffisamment couverts.

------------------------------------------------------------------------

## E. Contrôle des collectes

Le responsable peut :

-   consulter les opérations de collecte de son quartier ;
-   vérifier les opérations réalisées par les agents ;
-   comparer les résultats entre secteurs ;
-   détecter les écarts ;
-   signaler une opération douteuse ;
-   suivre les paiements non rapprochés.

Il ne doit pas modifier directement une opération financière déjà
enregistrée.

------------------------------------------------------------------------

## F. Gestion des anomalies

Le responsable peut :

-   créer une anomalie ;
-   documenter l'anomalie ;
-   affecter une action à un agent ;
-   suivre sa résolution ;
-   transmettre l'anomalie au superviseur ;
-   ajouter un commentaire ;
-   joindre les éléments autorisés par l'application.

Exemple :

``` text
Anomalie
Secteur : Q17-B
Contribuable : C-00542
Problème : activité différente de celle enregistrée
Action : vérification terrain
Statut : EN_COURS
Responsable : Agent A
```

------------------------------------------------------------------------

# 6. Ce que le Responsable de Quartier NE DOIT PAS faire

Le Responsable ne doit pas pouvoir :

-   consulter les autres quartiers de la zone ;
-   consulter les autres zones ;
-   modifier la structure des zones ;
-   créer ou supprimer une zone ;
-   créer ou supprimer un quartier ;
-   modifier les règles fiscales ;
-   modifier les taux de taxation ;
-   supprimer définitivement un contribuable ;
-   supprimer une opération de paiement ;
-   modifier silencieusement un encaissement ;
-   gérer les comptes utilisateurs de la commune ;
-   modifier les rôles Keycloak ;
-   accéder aux données financières globales de la commune.

------------------------------------------------------------------------

# 7. Comparaison directe des pouvoirs

  Fonctionnalité                            Superviseur Zone   Responsable Quartier
  ---------------------------------------- ------------------ ----------------------
  Voir sa zone                                     ✅                   ❌
  Voir tous les quartiers de sa zone               ✅                   ❌
  Voir son quartier                                ✅                   ✅
  Voir les autres quartiers                        ✅                   ❌
  Voir les secteurs de sa zone                     ✅                   ❌
  Voir les secteurs de son quartier                ✅                   ✅
  Voir les contribuables de sa zone                ✅                   ❌
  Voir les contribuables de son quartier           ✅                   ✅
  Voir les agents de sa zone                       ✅                   ❌
  Voir les agents de son quartier                  ✅                   ✅
  Affecter responsable de quartier                 ✅                   ❌
  Proposer une affectation d'agent                 ✅                   ✅
  Valider affectation d'agent                      ✅                   ❌
  Suivre les visites                               ✅                   ✅
  Contrôler les collectes                          ✅                   ✅
  Consulter les paiements                          ✅                   ✅
  Modifier un paiement                            ❌\*                 ❌\*
  Créer une anomalie                               ✅                   ✅
  Traiter une anomalie                             ✅                   ✅
  Escalader une anomalie                           ✅                   ✅
  Statistiques quartier                            ✅                   ✅
  Statistiques zone                                ✅                   ❌
  Comparer les quartiers                           ✅                   ❌
  Modifier les règles fiscales                     ❌                   ❌
  Gérer les utilisateurs                           ❌                   ❌
  Gérer les rôles                                  ❌                   ❌
  Supprimer un contribuable                        ❌                   ❌

\* Toute correction financière doit passer par une procédure contrôlée
avec traçabilité et audit.

------------------------------------------------------------------------

# 8. Modèle d'autorisation recommandé

Les rôles ne doivent pas être utilisés seuls.

Il faut combiner :

> **ROLE + PÉRIMÈTRE TERRITORIAL**

Exemple :

``` text
Utilisateur
├── role = SUPERVISEUR_ZONE
└── zone_id = 2
```

Cet utilisateur peut accéder à :

``` text
ZONE 2
├── Quartier A
├── Quartier B
├── Quartier C
└── Quartier D
```

Mais pas à :

``` text
ZONE 1
ZONE 3
ZONE 4
```

Pour un responsable :

``` text
Utilisateur
├── role = RESPONSABLE_QUARTIER
└── quartier_id = 17
```

Accès :

``` text
QUARTIER 17
├── Secteur A
├── Secteur B
└── Secteur C
```

Mais pas :

``` text
QUARTIER 16
QUARTIER 18
```

------------------------------------------------------------------------

# 9. Permissions techniques recommandées

## Superviseur

``` text
VIEW_ZONE
VIEW_QUARTIERS
VIEW_SECTEURS
VIEW_CONTRIBUABLES_ZONE
VIEW_AGENTS_ZONE
VIEW_STATISTICS_ZONE
VIEW_PAYMENTS_ZONE
VIEW_VISITS_ZONE

ASSIGN_QUARTIER_MANAGER
ASSIGN_AGENT
REASSIGN_AGENT
VALIDATE_OPERATION
REVIEW_ANOMALY
ESCALATE_ANOMALY
```

## Responsable de quartier

``` text
VIEW_QUARTIER
VIEW_SECTEURS_QUARTIER
VIEW_CONTRIBUABLES_QUARTIER
VIEW_AGENTS_QUARTIER
VIEW_STATISTICS_QUARTIER
VIEW_VISITS_QUARTIER
VIEW_PAYMENTS_QUARTIER

PROPOSE_AGENT_ASSIGNMENT
SUPERVISE_AGENT
REGISTER_ANOMALY
REVIEW_ANOMALY
ESCALATE_ANOMALY
```

------------------------------------------------------------------------

# 10. Règle métier fondamentale

Le système doit appliquer la règle suivante :

``` text
SUPERVISEUR
    ↓
PILOTE LA ZONE

RESPONSABLE DE QUARTIER
    ↓
PILOTE LE TERRAIN DU QUARTIER

AGENT COLLECTEUR
    ↓
EXÉCUTE LA COLLECTE DANS SON SECTEUR
```

Le Superviseur **ne remplace pas le Responsable de Quartier**.

Le Responsable de Quartier **ne remplace pas le Superviseur**.

L'Agent Collecteur **ne remplace ni l'un ni l'autre**.

------------------------------------------------------------------------

# 11. Flux opérationnel recommandé

``` text
                    ADMINISTRATEUR
                          │
                          ▼
                    ZONE DE COLLECTE
                          │
                          ▼
                   SUPERVISEUR DE ZONE
                          │
            ┌─────────────┼─────────────┐
            ▼             ▼             ▼
       QUARTIER A     QUARTIER B    QUARTIER C
            │             │             │
            ▼             ▼             ▼
       RESPONSABLE     RESPONSABLE    RESPONSABLE
            │             │             │
       ┌────┼────┐   ┌────┼────┐   ┌────┼────┐
       ▼    ▼    ▼   ▼    ▼    ▼   ▼    ▼    ▼
     SEC-A SEC-B SEC-C ...
       │
       ▼
     AGENTS
       │
       ▼
   CONTRIBUABLES
```

------------------------------------------------------------------------

# 12. Principe de management

La plateforme doit permettre au Superviseur de répondre à :

> **« Ma zone est-elle correctement couverte et mes équipes
> atteignent-elles leurs objectifs ? »**

Le Responsable de Quartier doit pouvoir répondre à :

> **« Mes agents ont-ils correctement travaillé aujourd'hui et quels
> problèmes dois-je remonter ? »**

L'Agent Collecteur doit pouvoir répondre à :

> **« Quels contribuables dois-je traiter aujourd'hui et quelles
> opérations dois-je enregistrer ? »**

------------------------------------------------------------------------

# 13. Conclusion

La séparation recommandée est donc :

### SUPERVISEUR DE ZONE

**Pilotage + contrôle + affectation + analyse + arbitrage**

### RESPONSABLE DE QUARTIER / CHEF D'ÉQUIPE

**Organisation terrain + suivi des agents + contrôle quotidien +
remontée des anomalies**

### AGENT COLLECTEUR

**Recensement + visite + taxation selon règles + collecte + remontée
terrain**

Cette architecture permet de gérer une zone comprenant potentiellement
**500, 800 ou plusieurs milliers de contribuables** sans transformer le
Superviseur en gestionnaire individuel de chaque contribuable.

Le Superviseur travaille **par indicateurs, quartiers et secteurs**.

Le Responsable travaille **par secteurs, agents et opérations terrain**.

L'Agent travaille **par contribuables et visites**.

------------------------------------------------------------------------

# 14. Implémentation frontend (Vue 3)

**Version :** 1.1\
**Date :** 2026-09-11\
**Périmètre :** Frontend Vue 3 (`frontend/src`)

## 14.1 Rôles RBAC implémentés

Le rôle `RESPONSABLE_QUARTIER` a été ajouté au service de permissions
(`src/services/permissionService.js`) avec les permissions définies en
section 9 du présent document.

Chaîne hiérarchique complète implémentée :

``` text
ADMIN
  │
  ├── SUPERVISEUR (scope: zone_id)
  │     │
  │     ├── RESPONSABLE_QUARTIER (scope: quartier_id)
  │     │     │
  │     │     └── AGENT (scope: secteur_id)
  │     │           │
  │     │           └── CONTRIBUABLES
  │     │
  │     └── (vue globale sur tous les quartiers de sa zone)
  │
  └── TRESOR (validation financière)
```

## 14.2 Permissions du RESPONSABLE_QUARTIER

``` text
dashboard.view
quartiers.view           secteurs.view
agents.view              agents.propose_assignment    agents.supervise
contribuables.view
visites.view
payments.view            transactions.view            collection-orders.view
anomalies.view           anomalies.create             anomalies.manage        anomalies.escalate
taxes.view
reports.view             reports.export
```

> **Point clé :** Le responsable peut `agents.propose_assignment`
> (proposition) mais **pas** `agents.assign` (validation). La validation
> d\'affectation reste au Superviseur (`supervision.assign`).

## 14.3 Fichiers créés

### Service

  Fichier                          Description
  -------------------------------- --------------------------------------------------------------
  `services/responsableService.js` Service consolidé (dashboard, agents, visites, anomalies, propositions d\'affectation) avec données de fallback

### Vues

  Fichier                                  Route                       Fonctionnalité
  ---------------------------------------- --------------------------- ------------------------------------------------------------------
  `views/DashboardResponsable.vue`         `/dashboard-responsable`    Tableau de bord du quartier (secteurs, agents, contribuables, collecte, anomalies)
  `views/ResponsableAgents.vue`            `/responsable-agents`       Organisation des agents + **proposition** d\'affectation (validation superviseur) + signalement d\'absence
  `views/ResponsableVisites.vue`           `/responsable-visites`      Suivi des visites terrain + couverture par secteur
  `views/ResponsableAnomalies.vue`         `/responsable-anomalies`    Créer, documenter, transmettre au superviseur

### Modifications

  Fichier                          Modification
  -------------------------------- ---------------------------------------------------------
  `services/permissionService.js`  Ajout du rôle `RESPONSABLE_QUARTIER` + permissions `quartiers.assign_responsable` pour SUPERVISEUR/ADMIN + méthode `isResponsable()`
  `services/index.js`              Export de `responsableService`
  `components/Sidebar.vue`         Label du rôle + nouveau bloc menu « Mon Quartier »
  `main.js`                        4 nouvelles routes

## 14.4 Menu Sidebar du Responsable de Quartier

``` text
┌──────────────────────────────────┐
│     E-COLLECTE TAXE              │
│     RESP. QUARTIER               │
├──────────────────────────────────┤
│                                  │
│ 🏠 Tableau de bord               │
│                                  │
│ 🏢 Mon Quartier                  │
│    ├── Tableau de bord           │
│    ├── Mes agents                │
│    ├── Visites terrain           │
│    └── Anomalies                 │
│                                  │
│ 💰 Finances                      │
│    ├── Taxes                     │
│    └── Paiements                 │
│                                  │
│ ⚙️ Paramètres                    │
│                                  │
└──────────────────────────────────┘
```

> Le responsable ne voit **pas** les blocs Supervision, Pilotage,
> Géographie (zones/quartiers CRUD), Réconciliation, Reversements,
> Utilisateurs — conformément à la section 6 du présent document.

## 14.5 Flux de proposition d\'affectation

``` text
RESPONSABLE QUARTIER
      │
      ├── Proposition d'affectation
      │     Agent A → Secteur Q17-B
      │     (motif : équilibrage de charge)
      │
      ▼
SUPERVISEUR ZONE
      │
      └── Validation / Rejet
            (traçabilité dans l'audit)
```

Implémenté dans `ResponsableAgents.vue` :
- Bouton « Proposer une réaffectation » par agent
- Section « Propositions en attente » (validation superviseur)
- Message explicite : « Cette proposition doit être validée par le Superviseur de Zone »

## 14.6 Flux de transmission d\'anomalie

``` text
RESPONSABLE QUARTIER
      │
      ├── Créer une anomalie
      │     (secteur, contribuable, problème, action)
      │
      ├── Documenter l'anomalie
      │     (commentaire, éléments)
      │
      └── Transmettre au superviseur
            │
            ▼
      SUPERVISEUR ZONE
            │
            └── Traiter / Escalader / Clôturer
                  (vue Anomalies.vue du superviseur)
```

## 14.7 Séparation des pouvoirs — vérification frontend

| Fonction                          | AGENT | RESPONSABLE | SUPERVISEUR | TRESOR |
|-----------------------------------|:-----:|:-----------:|:-----------:|:------:|
| Voir son quartier                 | ❌    | ✅          | ✅          | ❌     |
| Voir tous les quartiers de la zone| ❌    | ❌          | ✅          | ❌     |
| Proposer une affectation d'agent  | ❌    | ✅          | ✅          | ❌     |
| Valider une affectation d'agent   | ❌    | ❌          | ✅          | ❌     |
| Créer une anomalie                | ❌    | ✅          | ✅          | ❌     |
| Traiter une anomalie              | ❌    | ✅          | ✅          | ❌     |
| Escalader une anomalie            | ❌    | ✅          | ✅          | ❌     |
| Valider un paiement               | ❌    | ❌          | ❌          | ✅     |
| Supprimer un contribuable         | ❌    | ❌          | ❌          | ❌     |
| Modifier les règles fiscales      | ❌    | ❌          | ❌          | ❌     |

## 14.8 État d\'avancement

| Fonctionnalité                    | État   | Vue / Composant                     |
|-----------------------------------|--------|-------------------------------------|
| Tableau de bord quartier          | ✅      | `DashboardResponsable.vue`          |
| Organisation des agents           | ✅      | `ResponsableAgents.vue`             |
| Proposition d'affectation          | ✅      | `ResponsableAgents.vue`             |
| Signalement d'absence             | ✅      | `ResponsableAgents.vue`             |
| Suivi des visites terrain         | ✅      | `ResponsableVisites.vue`            |
| Couverture par secteur            | ✅      | `ResponsableVisites.vue`            |
| Suivi des contribuables           | ✅      | `ResponsableContribuables.vue`      |
| Fiche contribuable + historique   | ✅      | `ResponsableContribuables.vue`      |
| Signalement erreur d'affectation | ✅      | `ResponsableContribuables.vue`      |
| Contrôle des collectes            | ✅      | `ResponsableCollectes.vue`           |
| Comparaison entre secteurs        | ✅      | `ResponsableCollectes.vue`          |
| Signalement opération douteuse    | ✅      | `ResponsableCollectes.vue`          |
| Créer une anomalie                | ✅      | `ResponsableAnomalies.vue`          |
| Documenter une anomalie           | ✅      | `ResponsableAnomalies.vue`          |
| Transmettre au superviseur        | ✅      | `ResponsableAnomalies.vue`          |
| Rapports quartier (PDF/Excel)     | ✅      | `ResponsableRapports.vue`           |
| Affectation responsable → quartier| ✅      | `SupervisionResponsables.vue`       |
| Validation propositions d'affect. | ✅      | `SupervisionResponsables.vue`       |
| Historique des affectations       | ✅      | `SupervisionResponsables.vue`       |
| Scope territorial frontend        | ✅      | `services/territorialScope.js`      |

Légende : ✅ Implémenté · ⏳ À implémenter

## 14.9 Helper de scope territorial (frontend)

Le fichier `src/services/territorialScope.js` fournit les utilitaires
pour gérer le scope territorial côté frontend :

``` javascript
import { getTerritorialScope, canAccessEntity, withScope, filterByScope }
  from '@/services/territorialScope'

// Récupérer le scope de l'utilisateur courant
const scope = getTerritorialScope()
// → { role: 'RESPONSABLE_QUARTIER', quartierId: 17, scopeType: 'quartier' }

// Vérifier l'accès à une entité
canAccessEntity(contribuable)  // → true/false

// Enrichir les paramètres API avec le scope
const params = withScope({ page: 1 })
// → { page: 1, quartier_id: 17 }

// Filtrer une liste d'entités côté frontend (double sécurité)
const visibles = filterByScope(contribuables, { quartierId: 'quartier_id' })
```

Le scope est lu depuis :

1. L\'objet `user` de `authService` (priorité)
2. Le token JWT décodé (claims `zone_id`, `quartier_id`, `secteur_id`)
3. `localStorage` (fallback)

> **Note backend :** Le scope territorial doit être **également** appliqué
> côté backend (Keycloak → token claims → filtres API). Le filtrage
> frontend est une sécurité supplémentaire, pas une sécurité principale.

## 14.10 Prochaines étapes recommandées (backend)

1. **Keycloak** : injecter les claims `zone_id`, `quartier_id`,
   `secteur_id` dans le token JWT selon le rôle de l\'utilisateur.
2. **API** : ajouter un filtre automatique sur tous les endpoints
   `/api/taxcollect/responsable/*` et `/api/taxcollect/supervision/*`
   basé sur les claims du token.
3. **Endpoints** : créer les endpoints backend correspondant aux méthodes
   du `responsableService.js` et des nouvelles méthodes du
   `superviseurService.js` (responsables quartier, propositions
   d\'affectation, rapports export).
4. **Audit** : tracer toutes les affectations/remplacements de responsables
   dans le journal d\'audit immuable.
