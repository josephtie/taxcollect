<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Tableau de bord — {{ dashboard?.zone?.nom || 'Zone' }}</h1>
            <p class="text-xs text-gray-500">Superviseur de zone — vue opérationnelle</p>
          </div>
          <button
            @click="loadDashboard"
            :disabled="loading"
            class="p-2 text-gray-600 hover:text-gray-900 transition-colors"
            title="Rafraîchir"
          >
            <RefreshCw :class="{ 'animate-spin': loading }" class="w-5 h-5" />
          </button>
        </div>
      </div>
    </header>

    <main class="flex">
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <div class="flex-1 p-6 space-y-6">
        <div v-if="loading" class="flex justify-center py-12">
          <Loader2 class="w-8 h-8 text-primary-600 animate-spin" />
        </div>
        <template v-else-if="dashboard">
          <!-- Section Agents -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <Users class="w-4 h-4" /> Agents
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <StatsCard title="Agents actifs" :value="dashboard.agents.actifs" :icon="UserCheck" icon-color="text-success-600" icon-bg-color="bg-success-50" />
              <StatsCard title="Agents connectés" :value="dashboard.agents.connectes" :icon="Wifi" icon-color="text-info-600" icon-bg-color="bg-info-50" />
              <StatsCard title="Hors ligne" :value="dashboard.agents.horsLigne" :icon="WifiOff" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
            </div>
          </div>

          <!-- Section Contribuables -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <Building class="w-4 h-4" /> Contribuables
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
              <StatsCard title="Total" :value="dashboard.contribuables.total" :icon="Building" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
              <StatsCard title="Visités aujourd'hui" :value="dashboard.contribuables.visitesAujourdhui" :icon="MapPin" icon-color="text-info-600" icon-bg-color="bg-info-50" />
              <StatsCard title="Payés" :value="dashboard.contribuables.payes" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
              <StatsCard title="Impayés" :value="dashboard.contribuables.impayes" :icon="AlertCircle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
              <StatsCard title="À revisiter" :value="dashboard.contribuables.aRevisiter" :icon="RotateCcw" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
            </div>
          </div>

          <!-- Section Recouvrement -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <DollarSign class="w-4 h-4" /> Recouvrement
            </h2>
            <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-6">
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
                <div class="text-center">
                  <p class="text-xs text-gray-500 uppercase">Objectif</p>
                  <p class="text-2xl font-bold text-gray-900 mt-1">{{ formatCurrency(dashboard.recouvrement.objectif) }}</p>
                </div>
                <div class="text-center">
                  <p class="text-xs text-gray-500 uppercase">Collecté</p>
                  <p class="text-2xl font-bold text-success-600 mt-1">{{ formatCurrency(dashboard.recouvrement.collecte) }}</p>
                </div>
                <div class="text-center">
                  <p class="text-xs text-gray-500 uppercase">Taux</p>
                  <p class="text-2xl font-bold text-primary-600 mt-1">{{ dashboard.recouvrement.taux }}%</p>
                </div>
              </div>
              <div class="mt-4">
                <div class="w-full bg-gray-200 rounded-full h-3">
                  <div
                    class="bg-primary-600 h-3 rounded-full transition-all duration-500"
                    :style="{ width: `${Math.min(dashboard.recouvrement.taux, 100)}%` }"
                  ></div>
                </div>
              </div>
            </div>
          </div>

          <!-- Section Anomalies -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <AlertTriangle class="w-4 h-4" /> Anomalies
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 flex items-center gap-3">
                <div class="p-2.5 bg-danger-50 rounded-lg"><AlertTriangle class="w-5 h-5 text-danger-600" /></div>
                <div>
                  <p class="text-xs text-gray-500">Paiements à vérifier</p>
                  <p class="text-xl font-bold text-gray-900">{{ dashboard.anomalies.paiementsAVerifier }}</p>
                </div>
              </div>
              <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 flex items-center gap-3">
                <div class="p-2.5 bg-warning-50 rounded-lg"><RefreshCw class="w-5 h-5 text-warning-600" /></div>
                <div>
                  <p class="text-xs text-gray-500">Conflits de synchro</p>
                  <p class="text-xl font-bold text-gray-900">{{ dashboard.anomalies.conflitsSync }}</p>
                </div>
              </div>
              <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 flex items-center gap-3">
                <div class="p-2.5 bg-danger-50 rounded-lg"><Eye class="w-5 h-5 text-danger-600" /></div>
                <div>
                  <p class="text-xs text-gray-500">Visites suspectes</p>
                  <p class="text-xl font-bold text-gray-900">{{ dashboard.anomalies.visitesSuspectes }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Section Collecteurs de ma zone -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <Users class="w-4 h-4" /> Collecteurs de ma zone
            </h2>
            <div class="bg-white shadow-soft rounded-lg border border-gray-100 overflow-hidden">
              <div v-if="agentsLoading" class="flex justify-center py-6">
                <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
              </div>
              <div v-else-if="zoneAgents.length === 0" class="text-center py-6 text-sm text-gray-500">
                Aucun collecteur assigné à votre zone
              </div>
              <table v-else class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nom</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Téléphone</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="a in zoneAgents" :key="a.id" class="hover:bg-gray-50">
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900">
                      <div class="flex items-center gap-2">
                        <span class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-primary-100 text-primary-700 text-xs font-medium">{{ a.initials }}</span>
                        {{ a.nom }} {{ a.prenom }}
                      </div>
                    </td>
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-500">{{ a.telephone || '—' }}</td>
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-500">{{ a.email || '—' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Section Contribuables de ma zone -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <Building class="w-4 h-4" /> Contribuables de ma zone
              <span class="text-xs font-normal text-gray-400">{{ zoneContribuables.length }} trouvés</span>
            </h2>
            <div class="bg-white shadow-soft rounded-lg border border-gray-100 overflow-hidden">
              <div v-if="contribuablesLoading" class="flex justify-center py-6">
                <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
              </div>
              <div v-else-if="zoneContribuables.length === 0" class="text-center py-6 text-sm text-gray-500">
                Aucun contribuable dans votre zone
              </div>
              <table v-else class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">N° Contribuable</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nom</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Téléphone</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Zone</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Quartier</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Secteur</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="c in zoneContribuables" :key="c.id" class="hover:bg-gray-50">
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900">{{ c.numeroContribuable || '—' }}</td>
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900">{{ c.nom }} {{ c.prenom }}</td>
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-500">{{ c.telephone || '—' }}</td>
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-500">{{ c.zoneNom || '—' }}</td>
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-500">{{ c.quartierNom || '—' }}</td>
                    <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-500">{{ c.secteurNom || '—' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Raccourcis -->
          <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
            <router-link to="/anomalies" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <AlertTriangle class="w-6 h-6 text-danger-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Anomalies</p>
            </router-link>
            <router-link to="/recouvrement" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <Wallet class="w-6 h-6 text-warning-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Recouvrement</p>
            </router-link>
            <router-link to="/promesses" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <FileText class="w-6 h-6 text-primary-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Promesses</p>
            </router-link>
            <router-link to="/tournees" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <Route class="w-6 h-6 text-info-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Tournées</p>
            </router-link>
            <router-link to="/reclamations" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <MessageSquare class="w-6 h-6 text-primary-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Réclamations</p>
            </router-link>
            <router-link to="/synchronisation" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <RefreshCw class="w-6 h-6 text-info-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Synchro</p>
            </router-link>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  Users, UserCheck, Wifi, WifiOff, Building, MapPin, CheckCircle,
  AlertCircle, RotateCcw, DollarSign, AlertTriangle, RefreshCw,
  Eye, Wallet, FileText, Route, MessageSquare, Loader2
} from 'lucide-vue-next'
import { supervisionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const dashboard = ref(null)
const zoneAgents = ref([])
const zoneContribuables = ref([])
const agentsLoading = ref(false)
const contribuablesLoading = ref(false)
const currentZoneId = ref(null)

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}

