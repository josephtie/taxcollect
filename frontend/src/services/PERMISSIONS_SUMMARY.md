# Résumé des Permissions par Rôle

## Rôles Disponibles

### 1. **ADMIN** 
**Description** : Administrateur système avec accès complet à toutes les fonctionnalités

**Permissions** :
- `dashboard.view` - Accès au tableau de bord
- `agents.view` - Voir les agents
- `agents.create` - Créer des agents
- `agents.edit` - Modifier des agents
- `agents.delete` - Supprimer des agents
- `zones.view` - Voir les zones
- `zones.create` - Créer des zones
- `zones.edit` - Modifier des zones
- `zones.delete` - Supprimer des zones
- `transactions.view` - Voir les transactions
- `transactions.create` - Créer des transactions
- `transactions.edit` - Modifier des transactions
- `transactions.delete` - Supprimer des transactions
- `cloture.view` - Voir les clôtures
- `cloture.validate` - Valider les clôtures
- `cloture.edit` - Modifier les clôtures
- `settings.view` - Voir les paramètres
- `settings.edit` - Modifier les paramètres
- `settings.manage` - Gérer les paramètres système
- `supervision.view` - Voir la supervision
- `supervision.assign` - Affecter des agents
- `supervision.unassign` - Retirer des agents
- `reports.view` - Voir les rapports
- `reports.export` - Exporter les rapports

---

### 2. **SUPERVISEUR** 
**Description** : Superviseur de zones avec gestion des affectations d'agents

**Permissions** :
- `dashboard.view` - Accès au tableau de bord
- `agents.view` - Voir les agents
- `agents.assign` - Affecter des agents aux zones
- `agents.unassign` - Retirer des agents des zones
- `zones.view` - Voir les zones
- `zones.supervise` - Superviser les zones assignées
- `transactions.view` - Voir les transactions
- `transactions.supervise` - Superviser les transactions
- `cloture.view` - Voir les clôtures
- `cloture.supervise` - Superviser les clôtures
- `supervision.view` - Accès à l'interface de supervision
- `supervision.assign` - Affecter des agents
- `supervision.unassign` - Retirer des agents
- `reports.view` - Voir les rapports
- `reports.export` - Exporter les rapports

**Fonctionnalités principales** :
- Gestion des affectations agents/zones
- Supervision des performances
- Visualisation des statistiques de ses zones
- Rapports sur les zones supervisées

---

### 3. **TRESOR** 
**Description** : Trésorier avec validation financière

**Permissions** :
- `dashboard.view` - Accès au tableau de bord
- `transactions.view` - Voir les transactions
- `transactions.validate` - Valider les transactions
- `cloture.view` - Voir les clôtures
- `cloture.validate` - Valider les clôtures
- `reports.view` - Voir les rapports
- `reports.export` - Exporter les rapports

---

### 4. **AGENT** 
**Description** : Agent de terrain

**Permissions** :
- `dashboard.view` - Accès au tableau de bord
- `transactions.create` - Créer des transactions
- `transactions.edit` - Modifier ses transactions
- `profile.view` - Voir son profil
- `profile.edit` - Modifier son profil

**Limitations** :
- ❌ Pas d'accès aux paramètres système
- ❌ Pas de gestion des utilisateurs

---
Collecte des taxes et gestion quotidienne.

**Permissions disponibles :**
- ✅ `dashboard.view` - Voir le dashboard
- ✅ `transactions.view` - Voir les transactions
- ✅ `transactions.create` - Créer des transactions
- ✅ `transactions.edit` - Modifier ses transactions
- ✅ `cloture.view` - Voir ses clôtures
- ✅ `cloture.create` - Créer des clôtures
- ✅ `profile.view` - Voir son profil
- ✅ `profile.edit` - Modifier son profil

**Accès aux routes :** `/dashboard`, `/transactions`, `/reversements`

**Limitations :**
- ❌ Pas d'accès à la gestion des agents
- ❌ Pas d'accès aux zones
- ❌ Pas de validation de clôtures
- ❌ Pas d'accès aux paramètres
- ❌ Pas d'accès aux rapports

---

## 🛡️ Contrôle d'Accès Implémenté

### Router Guards
```javascript
// Vérification des permissions avant l'accès aux routes
router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth && to.meta.permissions) {
    if (!permissionService.hasAnyPermission(to.meta.permissions)) {
      next('/dashboard') // Redirection si pas les permissions
      return
    }
  }
  next()
})
```

### Sidebar Dynamique
```javascript
// Filtrage automatique des liens selon les permissions
const navigation = computed(() => {
  return navigationItems.filter(item => 
    permissionService.hasPermission(item.permission)
  )
})
```

### Composants Conditionnels
```vue
<!-- Utilisation de PermissionGuard -->
<PermissionGuard permission="users.create">
  <button @click="createUser">Créer un utilisateur</button>
</PermissionGuard>

<!-- Utilisation de directives -->
<button v-permission="'agents.delete'" @click="deleteAgent">
  Supprimer l'agent
</button>
```

---

## 🎯 Scénarios d'Utilisation

### 1. Admin se connecte
- ✅ Voit tous les liens dans le sidebar
- ✅ Accès à toutes les routes
- ✅ Peut créer, modifier, supprimer tout

### 2. Superviseur se connecte
- ✅ Voit: Dashboard, Contribuables, Collecteurs, Supervision, Rapports
- ❌ Ne voit pas: Paramètres système
- ✅ Peut affecter/retirer des agents des zones
- ✅ Peut superviser les performances de ses zones

### 3. Trésor se connecte
- ✅ Voit: Dashboard, Agents, Reversements, Rapports
- ❌ Ne voit pas: Zones, Paramètres, Utilisateurs
- ✅ Peut valider/rejeter les clôtures

### 4. Agent se connecte
- ✅ Voit: Dashboard, Transactions, Reversements
- ❌ Ne voit pas: Agents, Zones, Paramètres
- ✅ Peut créer des transactions et clôturer sa caisse

---

## 🔧 Utilisation dans le Code

### Vérification de permissions
```javascript
import { permissionService } from '@/services/permissionService'

// Vérifier une permission spécifique
if (permissionService.hasPermission('agents.create')) {
  // Créer un agent
}

// Vérifier le rôle
if (permissionService.isAdmin()) {
  // Actions admin uniquement
}
```

### Contrôle d'affichage
```vue
<template>
  <!-- Afficher seulement si permission -->
  <PermissionGuard permission="users.view">
    <UserList />
  </PermissionGuard>
  
  <!-- Afficher seulement pour certains rôles -->
  <div v-role="['ADMIN', 'TRESOR']">
    <FinancialReports />
  </div>
</template>
```

Cette matrice garantit que chaque rôle n'accède qu'aux fonctionnalités qui lui sont destinées ! 🚀
