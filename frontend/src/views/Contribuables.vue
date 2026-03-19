<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Carte des Contribuables - Grand-Bassam</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="refreshData"
              :disabled="loading"
              class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Actualiser
            </button>
            <button
              @click="exportData"
              class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              Exporter
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

      <!-- Contribuables Content -->
      <div class="flex-1 p-6">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Contribuables</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.totalContribuables }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Zones</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.totalZones }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Collecteurs</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.totalCollecteurs }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Moyenne/Zone</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.moyenneParZone }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Map and Zones Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Map Section -->
          <div class="lg:col-span-2">
            <div class="bg-white shadow rounded-lg overflow-hidden">
              <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Carte des Zones - Grand-Bassam</h3>
                <p class="mt-1 max-w-2xl text-sm text-gray-500">
                  Visualisation interactive des quartiers de Grand-Bassam avec répartition des contribuables et collecteurs
                </p>
              </div>
              <div class="p-4">
                <!-- Interactive Map -->
                <InteractiveMap
                  :zones="zones"
                  :selected-zone="selectedZone"
                  @zone-selected="selectZone"
                  @zone-clicked="onZoneClicked"
                />
              </div>
            </div>
          </div>

          <!-- Zones List -->
          <div class="lg:col-span-1">
            <div class="bg-white shadow rounded-lg">
              <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Liste des Zones</h3>
                <p class="mt-1 text-sm text-gray-500">Détails par zone de collecte</p>
              </div>
              <div class="p-4 max-h-96 overflow-y-auto">
                <div v-if="loading" class="text-center py-4">
                  <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
                </div>
                <div v-else class="space-y-3">
                  <div 
                    v-for="zone in zones" 
                    :key="zone.id"
                    @click="selectZone(zone)"
                    :class="[
                      'p-3 rounded-lg border cursor-pointer transition-colors',
                      selectedZone?.id === zone.id 
                        ? 'border-primary-500 bg-primary-50' 
                        : 'border-gray-200 hover:border-gray-300'
                    ]"
                  >
                    <div class="flex justify-between items-start mb-2">
                      <h4 class="font-medium text-gray-900">{{ zone.nom }}</h4>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        {{ zone.contribuables }} contribuables
                      </span>
                    </div>
                    <p class="text-sm text-gray-600 mb-2">{{ zone.description }}</p>
                    <div class="flex items-center justify-between text-sm">
                      <span class="text-gray-500">{{ zone.quartier }}</span>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        {{ zone.collecteurs }} collecteurs
                      </span>
                    </div>
                  </div>
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
import { ref, onMounted, computed } from 'vue'
import { agentService } from '@/services'
import InteractiveMap from '@/components/InteractiveMap.vue'
import Sidebar from '@/components/Sidebar.vue'

// Reactive data
const loading = ref(false)
const zones = ref([])
const selectedZone = ref(null)
const agents = ref([])

// Stats computed
const stats = computed(() => {
  const totalContribuables = zones.value.reduce((sum, zone) => sum + zone.contribuables, 0)
  const totalZones = zones.value.length
  const totalCollecteurs = zones.value.reduce((sum, zone) => sum + zone.collecteurs, 0)
  const moyenneParZone = totalZones > 0 ? Math.round(totalContribuables / totalZones) : 0

  return {
    totalContribuables,
    totalZones,
    totalCollecteurs,
    moyenneParZone
  }
})

// Methods
const refreshData = async () => {
  await Promise.all([fetchZones(), fetchAgents()])
}

const exportData = () => {
  const data = {
    zones: zones.value,
    agents: agents.value,
    stats: stats.value,
    exportDate: new Date().toISOString()
  }
  
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `contribuables-zones-${new Date().toISOString().split('T')[0]}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

const selectZone = (zone) => {
  selectedZone.value = zone
}

const onZoneClicked = (zone) => {
  selectZone(zone)
}

const fetchZones = async () => {
  try {
    loading.value = true
    // Simuler des données pour Grand-Bassam
    zones.value = [
      {
        id: 1,
        nom: 'Centre Ville - Ancienne Administration',
        description: 'Zone historique du centre administratif',
        quartier: 'Centre Ville',
        contribuables: 150,
        collecteurs: 3,
        coordinates: [5.2043, -3.7394]
      },
      {
        id: 2,
        nom: 'Zone France',
        description: 'Quartier résidentiel et commercial',
        quartier: 'Zone France',
        contribuables: 85,
        collecteurs: 2,
        coordinates: [5.2100, -3.7350]
      },
      {
        id: 3,
        nom: 'Quartier Ghana',
        description: 'Zone artisanale et de marché',
        quartier: 'Quartier Ghana',
        contribuables: 120,
        collecteurs: 2,
        coordinates: [5.1980, -3.7420]
      },
      {
        id: 4,
        nom: 'Zone Industrielle',
        description: 'Zone des entreprises et industries',
        quartier: 'Zone Industrielle',
        contribuables: 45,
        collecteurs: 1,
        coordinates: [5.2150, -3.7300]
      },
      {
        id: 5,
        nom: 'Quartier Sokoura',
        description: 'Zone résidentielle périphérique',
        quartier: 'Quartier Sokoura',
        contribuables: 65,
        collecteurs: 1,
        coordinates: [5.1900, -3.7450]
      },
      {
        id: 6,
        nom: 'Bord de Mer - France',
        description: 'Zone touristique et hôtelière',
        quartier: 'Bord de Mer - France',
        contribuables: 95,
        collecteurs: 2,
        coordinates: [5.2050, -3.7320]
      }
    ]
  } catch (error) {
    console.error('Erreur lors du chargement des zones:', error)
  } finally {
    loading.value = false
  }
}

const fetchAgents = async () => {
  try {
    const response = await agentService.getAllAgents()
    agents.value = response.data || []
  } catch (error) {
    console.error('Erreur lors du chargement des agents:', error)
    agents.value = []
  }
}

// Lifecycle
onMounted(() => {
  fetchZones()
  fetchAgents()
})
</script>

<style scoped>
#map {
  height: 400px;
  border-radius: 0.5rem;
}

/* Custom scrollbar */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>