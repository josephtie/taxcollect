<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Carte de Recensement</h1>
            <p class="text-xs text-gray-500">Visualisation GPS des recensements et vérification de conformité</p>
          </div>
          <div class="flex items-center space-x-3">
            <select v-model="selectedDate" @change="refreshData" class="form-input w-44">
              <option :value="today">Aujourd'hui</option>
              <option :value="yesterday">Hier</option>
              <option :value="week">7 derniers jours</option>
            </select>
            <button
              @click="refreshData"
              :disabled="loading"
              class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <RefreshCw :class="['w-4 h-4 mr-2', loading && 'animate-spin']" />
              Actualiser
            </button>
          </div>
        </div>
      </div>
    </header>

    <main class="flex">
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <div class="flex-1 p-6 space-y-6">
        <!-- KPI Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <StatsCard title="Recensements" :value="contribuables.length" :icon="Users" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="Avec GPS" :value="withGps" :icon="MapPin" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="Sans GPS" :value="withoutGps" :icon="AlertTriangle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Avec photo" :value="withPhoto" :icon="Camera" icon-color="text-info-600" icon-bg-color="bg-info-50" />
        </div>

        <!-- Loading -->
        <div v-if="loading" class="flex justify-center py-12">
          <Loader2 class="w-8 h-8 text-primary-600 animate-spin" />
        </div>

        <template v-else>
          <div class="flex gap-4" style="height: calc(100vh - 280px);">
            <!-- Map -->
            <div class="flex-1 bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden flex flex-col">
              <div class="px-4 py-3 border-b border-gray-100 flex items-center justify-between">
                <h3 class="font-semibold text-gray-900">Carte des recensements</h3>
                <div class="flex items-center space-x-4 text-xs text-gray-600">
                  <span class="flex items-center"><span class="w-3 h-3 rounded-full bg-green-500 mr-1"></span>Conforme (GPS + photo)</span>
                  <span class="flex items-center"><span class="w-3 h-3 rounded-full bg-amber-500 mr-1"></span>GPS sans photo</span>
                  <span class="flex items-center"><span class="w-3 h-3 rounded-full bg-red-500 mr-1"></span>Sans GPS</span>
                </div>
              </div>
              <div class="flex-1 relative">
                <div ref="mapContainer" class="absolute inset-0"></div>
                <div v-if="contribuables.length === 0" class="absolute inset-0 flex items-center justify-center pointer-events-none">
                  <div class="bg-white/90 px-6 py-4 rounded-lg shadow-lg text-center">
                    <MapPin class="w-8 h-8 text-gray-400 mx-auto mb-2" />
                    <p class="text-sm font-medium text-gray-700">Aucun recensement pour cette période</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Side panel: non-conform list -->
            <div class="w-80 flex-shrink-0 bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden flex flex-col">
              <div class="px-4 py-3 border-b border-gray-100">
                <h3 class="font-semibold text-gray-900">Recensements non conformes</h3>
                <p class="text-xs text-gray-500 mt-1">Sans GPS ou sans photo</p>
              </div>
              <div class="flex-1 overflow-y-auto">
                <ul class="divide-y divide-gray-100">
                  <li v-for="c in nonConformContribuables" :key="c.id" class="px-4 py-3 hover:bg-gray-50">
                    <div class="flex items-start gap-3">
                      <div class="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0"
                        :class="!c.latitude ? 'bg-red-100' : 'bg-amber-100'">
                        <AlertTriangle class="w-4 h-4" :class="!c.latitude ? 'text-red-600' : 'text-amber-600'" />
                      </div>
                      <div class="min-w-0 flex-1">
                        <p class="text-sm font-medium text-gray-900 truncate">{{ c.nom }} {{ c.prenoms || '' }}</p>
                        <p class="text-xs text-gray-500 truncate">{{ c.telephone }}</p>
                        <div class="flex gap-2 mt-1">
                          <span v-if="!c.latitude" class="text-xs text-red-600">Pas de GPS</span>
                          <span v-if="!c.photoContribuable" class="text-xs text-amber-600">Pas de photo</span>
                        </div>
                      </div>
                    </div>
                  </li>
                  <li v-if="nonConformContribuables.length === 0" class="px-4 py-8 text-center text-gray-400 text-sm">
                    Tous les recensements sont conformes
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import api from '@/services/api'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import {
  Users, MapPin, AlertTriangle, Camera, RefreshCw, Loader2
} from 'lucide-vue-next'

