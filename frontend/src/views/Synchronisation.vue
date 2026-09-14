<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Synchronisation</h1>
            <p class="text-xs text-gray-500">Statut de synchronisation des agents de la zone</p>
          </div>
          <div class="flex items-center gap-3">
            <button
              @click="loadSyncStatus"
              :disabled="loading"
              class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <RefreshCw :class="['w-4 h-4 mr-2', loading && 'animate-spin']" />
              Actualiser
            </button>
            <button
              @click="synchroniserZone"
              :disabled="syncing"
              class="inline-flex items-center px-3 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50"
            >
              <Loader2 v-if="syncing" class="w-4 h-4 mr-2 animate-spin" />
              <RefreshCw v-else class="w-4 h-4 mr-2" />
              Synchroniser la zone
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
        <!-- KPI -->
        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
          <StatsCard title="Synchronisés" :value="statutCount('SYNCHRONISE')" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="En attente" :value="statutCount('EN_ATTENTE')" :icon="Clock" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="Hors ligne" :value="statutCount('HORS_LIGNE')" :icon="WifiOff" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Opérations en attente" :value="totalOperationsEnAttente" :icon="Database" icon-color="text-info-600" icon-bg-color="bg-info-50" />
        </div>

        <!-- Liste -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="syncStatus.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucun agent à synchroniser.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="s in syncStatus" :key="s.agentId" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-center justify-between gap-4">
                <div class="flex items-center gap-3 min-w-0">
                  <div :class="['shrink-0 w-10 h-10 rounded-lg flex items-center justify-center', statutBg(s.statut)]">
                    <component :is="statutIcon(s.statut)" :class="['w-5 h-5', statutText(s.statut)]" />
                  </div>
                  <div class="min-w-0">
                    <p class="text-sm font-semibold text-gray-900">{{ s.agentNom }}</p>
                    <p class="text-xs text-gray-500 mt-0.5">Dernière synchro : {{ s.derniereSync || 'Jamais' }}</p>
                  </div>
                </div>
                <div class="flex items-center gap-4 shrink-0">
                  <div v-if="s.operationsEnAttente > 0" class="text-right">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-warning-100 text-warning-800">
                      {{ s.operationsEnAttente }} opérations
                    </span>
                  </div>
                  <span :class="['inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium', statutBadge(s.statut)]">
                    {{ statutLabel(s.statut) }}
                  </span>
                  <button
                    v-if="s.statut !== 'SYNCHRONISE' && s.statut !== 'HORS_LIGNE'"
                    @click="synchroniserAgent(s)"
                    :disabled="s._syncing"
                    class="px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-md disabled:opacity-50"
                  >
                    <Loader2 v-if="s._syncing" class="w-3.5 h-3.5 animate-spin inline" />
                    Synchroniser
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  CheckCircle, Clock, WifiOff, Database, RefreshCw,
  Loader2, Inbox, AlertTriangle
} from 'lucide-vue-next'
import { syncService, supervisionService, authService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const syncing = ref(false)
const syncStatus = ref([])

const statutCount = (statut) => syncStatus.value.filter(s => s.statut === statut).length
const totalOperationsEnAttente = computed(() => syncStatus.value.reduce((sum, s) => sum + (s.operationsEnAttente || 0), 0))

const statutBg = (s) => ({ SYNCHRONISE: 'bg-success-50', EN_ATTENTE: 'bg-warning-50', HORS_LIGNE: 'bg-danger-50' }[s] || 'bg-gray-100')
const statutText = (s) => ({ SYNCHRONISE: 'text-success-600', EN_ATTENTE: 'text-warning-600', HORS_LIGNE: 'text-danger-600' }[s] || 'text-gray-500')
const statutBadge = (s) => ({ SYNCHRONISE: 'bg-success-100 text-success-800', EN_ATTENTE: 'bg-warning-100 text-warning-800', HORS_LIGNE: 'bg-danger-100 text-danger-800' }[s] || 'bg-gray-100 text-gray-600')
const statutLabel = (s) => ({ SYNCHRONISE: '✓ Synchronisé', EN_ATTENTE: '⚠ En attente', HORS_LIGNE: '🔴 Hors ligne' }[s] || s)
const statutIcon = (s) => ({ SYNCHRONISE: CheckCircle, EN_ATTENTE: AlertTriangle, HORS_LIGNE: WifiOff }[s] || Clock)

async function loadSyncStatus() {
  loading.value = true
  try {
    // Le backend SyncItemController expose les items par statut ou par agent.
    // On récupère les agents de la zone du superviseur, puis leurs items en attente.
    const agentsResponse = await supervisionService.getMyZoneAgents()
    const agents = agentsResponse.data || []
    const result = []
    for (const agent of agents) {
      try {
        const pendingResponse = await syncService.getPendingCount(agent.id)
        const pendingCount = pendingResponse.data || 0
        result.push({
          agentId: agent.id,
          agentNom: (agent.nom || '') + ' ' + (agent.prenom || ''),
          statut: pendingCount > 0 ? 'EN_ATTENTE' : 'SYNCHRONISE',
          operationsEnAttente: pendingCount,
          derniereSync: null
        })
      } catch {
        result.push({
          agentId: agent.id,
          agentNom: (agent.nom || '') + ' ' + (agent.prenom || ''),
          statut: 'HORS_LIGNE',
          operationsEnAttente: 0,
          derniereSync: null
        })
      }
    }
    syncStatus.value = result
  } catch (e) {
    console.error('Erreur chargement sync:', e)
  } finally {
    loading.value = false
  }
}

async function synchroniserZone() {
  syncing.value = true
  try {
    // Pas de route "sync zone globale" : on synchronise chaque agent individuellement.
    for (const s of syncStatus.value) {
      if (s.operationsEnAttente > 0) {
        try {
          await syncService.getSyncByAgent(s.agentId)
        } catch (err) {
          console.error(`Erreur sync agent ${s.agentId}:`, err)
        }
      }
    }
    await loadSyncStatus()
  } catch (e) {
    console.error('Erreur sync zone:', e)
  } finally {
    syncing.value = false
  }
}

async function synchroniserAgent(s) {
  s._syncing = true
  try {
    await syncService.getSyncByAgent(s.agentId)
    s.statut = 'SYNCHRONISE'
    s.operationsEnAttente = 0
  } catch (e) {
    console.error('Erreur sync agent:', e)
  } finally {
    s._syncing = false
  }
}

onMounted(() => loadSyncStatus())
</script>
