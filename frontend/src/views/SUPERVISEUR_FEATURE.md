# 🟦 Module Superviseur de Zone — E-CollecteTaxe

## 📋 Vue d'ensemble

Pour **E-CollecteTaxe**, le **Superviseur de zone** est le niveau intermédiaire entre les agents de collecte et l'administration communale / trésorerie.

Son rôle n'est pas simplement de « voir les agents » : il doit **planifier, affecter, contrôler, valider, corriger les anomalies et piloter le recouvrement de sa zone**, sans disposer des droits d'un administrateur ou d'un trésorier.

Ce document décrit le périmètre fonctionnel cible du module Superviseur et le met en regard avec l'état actuel du frontend Vue (`frontend/src`).

---

## 🏗️ Architecture des rôles (RBAC)

```text
                    ADMIN
                      │
          ┌───────────┴───────────┐
          │                       │
     SUPERVISEUR              TRÉSORIER
       ZONE                       │
          │                       │
     ┌────┼────┐                  │
     │    │    │                  │
   AGENT AGENT AGENT          ENCAISSEMENTS
     │    │    │
     └────┼────┘
          │
     CONTRIBUABLES
```

Rôles définis dans `src/services/permissionService.js` : `ADMIN`, `SUPERVISEUR`, `TRESOR`, `AGENT`, `CONTRIBUABLE`.

### Permissions du rôle `SUPERVISEUR` (existant)

```text
dashboard.view          agents.view            agents.assign         agents.unassign
zones.view              zones.supervise        transactions.view     transactions.supervise
cloture.view            cloture.supervise      supervision.view      supervision.assign
supervision.unassign    taxes.view             reports.view          reports.export
payments.view           collection-orders.view receipts.view         reconciliation.view
```

> Recommandation : ajouter un **scope territorial** (`SUPERVISEUR_ZONE_03`) côté Keycloak/RBAC, pour qu'un superviseur ne puisse travailler que sur sa zone. C'est plus robuste que des rôles globaux seuls.

---

## 🎯 Les 8 responsabilités fondamentales

| # | Responsabilité | Description |
|---|----------------|-------------|
| 1 | **PLANIFIER** | Organiser les tournées et objectifs |
| 2 | **AFFECTER** | Agents ↔ secteurs ↔ contribuables |
| 3 | **SUIVRE** | Activité terrain en temps quasi réel |
| 4 | **CONTRÔLER** | Visites, paiements, GPS, synchronisation |
| 5 | **VALIDER** | Nouveaux contribuables, évaluations, anomalies |
| 6 | **RELANCER** | Impayés et promesses de paiement |
| 7 | **ANALYSER** | Performance, couverture, recouvrement |
| 8 | **ALERTER** | Anomalies, fraudes potentielles, problèmes terrain |

---

## 🧭 Menu cible du Superviseur

```text
┌──────────────────────────────────┐
│     E-COLLECTE TAXE              │
│     SUPERVISEUR ZONE             │
├──────────────────────────────────┤
│ 🏠 Tableau de bord               │
│ 🗺️ Carte de ma zone              │
│ 👥 Mes agents                    │
│ 🏢 Contribuables                 │
│ 📋 Tournées                       │
│ 💰 Recouvrement                  │
│ ⚠ Anomalies                      │
│ 🔄 Synchronisation               │
│ 📢 Réclamations                  │
│ 🔔 Notifications                 │
│ 📊 Rapports                      │
│ 📝 Audit                         │
│ ⚙️ Paramètres opérationnels      │
└──────────────────────────────────┘
```

### État actuel du menu (`src/components/Sidebar.vue`)

Le superviseur voit actuellement les blocs filtrés par permission :

- **Tableau de bord** → `/dashboard`
- **Acteurs** → Contribuables, Collecteurs (pas Utilisateurs — réservé `settings.manage`)
- **Supervision** → Supervision, Analyse Agents, Analyse Zones, Carte Recensement
- **Géographie** → Zones, Quartiers, Secteurs, Carte Territoriale
- **Finances** → Taxes, Avis d'imposition, Paiements, Réconciliation, Reversements
- **Paramètres** → `/settings`

> Manquants par rapport à la cible : **Tournées**, **Recouvrement (impayés/promesses)**, **Anomalies**, **Synchronisation**, **Réclamations**, **Notifications**, **Audit**.

