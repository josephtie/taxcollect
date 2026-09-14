<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Secteurs</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button @click="showCreateModal = true" class="btn-primary">
              <Plus class="w-4 h-4 mr-2" />
              Nouveau Secteur
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="flex">
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <div class="flex-1 p-6">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <StatsCard
            title="Total Secteurs"
            :value="secteurs.length"
            :icon="Map"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
          />
          <StatsCard
            title="Secteurs avec GPS"
            :value="secteursAvecGPS"
            :icon="MapPin"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          <StatsCard
            title="Total Quartiers"
            :value="quartiers.length"
            :icon="Building"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
        </div>

        <div class="bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Nom</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Quartier</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Rue</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">N° Lot</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">GPS</th>
                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Agents</th>
                <th class="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="secteur in paginatedSecteurs" :key="secteur.id" class="hover:bg-gray-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">{{ secteur.nom }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-500">{{ secteur.quartierNom || 'Non spécifié' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-500">{{ secteur.rue || '-' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm text-gray-500">{{ secteur.numeroLot || '-' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <div v-if="secteur.latitude && secteur.longitude" class="text-sm text-gray-500">
                    {{ secteur.latitude }}, {{ secteur.longitude }}
                  </div>
                  <div v-else class="text-sm text-gray-400">-</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <button
                    @click="openAgentsModal(secteur)"
                    class="text-sm font-medium text-primary-600 hover:text-primary-900 flex items-center"
                  >
                    <UserPlus class="w-3.5 h-3.5 mr-1" />
                    {{ secteurAgentCounts[secteur.id] || 0 }} agent(s)
                  </button>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right">
                  <div class="flex items-center justify-end space-x-2">
                    <button @click="editSecteur(secteur)" class="text-warning-600 hover:text-warning-900" title="Modifier">
                      <Edit class="w-4 h-4" />
                    </button>
                    <LogicalDeletionActions
                      :entity="secteur"
                      endpoint="secteur"
                      entity-name="le secteur"
                      :can-delete="canDeleteSecteur"
                      :can-restore="canRestoreSecteur"
                      :display-field="'nom'"
                      @deleted="handleSecteurDeleted"
                      @restored="handleSecteurRestored"
                    />
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div v-if="secteurs.length > itemsPerPage" class="flex items-center justify-between mt-4">
          <div class="text-sm text-gray-500">
            Affichage {{ (currentPage - 1) * itemsPerPage + 1 }}-{{ Math.min(currentPage * itemsPerPage, secteurs.length) }} sur {{ secteurs.length }}
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

        <div v-if="secteurs.length === 0 && !loading" class="text-center py-12">
          <Map class="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 mb-2">Aucun secteur</h3>
          <p class="text-gray-500 mb-4">Commencez par créer votre premier secteur</p>
          <button @click="showCreateModal = true" class="btn-primary">
            <Plus class="w-4 h-4 mr-2" />
            Créer un secteur
          </button>
        </div>
      </div>
    </main>

    <!-- Agent Affectation Modal -->
    <AgentAffectationModal
      :show="showAgentsModal"
      :territory-type="'SECTEUR'"
      :territory-id="agentsModalTerritory?.id"
      :territory-name="agentsModalTerritory?.nom || ''"
      @close="closeAgentsModal"
      @updated="onAffectationUpdated"
    />

    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <h3 class="modal-header">
          {{ editingSecteur ? 'Modifier' : 'Créer' }} un Secteur
        </h3>

        <form @submit.prevent="saveSecteur">
          <div class="space-y-4">
            <div>
              <label class="form-label">Nom du secteur</label>
              <input
                v-model="secteurForm.nom"
                type="text"
                required
                class="form-input"
                placeholder="Ex: Secteur A"
              />
            </div>

            <div>
              <label class="form-label">Quartier</label>
              <select
                v-model="secteurForm.quartierId"
                required
                class="form-input"
              >
                <option value="">Sélectionner un quartier</option>
                <option
                  v-for="quartier in quartiers"
                  :key="quartier.id"
                  :value="quartier.id"
                >
                  {{ quartier.nom }} ({{ quartier.zoneNom }})
                </option>
              </select>
            </div>

            <div>
              <label class="form-label">Point de repère (latitude / longitude)</label>
              <p class="text-xs text-gray-500 mb-2">Point central ou repère approximatif du secteur</p>
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <input
                    v-model="secteurForm.latitude"
                    type="number"
                    step="any"
                    class="form-input"
                    placeholder="Ex: 5.2048"
                  />
                </div>
                <div>
                  <input
                    v-model="secteurForm.longitude"
                    type="number"
                    step="any"
                    class="form-input"
                    placeholder="Ex: -3.7467"
                  />
                </div>
              </div>
            </div>

            <div>
              <label class="form-label">Rue</label>
              <input
                v-model="secteurForm.rue"
                type="text"
                class="form-input"
                placeholder="Ex: Rue du Marché"
              />
            </div>

            <div>
              <label class="form-label">Numéro de lot</label>
              <input
                v-model="secteurForm.numeroLot"
                type="text"
                class="form-input"
                placeholder="Ex: Lot 42"
              />
            </div>

            <div>
              <label class="form-label">Périmètre géographique complet (polygone)</label>
              <p class="text-xs text-gray-500 mb-2">Dessinez les limites du secteur sur la carte. Un polygone définit précisément la zone couverte.</p>
              <div class="h-[300px] border border-gray-300 rounded-lg overflow-hidden">
                <TerritoryMap
                  ref="secteurMapRef"
                  height="300px"
                  :initial-geo-json="secteurForm.geometryGeoJson"
                  :parent-layers="mapParentLayers"
                  :highlight-geo-json="mapParentLayers.length > 0 ? mapParentLayers[0].geoJson : null"
                  :editable="true"
                  @polygon-drawn="onPolygonDrawn"
                  @polygon-cleared="onPolygonCleared"
                />
              </div>
            </div>
          </div>

          <div class="flex justify-end space-x-3 mt-6">
            <button type="button" @click="closeModal" class="btn-secondary">
              Annuler
            </button>
            <button type="submit" :disabled="saving" class="btn-primary">
              {{ saving ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { secteurService, quartierService, affectationService, permissionService, supervisionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import LogicalDeletionActions from '@/components/LogicalDeletionActions.vue'
import AgentAffectationModal from '@/components/AgentAffectationModal.vue'
import TerritoryMap from '@/components/TerritoryMap.vue'
import { Map, MapPin, Building, Plus, Edit, UserPlus } from 'lucide-vue-next'

const loading = ref(false)
const showCreateModal = ref(false)
const editingSecteur = ref(null)
const saving = ref(false)

const secteurs = ref([])
const quartiers = ref([])

const currentPage = ref(1)
const itemsPerPage = ref(10)

// Agent management state
const showAgentsModal = ref(false)
const agentsModalTerritory = ref(null)
const secteurAgentCounts = ref({})

const secteurForm = ref({
  nom: '',
  quartierId: '',
  latitude: '',
  longitude: '',
  rue: '',
  numeroLot: '',
  geometryGeoJson: null
})
const secteurMapRef = ref(null)
const drawnGeometry = ref(null)
const mapParentLayers = ref([])

const onPolygonDrawn = (geoJson) => {
  drawnGeometry.value = geoJson
}

const onPolygonCleared = () => {
  drawnGeometry.value = null
}

watch(() => secteurForm.value.quartierId, async (newQuartierId) => {
  if (!newQuartierId) {
    mapParentLayers.value = []
    return
  }
  const selectedQuartier = quartiers.value.find(q => q.id == newQuartierId)
  if (selectedQuartier && selectedQuartier.geometryGeoJson) {
    mapParentLayers.value = [{
      type: 'quartier',
      name: selectedQuartier.nom,
      geoJson: selectedQuartier.geometryGeoJson
    }]
  } else {
    mapParentLayers.value = []
  }
  nextTick(() => {
    if (secteurMapRef.value) {
      secteurMapRef.value.invalidateMapSize()
    }
  })
})

const canDeleteSecteur = computed(() => permissionService.hasPermission('dashboard.view'))
const canRestoreSecteur = computed(() => permissionService.hasPermission('dashboard.view'))

const secteursAvecGPS = computed(() => {
  return secteurs.value.filter(s => s.latitude && s.longitude).length
})

const totalPages = computed(() => Math.ceil(secteurs.value.length / itemsPerPage.value) || 1)
const paginatedSecteurs = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return secteurs.value.slice(start, start + itemsPerPage.value)
})

const supervisedZoneIds = ref([])
const supervisedZoneNames = ref([])
const supervisedQuartierIds = ref([])
const supervisedQuartierNames = ref([])

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

const fetchSecteurs = async () => {
  try {
    loading.value = true
    const response = await secteurService.getAllSecteurs()
    let allSecteurs = response.data || []
    if (permissionService.isSuperviseur() && supervisedQuartierIds.value.length > 0) {
      allSecteurs = allSecteurs.filter(s =>
        supervisedQuartierIds.value.includes(s.quartierId) ||
        supervisedQuartierNames.value.includes(s.quartierNom)
      )
    }
    secteurs.value = allSecteurs
  } catch (error) {
    console.error('Erreur chargement secteurs:', error)
    secteurs.value = []
  } finally {
    loading.value = false
  }
}

const fetchQuartiers = async () => {
  try {
    const response = await quartierService.getAllQuartiers()
    let allQuartiers = response.data || []
    if (permissionService.isSuperviseur() && supervisedZoneIds.value.length > 0) {
      allQuartiers = allQuartiers.filter(q =>
        supervisedZoneIds.value.includes(q.zoneId) ||
        supervisedZoneNames.value.includes(q.zoneNom)
      )
      supervisedQuartierIds.value = allQuartiers.map(q => q.id)
      supervisedQuartierNames.value = allQuartiers.map(q => q.nom)
    }
    quartiers.value = allQuartiers
  } catch (error) {
    console.error('Erreur chargement quartiers:', error)
    quartiers.value = [
      { id: 1, nom: 'Centre Ville', zoneNom: 'Zone Nord' },
      { id: 2, nom: 'Zone France', zoneNom: 'Zone Nord' }
    ]
  }
}

const viewSecteurDetails = (secteur) => {
  console.log('View secteur details:', secteur)
}

const editSecteur = (secteur) => {
  editingSecteur.value = secteur
  secteurForm.value = {
    nom: secteur.nom,
    quartierId: secteur.quartierId || '',
    latitude: secteur.latitude || '',
    longitude: secteur.longitude || '',
    rue: secteur.rue || '',
    numeroLot: secteur.numeroLot || '',
    geometryGeoJson: secteur.geometryGeoJson || null
  }
  drawnGeometry.value = secteur.geometryGeoJson || null
  showCreateModal.value = true
}

const saveSecteur = async () => {
  saving.value = true
  try {
    const secteurData = {
      nom: secteurForm.value.nom,
      quartierId: secteurForm.value.quartierId,
      latitude: secteurForm.value.latitude || null,
      longitude: secteurForm.value.longitude || null,
      rue: secteurForm.value.rue || null,
      numeroLot: secteurForm.value.numeroLot || null,
      geometryGeoJson: drawnGeometry.value || null
    }

    if (editingSecteur.value) {
      await secteurService.updateSecteur(editingSecteur.value.id, secteurData)
    } else {
      await secteurService.createSecteur(secteurData)
    }

    await fetchSecteurs()
    closeModal()
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement:', error)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingSecteur.value = null
  drawnGeometry.value = null
  mapParentLayers.value = []
  secteurForm.value = {
    nom: '',
    quartierId: '',
    latitude: '',
    longitude: '',
    rue: '',
    numeroLot: '',
    geometryGeoJson: null
  }
}

const handleSecteurDeleted = (secteur) => {
  console.log('Secteur supprimé:', secteur)
  fetchSecteurs()
  alert('Secteur supprimé avec succès')
}

const handleSecteurRestored = (secteur) => {
  console.log('Secteur restauré:', secteur)
  fetchSecteurs()
  alert('Secteur restauré avec succès')
}

// Agent management methods
const openAgentsModal = (secteur) => {
  agentsModalTerritory.value = secteur
  showAgentsModal.value = true
}

const closeAgentsModal = () => {
  showAgentsModal.value = false
  agentsModalTerritory.value = null
}

const onAffectationUpdated = async () => {
  if (agentsModalTerritory.value) {
    try {
      const res = await affectationService.getByTerritory('SECTEUR', agentsModalTerritory.value.id)
      secteurAgentCounts.value[agentsModalTerritory.value.id] = (res.data || []).length
    } catch (e) {
      console.error('Erreur refresh count:', e)
    }
  }
}

const fetchSecteurAgentCounts = async () => {
  for (const s of secteurs.value) {
    try {
      const res = await affectationService.getByTerritory('SECTEUR', s.id)
      secteurAgentCounts.value[s.id] = (res.data || []).length
    } catch (e) {
      secteurAgentCounts.value[s.id] = 0
    }
  }
}

onMounted(async () => {
  if (permissionService.isSuperviseur()) {
    await fetchSupervisedZoneIds()
    const qResponse = await quartierService.getAllQuartiers()
    const allQ = qResponse.data || []
    const filteredQ = allQ.filter(q =>
      supervisedZoneIds.value.includes(q.zoneId) ||
      supervisedZoneNames.value.includes(q.zoneNom)
    )
    supervisedQuartierIds.value = filteredQ.map(q => q.id)
    supervisedQuartierNames.value = filteredQ.map(q => q.nom)
  }
  await Promise.all([fetchSecteurs(), fetchQuartiers()])
  await fetchSecteurAgentCounts()
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
