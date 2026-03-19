<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Tableau de Bord</h1>
          </div>
          <div class="flex items-center space-x-4">
            <!-- Bouton de rafraîchissement -->
            <button
              @click="refreshData"
              :disabled="loading"
              class="p-2 text-gray-600 hover:text-gray-900 transition-colors"
              title="Rafraîchir"
            >
              <RefreshCw 
                :class="{ 'animate-spin': loading }" 
                class="w-5 h-5" 
              />
            </button>
            
            <!-- Sélecteur de période -->
            <select
              v-model="selectedPeriod"
              @change="handlePeriodChange"
              class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="today">Aujourd'hui</option>
              <option value="week">7 derniers jours</option>
              <option value="month">30 derniers jours</option>
              <option value="custom">Personnalisé</option>
            </select>
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

      <!-- Dashboard Content -->
      <div class="flex-1 p-6">
        <!-- KPI Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatsCard title="Total collecté aujourd'hui" value="0" icon="mdi-cash" />
          <StatsCard title="Nombre de transactions" value="0" icon="mdi-credit-card" />
          <StatsCard title="Paiements Espèces" value="0" icon="mdi-banknote" />
          <StatsCard title="Paiements Mobile Money" value="0" icon="mdi-cellphone" />
          <StatsCard
            title="Nombre de transactions"
            :value="transactionStore.todayTransactionCount"
            :icon="CreditCard"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
            :change="transactionChange"
            change-type="absolute"
          />
          
          <StatsCard
            title="Paiements Espèces"
            :value="transactionStore.paymentMethodStats.cash"
            :icon="Banknote"
            format="currency"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
          
          <StatsCard
            title="Paiements Mobile Money"
            :value="transactionStore.paymentMethodStats.mobileMoney"
            :icon="Smartphone"
            format="currency"
            icon-color="text-info-600"
            icon-bg-color="bg-info-50"
          />
        </div>

        <!-- Charts Section -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <!-- Évolution des collectes -->
          <ChartComponent
            title="Évolution des collectes (7 derniers jours)"
            type="line"
            :data="transactionStore.last7DaysData"
            height="350px"
            :loading="transactionStore.loading"
          />
          
          <!-- Répartition des paiements -->
          <div class="bg-white rounded-lg shadow-soft p-6 border border-gray-100">
            <h3 class="text-lg font-semibold text-gray-900 mb-6">Répartition des paiements</h3>
            <div class="space-y-4">
              <div class="flex items-center justify-between">
                <div class="flex items-center">
                  <div class="w-4 h-4 bg-warning-500 rounded-full mr-3"></div>
                  <span class="text-sm font-medium text-gray-700">Espèces</span>
                </div>
                <div class="text-right">
                  <p class="text-sm font-semibold text-gray-900">
                    {{ formatCurrency(transactionStore.paymentMethodStats.cash) }}
                  </p>
                  <p class="text-xs text-gray-500">
                    {{ transactionStore.paymentMethodStats.cashPercentage.toFixed(1) }}%
                  </p>
                </div>
              </div>
              
              <div class="w-full bg-gray-200 rounded-full h-2">
                <div 
                  class="bg-warning-500 h-2 rounded-full transition-all duration-500"
                  :style="{ width: `${transactionStore.paymentMethodStats.cashPercentage}%` }"
                ></div>
              </div>
              
              <div class="flex items-center justify-between">
                <div class="flex items-center">
                  <div class="w-4 h-4 bg-info-500 rounded-full mr-3"></div>
                  <span class="text-sm font-medium text-gray-700">Mobile Money</span>
                </div>
                <div class="text-right">
                  <p class="text-sm font-semibold text-gray-900">
                    {{ formatCurrency(transactionStore.paymentMethodStats.mobileMoney) }}
                  </p>
                  <p class="text-xs text-gray-500">
                    {{ transactionStore.paymentMethodStats.mobileMoneyPercentage.toFixed(1) }}%
                  </p>
                </div>
              </div>
              
              <div class="w-full bg-gray-200 rounded-full h-2">
                <div 
                  class="bg-info-500 h-2 rounded-full transition-all duration-500"
                  :style="{ width: `${transactionStore.paymentMethodStats.mobileMoneyPercentage}%` }"
                ></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Transactions -->
        <div class="bg-white rounded-lg shadow-soft border border-gray-100">
          <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-lg font-semibold text-gray-900">Transactions récentes</h3>
            <router-link
              to="/transactions"
              class="text-primary-600 hover:text-primary-900 text-sm font-medium"
            >
              Voir tout
            </router-link>
          </div>
          
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    N° Reçu
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contribuable
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Agent
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Montant
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Paiement
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Statut
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-if="transactionStore.loading" class="text-center">
                  <td colspan="6" class="px-6 py-12">
                    <div class="flex items-center justify-center">
                      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                      <span class="ml-2 text-gray-600">Chargement...</span>
                    </div>
                  </td>
                </tr>
                <tr 
                  v-else
                  v-for="transaction in recentTransactions" 
                  :key="transaction.id"
                  class="hover:bg-gray-50 transition-colors"
                >
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {{ transaction.numeroRecu }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ transaction.contribuableNom }} {{ transaction.contribuablePrenom }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ transaction.agentNom }} {{ transaction.agentPrenom }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {{ formatCurrency(transaction.montant) }}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <StatusBadge 
                      :status="transaction.modePaiement" 
                      type="payment"
                    />
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <StatusBadge 
                      :status="transaction.statut" 
                      type="transaction"
                    />
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useTransactionStore } from '@/stores/transactions'
import { useAgentStore } from '@/stores/agents'
import { useClotureStore } from '@/stores/cloture'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import ChartComponent from '@/components/ChartComponent.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import {
  DollarSign,
  CreditCard,
  Banknote,
  Smartphone,
  RefreshCw
} from 'lucide-vue-next'

// Stores
const transactionStore = useTransactionStore()
const agentStore = useAgentStore()
const clotureStore = useClotureStore()

// State
const loading = ref(false)
const selectedPeriod = ref('today')

// Computed
const recentTransactions = computed(() => {
  return transactionStore.transactions
    .slice()
    .sort((a, b) => new Date(b.dateCreation) - new Date(a.dateCreation))
    .slice(0, 10)
})

const todayChange = computed(() => {
  // Simuler une variation (à remplacer par de vraies données)
  return 12.5
})

const transactionChange = computed(() => {
  // Simuler une variation (à remplacer par de vraies données)
  return 8
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

const refreshData = async () => {
  loading.value = true
  try {
    await Promise.all([
      transactionStore.refreshData(),
      agentStore.refreshAgentData(),
      clotureStore.refreshClotureData()
    ])
  } catch (error) {
    console.error('Erreur lors du rafraîchissement:', error)
  } finally {
    loading.value = false
  }
}

const handlePeriodChange = async () => {
  // Logique pour changer la période
  // À implémenter selon les besoins
  console.log('Période changée:', selectedPeriod.value)
}

// Lifecycle
onMounted(async () => {
  await refreshData()
})
</script>