---

## 1. Tableau de bord de la zone

À la connexion :

```text
SUPERVISEUR — ZONE 03
────────────────────────────────────

👥 AGENTS
Agents actifs                 12
Agents connectés               9
Agents hors ligne              3

🏢 CONTRIBUABLES
Total                         1 842
Visités aujourd'hui             386
Payés                            271
Impayés                          95
À revisiter                      20

💰 RECOUVREMENT
Objectif                  4 500 000 F
Collecté                  3 275 000 F
Taux                         72,8 %

⚠ ANOMALIES
Paiements à vérifier             4
Conflits de synchronisation      3
Visites suspectes                2
```

> **Frontend** : `Dashboard.vue` existe mais est générique. À spécialiser par rôle avec un tableau de bord « zone » pour le superviseur (KPI agents connectés, recouvrement, anomalies).

---

## 2. Gestion des agents de sa zone

Le superviseur peut consulter :

- liste des agents
- agent actif/inactif
- secteur affecté
- dernière connexion
- dernière synchronisation
- nombre de contribuables affectés
- nombre de visites
- montant collecté
- taux de recouvrement
- anomalies
- position GPS si la politique communale l'autorise

### Fiche agent

```text
AGENT : AG-0012

Secteur : France 02
Statut : ACTIF
Dernière synchro : 10:28

Contribuables : 156
Visités : 124
Payés : 89

Collecte :
Aujourd'hui       425 000 F
Cette semaine   2 150 000 F

[ VOIR ACTIVITÉ ]
[ VOIR CARTE ]
[ RÉAFFECTER ]
[ SUSPENDRE ]
```

> **Frontend** : `Agents.vue` (liste) et `Supervision.vue` (affectation par zone) existent. La fiche agent détaillée (activité, carte, réaffectation, suspension) reste à enrichir.

---

## 3. Affectation des agents

Le superviseur peut affecter un agent à :

- une zone
- un quartier
- un secteur
- une tournée
- une catégorie de contribuables

Exemple :

```text
ZONE 03

Quartier France
 ├── Secteur 01 → Agent A
 ├── Secteur 02 → Agent B
 └── Secteur 03 → Agent C

Quartier Impérial
 ├── Secteur 01 → Agent D
 └── Secteur 02 → Agent E
```

Avec possibilité de :

- affectation temporaire
- remplacement
- transfert
- répartition de charge
- désaffectation

> **Frontend** : `Supervision.vue` + `AgentAffectationModal.vue` gèrent l'affectation/désaffectation d'agents à une zone (bulk, pagination, recherche). Permissions `supervision.assign` / `supervision.unassign`. L'affectation fine par quartier/secteur/tournée reste à ajouter.

---

## 4. Planification des tournées

Le superviseur peut créer une tournée :

```text
TOURNÉE #2026-0911-03

Agent : AG-0012
Zone : Zone 03

Contribuables :
☐ ETS KOUASSI
☐ MAQUIS LA PAIX
☐ GARAGE ABC
☐ BOUTIQUE YAO
☐ ETS N'GUESSAN

Objectif : 250 000 F
Date : 11/09/2026
```

Il peut également redistribuer les contribuables entre agents.

> **Frontend** : **Non implémenté**. Nouvelle vue `Tournees.vue` à créer (CRUD tournées, affectation contribuables, objectif, date).

---

## 5. Carte opérationnelle de la zone

Fonction majeure du superviseur. La carte affiche :

- limites de la zone
- quartiers
- secteurs
- agents
- contribuables
- contribuables payés
- impayés
- nouveaux contribuables
- points de collecte
- activités non encore recensées

### Filtres

```text
☑ Agents
☑ Contribuables
☑ Impayés
☑ Payés
☑ Non visités
☑ Nouveaux
☑ Anomalies
```

Le superviseur dispose ainsi d'une **vision géographique du recouvrement**.

> **Frontend** : `CarteTerritoriale.vue`, `CarteRecensement.vue`, `InteractiveMap.vue`, `TerritoryMap.vue` existent (Leaflet/OpenStreetMap). À enrichir avec les filtres payés/impayés/nouveaux/anomalies et la couverture par secteur.

---

## 6. Suivi en temps réel des agents

Lorsque les agents sont online :

