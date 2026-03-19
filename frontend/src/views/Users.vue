<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Utilisateurs</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="refreshData"
              :disabled="loading"
              class="p-2 text-gray-600 hover:text-gray-900 transition-colors"
            >
              <RefreshCw :class="{ 'animate-spin': loading }" class="w-5 h-5" />
            </button>
            <button
              @click="showCreateModal = true"
              class="btn-primary"
            >
              <Plus class="w-4 h-4 mr-2" />
              Nouvel Utilisateur
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex">
      <!-- Sidebar -->
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <!-- Users Content -->
      <div class="flex-1 p-6">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatsCard
            title="Total Utilisateurs"
            :value="users.length"
            :icon="Users"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
          />
          
          <StatsCard
            title="Utilisateurs Actifs"
            :value="activeUsers.length"
            :icon="UserCheck"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          
          <StatsCard
            title="Administrateurs"
            :value="adminUsers.length"
            :icon="Shield"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
          
          <StatsCard
            title="Agents"
            :value="agentUsers.length"
            :icon="User"
            icon-color="text-info-600"
            icon-bg-color="bg-info-50"
          />
        </div>

        <!-- Filters -->
        <div class="bg-white rounded-lg shadow-soft p-6 mb-6 border border-gray-100">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label class="form-label">Recherche</label>
              <input
                v-model="filters.search"
                type="text"
                placeholder="Nom, email, username..."
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Rôle</label>
              <select
                v-model="filters.role"
                class="form-input"
              >
                <option value="">Tous les rôles</option>
                <option value="ADMIN">Administrateur</option>
                <option value="AGENT">Agent</option>
                <option value="TRESOR">Trésor</option>
                <option value="SUPERVISEUR">Superviseur</option>
              </select>
            </div>
            
            <div>
              <label class="form-label">Statut</label>
              <select
                v-model="filters.status"
                class="form-input"
              >
                <option value="">Tous les statuts</option>
                <option value="true">Actif</option>
                <option value="false">Inactif</option>
              </select>
            </div>
            
            <div class="flex items-end">
              <button
                @click="applyFilters"
                class="w-full px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
              >
                Filtrer
              </button>
            </div>
          </div>
        </div>

        <!-- Users Table -->
        <div class="bg-white rounded-lg shadow-soft border border-gray-100">
          <div class="px-6 py-4 border-b border-gray-200">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900">Liste des Utilisateurs</h3>
              <div class="flex items-center space-x-3">
                <input
                  v-model="searchQuery"
                  type="text"
                  placeholder="Rechercher un utilisateur..."
                  class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>
          </div>
          
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Utilisateur
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contact
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Rôle
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Statut
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Dernière connexion
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-if="loading" class="text-center">
                  <td colspan="6" class="px-6 py-12">
                    <div class="flex items-center justify-center">
                      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                      <span class="ml-2 text-gray-600">Chargement...</span>
                    </div>
                  </td>
                </tr>
                <tr 
                  v-else
                  v-for="user in filteredUsers" 
                  :key="user.id"
                  class="hover:bg-gray-50 transition-colors"
                >
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-3">
                        <span class="text-sm font-medium text-gray-600">
                          {{ (user.nom || '')[0] }}{{ (user.prenom || '')[0] }}
                        </span>
                      </div>
                      <div>
                        <div class="text-sm font-medium text-gray-900">
                          {{ user.nom }} {{ user.prenom }}
                        </div>
                        <div class="text-xs text-gray-500">@{{ user.username }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm text-gray-900">{{ user.email }}</div>
                    <div class="text-xs text-gray-500">{{ user.telephone || '-' }}</div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span 
                      class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      :class="getRoleBadgeClass(user.role)"
                    >
                      {{ getRoleLabel(user.role) }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <StatusBadge 
                      :status="user.active ? 'Actif' : 'Inactif'" 
                      type="user"
                    />
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {{ formatDate(user.lastLogin) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div class="flex items-center space-x-2">
                      <button
                        @click="viewUserDetails(user)"
                        class="text-primary-600 hover:text-primary-900"
                        title="Voir les détails"
                      >
                        <Eye class="w-4 h-4" />
                      </button>
                      <button
                        @click="editUser(user)"
                        class="text-warning-600 hover:text-warning-900"
                        title="Modifier"
                      >
                        <Edit class="w-4 h-4" />
                      </button>
                      <button
                        @click="toggleUserStatus(user)"
                        :class="user.active ? 'text-gray-600 hover:text-gray-900' : 'text-green-600 hover:text-green-900'"
                        :title="user.active ? 'Désactiver' : 'Activer'"
                      >
                        <Power v-if="user.active" class="w-4 h-4" />
                        <PowerOff v-else class="w-4 h-4" />
                      </button>
                      <button
                        @click="deleteUser(user)"
                        class="text-danger-600 hover:text-danger-900"
                        title="Supprimer"
                      >
                        <Trash2 class="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
          {{ editingUser ? 'Modifier' : 'Créer' }} un Utilisateur
        </h3>
        
        <form @submit.prevent="saveUser">
          <div class="space-y-4">
            <div>
              <label class="form-label">Nom</label>
              <input
                v-model="userForm.nom"
                type="text"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Prénom</label>
              <input
                v-model="userForm.prenom"
                type="text"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Username</label>
              <input
                v-model="userForm.username"
                type="text"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Email</label>
              <input
                v-model="userForm.email"
                type="email"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Téléphone</label>
              <input
                v-model="userForm.telephone"
                type="tel"
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Rôle</label>
              <select
                v-model="userForm.role"
                required
                class="form-input"
              >
                <option value="">Sélectionner un rôle</option>
                <option value="ADMIN">Administrateur</option>
                <option value="AGENT">Agent</option>
                <option value="TRESOR">Trésor</option>
                <option value="SUPERVISEUR">Superviseur</option>
              </select>
            </div>
            
            <div v-if="!editingUser">
              <label class="form-label">Mot de passe</label>
              <input
                v-model="userForm.password"
                type="password"
                required
                class="form-input"
              />
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 mt-6">
            <button
              type="button"
              @click="closeModal"
              class="btn-secondary"
            >
              Annuler
            </button>
            <button
              type="submit"
              :disabled="saving"
              class="btn-primary"
            >
              {{ saving ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- User Details Modal -->
    <div v-if="showDetailsModal && selectedUser" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold text-gray-900">
            Détails de l'Utilisateur
          </h3>
          <button
            @click="closeDetailsModal"
            class="text-gray-400 hover:text-gray-600"
          >
            <X class="w-6 h-6" />
          </button>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="bg-gray-50 rounded-lg p-4">
            <h4 class="font-medium text-gray-900 mb-3">Informations personnelles</h4>
            <div class="space-y-2">
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Nom complet:</span>
                <span class="text-sm font-medium text-gray-900">{{ selectedUser.nom }} {{ selectedUser.prenom }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Username:</span>
                <span class="text-sm font-medium text-gray-900">@{{ selectedUser.username }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Email:</span>
                <span class="text-sm font-medium text-gray-900">{{ selectedUser.email }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Téléphone:</span>
                <span class="text-sm font-medium text-gray-900">{{ selectedUser.telephone || '-' }}</span>
              </div>
            </div>
          </div>
          
          <div class="bg-gray-50 rounded-lg p-4">
            <h4 class="font-medium text-gray-900 mb-3">Informations système</h4>
            <div class="space-y-2">
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Rôle:</span>
                <span class="text-sm font-medium text-gray-900">{{ getRoleLabel(selectedUser.role) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Statut:</span>
                <StatusBadge :status="selectedUser.active ? 'Actif' : 'Inactif'" type="user" />
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Dernière connexion:</span>
                <span class="text-sm font-medium text-gray-900">{{ formatDate(selectedUser.lastLogin) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-sm text-gray-600">Date de création:</span>
                <span class="text-sm font-medium text-gray-900">{{ formatDate(selectedUser.createdAt) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { userService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import {
  Users,
  UserCheck,
  Shield,
  User,
  Plus,
  RefreshCw,
  Eye,
  Edit,
  Trash2,
  Power,
  PowerOff,
  X
} from 'lucide-vue-next'

// State
const users = ref([])
const loading = ref(false)
const showCreateModal = ref(false)
const showDetailsModal = ref(false)
const editingUser = ref(null)
const selectedUser = ref(null)
const saving = ref(false)
const searchQuery = ref('')

const filters = ref({
  search: '',
  role: '',
  status: ''
})

const userForm = ref({
  nom: '',
  prenom: '',
  username: '',
  email: '',
  telephone: '',
  role: '',
  password: ''
})

// Computed
const filteredUsers = computed(() => {
  let filtered = users.value || []

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(user => 
      (user.nom || '').toLowerCase().includes(query) ||
      (user.prenom || '').toLowerCase().includes(query) ||
      (user.email || '').toLowerCase().includes(query) ||
      (user.username || '').toLowerCase().includes(query)
    )
  }

  if (filters.value.role) {
    filtered = filtered.filter(user => user.role === filters.value.role)
  }

  if (filters.value.status !== '') {
    const isActive = filters.value.status === 'true'
    filtered = filtered.filter(user => user.active === isActive)
  }

  return filtered
})

const activeUsers = computed(() => {
  return (users.value || []).filter(user => user.active === true)
})

const adminUsers = computed(() => {
  return (users.value || []).filter(user => user.role === 'ADMIN')
})

const agentUsers = computed(() => {
  return (users.value || []).filter(user => user.role === 'AGENT')
})

// Methods
const getRoleBadgeClass = (role) => {
  const classes = {
    'ADMIN': 'bg-red-100 text-red-800',
    'AGENT': 'bg-blue-100 text-blue-800',
    'TRESOR': 'bg-green-100 text-green-800',
    'SUPERVISEUR': 'bg-purple-100 text-purple-800'
  }
  return classes[role] || 'bg-gray-100 text-gray-800'
}

const getRoleLabel = (role) => {
  const labels = {
    'ADMIN': 'Administrateur',
    'AGENT': 'Agent',
    'TRESOR': 'Trésor',
    'SUPERVISEUR': 'Superviseur'
  }
  return labels[role] || role
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  try {
    const date = new Date(dateString)
    if (isNaN(date.getTime())) return '-'
    return date.toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    console.warn('Erreur de formatage de date:', dateString, error)
    return '-'
  }
}

const refreshData = async () => {
  await fetchUsers()
}

const applyFilters = () => {
  // Les filtres sont appliqués automatiquement via les computed
}

const viewUserDetails = (user) => {
  selectedUser.value = user
  showDetailsModal.value = true
}

const editUser = (user) => {
  editingUser.value = user
  userForm.value = { ...user }
  showCreateModal.value = true
}

const toggleUserStatus = async (user) => {
  if (confirm(`Êtes-vous sûr de vouloir ${user.active ? 'désactiver' : 'activer'} cet utilisateur?`)) {
    try {
      await userService.toggleUserStatus(user.id, !user.active)
      user.active = !user.active
    } catch (error) {
      console.error('Erreur lors du changement de statut:', error)
    }
  }
}

const deleteUser = async (user) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer l'utilisateur ${user.nom} ${user.prenom}?`)) {
    try {
      await userService.deleteUser(user.id)
      users.value = users.value.filter(u => u.id !== user.id)
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const saveUser = async () => {
  saving.value = true
  try {
    if (editingUser.value) {
      const updatedUser = await userService.updateUser(editingUser.value.id, userForm.value)
      const index = users.value.findIndex(u => u.id === editingUser.value.id)
      if (index !== -1) {
        users.value[index] = updatedUser.data
      }
    } else {
      const newUser = await userService.createUser(userForm.value)
      users.value.push(newUser.data)
    }
    closeModal()
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement:', error)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingUser.value = null
  userForm.value = {
    nom: '',
    prenom: '',
    username: '',
    email: '',
    telephone: '',
    role: '',
    password: ''
  }
}

const closeDetailsModal = () => {
  showDetailsModal.value = false
  selectedUser.value = null
}

const fetchUsers = async () => {
  loading.value = true
  try {
    const response = await userService.getAllUsers()
    // Transformer les données de la nouvelle structure vers l'ancienne
    users.value = response.data.map(userWithRoles => {
      const user = userWithRoles.userdto
      return {
        id: user.id,
        username: user.username,
        email: user.email,
        active: user.enabled,
        lastLogin: user.lastLogin,
        // Extraire le rôle principal (ignorer "default-roles-mairie")
        role: userWithRoles.roles.find(r => r !== 'default-roles-mairie') || 'USER',
        telephone: '', // Pas dans la réponse actuelle
        nom: user.username.split('@')[0] || '', // Extraire depuis l'email
        prenom: '' // Pas dans la réponse actuelle
      }
    })
  } catch (error) {
    console.error('Erreur lors du chargement des utilisateurs:', error)
  } finally {
    loading.value = false
  }
}

// Lifecycle
onMounted(() => {
  fetchUsers()
})
</script>
