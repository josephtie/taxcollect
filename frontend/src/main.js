import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import { permissionService } from './services/permissionService'
import { permissionDirective, roleDirective } from './directives/permission'

// Import des styles
import './style.css'

// Import des stores
import { useTransactionStore } from './stores/transactions'
import { useAgentStore } from './stores/agents'
import { useClotureStore } from './stores/cloture'
import { useQuartierStore } from './stores/quartiers'

// Import des vues
import Dashboard from './views/Dashboard.vue'

// Configuration du router
const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Dashboard,
    meta: { 
      requiresAuth: true,
      permissions: ['dashboard.view']
    }
  },
  {
    path: '/agents',
    name: 'Agents',
    component: () => import('./views/Agents.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['agents.view']
    }
  },
  {
    path: '/users',
    name: 'Users',
    component: () => import('./views/Users.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['settings.manage']
    }
  },
  {
    path: '/zones',
    name: 'Zones',
    component: () => import('./views/Zones.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['zones.view']
    }
  },
  {
    path: '/quartiers',
    name: 'Quartiers',
    component: () => import('./views/Quartiers.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['dashboard.view']
    }
  },
  {
    path: '/secteurs',
    name: 'Secteurs',
    component: () => import('./views/Secteurs.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['dashboard.view']
    }
  },
  {
    path: '/carte-territoriale',
    name: 'CarteTerritoriale',
    component: () => import('./views/CarteTerritoriale.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['dashboard.view']
    }
  },
  {
    path: '/reversements',
    name: 'Reversements',
    component: () => import('./views/Reversements.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['cloture.view']
    }
  },
  {
    path: '/transactions',
    name: 'Transactions',
    component: () => import('./views/Transactions.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['transactions.view']
    }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('./views/Settings.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['settings.view']
    }
  },
  {
    path: '/contribuables',
    name: 'Contribuables',
    component: () => import('./views/Contribuables.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['dashboard.view']
    }
  },
  {
    path: '/supervision',
    name: 'Supervision',
    component: () => import('./views/Supervision.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['supervision.view']
    }
  },
  {
    path: '/analyse-agents',
    name: 'AnalyseAgents',
    component: () => import('./views/AnalyseAgents.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['supervision.view']
    }
  },
  {
    path: '/analyse-zones',
    name: 'AnalyseZones',
    component: () => import('./views/AnalyseZones.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['supervision.view']
    }
  },
  {
    path: '/carte-recensement',
    name: 'CarteRecensement',
    component: () => import('./views/CarteRecensement.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['supervision.view']
    }
  },
  {
    path: '/taxes',
    name: 'Taxes',
    component: () => import('./views/Taxes.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['taxes.view']
    }
  },
  {
    path: '/payments',
    name: 'Payments',
    component: () => import('./views/Payments.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['payments.view']
    }
  },
  {
    path: '/reconciliation',
    name: 'Reconciliation',
    component: () => import('./views/Reconciliation.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['reconciliation.view']
    }
  },
  {
    path: '/assessments',
    name: 'Assessments',
    component: () => import('./views/Assessments.vue'),
    meta: { 
      requiresAuth: true,
      permissions: ['assessments.view']
    }
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('./views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('./views/Profile.vue'),
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Guard d'authentification et de permissions
router.beforeEach((to, from, next) => {
  const publicPages = ['/login']
  const authRequired = !publicPages.includes(to.path)
  const token = localStorage.getItem('authToken')

  if (authRequired && !token) {
    next('/login')
    return
  }

  // Vérifier les permissions si la route en requiert
  if (to.meta.requiresAuth && to.meta.permissions) {
    // Initialiser les permissions si nécessaire
    const userStr = localStorage.getItem('user')
    if (userStr) {
      try {
        const user = JSON.parse(userStr)
        permissionService.init(user)
        
        // Vérifier si l'utilisateur a les permissions requises
        if (!permissionService.hasAnyPermission(to.meta.permissions)) {
          console.warn(`Accès refusé: permissions requises ${to.meta.permissions.join(', ')}`)
          console.warn(`Rôle utilisateur: ${user.role}, Permissions: ${permissionService.userPermissions.join(', ')}`)
          
          // Éviter la boucle infinie - si on essaie déjà d'accéder au dashboard, aller à login
          if (to.path === '/dashboard') {
            next('/login')
            return
          }
          
          next('/dashboard')
          return
        }
      } catch (error) {
        console.error('Erreur initialisation permissions:', error)
        next('/login')
        return
      }
    } else {
      // Pas d'utilisateur dans localStorage, rediriger vers login
      next('/login')
      return
    }
  }

  next()
})

// Création de l'application
const app = createApp(App)

app.use(createPinia())
app.use(router)

// Enregistrer les directives globales
app.directive('permission', permissionDirective)
app.directive('role', roleDirective)

// Initialisation des stores au démarrage
app.mount('#app')

// Pré-charger les données si l'utilisateur est authentifié
const token = localStorage.getItem('authToken')
if (token) {
  const transactionStore = useTransactionStore()
  const agentStore = useAgentStore()
  const clotureStore = useClotureStore()
  
  // Charger les données initiales en arrière-plan
  Promise.all([
    transactionStore.fetchTransactions(),
    agentStore.fetchAgents(),
    clotureStore.fetchClotures()
  ]).catch(error => {
    console.error('Erreur lors du chargement initial des données:', error)
  })
}