```text
AGENT        SECTEUR       STATUT       VISITES
──────────────────────────────────────────────
AG-001       France 01     🟢           32
AG-002       France 02     🟢           27
AG-003       Impérial      🔴           14
AG-004       Mockeyville   🟢           31
```

Le superviseur peut voir :

- dernière position
- dernière activité
- dernière synchronisation
- nombre de visites
- paiements enregistrés

> ⚠️ La localisation doit être limitée à ce qui est nécessaire au contrôle opérationnel et encadrée par les règles de la commune.

> **Frontend** : Tableau de suivi temps réel à ajouter dans `Supervision.vue` (statut connecté, visites, synchro).

---

## 7. Suivi des visites

Le superviseur peut contrôler les visites :

```text
11/09/2026

Agent       Visites    Payés    Refus    Absents
AG-001          32       24        3        5
AG-002          27       21        2        4
AG-003          14        8        4        2
```

Il peut ouvrir le détail :

- date
- heure
- GPS
- contribuable
- résultat
- observation
- montant éventuellement encaissé

> **Frontend** : `AnalyseAgents.vue` fournit déjà la comparaison de performance par agent. Le détail visite (date/heure/GPS/résultat/observation) reste à ajouter.

---

## 8. Validation des nouveaux contribuables

Un agent découvre un établissement (ex. *Restaurant Chez Aya*) et crée la fiche. Le superviseur reçoit :

```text
🟠 NOUVEAU CONTRIBUABLE

Restaurant Chez Aya
Activité : Restaurant
Secteur : France 03

Base imposable proposée :
150 000 FCFA

GPS :
5.20xxxx, -3.81xxxx

[ APPROUVER ]
[ MODIFIER ]
[ REJETER ]
```

Cela permet de conserver un contrôle sur la qualité du référentiel fiscal.

