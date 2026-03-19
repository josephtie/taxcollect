<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Agents</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="showCreateModal = true"
              class="btn-primary"
            >
              <Plus class="w-4 h-4 mr-2" />
              Nouvel Agent
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

      <!-- Agents Content -->
      <div class="flex-1 p-6">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <StatsCard
            title="Agents Actifs"
            :value="(agentStore.activeAgents || []).length"
            :icon="Users"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          
          <StatsCard
            title="Agents en Ligne"
            :value="(agentStore.onlineAgents || []).length"
            :icon="Wifi"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
          />
          
          <StatsCard
            title="Total Collecté Aujourd'hui"
            :value="totalCollectedToday"
            :icon="DollarSign"
            format="currency"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
        </div>

        <!-- Agents Table -->
        <div class="bg-white rounded-lg shadow-soft border border-gray-100">
          <div class="px-6 py-4 border-b border-gray-200">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900">Liste des Agents</h3>
              <div class="flex items-center space-x-3">
                <input
                  v-model="searchQuery"
                  type="text"
                  placeholder="Rechercher un agent..."
                  class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                />
                <select
                  v-model="statusFilter"
                  class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="">Tous les statuts</option>
                  <option value="online">En ligne</option>
                  <option value="offline">Hors ligne</option>
                </select>
              </div>
            </div>
          </div>
          
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Agent
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contact
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Zone
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Statut
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Total Aujourd'hui
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Transactions
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-if="agentStore.loading" class="text-center">
                  <td colspan="7" class="px-6 py-12">
                    <div class="flex items-center justify-center">
                      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                      <span class="ml-2 text-gray-600">Chargement...</span>
                    </div>
                  </td>
                </tr>
                <tr 
                  v-else
                  v-for="agent in filteredAgents" 
                  :key="agent.id"
                  class="hover:bg-gray-50 transition-colors"
                >
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-3">
                        <span class="text-sm font-medium text-gray-600">
                          {{ agent.nom[0] }}{{ agent.prenom[0] }}
                        </span>
                      </div>
                      <div>
                        <div class="text-sm font-medium text-gray-900">
                          {{ agent.nom }} {{ agent.prenom }}
                        </div>
                        <div class="text-xs text-gray-500">ID: {{ agent.id }}</div>
                      </div>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm text-gray-900">{{ agent.email }}</div>
                    <div class="text-xs text-gray-500">{{ agent.telephone }}</div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ agent.zoneCollecte?.nom || 'Non assigné' }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <StatusBadge 
                      :status="agent.enLigne ? 'En ligne' : 'Hors ligne'" 
                      type="agent"
                    />
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ formatCurrency(agent.totalCollecteDuJour || 0) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ agent.nombreTransactionsDuJour || 0 }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div class="flex items-center space-x-2">
                      <button
                        @click="viewAgentDetails(agent)"
                        class="text-primary-600 hover:text-primary-900"
                      >
                        <Eye class="w-4 h-4" />
                      </button>
                      <button
                        @click="editAgent(agent)"
                        class="text-warning-600 hover:text-warning-900"
                      >
                        <Edit class="w-4 h-4" />
                      </button>
                      <button
                        @click="deleteAgent(agent)"
                        class="text-danger-600 hover:text-danger-900"
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
          {{ editingAgent ? 'Modifier' : 'Créer' }} un Agent
        </h3>
        
        <form @submit.prevent="saveAgent">
          <div class="space-y-4">
            <div>
              <label class="form-label">Nom</label>
              <input
                v-model="agentForm.nom"
                type="text"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Prénom</label>
              <input
                v-model="agentForm.prenom"
                type="text"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Email</label>
              <input
                v-model="agentForm.email"
                type="email"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Téléphone</label>
              <input
                v-model="agentForm.telephone"
                type="tel"
                required
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Statut</label>
              <select
                v-model="agentForm.statut"
                required
                class="form-input"
              >
                <option value="ACTIF">Actif</option>
                <option value="INACTIF">Inactif</option>
                <option value="SUSPENDU">Suspendu</option>
              </select>
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAgentStore } from '@/stores/agents'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import {
  Users,
  Wifi,
  DollarSign,
  Plus,
  Eye,
  Edit,
  Trash2
} from 'lucide-vue-next'

const agentStore = useAgentStore()

// State
const searchQuery = ref('')
const statusFilter = ref('')
const showCreateModal = ref(false)
const editingAgent = ref(null)
const saving = ref(false)
const agentForm = ref({
  nom: '',
  prenom: '',
  email: '',
  telephone: '',
  statut: 'ACTIF'  // Valeur par défaut
})

// Computed
const filteredAgents = computed(() => {
  let agents = agentStore.agentStats || []
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    agents = agents.filter(agent => 
      agent.nom?.toLowerCase().includes(query) ||
      agent.prenom?.toLowerCase().includes(query) ||
      agent.email?.toLowerCase().includes(query)
    )
  }
  
  if (statusFilter.value) {
    if (statusFilter.value === 'online') {
      agents = agents.filter(agent => agent.enLigne)
    } else if (statusFilter.value === 'offline') {
      agents = agents.filter(agent => !agent.enLigne)
    }
  }
  
  return agents
})

const totalCollectedToday = computed(() => {
  const stats = agentStore.agentStats || []
  return stats.reduce((sum, agent) => sum + (agent.todayTotal || 0), 0)
})

// Methods
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(amount)
}

const viewAgentDetails = (agent) => {
  // Implémenter la vue des détails
  console.log('View agent:', agent)
}

const editAgent = (agent) => {
  editingAgent.value = agent
  agentForm.value = { 
    ...agent,
    statut: agent.statut || 'ACTIF'  // S'assurer qu'il y a un statut
  }
  showCreateModal.value = true
}

const deleteAgent = async (agent) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer l'agent ${agent.nom} ${agent.prenom}?`)) {
    try {
      await agentStore.deleteAgent(agent.id)
      // Afficher une notification de succès
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const saveAgent = async () => {
  saving.value = true
  try {
    console.log('Agent form data:', agentForm.value) // Debug
    if (editingAgent.value) {
      await agentStore.updateAgent(editingAgent.value.id, agentForm.value)
    } else {
      await agentStore.createAgent(agentForm.value)
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
  editingAgent.value = null
  agentForm.value = {
    nom: '',
    prenom: '',
    email: '',
    telephone: '',
    statut: 'ACTIF'  // Réinitialiser avec la valeur par défaut
  }
}

// Lifecycle
onMounted(() => {
  agentStore.fetchAgents() // Utiliser la méthode paginée par défaut
})
</script>
