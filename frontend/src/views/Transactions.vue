<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Historique des Transactions</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="generatePdfReport"
              :disabled="exporting"
              class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <FileBarChart class="w-4 h-4 mr-2" />
              Rapport PDF
            </button>
            <div class="relative">
              <button
                @click="showExportMenu = !showExportMenu"
                class="btn-primary"
              >
                <Download class="w-4 h-4 mr-2" />
                Exporter
                <ChevronDown class="w-4 h-4 ml-2" />
              </button>
              <div
                v-if="showExportMenu"
                class="absolute right-0 mt-2 w-44 bg-white rounded-lg shadow-lg border border-gray-200 z-50"
              >
                <button
                  @click="exportTransactions('csv')"
                  data-testid="export-csv"
                  class="w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-50 rounded-t-lg"
                >
                  <FileText class="w-4 h-4 inline mr-2" />
                  Export CSV
                </button>
                <button
                  @click="exportTransactions('xlsx')"
                  data-testid="export-xlsx"
                  class="w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-50 rounded-b-lg"
                >
                  <FileSpreadsheet class="w-4 h-4 inline mr-2" />
                  Export Excel
                </button>
              </div>
            </div>
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

      <!-- Transactions Content -->
      <div class="flex-1 p-6">
        <!-- Filters Section -->
        <div class="bg-white rounded-lg shadow-soft p-6 mb-6 border border-gray-100">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Filtres</h3>
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label class="form-label">Date début</label>
              <input
                v-model="filters.dateStart"
                data-testid="filter-date-start"
                type="date"
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Date fin</label>
              <input
                v-model="filters.dateEnd"
                data-testid="filter-date-end"
                type="date"
                class="form-input"
              />
            </div>
            
            <div>
              <label class="form-label">Agent</label>
              <select
                v-model="filters.agentId"
                class="form-input"
              >
                <option value="">Tous les agents</option>
                <option
                  v-for="agent in agents"
                  :key="agent.id"
                  :value="agent.id"
                >
                  {{ agent.nom }} {{ agent.prenom }}
                </option>
              </select>
            </div>
            
            <div>
              <label class="form-label">Mode de paiement</label>
              <select
                v-model="filters.paymentMethod"
                class="form-input"
              >
                <option value="">Tous les paiements</option>
                <option value="ESPECE">Espèces</option>
                <option value="MOBILE_MONEY">Mobile Money</option>
              </select>
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 mt-4">
            <button
              @click="clearFilters"
              class="btn-secondary"
            >
              Effacer
            </button>
            <button
              @click="applyFilters"
              class="btn-primary"
            >
              Appliquer
            </button>
          </div>
        </div>

        <!-- Transactions Table -->
        <div data-testid="transactions-table">
        <TransactionTable
          :transactions="displayedTransactions"
          :loading="loading"
          :show-filters="false"
          :show-pagination="true"
          :current-page="currentPage"
          :total-pages="totalPages"
          :total-items="totalItems"
          :items-per-page="itemsPerPage"
          :agents="agents"
          title="Liste des Transactions"
          @page-change="handlePageChange"
          @view-details="viewTransactionDetails"
        />
        </div>

        <!-- Transaction Details Modal -->
        <div v-if="showDetailsModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between mb-6">
              <h3 class="modal-header">
                Détails de la Transaction
              </h3>
              <button
                @click="closeDetailsModal"
                class="text-gray-400 hover:text-gray-600"
              >
                <X class="w-6 h-6" />
              </button>
            </div>
            
            <div v-if="selectedTransaction" class="space-y-6">
              <!-- Header Info -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="bg-gray-50 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-3">Informations générales</h4>
                  <div class="space-y-2">
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Numéro de reçu:</span>
                      <span class="text-sm font-medium text-gray-900">{{ selectedTransaction.numeroRecu }}</span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Date:</span>
                      <span class="text-sm font-medium text-gray-900">{{ formatDate(selectedTransaction.dateCreation) }}</span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Montant:</span>
                      <span class="text-sm font-medium text-gray-900">{{ formatCurrency(selectedTransaction.montant) }}</span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Statut:</span>
                      <StatusBadge :status="selectedTransaction.statut" type="transaction" />
                    </div>
                  </div>
                </div>
                
                <div class="bg-gray-50 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-3">Paiement</h4>
                  <div class="space-y-2">
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Mode:</span>
                      <StatusBadge :status="selectedTransaction.modePaiement" type="payment" />
                    </div>
                    <div v-if="selectedTransaction.referencePaiement" class="flex justify-between">
                      <span class="text-sm text-gray-600">Référence:</span>
                      <span class="text-sm font-medium text-gray-900">{{ selectedTransaction.referencePaiement }}</span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Hors-ligne:</span>
                      <span class="text-sm font-medium text-gray-900">
                        {{ selectedTransaction.offline ? 'Oui' : 'Non' }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- People Info -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="bg-gray-50 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-3">Contribuable</h4>
                  <div class="space-y-2">
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Nom:</span>
                      <span class="text-sm font-medium text-gray-900">
                        {{ selectedTransaction.contribuableNom }} {{ selectedTransaction.contribuablePrenom }}
                      </span>
                    </div>
                  </div>
                </div>
                
                <div class="bg-gray-50 rounded-lg p-4">
                  <h4 class="font-medium text-gray-900 mb-3">Agent</h4>
                  <div class="space-y-2">
                    <div class="flex justify-between">
                      <span class="text-sm text-gray-600">Nom:</span>
                      <span class="text-sm font-medium text-gray-900">
                        {{ selectedTransaction.agentNom }} {{ selectedTransaction.agentPrenom }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Location Info -->
              <div v-if="selectedTransaction.latitude && selectedTransaction.longitude" class="bg-gray-50 rounded-lg p-4">
                <h4 class="font-medium text-gray-900 mb-3">Localisation</h4>
                <div class="space-y-2">
                  <div class="flex justify-between">
                    <span class="text-sm text-gray-600">Latitude:</span>
                    <span class="text-sm font-medium text-gray-900">{{ selectedTransaction.latitude }}</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-sm text-gray-600">Longitude:</span>
                    <span class="text-sm font-medium text-gray-900">{{ selectedTransaction.longitude }}</span>
                  </div>
                  <div v-if="selectedTransaction.adresseCollecte" class="flex justify-between">
                    <span class="text-sm text-gray-600">Adresse:</span>
                    <span class="text-sm font-medium text-gray-900">{{ selectedTransaction.adresseCollecte }}</span>
                  </div>
                </div>
              </div>

              <!-- Security Info -->
              <div v-if="selectedTransaction.hashTransaction" class="bg-gray-50 rounded-lg p-4">
                <h4 class="font-medium text-gray-900 mb-3">Sécurité</h4>
                <div class="space-y-2">
                  <div>
                    <span class="text-sm text-gray-600">Hash de transaction:</span>
                    <div class="mt-1 p-2 bg-white border border-gray-200 rounded text-xs font-mono break-all">
                      {{ selectedTransaction.hashTransaction }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="flex justify-end mt-6">
              <button
                @click="closeDetailsModal"
                class="btn-secondary"
              >
                Fermer
              </button>
            </div>
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
import { transactionService } from '@/services'
import { generateProductivityReport } from '@/services/pdfReportService'
import api from '@/services/api'
import Sidebar from '@/components/Sidebar.vue'
import TransactionTable from '@/components/TransactionTable.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { Download, X, ChevronDown, FileText, FileSpreadsheet, FileBarChart } from 'lucide-vue-next'

const transactionStore = useTransactionStore()
const agentStore = useAgentStore()

// State
const loading = ref(false)
const showDetailsModal = ref(false)
const selectedTransaction = ref(null)
const currentPage = ref(1)
const itemsPerPage = ref(10)
const showExportMenu = ref(false)
const exporting = ref(false)

const filters = ref({
  dateStart: '',
  dateEnd: '',
  agentId: '',
  paymentMethod: ''
})

// Computed
const agents = computed(() => agentStore.agents)

const displayedTransactions = computed(() => {
  let transactions = transactionStore.filteredTransactions
  
  // Pagination
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return transactions.slice(start, end)
})

const totalItems = computed(() => transactionStore.filteredTransactions.length)
const totalPages = computed(() => Math.ceil(totalItems.value / itemsPerPage.value))

// Methods
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(amount)
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const applyFilters = () => {
  transactionStore.updateFilters(filters.value)
  currentPage.value = 1
}

const clearFilters = () => {
  filters.value = {
    dateStart: '',
    dateEnd: '',
    agentId: '',
    paymentMethod: ''
  }
  transactionStore.clearFilters()
  currentPage.value = 1
}

const handlePageChange = (page) => {
  currentPage.value = page
}

const viewTransactionDetails = (transaction) => {
  selectedTransaction.value = transaction
  showDetailsModal.value = true
}

const closeDetailsModal = () => {
  showDetailsModal.value = false
  selectedTransaction.value = null
}

const exportTransactions = async (format) => {
  showExportMenu.value = false
  exporting.value = true
  try {
    const params = {}
    if (filters.value.dateStart) params.debut = new Date(filters.value.dateStart).toISOString()
    if (filters.value.dateEnd) params.fin = new Date(filters.value.dateEnd + 'T23:59:59').toISOString()
    if (filters.value.agentId) params.agentId = filters.value.agentId
    if (filters.value.paymentMethod) params.paymentMethod = filters.value.paymentMethod

    const response = await transactionService.exportTransactions(format, params)
    const blob = new Blob([response.data], {
      type: format === 'csv' ? 'text/csv' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    const now = new Date()
    const filename = `transactions_${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}.${format}`
    link.setAttribute('download', filename)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Erreur export:', error)
    alert('Erreur lors de l\'export des transactions')
  } finally {
    exporting.value = false
  }
}

const generatePdfReport = async () => {
  exporting.value = true
  try {
    const { agentService } = await import('@/services')

    const agentsRes = await agentService.getActiveAgents()
    const activeAgents = agentsRes.data || []

    let dateRange = null
    if (filters.value.dateStart || filters.value.dateEnd) {
      dateRange = {
        debut: filters.value.dateStart ? new Date(filters.value.dateStart).toISOString() : new Date(Date.now() - 7 * 86400000).toISOString(),
        fin: filters.value.dateEnd ? new Date(filters.value.dateEnd + 'T23:59:59').toISOString() : new Date().toISOString()
      }
    } else {
      const fin = new Date()
      const debut = new Date()
      debut.setDate(debut.getDate() - 7)
      dateRange = { debut: debut.toISOString(), fin: fin.toISOString() }
    }

    const agentStatsData = await Promise.all(
      activeAgents.map(async (agent) => {
        try {
          const txRes = await transactionService.getTransactionsByAgentAndDateRange(
            agent.id, new Date(dateRange.debut), new Date(dateRange.fin)
          )
          const transactions = txRes.data || []
          const totalAmount = transactions.reduce((s, t) => s + (t.montant || 0), 0)
          const cashAmount = transactions.filter(t => t.modePaiement === 'ESPECE').reduce((s, t) => s + (t.montant || 0), 0)
          const mobileMoneyAmount = transactions.filter(t => t.modePaiement === 'MOBILE_MONEY').reduce((s, t) => s + (t.montant || 0), 0)
          return {
            id: agent.id, nom: agent.nom, prenom: agent.prenom,
            transactionCount: transactions.length,
            totalAmount,
            avgAmount: transactions.length > 0 ? totalAmount / transactions.length : 0,
            cashAmount, mobileMoneyAmount
          }
        } catch {
          return { id: agent.id, nom: agent.nom, prenom: agent.prenom, transactionCount: 0, totalAmount: 0, avgAmount: 0, cashAmount: 0, mobileMoneyAmount: 0 }
        }
      })
    )

    let recensementStats = null
    try {
      const recRes = await api.get('/api/recensement/statistics')
      recensementStats = recRes.data
    } catch { /* optional */ }

    generateProductivityReport({
      agents: agentStatsData,
      recensementStats,
      dateRange
    })
  } catch (error) {
    console.error('Erreur generation rapport PDF:', error)
    alert('Erreur lors de la generation du rapport PDF')
  } finally {
    exporting.value = false
  }
}

// Lifecycle
onMounted(async () => {
  loading.value = true
  try {
    await Promise.all([
      transactionStore.fetchTransactions(),
      agentStore.fetchAgents()
    ])
  } catch (error) {
    console.error('Erreur lors du chargement:', error)
  } finally {
    loading.value = false
  }
})
</script>