async function loadDashboard() {
  loading.value = true
  try {
    // Le backend exige un zoneId : on charge d'abord les zones supervisées,
    // puis le dashboard de la première zone.
    const zonesResponse = await supervisionService.getSupervisedZones()
    const zones = zonesResponse.data || []
    if (zones.length > 0) {
      currentZoneId.value = zones[0].zoneId || zones[0].id
      const response = await supervisionService.getDashboardZone(currentZoneId.value)
      dashboard.value = response.data
    } else {
      dashboard.value = null
    }
  } catch (e) {
    console.error('Erreur chargement dashboard:', e)
  } finally {
    loading.value = false
  }
}

async function loadZoneAgents() {
  agentsLoading.value = true
  try {
    const response = await supervisionService.getMyZoneAgents()
    zoneAgents.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement agents:', e)
    zoneAgents.value = []
  } finally {
    agentsLoading.value = false
  }
}

async function loadZoneContribuables() {
  contribuablesLoading.value = true
  try {
    const response = await supervisionService.getMyZoneContribuables()
    zoneContribuables.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement contribuables:', e)
    zoneContribuables.value = []
  } finally {
    contribuablesLoading.value = false
  }
}

onMounted(() => {
  loadDashboard()
  loadZoneAgents()
  loadZoneContribuables()
})
</script>
