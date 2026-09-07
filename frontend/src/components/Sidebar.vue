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
    <nav class="flex-1 px-3 py-4 overflow-y-auto">
      <template v-for="group in navigation" :key="group.label">
        <!-- Groupe avec sous-menu -->
        <div v-if="group.children && group.children.length > 0" class="mb-1">
          <button
            @click="toggleGroup(group.label)"
            class="w-full flex items-center px-3 py-2.5 text-xs font-semibold text-gray-500 uppercase tracking-wider rounded-lg hover:bg-gray-800 transition-colors"
          >
            <component :is="group.icon" class="w-4 h-4 mr-2.5" />
            <span class="flex-1 text-left">{{ group.label }}</span>
            <ChevronDown
              v-if="expandedGroups.has(group.label)"
              class="w-4 h-4 text-gray-500"
            />
            <ChevronRight v-else class="w-4 h-4 text-gray-500" />
          </button>

          <transition name="submenu">
            <div v-show="expandedGroups.has(group.label)" class="mt-1 space-y-0.5">
              <router-link
                v-for="item in group.children"
                :key="item.name"
                :to="item.to"
                class="flex items-center pl-10 pr-3 py-2.5 text-sm font-medium rounded-lg transition-colors"
                :class="[
                  $route.path === item.to
                    ? 'bg-primary-600 text-white'
                    : 'text-gray-300 hover:bg-gray-800 hover:text-white'
                ]"
              >
                <component :is="item.icon" class="w-4 h-4 mr-3" />
                {{ item.name }}
                <span
                  v-if="item.badge"
                  class="ml-auto bg-red-500 text-white text-xs rounded-full px-2 py-0.5"
                >
                  {{ item.badge }}
                </span>
              </router-link>
            </div>
          </transition>
        </div>

        <!-- Item seul (sans sous-menu) -->
        <router-link
          v-else
          :to="group.to"
          class="flex items-center px-3 py-2.5 text-sm font-medium rounded-lg transition-colors mb-0.5"
          :class="[
            $route.path === group.to
              ? 'bg-primary-600 text-white'
              : 'text-gray-300 hover:bg-gray-800 hover:text-white'
          ]"
        >
          <component :is="group.icon" class="w-5 h-5 mr-3" />
          {{ group.name }}
          <span
            v-if="group.badge"
            class="ml-auto bg-red-500 text-white text-xs rounded-full px-2 py-0.5"
          >
            {{ group.badge }}
          </span>
        </router-link>
      </template>
    </nav>

    <!-- User Section -->
    <div class="p-4 border-t border-gray-800">
      <button
        @click="showUserMenu = !showUserMenu"
        class="w-full flex items-center px-2 py-2 rounded-lg hover:bg-gray-800 transition-colors"
      >
        <div class="w-9 h-9 bg-primary-600 rounded-full flex items-center justify-center flex-shrink-0">
          <span class="text-white text-sm font-medium">
            {{ userInitials }}
          </span>
        </div>
        <div class="ml-3 flex-1 text-left">
          <p class="text-sm font-medium text-white">{{ userName }}</p>
          <p class="text-xs text-gray-400">{{ userRole }}</p>
        </div>
        <ChevronUp v-if="showUserMenu" class="w-4 h-4 text-gray-400" />
        <ChevronDown v-else class="w-4 h-4 text-gray-400" />
      </button>

      <!-- User Dropdown Menu -->
      <transition name="dropdown">
        <div v-if="showUserMenu" class="mt-2 space-y-1">
          <router-link
            to="/profile"
            class="flex items-center px-3 py-2 text-sm text-gray-300 hover:bg-gray-800 hover:text-white rounded-lg transition-colors"
          >
            <UserCircle class="w-4 h-4 mr-3" />
            Mon profil
          </router-link>
          <button
            @click="handleLogout"
            data-testid="logout-button"
            class="w-full flex items-center px-3 py-2 text-sm text-red-400 hover:bg-red-900/30 hover:text-red-300 rounded-lg transition-colors"
          >
            <LogOut class="w-4 h-4 mr-3" />
            Déconnexion
          </button>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { permissionService } from '@/services/permissionService'
import {
  LayoutDashboard,
  Users,
  UserCheck,
  MapPin,
  Banknote,
  DollarSign,
  CreditCard,
  Scale,
  Eye,
  Settings,
  LogOut,
  Building,
  Map,
  MapPinned,
  BarChart3,
  TrendingUp,
  ChevronUp,
  ChevronDown,
  ChevronRight,
  UserCircle,
  Wallet,
  Map as MapIcon,
  Users as UsersIcon,
  FileText
} from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const showUserMenu = ref(false)
const expandedGroups = ref(new Set())

