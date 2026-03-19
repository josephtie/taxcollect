<template>
  <div class="flex flex-col h-full bg-gray-900">
    <!-- Logo -->
    <div class="flex items-center justify-center h-16 px-4 bg-gray-800">
      <div class="flex items-center">
        <div class="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
          <span class="text-white font-bold text-lg">T</span>
        </div>
        <span class="ml-2 text-white font-semibold">TaxCollect</span>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 px-4 py-6 space-y-2">
      <router-link
        v-for="item in navigation"
        :key="item.name"
        :to="item.to"
        class="flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors"
        :class="[
          $route.path === item.to
            ? 'bg-primary-600 text-white'
            : 'text-gray-300 hover:bg-gray-800 hover:text-white'
        ]"
      >
        <component :is="item.icon" class="w-5 h-5 mr-3" />
        {{ item.name }}
        <span 
          v-if="item.badge" 
          class="ml-auto bg-red-500 text-white text-xs rounded-full px-2 py-0.5"
        >
          {{ item.badge }}
        </span>
      </router-link>
    </nav>

    <!-- User Section -->
    <div class="p-4 border-t border-gray-800">
      <div class="flex items-center">
        <div class="w-8 h-8 bg-gray-600 rounded-full flex items-center justify-center">
          <span class="text-white text-sm font-medium">
            {{ userInitials }}
          </span>
        </div>
        <div class="ml-3 flex-1">
          <p class="text-sm font-medium text-white">{{ userName }}</p>
          <p class="text-xs text-gray-400">{{ userRole }}</p>
        </div>
        <button
          @click="handleLogout"
          class="text-gray-400 hover:text-white transition-colors"
          title="Déconnexion"
        >
          <LogOut class="w-5 h-5" />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { permissionService } from '@/services/permissionService'
import {
  LayoutDashboard,
  Users,
  UserCheck,
  MapPin,
  Banknote,
  DollarSign,
  Eye,
  Settings,
  LogOut,
  Building
} from 'lucide-vue-next'

const router = useRouter()

// Données utilisateur depuis localStorage
const user = computed(() => {
  const userStr = localStorage.getItem('user')
  if (userStr) {
    const userData = JSON.parse(userStr)
    // Initialiser les permissions si nécessaire
    permissionService.init(userData)
    return userData
  }
  return {
    nom: 'User',
    prenom: 'Unknown',
    role: 'USER'
  }
})

// Navigation avec permissions
const navigationItems = [
  {
    name: 'Vue d\'ensemble',
    to: '/dashboard',
    icon: LayoutDashboard,
    permission: 'dashboard.view'
  },
  {
    name: 'Contribuables',
    to: '/contribuables',
    icon: MapPin,
    permission: 'dashboard.view'
  },
  {
    name: 'Collecteurs',
    to: '/agents',
    icon: Users,
    permission: 'agents.view'
  },
  {
    name: 'Utilisateurs',
    to: '/users',
    icon: UserCheck,
    permission: 'settings.manage'
  },
  {
    name: 'Supervision',
    to: '/supervision',
    icon: Eye,
    permission: 'supervision.view'
  },
  {
    name: 'Zones',
    to: '/zones',
    icon: MapPin,
    permission: 'zones.view'
  },
  {
    name: 'Quartiers',
    to: '/quartiers',
    icon: Building,
    permission: 'dashboard.view'
  },
  {
    name: 'Taxes',
    to: '/taxes',
    icon: DollarSign,
    permission: 'taxes.view'
  },
  {
    name: 'Reversements',
    to: '/reversements',
    icon: Banknote,
    permission: 'cloture.view',
    badge: null // À mettre à jour avec le nombre de validations en attente
  },
  {
    name: 'Paramètres',
    to: '/settings',
    icon: Settings,
    permission: 'settings.view'
  }
]

// Navigation filtrée selon les permissions
const navigation = computed(() => {
  return navigationItems.filter(item => permissionService.hasPermission(item.permission))
})

const userName = computed(() => {
  return `${user.value.prenom} ${user.value.nom}`
})

const userInitials = computed(() => {
  return `${user.value.prenom[0]}${user.value.nom[0]}`.toUpperCase()
})

const userRole = computed(() => {
  const role = user.value?.role || 'USER'
  switch (role) {
    case 'ADMIN': return 'Administrateur'
    case 'SUPERVISEUR': return 'Superviseur'
    case 'TRESOR': return 'Trésor'
    case 'AGENT': return 'Agent'
    default: return role
  }
})

const handleLogout = async () => {
  try {
    // Utiliser authService pour la déconnexion propre
    const { authService } = await import('@/services/authService')
    authService.logout()
  } catch (error) {
    console.error('Erreur déconnexion:', error)
    // Fallback: déconnexion manuelle
    localStorage.removeItem('authToken')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('user')
    router.push('/login')
  }
}
</script>
