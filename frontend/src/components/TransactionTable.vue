<template>
  <div class="bg-white rounded-lg shadow-soft border border-gray-100">
    <!-- Header -->
    <div class="px-6 py-4 border-b border-gray-200">
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold text-gray-900">{{ title }}</h3>
        <div v-if="showFilters" class="flex items-center space-x-3">
          <!-- Filtre par date -->
          <input
            v-model="localFilters.dateStart"
            type="date"
            class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
            placeholder="Date début"
          />
          <input
            v-model="localFilters.dateEnd"
            type="date"
            class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
            placeholder="Date fin"
          />
          
          <!-- Filtre par agent -->
          <select
            v-model="localFilters.agentId"
            class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
          >
            <option value="">Tous les agents</option>
            <option v-for="agent in agents" :key="agent.id" :value="agent.id">
              {{ agent.nom }} {{ agent.prenom }}
            </option>
          </select>
          
          <!-- Filtre par méthode de paiement -->
          <select
            v-model="localFilters.paymentMethod"
            class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
          >
            <option value="">Tous les paiements</option>
            <option value="ESPECE">Espèces</option>
            <option value="MOBILE_MONEY">Mobile Money</option>
          </select>
          
          <button
            @click="applyFilters"
            class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 transition-colors text-sm"
          >
            Appliquer
          </button>
          <button
            @click="clearFilters"
            class="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors text-sm"
          >
            Effacer
          </button>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th 
              v-for="column in columns" 
              :key="column.key"
              class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
            >
              {{ column.label }}
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-if="loading" class="text-center">
            <td :colspan="columns.length" class="px-6 py-12">
              <div class="flex items-center justify-center">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                <span class="ml-2 text-gray-600">Chargement...</span>
              </div>
            </td>
          </tr>
          <tr v-else-if="transactions.length === 0" class="text-center">
            <td :colspan="columns.length" class="px-6 py-12 text-gray-500">
              Aucune transaction trouvée
            </td>
          </tr>
          <tr 
            v-for="transaction in transactions" 
            :key="transaction.id"
            class="hover:bg-gray-50 transition-colors"
          >
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
              {{ transaction.numeroRecu }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
              {{ formatDate(transaction.dateCreation) }}
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
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              <button
                @click="$emit('view-details', transaction)"
                class="text-primary-600 hover:text-primary-900 font-medium"
              >
                Détails
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div v-if="showPagination && totalPages > 1" class="px-6 py-4 border-t border-gray-200">
      <div class="flex items-center justify-between">
        <div class="text-sm text-gray-700">
          Affichage de {{ startItem }} à {{ endItem }} sur {{ totalItems }} résultats
        </div>
        <div class="flex items-center space-x-2">
          <button
            @click="goToPage(currentPage - 1)"
            :disabled="currentPage === 1"
            class="px-3 py-1 border border-gray-300 rounded-md text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
          >
            Précédent
          </button>
          <span class="px-3 py-1 text-sm">
            Page {{ currentPage }} sur {{ totalPages }}
          </span>
          <button
            @click="goToPage(currentPage + 1)"
            :disabled="currentPage === totalPages"
            class="px-3 py-1 border border-gray-300 rounded-md text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
          >
            Suivant
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'
import StatusBadge from './StatusBadge.vue'

const props = defineProps({
  title: {
    type: String,
    default: 'Transactions'
  },
  transactions: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  },
  showFilters: {
    type: Boolean,
    default: true
  },
  showPagination: {
    type: Boolean,
    default: true
  },
  currentPage: {
    type: Number,
    default: 1
  },
  totalPages: {
    type: Number,
    default: 1
  },
  totalItems: {
    type: Number,
    default: 0
  },
  itemsPerPage: {
    type: Number,
    default: 10
  },
  agents: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['apply-filters', 'clear-filters', 'page-change', 'view-details'])

const localFilters = ref({
  dateStart: '',
  dateEnd: '',
  agentId: '',
  paymentMethod: ''
})

const columns = [
  { key: 'numeroRecu', label: 'N° Reçu' },
  { key: 'dateCreation', label: 'Date' },
  { key: 'contribuable', label: 'Contribuable' },
  { key: 'agent', label: 'Agent' },
  { key: 'montant', label: 'Montant' },
  { key: 'modePaiement', label: 'Paiement' },
  { key: 'statut', label: 'Statut' },
  { key: 'actions', label: 'Actions' }
]

const startItem = computed(() => {
  return (props.currentPage - 1) * props.itemsPerPage + 1
})

const endItem = computed(() => {
  return Math.min(props.currentPage * props.itemsPerPage, props.totalItems)
})

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return format(new Date(dateString), 'dd MMM yyyy HH:mm', { locale: fr })
}

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(amount)
}

const applyFilters = () => {
  emit('apply-filters', { ...localFilters.value })
}

const clearFilters = () => {
  localFilters.value = {
    dateStart: '',
    dateEnd: '',
    agentId: '',
    paymentMethod: ''
  }
  emit('clear-filters')
}

const goToPage = (page) => {
  if (page >= 1 && page <= props.totalPages) {
    emit('page-change', page)
  }
}

// Watch for external filter changes
watch(() => props.filters, (newFilters) => {
  if (newFilters) {
    localFilters.value = { ...newFilters }
  }
}, { immediate: true, deep: true })
</script>
