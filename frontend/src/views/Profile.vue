<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <h1 class="text-2xl font-bold text-gray-900">Mon Profil</h1>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex">
      <!-- Sidebar -->
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <!-- Profile Content -->
      <div class="flex-1 p-6">
        <div class="max-w-2xl mx-auto">
          <!-- Profile Card -->
          <div class="bg-white rounded-lg shadow-soft border border-gray-100">
            <!-- Cover -->
            <div class="h-32 bg-gradient-to-r from-primary-600 to-primary-800 rounded-t-lg"></div>

            <!-- Avatar + Info -->
            <div class="px-6 pb-6">
              <div class="flex items-end justify-between -mt-12 mb-4">
                <div class="w-24 h-24 bg-primary-600 rounded-full border-4 border-white flex items-center justify-center shadow-lg">
                  <span class="text-white text-2xl font-bold">{{ userInitials }}</span>
                </div>
              </div>

              <h2 class="text-xl font-bold text-gray-900">{{ userName }}</h2>
              <p class="text-sm text-gray-500">{{ userRole }}</p>

              <!-- Details -->
              <div class="mt-6 space-y-4">
                <div class="flex items-center text-sm">
                  <Mail class="w-5 h-5 text-gray-400 mr-3" />
                  <span class="text-gray-500">Email</span>
                  <span class="ml-auto font-medium text-gray-900">{{ user.email || '—' }}</span>
                </div>
                <div class="flex items-center text-sm">
                  <User class="w-5 h-5 text-gray-400 mr-3" />
                  <span class="text-gray-500">Nom d'utilisateur</span>
                  <span class="ml-auto font-medium text-gray-900">{{ user.username || '—' }}</span>
                </div>
                <div class="flex items-center text-sm">
                  <Shield class="w-5 h-5 text-gray-400 mr-3" />
                  <span class="text-gray-500">Rôle</span>
                  <span class="ml-auto">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                      {{ userRole }}
                    </span>
                  </span>
                </div>
              </div>

              <!-- Permissions -->
              <div class="mt-6 pt-6 border-t border-gray-200">
                <h3 class="text-sm font-medium text-gray-900 mb-3">Permissions</h3>
                <div class="flex flex-wrap gap-2">
                  <span
                    v-for="perm in permissions"
                    :key="perm"
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-700"
                  >
                    {{ perm }}
                  </span>
                  <span v-if="permissions.length === 0" class="text-sm text-gray-400">Aucune permission spécifique</span>
                </div>
              </div>

              <!-- Actions -->
              <div class="mt-6 pt-6 border-t border-gray-200 flex justify-end">
                <button
                  @click="handleLogout"
                  class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  <LogOut class="w-4 h-4 mr-2" />
                  Se déconnecter
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import Sidebar from '@/components/Sidebar.vue'
import { permissionService } from '@/services/permissionService'
import { Mail, User, Shield, LogOut } from 'lucide-vue-next'

const router = useRouter()

const user = computed(() => {
  const userStr = localStorage.getItem('user')
  if (userStr) {
    const userData = JSON.parse(userStr)
    permissionService.init(userData)
    return userData
  }
  return { nom: 'User', prenom: 'Unknown', role: 'USER', email: '', username: '' }
})

const userName = computed(() => `${user.value.prenom} ${user.value.nom}`)

const userInitials = computed(() => {
  const prenom = user.value.prenom || 'U'
  const nom = user.value.nom || 'U'
  return `${prenom[0]}${nom[0]}`.toUpperCase()
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

const permissions = computed(() => permissionService.userPermissions || [])

const handleLogout = async () => {
  try {
    const { authService } = await import('@/services/authService')
    authService.logout()
  } catch (error) {
    console.error('Erreur déconnexion:', error)
    localStorage.removeItem('authToken')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('user')
    router.push('/login')
  }
}
</script>
