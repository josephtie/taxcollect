<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Analyse par Zone</h1>
            <p class="text-xs text-gray-500">Répartition des contribuables et taux de recensement</p>
          </div>
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
    </header>

    <main class="flex">
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <div class="flex-1 p-6 space-y-6">
        <!-- KPI Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <StatsCard title="Total contribuables" :value="stats.totalContribuables" :icon="Users" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="Créés aujourd'hui" :value="stats.creesAujourdhui" :icon="UserPlus" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="En validation" :value="stats.enValidation" :icon="AlertTriangle" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="Taux de synchro" :value="`${(stats.tauxSynchronisation || 0).toFixed(1)}%`" :icon="RefreshCw" icon-color="text-info-600" icon-bg-color="bg-info-50" />
        </div>

        <!-- Loading -->
        <div v-if="loading" class="flex justify-center py-12">
          <Loader2 class="w-8 h-8 text-primary-600 animate-spin" />
        </div>

        <template v-else>
          <!-- Répartition par zone -->
          <div class="bg-white rounded-lg shadow-soft p-6 border border-gray-100">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Répartition des contribuables par zone</h3>
            <div class="space-y-3">
              <div v-for="(count, zoneName) in sortedZoneRepartition" :key="zoneName" class="flex items-center gap-4">
                <div class="w-48 flex-shrink-0">
                  <p class="text-sm font-medium text-gray-900 truncate">{{ zoneName }}</p>
                </div>
                <div class="flex-1 relative">
                  <div class="w-full bg-gray-200 rounded-full h-7 overflow-hidden">
                    <div
                      class="h-7 rounded-full transition-all duration-500 flex items-center justify-end pr-2 bg-primary-600"
                      :style="{ width: `${maxZoneCount > 0 ? (count / maxZoneCount) * 100 : 0}%` }"
                    >
                      <span v-if="count > 0" class="text-xs font-semibold text-white">{{ count }}</span>
                    </div>
                  </div>
                </div>
              </div>
              <div v-if="Object.keys(sortedZoneRepartition).length === 0" class="text-center text-gray-400 py-8">
                Aucune donnée de répartition par zone
              </div>
            </div>
          </div>

          <!-- Répartition par type -->
          <div class="bg-white rounded-lg shadow-soft p-6 border border-gray-100">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Répartition par type de contribuable</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div v-for="(count, type) in stats.repartitionParType" :key="type" class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                <div class="flex items-center">
                  <div class="w-3 h-3 rounded-full mr-3" :style="{ backgroundColor: getTypeColor(type) }"></div>
                  <span class="text-sm font-medium text-gray-700">{{ getTypeLabel(type) }}</span>
                </div>
                <span class="text-lg font-bold text-gray-900">{{ count }}</span>
              </div>
              <div v-if="!stats.repartitionParType || Object.keys(stats.repartitionParType).length === 0" class="col-span-2 text-center text-gray-400 py-4">
                Aucune donnée de répartition par type
              </div>
            </div>
          </div>

          <!-- Detailed table -->
          <div class="bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-semibold text-gray-900">Détail par zone</h3>
            </div>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Zone</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contribuables</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Part</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Barre</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="(count, zoneName) in sortedZoneRepartition" :key="zoneName" class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ zoneName }}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ count }}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ stats.totalContribuables > 0 ? ((count / stats.totalContribuables) * 100).toFixed(1) : 0 }}%
                    </td>
                    <td class="px-6 py-4 w-48">
                      <div class="w-full bg-gray-200 rounded-full h-3">
                        <div class="bg-primary-600 h-3 rounded-full" :style="{ width: `${maxZoneCount > 0 ? (count / maxZoneCount) * 100 : 0}%` }"></div>
                      </div>
                    </td>
                  </tr>
                  <tr v-if="Object.keys(sortedZoneRepartition).length === 0">
                    <td colspan="4" class="px-6 py-12 text-center text-gray-400">Aucune donnée</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import {
  Users, UserPlus, AlertTriangle, RefreshCw, Loader2
} from 'lucide-vue-next'

const loading = ref(false)
const stats = ref({
  totalContribuables: 0,
  nonSynchronises: 0,
  enValidation: 0,
  creesAujourdhui: 0,
  misAJourAujourdhui: 0,
  repartitionParType: {},
  repartitionParZone: {},
  tauxSynchronisation: 0
})

const sortedZoneRepartition = computed(() => {
  const entries = Object.entries(stats.value.repartitionParZone || {})
  return Object.fromEntries(entries.sort((a, b) => b[1] - a[1]))
})

const maxZoneCount = computed(() => {
  const values = Object.values(stats.value.repartitionParZone || {})
  return values.length > 0 ? Math.max(...values) : 0
})

const getTypeColor = (type) => {
  const colors = {
    'PERSONNE_PHYSIQUE': '#3b82f6',
    'PERSONNE_MORALE': '#10b981',
    'PP': '#3b82f6',
    'PM': '#10b981',
  }
  return colors[type] || '#6b7280'
}

const getTypeLabel = (type) => {
  const labels = {
    'PERSONNE_PHYSIQUE': 'Personne Physique',
    'PERSONNE_MORALE': 'Personne Morale',
    'PP': 'Personne Physique',
    'PM': 'Personne Morale',
  }
  return labels[type] || type
}

const refreshData = async () => {
  loading.value = true
  try {
    const response = await api.get('/api/recensement/statistics')
    stats.value = response.data || stats.value
  } catch (error) {
    console.error('Erreur chargement statistiques:', error)
  } finally {
    loading.value = false
  }
}

onMounted(refreshData)
</script>

<style scoped>
.btn-primary {
  @apply bg-primary-600 text-white px-3 py-1.5 rounded-lg hover:bg-primary-700 transition-colors flex items-center disabled:opacity-50 disabled:cursor-not-allowed;
}
</style>
