<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Quartiers</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="showCreateModal = true"
              class="btn-primary"
            >
              <Plus class="w-4 h-4 mr-2" />
              Nouveau Quartier
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

      <!-- Quartiers Content -->
      <div class="flex-1 p-6">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <StatsCard
            title="Total Quartiers"
            :value="quartiers.length"
            :icon="Building"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
          />
          
          <StatsCard
            title="Quartiers Actifs"
            :value="activeQuartiers"
            :icon="CheckCircle"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          
          <StatsCard
            title="Total Secteurs"
            :value="totalSecteurs"
            :icon="Map"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
        </div>

        <!-- Quartiers Table -->
        <div class="bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Nom</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Zone</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Commune</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Agents</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Secteurs</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Statut</th>
                <th class="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="quartier in paginatedQuartiers" :key="quartier.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">{{ quartier.nom }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-500">{{ quartier.zoneNom || 'Non spécifiée' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-500">{{ quartier.communeNom || '' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <button
                    @click="openAgentsModal(quartier)"
                    class="text-sm font-medium text-primary-600 hover:text-primary-900 flex items-center"
                  >
                    <UserPlus class="w-3.5 h-3.5 mr-1" />
                    {{ quartierAgentCounts[quartier.id] || 0 }} agent(s)
                  </button>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-900">{{ quartier.secteurs?.length || 0 }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <StatusBadge :status="quartier.statut ? 'ACTIF' : 'INACTIF'" type="quartier" />
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right">
                  <div class="flex items-center justify-end space-x-2">
                    <button @click="editQuartier(quartier)" class="text-primary-600 hover:text-primary-900" title="Modifier">
                      <Edit class="w-4 h-4" />
                    </button>
                    <LogicalDeletionActions
                      :entity="quartier"
                      endpoint="quartier"
                      entity-name="le quartier"
                      :can-delete="canDeleteQuartier"
                      :can-restore="canRestoreQuartier"
                      :display-field="'nom'"
                      @deleted="handleQuartierDeleted"
                      @restored="handleQuartierRestored"
                    />
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div v-if="quartiers.length > itemsPerPage" class="flex items-center justify-between mt-4">
          <div class="text-sm text-gray-500">
            Affichage {{ (currentPage - 1) * itemsPerPage + 1 }}-{{ Math.min(currentPage * itemsPerPage, quartiers.length) }} sur {{ quartiers.length }}
          </div>
          <div class="flex items-center space-x-2">
            <select v-model="itemsPerPage" @change="currentPage = 1" class="text-sm border border-gray-300 rounded-lg px-2 py-1">
              <option :value="5">5</option>
              <option :value="10">10</option>
              <option :value="20">20</option>
              <option :value="50">50</option>
            </select>
            <button @click="currentPage--" :disabled="currentPage === 1" class="px-3 py-1 text-sm border border-gray-300 rounded-lg disabled:opacity-50 hover:bg-gray-50">Précédent</button>
            <span class="text-sm text-gray-600">{{ currentPage }} / {{ totalPages }}</span>
            <button @click="currentPage++" :disabled="currentPage === totalPages" class="px-3 py-1 text-sm border border-gray-300 rounded-lg disabled:opacity-50 hover:bg-gray-50">Suivant</button>
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="loading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
          <p class="mt-2 text-gray-500">Chargement des quartiers...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="quartiers.length === 0" class="text-center py-12">
          <Building class="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 mb-2">Aucun quartier trouvé</h3>
          <p class="text-gray-500 mb-4">Commencez par créer votre premier quartier</p>
          <button @click="showCreateModal = true" class="btn-primary">
            <Plus class="w-4 h-4 mr-2" />
            Nouveau Quartier
          </button>
        </div>
      </div>
    </main>

    <!-- Agent Affectation Modal -->
    <AgentAffectationModal
      :show="showAgentsModal"
      :territory-type="'QUARTIER'"
      :territory-id="agentsModalTerritory?.id"
      :territory-name="agentsModalTerritory?.nom || ''"
      @close="closeAgentsModal"
      @updated="onAffectationUpdated"
    />

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <h3 class="text-lg font-medium text-gray-900">
            {{ editingQuartier ? 'Modifier le Quartier' : 'Nouveau Quartier' }}
          </h3>
          <form @submit.prevent="saveQuartier" class="mt-4 space-y-4">
            <div>
              <label class="form-label">Nom du quartier</label>
              <input
                v-model="quartierForm.nom"
                type="text"
                required
                class="form-input"
                placeholder="Ex: Centre-ville"
              />
            </div>
            
            <div>
              <label class="form-label">Zone</label>
              <select
                v-model="quartierForm.zoneId"
                required
                class="form-input"
              >
                <option value="">Sélectionner une zone</option>
                <option v-for="zone in zones" :key="zone.id" :value="zone.id">
                  {{ zone.nom }} ({{ zone.communeNom }})
                </option>
              </select>
            </div>

            <div class="flex items-center">
              <input
                v-model="quartierForm.statut"
                type="checkbox"
                id="statut"
                class="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
              />
              <label for="statut" class="ml-2 block text-sm text-gray-900">
                Quartier actif
              </label>
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { quartierService, zoneService, affectationService, permissionService, supervisionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import LogicalDeletionActions from '@/components/LogicalDeletionActions.vue'
import AgentAffectationModal from '@/components/AgentAffectationModal.vue'
import { Plus, Building, CheckCircle, Map, Edit, UserPlus } from 'lucide-vue-next'

// State
const loading = ref(false)
const saving = ref(false)
const showCreateModal = ref(false)
const editingQuartier = ref(null)
const quartiers = ref([])
const zones = ref([])

const currentPage = ref(1)
const itemsPerPage = ref(10)

// Agent management state
const showAgentsModal = ref(false)
const agentsModalTerritory = ref(null)
const quartierAgentCounts = ref({})

// Form
const quartierForm = ref({
  nom: '',
  zoneId: '',
  statut: true
})

// Computed
const canDeleteQuartier = computed(() => permissionService.hasPermission('quartiers.delete'))
const canRestoreQuartier = computed(() => permissionService.hasPermission('quartiers.restore'))

const activeQuartiers = computed(() => {
  return quartiers.value.filter(q => q.statut).length
})

const totalSecteurs = computed(() => {
  return quartiers.value.reduce((sum, quartier) => sum + (quartier.secteurs?.length || 0), 0)
})

const totalPages = computed(() => Math.ceil(quartiers.value.length / itemsPerPage.value) || 1)
const paginatedQuartiers = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return quartiers.value.slice(start, start + itemsPerPage.value)
})

// Methods
const totalAgentsInQuartier = (quartier) => {
  return quartierAgentCounts.value[quartier.id] || 0
}

const supervisedZoneIds = ref([])
const supervisedZoneNames = ref([])

const fetchSupervisedZoneIds = async () => {
  try {
    const response = await supervisionService.getSupervisedZones()
    const zones = response.data || []
    supervisedZoneIds.value = zones.map(z => z.id)
    supervisedZoneNames.value = zones.map(z => z.nom)
  } catch (error) {
    console.error('Erreur chargement zones supervisées:', error)
    supervisedZoneIds.value = []
    supervisedZoneNames.value = []
  }
}

const fetchQuartiers = async () => {
  try {
    loading.value = true
    const response = await quartierService.getAllQuartiers()
    let allQuartiers = response.data || []
    if (permissionService.isSuperviseur() && supervisedZoneIds.value.length > 0) {
      allQuartiers = allQuartiers.filter(q =>
        supervisedZoneIds.value.includes(q.zoneId) ||
        supervisedZoneNames.value.includes(q.zoneNom)
      )
    }
    quartiers.value = allQuartiers
  } catch (error) {
    console.error('Erreur chargement quartiers:', error)
    quartiers.value = []
  } finally {
    loading.value = false
  }
}

const fetchZones = async () => {
  try {
    if (permissionService.isSuperviseur()) {
      const response = await supervisionService.getSupervisedZones()
      zones.value = (response.data || []).map(z => ({ id: z.id, nom: z.nom, communeNom: z.communeNom }))
    } else {
      const response = await zoneService.getAllZones()
      zones.value = response.data || []
    }
  } catch (error) {
    console.error('Erreur chargement zones:', error)
    zones.value = []
  }
}

const viewQuartierDetails = (quartier) => {
  console.log('View quartier details:', quartier)
  // Naviguer vers une page de détails ou ouvrir un modal
}

const editQuartier = (quartier) => {
  editingQuartier.value = quartier
  quartierForm.value = {
    nom: quartier.nom,
    zoneId: quartier.zoneId || '',
    statut: quartier.statut
  }
  showCreateModal.value = true
}

const deleteQuartier = async (quartier) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer le quartier "${quartier.nom}"?`)) {
    try {
      await quartierService.deleteQuartier(quartier.id)
      await fetchQuartiers()
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const saveQuartier = async () => {
  saving.value = true
  try {
    const quartierData = {
      nom: quartierForm.value.nom,
      zoneId: quartierForm.value.zoneId,
      statut: quartierForm.value.statut
    }

    if (editingQuartier.value) {
      // Mettre à jour le quartier existant
      await quartierService.updateQuartier(editingQuartier.value.id, quartierData)
    } else {
      // Créer un nouveau quartier
      await quartierService.createQuartier(quartierData)
    }
    
    await fetchQuartiers()
    closeModal()
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement:', error)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingQuartier.value = null
  quartierForm.value = {
    nom: '',
    zoneId: '',
    statut: true
  }
}

// Méthodes pour la suppression logique
const handleQuartierDeleted = (quartier) => {
  console.log('Quartier supprimé:', quartier)
  fetchQuartiers()
  alert('Quartier supprimé avec succès')
}

const handleQuartierRestored = (quartier) => {
  console.log('Quartier restauré:', quartier)
  fetchQuartiers()
  alert('Quartier restauré avec succès')
}

// Agent management methods
const openAgentsModal = (quartier) => {
  agentsModalTerritory.value = quartier
  showAgentsModal.value = true
}

const closeAgentsModal = () => {
  showAgentsModal.value = false
  agentsModalTerritory.value = null
}

const onAffectationUpdated = async () => {
  if (agentsModalTerritory.value) {
    try {
      const res = await affectationService.getByTerritory('QUARTIER', agentsModalTerritory.value.id)
      quartierAgentCounts.value[agentsModalTerritory.value.id] = (res.data || []).length
    } catch (e) {
      console.error('Erreur refresh count:', e)
    }
  }
}

const fetchQuartierAgentCounts = async () => {
  for (const q of quartiers.value) {
    try {
      const res = await affectationService.getByTerritory('QUARTIER', q.id)
      quartierAgentCounts.value[q.id] = (res.data || []).length
    } catch (e) {
      quartierAgentCounts.value[q.id] = 0
    }
  }
}

// Lifecycle
onMounted(async () => {
  if (permissionService.isSuperviseur()) {
    await fetchSupervisedZoneIds()
  }
  await Promise.all([fetchQuartiers(), fetchZones()])
  await fetchQuartierAgentCounts()
})
</script>

<style scoped>
.btn-primary {
  @apply bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition-colors flex items-center;
}

.btn-secondary {
  @apply bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300 transition-colors;
}

.form-input {
  @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent;
}

.form-label {
  @apply block text-sm font-medium text-gray-700 mb-1;
}
</style>
