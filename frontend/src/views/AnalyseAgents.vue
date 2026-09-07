<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Analyse par Agent</h1>
            <p class="text-xs text-gray-500">Comparaison des performances des agents de collecte</p>
          </div>
          <div class="flex items-center space-x-3">
            <select v-model="selectedPeriod" @change="handlePeriodChange" class="form-input w-44">
              <option value="today">Aujourd'hui</option>
              <option value="week">7 derniers jours</option>
              <option value="month">30 derniers jours</option>
              <option value="custom">Personnalisé</option>
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
        <!-- Custom date range -->
        <div v-if="selectedPeriod === 'custom'" class="bg-white rounded-lg shadow-soft p-4 border border-gray-100">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="form-label">Date début</label>
              <input v-model="customDateStart" type="date" class="form-input" />
            </div>
            <div>
              <label class="form-label">Date fin</label>
              <input v-model="customDateEnd" type="date" class="form-input" />
            </div>
          </div>
          <div class="flex justify-end mt-3">
            <button @click="refreshData" class="btn-primary">Appliquer</button>
          </div>
        </div>

        <!-- KPI Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <StatsCard title="Agents actifs" :value="agentStats.length" :icon="Users" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="Montant total collecté" :value="formatCurrency(totalCollected)" :icon="DollarSign" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="Total transactions" :value="totalTransactions" :icon="CreditCard" icon-color="text-info-600" icon-bg-color="bg-info-50" />
          <StatsCard title="Montant moyen / agent" :value="formatCurrency(avgPerAgent)" :icon="TrendingUp" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
        </div>

        <!-- Loading -->
        <div v-if="loading" class="flex justify-center py-12">
          <Loader2 class="w-8 h-8 text-primary-600 animate-spin" />
        </div>

        <template v-else>
          <!-- Bar chart: comparison -->
          <div class="bg-white rounded-lg shadow-soft p-6 border border-gray-100">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Comparaison des montants collectés</h3>
            <div class="space-y-3">
              <div v-for="agent in sortedAgentStats" :key="agent.id" class="flex items-center gap-4">
                <div class="w-40 flex-shrink-0">
                  <p class="text-sm font-medium text-gray-900 truncate">{{ agent.nom }} {{ agent.prenom }}</p>
                  <p class="text-xs text-gray-500">{{ agent.transactionCount }} transaction(s)</p>
                </div>
                <div class="flex-1 relative">
                  <div class="w-full bg-gray-200 rounded-full h-8 overflow-hidden">
                    <div
                      class="h-8 rounded-full transition-all duration-500 flex items-center justify-end pr-2"
                      :style="{
                        width: `${maxAmount > 0 ? (agent.totalAmount / maxAmount) * 100 : 0}%`,
                        backgroundColor: getBarColor(agent.totalAmount, maxAmount)
                      }"
                    >
                      <span v-if="agent.totalAmount > 0" class="text-xs font-semibold text-white whitespace-nowrap">
                        {{ formatCurrency(agent.totalAmount) }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div v-if="sortedAgentStats.length === 0" class="text-center text-gray-400 py-8">
                Aucune donnée disponible pour cette période
              </div>
            </div>
          </div>

          <!-- Detailed table -->
          <div class="bg-white rounded-lg shadow-soft border border-gray-100 overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200">
              <h3 class="text-lg font-semibold text-gray-900">Détail par agent</h3>
            </div>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Agent</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Transactions</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Montant total</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Montant moyen</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Espèces</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mobile Money</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="agent in sortedAgentStats" :key="agent.id" class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {{ agent.nom }} {{ agent.prenom }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ agent.transactionCount }}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-900">{{ formatCurrency(agent.totalAmount) }}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ formatCurrency(agent.avgAmount) }}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ formatCurrency(agent.cashAmount) }}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ formatCurrency(agent.mobileMoneyAmount) }}</td>
                  </tr>
                  <tr v-if="sortedAgentStats.length === 0">
                    <td colspan="6" class="px-6 py-12 text-center text-gray-400">Aucune donnée</td>
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
import { agentService, transactionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import {
  Users, DollarSign, CreditCard, TrendingUp, RefreshCw, Loader2
} from 'lucide-vue-next'

const loading = ref(false)
const selectedPeriod = ref('week')
const customDateStart = ref('')
const customDateEnd = ref('')
const agents = ref([])
const agentStats = ref([])

const dateRange = computed(() => {
  const now = new Date()
  const fin = new Date(now)
  fin.setHours(23, 59, 59, 999)

  let debut
  switch (selectedPeriod.value) {
    case 'today':
      debut = new Date(now)
      debut.setHours(0, 0, 0, 0)
      break
    case 'week':
      debut = new Date(now)
      debut.setDate(debut.getDate() - 7)
      break
    case 'month':
      debut = new Date(now)
      debut.setDate(debut.getDate() - 30)
      break
    case 'custom':
      if (customDateStart.value && customDateEnd.value) {
        debut = new Date(customDateStart.value)
        debut.setHours(0, 0, 0, 0)
        const customFin = new Date(customDateEnd.value)
        customFin.setHours(23, 59, 59, 999)
        return { debut, fin: customFin }
      }
      debut = new Date(now)
      debut.setDate(debut.getDate() - 7)
      break
    default:
      debut = new Date(now)
      debut.setDate(debut.getDate() - 7)
  }
  return { debut, fin }
})

const sortedAgentStats = computed(() => {
  return [...agentStats.value].sort((a, b) => b.totalAmount - a.totalAmount)
})

const maxAmount = computed(() => {
  return agentStats.value.reduce((max, a) => Math.max(max, a.totalAmount), 0)
})

const totalCollected = computed(() => {
  return agentStats.value.reduce((sum, a) => sum + a.totalAmount, 0)
})

const totalTransactions = computed(() => {
  return agentStats.value.reduce((sum, a) => sum + a.transactionCount, 0)
})

const avgPerAgent = computed(() => {
  return agentStats.value.length > 0 ? totalCollected.value / agentStats.value.length : 0
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency', currency: 'XOF',
    minimumFractionDigits: 0, maximumFractionDigits: 0
  }).format(amount || 0)
}

