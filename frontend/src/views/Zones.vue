<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Zones</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="showCreateModal = true"
              class="btn-primary"
            >
              <Plus class="w-4 h-4 mr-2" />
              Nouvelle Zone
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

      <!-- Zones Content -->
      <div class="flex-1 p-6">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <StatsCard
            title="Total Zones"
            :value="zones.length"
            :icon="MapPin"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
          />
          
          <StatsCard
            title="Zones Actives"
            :value="activeZones"
            :icon="CheckCircle"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          
          <StatsCard
            title="Agents Assignés"
            :value="totalAssignedAgents"
            :icon="Users"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
        </div>

        <!-- Zones Table -->
        <div class="bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Nom</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Commune</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Agents</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Statut</th>
                <th class="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="zone in paginatedZones" :key="zone.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">{{ zone.nom }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-500">{{ zone.communeNom || 'Non spécifiée' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <button
                    @click="openAgentsModal(zone)"
                    class="text-sm font-medium text-primary-600 hover:text-primary-900 flex items-center"
                  >
                    <UserPlus class="w-3.5 h-3.5 mr-1" />
                    {{ zoneAgentCounts[zone.id] ?? zone.agents?.length ?? 0 }} agent(s)
                  </button>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <StatusBadge :status="zone.statut ? 'ACTIF' : 'INACTIF'" type="zone" />
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right">
                  <div class="flex items-center justify-end space-x-2">
                    <button @click="editZone(zone)" class="text-warning-600 hover:text-warning-900" title="Modifier">
                      <Edit class="w-4 h-4" />
                    </button>
                    <LogicalDeletionActions
                      :entity="zone"
                      endpoint="zone"
                      entity-name="la zone"
                      :can-delete="canDeleteZone"
                      :can-restore="canRestoreZone"
                      :display-field="'nom'"
                      @deleted="handleZoneDeleted"
                      @restored="handleZoneRestored"
                    />
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div v-if="zones.length > itemsPerPage" class="flex items-center justify-between mt-4">
          <div class="text-sm text-gray-500">
            Affichage {{ (currentPage - 1) * itemsPerPage + 1 }}-{{ Math.min(currentPage * itemsPerPage, zones.length) }} sur {{ zones.length }}
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

        <!-- Empty State -->
        <div v-if="zones.length === 0 && !loading" class="text-center py-12">
          <MapPin class="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune zone</h3>
          <p class="text-gray-500 mb-4">Commencez par créer votre première zone de collecte</p>
          <button @click="showCreateModal = true" class="btn-primary">
            <Plus class="w-4 h-4 mr-2" />
            Créer une zone
          </button>
        </div>
      </div>
    </main>

    <!-- Agent Affectation Modal -->
    <AgentAffectationModal
      :show="showAgentsModal"
      :territory-type="'ZONE'"
      :territory-id="agentsModalZone?.id"
      :territory-name="agentsModalZone?.nom || ''"
      @close="closeAgentsModal"
      @updated="onAffectationUpdated"
    />

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="modal-header">
          {{ editingZone ? 'Modifier' : 'Créer' }} une Zone
        </h3>
        
        <form @submit.prevent="saveZone">
          <div class="space-y-4">
            <div>
              <label class="form-label">Nom de la zone</label>
              <input
                v-model="zoneForm.nom"
                type="text"
                required
                class="form-input"
                placeholder="Ex: Marché Central"
              />
            </div>
            
            <div>
              <label class="form-label">Commune</label>
              <select
                v-model="zoneForm.communeId"
                required
                class="form-input"
              >
                <option value="">Sélectionner une commune</option>
                <option
                  v-for="commune in communes"
                  :key="commune.id"
                  :value="commune.id"
                >
                  {{ commune.nom }}
                </option>
              </select>
            </div>
            
            <div>
              <label class="flex items-center">
                <input
                  v-model="zoneForm.statut"
                  type="checkbox"
                  class="form-checkbox mr-2"
                />
                <span class="text-sm font-medium text-gray-700">Zone active</span>
              </label>
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
import { zoneService, communeService, affectationService, permissionService, supervisionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import LogicalDeletionActions from '@/components/LogicalDeletionActions.vue'
import AgentAffectationModal from '@/components/AgentAffectationModal.vue'
import {
  MapPin,
  CheckCircle,
  Users,
  Plus,
  Edit,
  UserPlus
} from 'lucide-vue-next'

// State
const loading = ref(false)
const showCreateModal = ref(false)
const editingZone = ref(null)
const saving = ref(false)

const zones = ref([])
const communes = ref([])

const currentPage = ref(1)
const itemsPerPage = ref(10)

// Agent management state
const showAgentsModal = ref(false)
const agentsModalZone = ref(null)
const zoneAgentCounts = ref({})

const zoneForm = ref({
  nom: '',
  communeId: '',
  statut: true
})

// Computed
const canDeleteZone = computed(() => permissionService.hasPermission('zones.delete'))
const canRestoreZone = computed(() => permissionService.hasPermission('zones.restore'))

const activeZones = computed(() => {
  return zones.value.filter(zone => zone.statut === true).length
})

const totalAssignedAgents = computed(() => {
  return Object.values(zoneAgentCounts.value).reduce((sum, count) => sum + count, 0) ||
    zones.value.reduce((sum, zone) => sum + (zone.agents?.length || 0), 0)
})

const totalPages = computed(() => Math.ceil(zones.value.length / itemsPerPage.value) || 1)
const paginatedZones = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return zones.value.slice(start, start + itemsPerPage.value)
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

const fetchZones = async () => {
  try {
    loading.value = true
    if (permissionService.isSuperviseur()) {
      const response = await supervisionService.getSupervisedZones()
      zones.value = (response.data || []).map(z => ({
        id: z.id,
        nom: z.nom,
        communeNom: z.communeNom,
        statut: z.statut,
        agents: z.agents || []
      }))
    } else {
      const response = await zoneService.getAllZones()
      zones.value = response.data
    }
  } catch (error) {
    console.error('Erreur chargement zones:', error)
    zones.value = []
  } finally {
    loading.value = false
  }
}

const fetchCommunes = async () => {
  try {
    const response = await communeService.getAllCommunes()
    communes.value = response.data
  } catch (error) {
    console.error('Erreur chargement communes:', error)
    communes.value = []
  }
}

const viewZoneDetails = (zone) => {
  console.log('View zone details:', zone)
  // Naviguer vers une page de détails ou ouvrir un modal
}

const editZone = (zone) => {
  editingZone.value = zone
  zoneForm.value = {
    nom: zone.nom,
    communeId: zone.communeId || '',
    statut: zone.statut
  }
  showCreateModal.value = true
}

const deleteZone = async (zone) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer la zone "${zone.nom}"?`)) {
    try {
      await zoneService.deleteZone(zone.id)
      await fetchZones()
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const saveZone = async () => {
  saving.value = true
  try {
    const zoneData = {
      nom: zoneForm.value.nom,
      communeId: zoneForm.value.communeId,
      statut: zoneForm.value.statut
    }

    if (editingZone.value) {
      // Mettre à jour la zone existante
      await zoneService.updateZone(editingZone.value.id, zoneData)
    } else {
      // Créer une nouvelle zone
      await zoneService.createZone(zoneData)
    }
    
    await fetchZones()
    closeModal()
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement:', error)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingZone.value = null
  zoneForm.value = {
    nom: '',
    communeId: '',
    statut: true
  }
}

// Méthodes pour la suppression logique
const handleZoneDeleted = (zone) => {
  console.log('Zone supprimée:', zone)
  fetchZones()
  alert('Zone supprimée avec succès')
}

const handleZoneRestored = (zone) => {
  console.log('Zone restaurée:', zone)
  fetchZones()
  alert('Zone restaurée avec succès')
}

// Agent management methods
const openAgentsModal = async (zone) => {
  agentsModalZone.value = zone
  showAgentsModal.value = true
}

const closeAgentsModal = () => {
  showAgentsModal.value = false
  agentsModalZone.value = null
}

const onAffectationUpdated = async () => {
  if (agentsModalZone.value) {
    try {
      const res = await affectationService.getByTerritory('ZONE', agentsModalZone.value.id)
      zoneAgentCounts.value[agentsModalZone.value.id] = (res.data || []).length
    } catch (e) {
      console.error('Erreur refresh count:', e)
    }
  }
}

const fetchZoneAgentCounts = async () => {
  for (const zone of zones.value) {
    try {
      const res = await affectationService.getByTerritory('ZONE', zone.id)
      zoneAgentCounts.value[zone.id] = (res.data || []).length
    } catch (e) {
      zoneAgentCounts.value[zone.id] = zone.agents?.length || 0
    }
  }
}

// Lifecycle
onMounted(async () => {
  await Promise.all([fetchZones(), fetchCommunes()])
  await fetchZoneAgentCounts()
})
</script>