function toggleGroup(label) {
  if (expandedGroups.value.has(label)) {
    expandedGroups.value.delete(label)
  } else {
    expandedGroups.value.add(label)
  }
  // Trigger reactivity
  expandedGroups.value = new Set(expandedGroups.value)
}

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

// Navigation organisée par blocs avec sous-menus
const menuGroups = [
  // Bloc 1: Tableau de bord (item seul)
  {
    name: 'Tableau de bord',
    to: '/dashboard',
    icon: LayoutDashboard,
    permission: 'dashboard.view'
  },
  // Bloc 2: Acteurs
  {
    label: 'Acteurs',
    icon: UsersIcon,
    children: [
      { name: 'Contribuables', to: '/contribuables', icon: MapPin, permission: 'dashboard.view' },
      { name: 'Collecteurs', to: '/agents', icon: Users, permission: 'agents.view' },
      { name: 'Utilisateurs', to: '/users', icon: UserCheck, permission: 'settings.manage' }
    ]
  },
  // Bloc 3: Supervision & Analyse
  {
    label: 'Supervision',
    icon: Eye,
    children: [
      { name: 'Supervision', to: '/supervision', icon: Eye, permission: 'supervision.view' },
      { name: 'Analyse Agents', to: '/analyse-agents', icon: BarChart3, permission: 'supervision.view' },
      { name: 'Analyse Zones', to: '/analyse-zones', icon: TrendingUp, permission: 'supervision.view' },
      { name: 'Carte Recensement', to: '/carte-recensement', icon: MapPin, permission: 'supervision.view' }
    ]
  },
  // Bloc 4: Géographie
  {
    label: 'Géographie',
    icon: MapIcon,
    children: [
      { name: 'Zones', to: '/zones', icon: MapPin, permission: 'zones.view' },
      { name: 'Quartiers', to: '/quartiers', icon: Building, permission: 'dashboard.view' },
      { name: 'Secteurs', to: '/secteurs', icon: Map, permission: 'dashboard.view' },
      { name: 'Carte Territoriale', to: '/carte-territoriale', icon: MapPinned, permission: 'dashboard.view' }
    ]
  },
  // Bloc 5: Finances
  {
    label: 'Finances',
    icon: Wallet,
    children: [
      { name: 'Taxes', to: '/taxes', icon: DollarSign, permission: 'taxes.view' },
      { name: 'Avis d\'imposition', to: '/assessments', icon: FileText, permission: 'assessments.view' },
      { name: 'Paiements', to: '/payments', icon: CreditCard, permission: 'payments.view' },
      { name: 'Réconciliation', to: '/reconciliation', icon: Scale, permission: 'reconciliation.view' },
      { name: 'Reversements', to: '/reversements', icon: Banknote, permission: 'cloture.view', badge: null }
    ]
  },
  // Bloc 6: Paramètres (item seul)
  {
    name: 'Paramètres',
    to: '/settings',
    icon: Settings,
    permission: 'settings.view'
  }
]

// Filtrer selon les permissions — un groupe n'apparaît que s'il a au moins un enfant visible
const navigation = computed(() => {
  const result = []
  for (const group of menuGroups) {
    if (group.children) {
      const visibleChildren = group.children.filter(child => permissionService.hasPermission(child.permission))
      if (visibleChildren.length > 0) {
        result.push({ ...group, children: visibleChildren })
      }
    } else if (group.permission && permissionService.hasPermission(group.permission)) {
      result.push(group)
    }
  }
  return result
})

// Auto-expand le groupe contenant la route active
watch(() => route.path, (newPath) => {
  for (const group of menuGroups) {
    if (group.children) {
      const match = group.children.some(child => child.to === newPath)
      if (match) {
        expandedGroups.value.add(group.label)
        expandedGroups.value = new Set(expandedGroups.value)
      }
    }
  }
}, { immediate: true })

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
    case 'CONTRIBUABLE': return 'Contribuable'
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

<style scoped>
.submenu-enter-active,
.submenu-leave-active {
  transition: all 0.2s ease;
  overflow: hidden;
}
.submenu-enter-from,
.submenu-leave-to {
  opacity: 0;
  max-height: 0;
}
.submenu-enter-to,
.submenu-leave-from {
  opacity: 1;
  max-height: 500px;
}

nav::-webkit-scrollbar {
  width: 4px;
}
nav::-webkit-scrollbar-track {
  background: transparent;
}
nav::-webkit-scrollbar-thumb {
  background: #374151;
  border-radius: 2px;
}
</style>