const getBarColor = (value, max) => {
  if (max === 0) return '#d1d5db'
  const ratio = value / max
  if (ratio > 0.75) return '#10b981'
  if (ratio > 0.5) return '#3b82f6'
  if (ratio > 0.25) return '#f59e0b'
  return '#ef4444'
}

const handlePeriodChange = () => {
  if (selectedPeriod.value !== 'custom') {
    refreshData()
  }
}

const refreshData = async () => {
  loading.value = true
  try {
    const agentsRes = await agentService.getActiveAgents()
    agents.value = agentsRes.data || []

    const { debut, fin } = dateRange.value
    const statsPromises = agents.value.map(async (agent) => {
      try {
        const txRes = await transactionService.getTransactionsByAgentAndDateRange(
          agent.id, debut, fin
        )
        const transactions = txRes.data || []
        const totalAmount = transactions.reduce((sum, t) => sum + (t.montant || 0), 0)
        const cashAmount = transactions.filter(t => t.modePaiement === 'ESPECE').reduce((sum, t) => sum + (t.montant || 0), 0)
        const mobileMoneyAmount = transactions.filter(t => t.modePaiement === 'MOBILE_MONEY').reduce((sum, t) => sum + (t.montant || 0), 0)
        return {
          id: agent.id,
          nom: agent.nom,
          prenom: agent.prenom,
          transactionCount: transactions.length,
          totalAmount,
          avgAmount: transactions.length > 0 ? totalAmount / transactions.length : 0,
          cashAmount,
          mobileMoneyAmount
        }
      } catch {
        return {
          id: agent.id, nom: agent.nom, prenom: agent.prenom,
          transactionCount: 0, totalAmount: 0, avgAmount: 0, cashAmount: 0, mobileMoneyAmount: 0
        }
      }
    })

    agentStats.value = await Promise.all(statsPromises)
  } catch (error) {
    console.error('Erreur chargement analyse agents:', error)
    agents.value = []
    agentStats.value = []
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
.form-input {
  @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent;
}
.form-label {
  @apply block text-sm font-medium text-gray-700 mb-1;
}
</style>