const loading = ref(false)
const mapContainer = ref(null)
const mapInstance = ref(null)
const markers = ref([])
const contribuables = ref([])

const today = new Date().toISOString().split('T')[0]
const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0]
const week = new Date(Date.now() - 7 * 86400000).toISOString().split('T')[0]

const selectedDate = ref(today)

const withGps = computed(() => contribuables.value.filter(c => c.latitude && c.longitude).length)
const withoutGps = computed(() => contribuables.value.filter(c => !c.latitude || !c.longitude).length)
const withPhoto = computed(() => contribuables.value.filter(c => c.photoContribuable).length)
const nonConformContribuables = computed(() => contribuables.value.filter(c => !c.latitude || !c.photoContribuable))

const getDateRange = () => {
  if (selectedDate.value === today || selectedDate.value === yesterday) {
    const start = new Date(selectedDate.value + 'T00:00:00')
    const end = new Date(selectedDate.value + 'T23:59:59')
    return { debut: start.toISOString(), fin: end.toISOString() }
  }
  const start = new Date(selectedDate.value + 'T00:00:00')
  const end = new Date()
  end.setHours(23, 59, 59, 999)
  return { debut: start.toISOString(), fin: end.toISOString() }
}

const refreshData = async () => {
  loading.value = true
  try {
    const { debut, fin } = getDateRange()
    const response = await api.get('/api/recensement/contribuables', {
      params: { limit: 500, offset: 0 }
    })
    const all = response.data || []
    // Filter by date client-side since the API doesn't support date filtering directly
    contribuables.value = all.filter(c => {
      const created = new Date(c.dateCreation)
      return created >= new Date(debut) && created <= new Date(fin)
    })
    await nextTick()
    renderMarkers()
  } catch (error) {
    console.error('Erreur chargement recensements:', error)
    contribuables.value = []
  } finally {
    loading.value = false
  }
}

const getMarkerColor = (c) => {
  if (!c.latitude || !c.longitude) return '#ef4444'
  if (!c.photoContribuable) return '#f59e0b'
  return '#10b981'
}

const initMap = () => {
  if (typeof window.L === 'undefined') {
    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'
    document.head.appendChild(link)

    const script = document.createElement('script')
    script.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js'
    script.onload = () => {
      createMap()
    }
    document.head.appendChild(script)
  } else {
    createMap()
  }
}

const createMap = () => {
  if (!mapContainer.value || mapInstance.value) return
  mapInstance.value = window.L.map(mapContainer.value).setView([5.2043, -3.7394], 13)
  window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 19
  }).addTo(mapInstance.value)
  renderMarkers()
}

const renderMarkers = () => {
  if (!mapInstance.value) return

  markers.value.forEach(m => mapInstance.value.removeLayer(m))
  markers.value = []

  contribuables.value.forEach(c => {
    if (!c.latitude || !c.longitude) return

    const color = getMarkerColor(c)
    const marker = window.L.circleMarker([c.latitude, c.longitude], {
      radius: 8,
      fillColor: color,
      color: '#fff',
      weight: 2,
      opacity: 1,
      fillOpacity: 0.8
    }).addTo(mapInstance.value)

    marker.bindPopup(`
      <div style="min-width: 200px;">
        <strong>${c.nom || ''} ${c.prenoms || ''}</strong><br/>
        <span style="font-size: 12px; color: #666;">${c.telephone || ''}</span><br/>
        <span style="font-size: 12px;">Activité: ${c.activite || 'N/A'}</span><br/>
        <span style="font-size: 12px;">N°: ${c.numeroContribuable || 'N/A'}</span><br/>
        <span style="font-size: 12px; color: ${c.photoContribuable ? '#10b981' : '#f59e0b'};">
          Photo: ${c.photoContribuable ? 'Oui' : 'Non'}
        </span><br/>
        <span style="font-size: 12px;">GPS: ${c.latitude.toFixed(5)}, ${c.longitude.toFixed(5)}</span>
      </div>
    `)

    markers.value.push(marker)
  })
}

onMounted(async () => {
  await refreshData()
  initMap()
})

onUnmounted(() => {
  if (mapInstance.value) {
    mapInstance.value.remove()
    mapInstance.value = null
  }
})
</script>

<style scoped>
.form-input {
  @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent;
}
</style>