> **Frontend** : Flux de validation à ajouter (file d'attente des nouveaux contribuables, approbation/modification/rejet).

---

## 9. Validation des évaluations

Règle définie pour E-CollecteTaxe :

```text
baseImposable renseignée
        ↓
utiliser la base
        ↓
sinon estimation activité
        ↓
calcul taxe
```

Le superviseur contrôle les cas particuliers :

```text
Activité : Commerce
Base automatique : 250 000 F

Agent propose :
Base : 600 000 F

Motif :
Grande surface commerciale

[ VALIDER ]
[ DEMANDER JUSTIFICATION ]
[ REJETER ]
```

> **Frontend** : `Assessments.vue` existe (vue). Le workflow de validation superviseur (proposition agent → validation/rejet) reste à ajouter.

---

## 10. Contrôle des paiements

Le superviseur peut voir les paiements de sa zone :

- paiements du jour
- paiements espèces
- Mobile Money
- paiements électroniques
- paiements partiels
- paiements en attente
- paiements offline
- paiements synchronisés

> ⚠️ Il ne doit **pas** pouvoir supprimer un paiement. Une correction doit générer une opération d'audit.

> **Frontend** : `Payments.vue`, `Transactions.vue` existent (vue). Le rôle `SUPERVISEUR` n'a pas `payments.cancel`/`payments.refund` — conforme à la règle « pas de suppression ».

---

## 11. Contrôle des paiements offline

```text
PAIEMENT OFFLINE

Agent : AG-003
Contribuable : ETS YAO
Montant : 25 000 F
Heure locale : 09:42
Synchronisé : 10:17

Statut :
🟠 À contrôler
```

Le superviseur peut accepter ou signaler l'opération.

> **Frontend** : `Reconciliation.vue` existe. Le marquage « à contrôler / accepté / signalé » des paiements offline reste à ajouter.

---

## 12. Gestion des anomalies

Boîte ⚠ Anomalies :

- doublon contribuable
- paiement suspect
- montant inhabituel
- GPS incohérent
- visite trop rapide
- activité inexistante
- contribuable affecté à deux agents
- paiement offline en conflit
- synchronisation échouée
- reçu non généré
- écart de caisse déclaré
- agent inactif

> **Frontend** : **Non implémenté**. Nouvelle vue `Anomalies.vue` à créer (liste, filtres, traitement, statut).

---

## 13. Contrôle anti-fraude

Indicateurs automatiques :

```text
⚠ ANOMALIE

Agent AG-002

18 paiements
tous enregistrés en moins de 12 minutes

→ Vérification recommandée
```

Ou :

```text
⚠ GPS

Agent : AG-004

Visite déclarée :
Secteur France

Position :
2,8 km hors secteur

→ À contrôler
```

Le système ne condamne pas l'agent : il **signale**.

> **Frontend** : Règles de détection à implémenter côté backend + vue de signalement dans `Anomalies.vue`.

---

## 14. Gestion des impayés

```text
IMPAYÉS ZONE 03

Total contribuables : 418

Montant dû :
12 750 000 F

Collecté :
7 800 000 F

Reste :
4 950 000 F
```

Filtres :

- gros débiteurs
- ancienneté
- quartier
- secteur
- agent
- activité

> **Frontend** : **Non implémenté**. Nouvelle vue `Recouvrement.vue` (impayés, filtres, relances).

---

## 15. Relance des contribuables

```text
ETS KOFFI
Dette : 75 000 F

Agent responsable : AG-002

Action :
[ PLANIFIER VISITE ]
[ ASSIGNER AGENT ]
[ PROMESSE DE PAIEMENT ]
```

> **Frontend** : **Non implémenté**. À intégrer dans `Recouvrement.vue`.

---

## 16. Gestion des promesses de paiement

```text
PROMESSES

Aujourd'hui       14
Échéance demain    8
En retard          6

Montant :
1 850 000 F
```

Le superviseur peut réaffecter les relances.

> **Frontend** : **Non implémenté**. Nouvelle vue `Promesses.vue` (suivi, échéances, retard, réaffectation).

---

## 17. Réaffectation des contribuables

Exemple : l'agent A a 300 contribuables, l'agent B seulement 80.

```text
AGENT A
300 contribuables

↓ sélectionner 50

AGENT B
+50

Nouvelle charge :
130
```

Cela permet d'équilibrer le travail.

> **Frontend** : Le bulk assign/unassign existe dans `Supervision.vue`. La **réaffectation de contribuables** (et non d'agents) reste à ajouter.

---

## 18. Gestion des secteurs

Modèle hiérarchique :

```text
ZONE
 ↓
QUARTIER
 ↓
SECTEUR
 ↓
AGENT
```

Couverture :

```text
ZONE 03

Secteur 01    94 %
Secteur 02    81 %
Secteur 03    47 % ⚠
Secteur 04    72 %
```

Les secteurs sous-performants apparaissent immédiatement.

> **Frontend** : `Zones.vue`, `Quartiers.vue`, `Secteurs.vue` existent. L'indicateur de taux de couverture par secteur reste à ajouter.

---

## 19. Objectifs de collecte

```text
OBJECTIF ZONE

Prévision :     25 000 000 F
Collecté :      18 500 000 F

Taux :              74 %

Jours restants :     8

Projection :
22 700 000 F ⚠
```

> **Frontend** : **Non implémenté**. À ajouter dans le tableau de bord superviseur (objectif, réalisé, projection).

---

## 20. Performance des agents

Classement **interne à la zone** :

```text
PERFORMANCE

1. AG-004     92 %
2. AG-001     87 %
3. AG-008     81 %
4. AG-003     69 %
5. AG-007     51 % ⚠
```

> Recommandation : privilégier un **tableau de pilotage** plutôt qu'un classement « compétitif ».

> **Frontend** : `AnalyseAgents.vue` fournit déjà la comparaison de performance par agent.

---

## 21. Rapports

### Rapport journalier
- visites, paiements, montants, impayés, nouveaux contribuables, anomalies

### Rapport hebdomadaire
- évolution du recouvrement, performance agents, couverture territoriale

### Rapport mensuel
- objectif, réalisé, taux, reste à recouvrer, comparaison période précédente

Formats : **PDF**, **Excel**, **CSV**.

> **Frontend** : Permissions `reports.view` / `reports.export` présentes pour `SUPERVISEUR`. Vue de génération/export à ajouter.

---

## 22. Rapport de tournée

```text
TOURNÉE #2026-0911

Contribuables : 40
Visités : 37
Payés : 28
Absents : 5
Refus : 2
À revoir : 2

Montant attendu : 850 000 F
Collecté :        625 000 F

Taux : 73,5 %
```

> **Frontend** : Dépend de la vue `Tournees.vue` (à créer).

---

## 23. Communication avec les agents

Le superviseur peut envoyer :

- instructions
- messages
- alertes
- demandes de justification
- changement de tournée
- changement d'affectation

Exemple :

> « Tous les contribuables du secteur France 03 doivent être visités avant 16h. »

> **Frontend** : **Non implémenté**. Système de messagerie/notification interne à ajouter.

---

## 24. Contrôle de présence opérationnelle

```text
AGENTS

🟢 Actif
🟡 Inactif depuis 30 min
🔴 Hors ligne
⚠ Synchronisation en retard
```

Avec :

- première connexion
- dernière activité
- dernière synchronisation

> **Frontend** : À ajouter dans `Supervision.vue` (statut temps réel + synchro).

---

## 25. Gestion des appareils

```text
AGENT AG-002

Appareil :
Android XXXXX

Dernière connexion :
10:24

Version application :
1.4.2

Base locale :
Synchronisée

État :
NORMAL
```

Le superviseur peut détecter les anciennes versions ou appareils problématiques.

> **Frontend** : **Non implémenté**. Vue de gestion des appareils à ajouter.

---

## 26. Synchronisation de zone

```text
SYNCHRONISATION

AG-001 ✓
AG-002 ✓
AG-003 ⚠ 17 opérations
AG-004 ✓
AG-005 🔴 hors ligne
```

Action : **« Synchroniser la zone »** pour déclencher/ordonner les synchronisations lorsque l'architecture le permet.

> **Frontend** : **Non implémenté**. Nouvelle vue `Synchronisation.vue` (statut par agent, déclenchement).

---

## 27. Contrôle territorial

### Secteurs non couverts

```text
ZONE 03

Secteur 01 ✓
Secteur 02 ✓
Secteur 03 ⚠ 12 % couvert
Secteur 04 ✓
```

### Contribuables sans agent

```text
⚠ 37 contribuables non affectés
```

### Agents surchargés

```text
AG-003 : 310
AG-004 : 92
```

> **Frontend** : `AnalyseZones.vue` fournit la répartition contribuables / taux de recensement. Les alertes « non couvert / sans agent / surchargé » restent à ajouter.

---

## 28. Gestion des réclamations

Un contribuable peut contester : montant, activité, identité, paiement, localisation, taxe.

```text
RÉCLAMATION #458

ETS KOFFI

Motif :
Montant contesté

Montant :
75 000 F

[ EXAMINER ]
[ TRANSMETTRE ]
[ CLÔTURER ]
```

> **Frontend** : **Non implémenté**. Nouvelle vue `Reclamations.vue` (file, examen, transmission, clôture).

---

## 29. Historique / audit

Le superviseur doit pouvoir savoir : **Qui a fait quoi, quand et où ?**

```text
11/09 09:42
AG-002
Visite ETS YAO

11/09 09:45
AG-002
Paiement 25 000 F

11/09 10:02
SUP-001
Affectation modifiée

11/09 10:17
AG-002
Synchronisation
```

> **Frontend** : **Non implémenté**. Nouvelle vue `Audit.vue` (journal immuable, filtres par acteur/date/zone).

---

## 30. Ce que le superviseur NE doit PAS pouvoir faire

| ❌ Interdit | Raison |
|------------|--------|
| Gestion des utilisateurs système | Rôle **ADMIN** |
| Modification des règles fiscales globales | Rôle **ADMIN / administration fiscale** |
| Suppression de paiements | Jamais directement |
| Modification de l'historique | Audit immuable |
| Gestion globale de la trésorerie | Rôle **TRÉSORIER** |
| Accès aux autres zones | Sauf délégation explicite (scope territorial) |

> **Frontend** : Conforme côté permissions — `SUPERVISEUR` n'a ni `settings.manage`, ni `payments.cancel`/`payments.refund`, ni `agents.delete`, ni `zones.create/edit/delete`.

---

## 31. Vue fonctionnelle complète (menu cible)

```text
┌──────────────────────────────────┐
│     E-COLLECTE TAXE              │
│     SUPERVISEUR ZONE             │
├──────────────────────────────────┤
│                                  │
│ 🏠 Tableau de bord               │
│                                  │
│ 🗺️ Carte de ma zone              │
│                                  │
│ 👥 Mes agents                    │
│                                  │
│ 🏢 Contribuables                 │
│                                  │
│ 📋 Tournées                       │
│                                  │
│ 💰 Recouvrement                  │
│                                  │
│ ⚠ Anomalies                      │
│                                  │
│ 🔄 Synchronisation               │
│                                  │
│ 📢 Réclamations                  │
│                                  │
│ 🔔 Notifications                 │
│                                  │
│ 📊 Rapports                      │
│                                  │
│ 📝 Audit                         │
│                                  │
│ ⚙️ Paramètres opérationnels      │
│                                  │
└──────────────────────────────────┘
```

---

## 📈 État d'avancement frontend (synthèse)

| # | Fonctionnalité | État | Vue / Composant |
|---|---------------|------|-----------------|
| 1 | Tableau de bord zone | Partiel (générique) | `Dashboard.vue` |
| 2 | Gestion des agents | Partiel | `Agents.vue`, `Supervision.vue` |
| 3 | Affectation agents | ✅ Zone | `Supervision.vue`, `AgentAffectationModal.vue` |
| 4 | Planification tournées | ❌ | À créer (`Tournees.vue`) |
| 5 | Carte opérationnelle | Partiel | `CarteTerritoriale.vue`, `CarteRecensement.vue` |
| 6 | Suivi temps réel | ❌ | À ajouter dans `Supervision.vue` |
| 7 | Suivi des visites | Partiel | `AnalyseAgents.vue` |
| 8 | Validation nouveaux contribuables | ❌ | À créer |
| 9 | Validation évaluations | Partiel (vue) | `Assessments.vue` |
| 10 | Contrôle paiements | ✅ Vue | `Payments.vue`, `Transactions.vue` |
| 11 | Contrôle paiements offline | Partiel | `Reconciliation.vue` |
| 12 | Gestion anomalies | ❌ | À créer (`Anomalies.vue`) |
| 13 | Contrôle anti-fraude | ❌ | Backend + `Anomalies.vue` |
| 14 | Gestion impayés | ❌ | À créer (`Recouvrement.vue`) |
| 15 | Relance contribuables | ❌ | À intégrer dans `Recouvrement.vue` |
| 16 | Promesses de paiement | ❌ | À créer (`Promesses.vue`) |
| 17 | Réaffectation contribuables | ❌ | À ajouter |
| 18 | Gestion secteurs | Partiel | `Secteurs.vue`, `AnalyseZones.vue` |
| 19 | Objectifs de collecte | ❌ | À ajouter au dashboard |
| 20 | Performance agents | ✅ | `AnalyseAgents.vue` |
| 21 | Rapports | Partiel (perms) | Vue export à créer |
| 22 | Rapport de tournée | ❌ | Dépend de `Tournees.vue` |
| 23 | Communication agents | ❌ | Messagerie à créer |
| 24 | Présence opérationnelle | ❌ | À ajouter dans `Supervision.vue` |
| 25 | Gestion appareils | ❌ | À créer |
| 26 | Synchronisation zone | ❌ | À créer (`Synchronisation.vue`) |
| 27 | Contrôle territorial | Partiel | `AnalyseZones.vue` |
| 28 | Réclamations | ❌ | À créer (`Reclamations.vue`) |
| 29 | Audit | ❌ | À créer (`Audit.vue`) |
| 30 | Interdictions | ✅ Conforme | `permissionService.js` |

---

## 🚀 Prochaines étapes recommandées

1. **Spécialiser le dashboard** par rôle (vue zone pour le superviseur).
2. **Créer les vues manquantes** : `Tournees.vue`, `Recouvrement.vue`, `Promesses.vue`, `Anomalies.vue`, `Reclamations.vue`, `Synchronisation.vue`, `Audit.vue`.
3. **Ajouter le scope territorial** côté Keycloak/RBAC pour limiter un superviseur à sa zone.
4. **Mettre en place la détection d'anomalies** côté backend (visites trop rapides, GPS incohérent, doublons).
5. **Compléter la carte opérationnelle** avec les filtres payés/impayés/nouveaux/anomalies.
6. **Ajouter le workflow de validation** des nouveaux contribuables et des évaluations.

---

*Module Superviseur de Zone — E-CollecteTaxe. Document établi à partir du périmètre fonctionnel cible et de l'état actuel du frontend Vue.*
