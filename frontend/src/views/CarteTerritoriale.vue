<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Carte Territoriale</h1>
          </div>
          <div class="flex items-center space-x-3">
            <select v-model="selectedLevel" class="form-input w-48">
              <option value="commune">Communes</option>
              <option value="zone">Zones</option>
              <option value="quartier">Quartiers</option>
              <option value="secteur">Secteurs</option>
            </select>
          </div>
        </div>
      </div>
    </header>

    <main class="flex">
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <div class="flex-1 p-6">
        <!-- Single map with side panel -->
        <div class="flex gap-4" style="height: calc(100vh - 120px);">
          <!-- Entity list panel -->
          <div class="w-72 flex-shrink-0 bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden flex flex-col">
            <div class="px-4 py-3 border-b border-gray-100">
              <h3 class="font-semibold text-gray-900">{{ levelLabel }}</h3>
              <p class="text-xs text-gray-500 mt-1">
                {{ editingEntity ? 'Dessinez sur la carte' : 'Cliquez pour délimiter' }}
              </p>
            </div>
            <div class="flex-1 overflow-y-auto p-3 space-y-2">
              <div
                v-for="entity in entitiesForLevel"
                :key="entity.id"
                @click="selectEntityForEdit(entity)"
                :class="[
                  'p-3 rounded-lg border cursor-pointer transition-all',
                  editingEntity?.id === entity.id
                    ? 'border-primary-500 bg-primary-50 ring-2 ring-primary-200'
                    : 'border-gray-200 hover:border-gray-300'
                ]"
              >
                <div class="flex items-center justify-between">
                  <span class="font-medium text-gray-900 text-sm">{{ entity.nom }}</span>
                  <span
                    :class="[
                      'w-2 h-2 rounded-full',
                      entity.geometryGeoJson ? 'bg-green-500' : 'bg-gray-300'
                    ]"
                    :title="entity.geometryGeoJson ? 'Délimité' : 'Non délimité'"
                  ></span>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                  {{ entity.geometryGeoJson ? 'Cliquer pour modifier' : 'Cliquer pour délimiter' }}
                </p>
                <p v-if="entity.quartierNom || entity.zoneNom || entity.communeNom" class="text-xs text-gray-400 mt-1">
                  <span v-if="entity.communeNom">{{ entity.communeNom }}</span>
                  <span v-if="entity.zoneNom"> › {{ entity.zoneNom }}</span>
                  <span v-if="entity.quartierNom"> › {{ entity.quartierNom }}</span>
                </p>
              </div>
              <div v-if="entitiesForLevel.length === 0" class="text-center text-gray-400 text-sm py-8">
                Aucune entité
              </div>
            </div>
          </div>

          <!-- Map area -->
          <div class="flex-1 bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden flex flex-col">
            <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <h3 class="font-semibold text-gray-900">
                  {{ editingEntity ? 'Édition — ' + editingEntity.nom : 'Carte interactive — Grand-Bassam' }}
                </h3>
                <span v-if="editingEntity" class="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">
                  Mode édition
                </span>
              </div>
              <div class="flex items-center space-x-4 text-xs text-gray-600">
                <span class="flex items-center"><span class="w-3 h-3 rounded-full bg-blue-500 mr-1"></span>Communes</span>
                <span class="flex items-center"><span class="w-3 h-3 rounded-full bg-green-500 mr-1"></span>Zones</span>
                <span class="flex items-center"><span class="w-3 h-3 rounded-full bg-amber-500 mr-1"></span>Quartiers</span>
                <span class="flex items-center"><span class="w-3 h-3 rounded-full bg-purple-500 mr-1"></span>Secteurs</span>
              </div>
            </div>

            <!-- Edit toolbar -->
            <div v-if="editingEntity" class="px-4 py-2 bg-amber-50 border-b border-amber-100 flex items-center justify-between">
              <div class="text-sm text-amber-800">
                <!-- Breadcrumb of ancestors -->
                <div v-if="ancestorLayers.length > 0" class="flex items-center space-x-1 text-xs mb-1">
                  <span class="text-gray-500">Hiérarchie :</span>
                  <span v-for="(al, idx) in ancestorLayers" :key="al.type" class="flex items-center space-x-1">
                    <span
                      class="inline-flex items-center px-1.5 py-0.5 rounded"
                      :style="{ backgroundColor: parentStyleMap[al.type]?.color + '15', color: parentStyleMap[al.type]?.color }"
                    >
                      {{ al.name }}
                    </span>
                    <span v-if="idx < ancestorLayers.length - 1" class="text-gray-400">›</span>
                  </span>
                </div>
                <p v-if="containmentError" class="text-xs text-red-600 font-medium mb-1">
                  ⚠ {{ containmentError }}
                </p>
                <p v-else-if="ancestorLayers.length > 0" class="text-xs text-green-700 mb-1">
                  Dessinez à l'intérieur des limites parentales affichées.
                </p>
                <p class="text-xs">
                  Cliquez sur l'outil polygone, puis cliquez sur la carte pour placer les sommets. Pour fermer : cliquez sur le <strong>1er point</strong> ou <strong>double-cliquez</strong>.
                </p>
              </div>
              <div class="flex items-center space-x-2 flex-shrink-0">
                <button @click="clearDrawing" class="text-xs text-gray-600 hover:text-gray-800 px-2 py-1">
                  Effacer
                </button>
                <button @click="cancelEdit" class="btn-secondary text-sm">
                  Annuler
                </button>
                <button
                  @click="saveGeometry"
                  :disabled="saving || !drawnGeometry || !!containmentError"
                  class="btn-primary text-sm"
                >
                  {{ saving ? '...' : 'Enregistrer' }}
                </button>
              </div>
            </div>

            <div class="flex-1 relative">
              <TerritoryMap
                ref="mapRef"
                :height="'100%'"
                :center="[5.2048, -3.7467]"
                :zoom="13"
                :existing-polygons="displayPolygons"
                :initial-geo-json="editingEntity?.geometryGeoJson"
                :highlight-geo-json="parentHighlightGeoJson"
                :parent-layers="ancestorLayers"
                :editable="!!editingEntity"
                @polygon-drawn="onPolygonDrawn"
                @polygon-cleared="onPolygonCleared"
                @containment-violation="onContainmentViolation"
              />
              <div v-if="!editingEntity && allPolygons.length === 0" class="absolute inset-0 flex items-center justify-center pointer-events-none">
                <div class="bg-white/90 px-6 py-4 rounded-lg shadow-lg text-center max-w-sm">
                  <MapPin class="w-8 h-8 text-gray-400 mx-auto mb-2" />
                  <p class="text-sm font-medium text-gray-700">Aucune délimitation sur la carte</p>
                  <p class="text-xs text-gray-500 mt-1">Sélectionnez une entité à gauche pour dessiner son polygone</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { communeService, quartierService, zoneService, secteurService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import TerritoryMap from '@/components/TerritoryMap.vue'
import { MapPin } from 'lucide-vue-next'

const selectedLevel = ref('secteur')
const editingEntity = ref(null)
const saving = ref(false)
const drawnGeometry = ref(null)
const mapRef = ref(null)
const containmentError = ref('')

const parentStyleMap = {
  commune: { color: '#3b82f6', weight: 4, fillOpacity: 0.05, dashArray: '10, 6' },
  zone: { color: '#10b981', weight: 3, fillOpacity: 0.05, dashArray: '8, 4' },
  quartier: { color: '#f59e0b', weight: 2, fillOpacity: 0.05, dashArray: '6, 3' }
}

const communes = ref([])
const zones = ref([])
const quartiers = ref([])
const secteurs = ref([])

const levelLabel = computed(() => {
  const labels = { commune: 'Communes', zone: 'Zones', quartier: 'Quartiers', secteur: 'Secteurs' }
  return labels[selectedLevel.value]
})

// When editing, highlight the parent entity's polygon and show only relevant entities
const parentHighlightGeoJson = computed(() => {
  if (!editingEntity.value) return null
  const entity = editingEntity.value

  switch (selectedLevel.value) {
    case 'zone':
      // Zone → highlight its commune
      if (entity.communeId) {
        const commune = communes.value.find(c => c.id === entity.communeId)
        return commune?.geometryGeoJson || null
      }
      return null
    case 'quartier':
      // Quartier → highlight its zone
      if (entity.zoneId) {
        const zone = zones.value.find(z => z.id === entity.zoneId)
        return zone?.geometryGeoJson || null
      }
      return null
    case 'secteur':
      // Secteur → highlight its quartier
      if (entity.quartierId) {
        const quartier = quartiers.value.find(q => q.id === entity.quartierId)
        return quartier?.geometryGeoJson || null
      }
      return null
    default:
      return null
  }
})

const parentLabel = computed(() => {
  if (!editingEntity.value) return ''
  const entity = editingEntity.value
  switch (selectedLevel.value) {
    case 'zone':
      return entity.communeNom || communes.value.find(c => c.id === entity.communeId)?.nom || ''
    case 'quartier':
      return entity.zoneNom || zones.value.find(z => z.id === entity.zoneId)?.nom || ''
    case 'secteur':
      return entity.quartierNom || quartiers.value.find(q => q.id === entity.quartierId)?.nom || ''
    default:
      return ''
  }
})

// Compute ancestor layers for containment and display
const ancestorLayers = computed(() => {
  if (!editingEntity.value) return []
  const entity = editingEntity.value
  const layers = []

  switch (selectedLevel.value) {
    case 'zone': {
      const commune = communes.value.find(c => c.id === entity.communeId)
      if (commune?.geometryGeoJson) {
        layers.push({ type: 'commune', name: commune.nom, geoJson: commune.geometryGeoJson })
      }
      break
    }
    case 'quartier': {
      const commune = communes.value.find(c => c.id === entity.communeId)
      if (commune?.geometryGeoJson) {
        layers.push({ type: 'commune', name: commune.nom, geoJson: commune.geometryGeoJson })
      }
      const zone = zones.value.find(z => z.id === entity.zoneId)
      if (zone?.geometryGeoJson) {
        layers.push({ type: 'zone', name: zone.nom, geoJson: zone.geometryGeoJson })
      }
      break
    }
    case 'secteur': {
      const commune = communes.value.find(c => c.id === entity.communeId)
      if (commune?.geometryGeoJson) {
        layers.push({ type: 'commune', name: commune.nom, geoJson: commune.geometryGeoJson })
      }
      const zone = zones.value.find(z => z.id === entity.zoneId)
      if (zone?.geometryGeoJson) {
        layers.push({ type: 'zone', name: zone.nom, geoJson: zone.geometryGeoJson })
      }
      const quartier = quartiers.value.find(q => q.id === entity.quartierId)
      if (quartier?.geometryGeoJson) {
        layers.push({ type: 'quartier', name: quartier.nom, geoJson: quartier.geometryGeoJson })
      }
      break
    }
  }
  return layers
})

// When editing, show only siblings (same parent) in the entity list
const entitiesForLevel = computed(() => {
  switch (selectedLevel.value) {
    case 'commune': return communes.value
    case 'zone': return zones.value
    case 'quartier': return quartiers.value
    case 'secteur': return secteurs.value
    default: return []
  }
})

const allPolygons = computed(() => {
  const result = []
  communes.value.forEach(c => { if (c.geometryGeoJson || (c.latitude && c.longitude)) result.push({ ...c, _type: 'commune' }) })
  zones.value.forEach(z => { if (z.geometryGeoJson || (z.latitude && z.longitude)) result.push({ ...z, _type: 'zone' }) })
  quartiers.value.forEach(q => { if (q.geometryGeoJson || (q.latitude && q.longitude)) result.push({ ...q, _type: 'quartier' }) })
  secteurs.value.forEach(s => { if (s.geometryGeoJson || (s.latitude && s.longitude)) result.push({ ...s, _type: 'secteur' }) })
  return result
})

// When editing, show only polygons within the same parent (siblings), plus the parent highlight
const displayPolygons = computed(() => {
  if (!editingEntity.value) return allPolygons.value
  const entity = editingEntity.value

  // Filter to show only siblings (same parent) when editing
  let filtered = []
  switch (selectedLevel.value) {
    case 'zone':
      // Show zones in the same commune
      filtered = allPolygons.value.filter(p => {
        if (p._type === 'zone') return p.communeId === entity.communeId && p.id !== entity.id
        if (p._type === 'commune') return p.id === entity.communeId
        return false
      })
      break
    case 'quartier':
      // Show quartiers in the same zone
      filtered = allPolygons.value.filter(p => {
        if (p._type === 'quartier') return p.zoneId === entity.zoneId && p.id !== entity.id
        if (p._type === 'zone') return p.id === entity.zoneId
        return false
      })
      break
    case 'secteur':
      // Show secteurs in the same quartier
      filtered = allPolygons.value.filter(p => {
        if (p._type === 'secteur') return p.quartierId === entity.quartierId && p.id !== entity.id
        if (p._type === 'quartier') return p.id === entity.quartierId
        return false
      })
      break
    default:
      // Commune editing: show all communes except the one being edited
      filtered = allPolygons.value.filter(p => p.id !== entity.id || p._type !== 'commune')
  }
  return filtered
})

const selectEntityForEdit = (entity) => {
  if (editingEntity.value?.id === entity.id) {
    cancelEdit()
    return
  }
  containmentError.value = ''
  editingEntity.value = entity
  drawnGeometry.value = entity.geometryGeoJson || null
  nextTick(() => {
    if (mapRef.value) {
      mapRef.value.invalidateMapSize()
      if (entity.geometryGeoJson) {
        mapRef.value.setGeoJson(entity.geometryGeoJson)
      } else {
        mapRef.value.clearDrawn()
      }
    }
  })
}

const cancelEdit = () => {
  editingEntity.value = null
  drawnGeometry.value = null
  containmentError.value = ''
  nextTick(() => {
    if (mapRef.value) {
      mapRef.value.clearDrawn()
      mapRef.value.invalidateMapSize()
    }
  })
}

const clearDrawing = () => {
  if (mapRef.value) {
    mapRef.value.clearDrawn()
  }
  drawnGeometry.value = null
}

const onPolygonDrawn = (geoJson) => {
  drawnGeometry.value = geoJson
}

const onPolygonCleared = () => {
  drawnGeometry.value = null
  containmentError.value = ''
}

const onContainmentViolation = (violated) => {
  if (violated) {
    containmentError.value = 'Le polygone dépasse les limites du parent. Ajustez le tracé.'
  } else {
    containmentError.value = ''
  }
}

const saveGeometry = async () => {
  if (!editingEntity.value || !drawnGeometry.value) {
    alert('Veuillez dessiner un polygone sur la carte')
    return
  }
  if (containmentError.value) {
    alert('Le polygone dépasse les limites du parent. Veuillez corriger le tracé.')
    return
  }

  saving.value = true
  try {
    const entity = { ...editingEntity.value, geometryGeoJson: drawnGeometry.value }

    switch (selectedLevel.value) {
      case 'commune':
        await communeService.updateCommune(entity.id, entity)
        await fetchCommunes()
        break
      case 'zone':
        await zoneService.updateZone(entity.id, entity)
        await fetchZones()
        break
      case 'quartier':
        await quartierService.updateQuartier(entity.id, entity)
        await fetchQuartiers()
        break
      case 'secteur':
        await secteurService.updateSecteur(entity.id, entity)
        await fetchSecteurs()
        break
    }

    editingEntity.value = null
    drawnGeometry.value = null
    if (mapRef.value) mapRef.value.clearDrawn()
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement:', error)
    alert('Erreur lors de l\'enregistrement de la délimitation')
  } finally {
    saving.value = false
  }
}

const fetchCommunes = async () => {
  try {
    const res = await communeService.getAllCommunes()
    communes.value = res.data || []
  } catch (e) { communes.value = [] }
}

const fetchZones = async () => {
  try {
    const res = await zoneService.getAllZones()
    zones.value = res.data || []
  } catch (e) { zones.value = [] }
}

const fetchQuartiers = async () => {
  try {
    const res = await quartierService.getAllQuartiers()
    quartiers.value = res.data || []
  } catch (e) { quartiers.value = [] }
}

const fetchSecteurs = async () => {
  try {
    const res = await secteurService.getAllSecteurs()
    secteurs.value = res.data || []
  } catch (e) { secteurs.value = [] }
}

watch(selectedLevel, () => {
  cancelEdit()
})

onMounted(async () => {
  await Promise.all([fetchCommunes(), fetchZones(), fetchQuartiers(), fetchSecteurs()])
})
</script>

<style scoped>
.btn-primary {
  @apply bg-primary-600 text-white px-3 py-1.5 rounded-lg hover:bg-primary-700 transition-colors flex items-center disabled:opacity-50 disabled:cursor-not-allowed;
}
.btn-secondary {
  @apply bg-gray-200 text-gray-800 px-3 py-1.5 rounded-lg hover:bg-gray-300 transition-colors;
}
.form-input {
  @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent;
}
</style>
