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

        <!-- Zones Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="zone in zones"
            :key="zone.id"
            class="bg-white rounded-lg shadow-soft border border-gray-100 p-6 hover:shadow-medium transition-shadow"
          >
            <div class="flex items-start justify-between mb-4">
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ zone.nom }}</h3>
                <p class="text-sm text-gray-500">{{ zone.quartier?.nom || 'Non spécifié' }} - {{ zone.quartier?.commune?.nom || '' }}</p>
              </div>
              <StatusBadge 
                :status="zone.statut ? 'ACTIF' : 'INACTIF'" 
                type="zone"
              />
            </div>

            <div class="space-y-3">
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-600">Agents assignés</span>
                <span class="text-sm font-medium text-gray-900">{{ zone.agents?.length || 0 }}</span>
              </div>
              
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-600">Taxes collectées</span>
                <span class="text-sm font-medium text-gray-900">{{ zone.taxes?.length || 0 }}</span>
              </div>
              
              <div class="flex items-center justify-between">
                <span class="text-sm text-gray-600">Statut</span>
                <span class="text-sm font-medium" :class="zone.statut ? 'text-green-600' : 'text-red-600'">
                  {{ zone.statut ? 'Actif' : 'Inactif' }}
                </span>
              </div>
            </div>

            <div class="mt-4 pt-4 border-t border-gray-200 flex justify-between">
              <button
                @click="viewZoneDetails(zone)"
                class="text-primary-600 hover:text-primary-900 text-sm font-medium"
              >
                Voir détails
              </button>
              <div class="flex items-center space-x-2">
                <button
                  @click="editZone(zone)"
                  class="text-warning-600 hover:text-warning-900"
                >
                  <Edit class="w-4 h-4" />
                </button>
                
                <!-- Actions de suppression logique -->
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
            </div>
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

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
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
              <label class="form-label">Quartier</label>
              <select
                v-model="zoneForm.quartierId"
                required
                class="form-input"
              >
                <option value="">Sélectionner un quartier</option>
                <option
                  v-for="quartier in quartiers"
                  :key="quartier.id"
                  :value="quartier.id"
                >
                  {{ quartier.nom }} ({{ quartier.commune?.nom }})
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
import { zoneService, quartierService, permissionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import LogicalDeletionActions from '@/components/LogicalDeletionActions.vue'
import {
  MapPin,
  CheckCircle,
  Users,
  Plus,
  Edit
} from 'lucide-vue-next'

// State
const loading = ref(false)
const showCreateModal = ref(false)
const editingZone = ref(null)
const saving = ref(false)

const zones = ref([])
const quartiers = ref([])

const zoneForm = ref({
  nom: '',
  quartierId: '',
  statut: true
})

// Computed
const canDeleteZone = computed(() => permissionService.hasPermission('zones.delete'))
const canRestoreZone = computed(() => permissionService.hasPermission('zones.restore'))

const activeZones = computed(() => {
  return zones.value.filter(zone => zone.statut === true).length
})

const totalAssignedAgents = computed(() => {
  return zones.value.reduce((sum, zone) => sum + (zone.agents?.length || 0), 0)
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
    const response = await zoneService.getAllZones()
    zones.value = response.data
  } catch (error) {
    console.error('Erreur chargement zones:', error)
    // Fallback avec données mock pour Grand-Bassam
    zones.value = [
      {
        id: 1,
        nom: 'Centre Ville - Ancienne Administration',
        quartier: { id: 1, nom: 'Centre Ville', commune: { nom: 'Grand-Bassam' } },
        statut: true,
        agents: [
          { id: 1, nom: 'Kouadio Konan', contact: 'kouadio@tax.ci' },
          { id: 2, nom: 'Awa Touré', contact: 'awa@tax.ci' }
        ],
        taxes: []
      },
      {
        id: 2,
        nom: 'Zone France',
        quartier: { id: 2, nom: 'Zone France', commune: { nom: 'Grand-Bassam' } },
        statut: true,
        agents: [],
        taxes: []
      }
    ]
  } finally {
    loading.value = false
  }
}

const fetchQuartiers = async () => {
  try {
    const response = await quartierService.getAllQuartiers()
    quartiers.value = response.data
  } catch (error) {
    console.error('Erreur chargement quartiers:', error)
    // Fallback avec données mock pour Grand-Bassam
    quartiers.value = [
      { id: 1, nom: 'Centre Ville', commune: { nom: 'Grand-Bassam' } },
      { id: 2, nom: 'Zone France', commune: { nom: 'Grand-Bassam' } },
      { id: 3, nom: 'Quartier Ghana', commune: { nom: 'Grand-Bassam' } },
      { id: 4, nom: 'Zone Industrielle', commune: { nom: 'Grand-Bassam' } },
      { id: 5, nom: 'Quartier Sokoura', commune: { nom: 'Grand-Bassam' } },
      { id: 6, nom: 'Bord de Mer - France', commune: { nom: 'Grand-Bassam' } }
    ]
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
    quartierId: zone.quartier?.id || '',
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
      quartierId: zoneForm.value.quartierId,
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
    quartierId: '',
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

// Lifecycle
onMounted(async () => {
  await Promise.all([fetchZones(), fetchQuartiers()])
})
</script>
