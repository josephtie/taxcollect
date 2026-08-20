<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Reversements</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="refreshData"
              :disabled="loading"
              class="p-2 text-gray-600 hover:text-gray-900 transition-colors"
            >
              <RefreshCw :class="{ 'animate-spin': loading }" class="w-5 h-5" />
            </button>
            <button
              @click="exportDeposits"
              class="btn-primary"
            >
              <Download class="w-4 h-4 mr-2" />
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

      <!-- Reversements Content -->
      <div class="flex-1 p-6">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <StatsCard
            title="En Attente de Validation"
            :value="clotureStore.pendingValidation.length"
            :icon="Clock"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
          
          <StatsCard
            title="Validées Aujourd'hui"
            :value="validatedToday"
            :icon="CheckCircle"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          
          <StatsCard
            title="Total Déposé Aujourd'hui"
            :value="clotureStore.todayTotalDeposits"
            :icon="Banknote"
            format="currency"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
          />
          
          <StatsCard
            title="Rejetées"
            :value="clotureStore.rejectedClotures.length"
            :icon="XCircle"
            icon-color="text-danger-600"
            icon-bg-color="bg-danger-50"
          />
        </div>

        <!-- Tabs -->
        <div class="bg-white rounded-lg shadow-soft border border-gray-100">
          <div class="border-b border-gray-200">
            <nav class="flex -mb-px">
              <button
                v-for="tab in tabs"
                :key="tab.key"
                @click="activeTab = tab.key"
                class="py-4 px-6 text-sm font-medium border-b-2 transition-colors"
                :class="[
                  activeTab === tab.key
                    ? 'border-primary-500 text-primary-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                ]"
              >
                {{ tab.label }}
                <span
                  v-if="tab.count !== undefined"
                  class="ml-2 bg-gray-100 text-gray-600 text-xs rounded-full px-2 py-0.5"
                >
                  {{ tab.count }}
                </span>
              </button>
            </nav>
          </div>

          <!-- Tab Content -->
          <div class="p-6">
            <!-- Pending Validations -->
            <div v-if="activeTab === 'pending'">
              <div class="space-y-4">
                <div
                  v-for="cloture in clotureStore.pendingValidation"
                  :key="cloture.id"
                  class="border border-gray-200 rounded-lg p-6 hover:shadow-medium transition-shadow"
                >
                  <div class="flex items-start justify-between">
                    <div class="flex-1">
                      <div class="flex items-center mb-4">
                        <div class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center mr-3">
                          <User class="w-5 h-5 text-primary-600" />
                        </div>
                        <div>
                          <h3 class="text-lg font-semibold text-gray-900">
                            {{ cloture.agentNom }} {{ cloture.agentPrenom }}
                          </h3>
                          <p class="text-sm text-gray-500">
                            Clôture du {{ formatDate(cloture.dateCloture) }}
                          </p>
                        </div>
                      </div>

                      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                        <div>
                          <p class="text-sm text-gray-500">Total Espèces</p>
                          <p class="text-lg font-semibold text-gray-900">
                            {{ formatCurrency(cloture.montantTotalEspece) }}
                          </p>
                        </div>
                        <div>
                          <p class="text-sm text-gray-500">Total Mobile Money</p>
                          <p class="text-lg font-semibold text-gray-900">
                            {{ formatCurrency(cloture.montantTotalMobileMoney) }}
                          </p>
                        </div>
                        <div>
                          <p class="text-sm text-gray-500">Montant Déclaré</p>
                          <p class="text-lg font-semibold text-gray-900">
                            {{ formatCurrency(cloture.montantDeclare) }}
                          </p>
                        </div>
                      </div>

                      <div v-if="cloture.commentaireAgent" class="bg-gray-50 rounded p-3 mb-4">
                        <p class="text-sm text-gray-600">
                          <span class="font-medium">Commentaire agent:</span> {{ cloture.commentaireAgent }}
                        </p>
                      </div>

                      <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-4 text-sm text-gray-500">
                          <span>{{ cloture.nombreTransactions }} transactions</span>
                          <span>•</span>
                          <StatusBadge :status="cloture.statut" type="cloture" />
                        </div>
                        
                        <div class="flex items-center space-x-2">
                          <button
                            @click="showRejectModal(cloture)"
                            class="btn-danger"
                          >
                            <X class="w-4 h-4 mr-2" />
                            Rejeter
                          </button>
                          <button
                            @click="showValidateModal(cloture)"
                            class="btn-success"
                          >
                            <Check class="w-4 h-4 mr-2" />
                            Valider
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div v-if="clotureStore.pendingValidation.length === 0" class="text-center py-12">
                  <CheckCircle class="w-12 h-12 text-gray-400 mx-auto mb-4" />
                  <p class="text-gray-500">Aucune demande de validation en attente</p>
                </div>
              </div>
            </div>

            <!-- Validated -->
            <div v-if="activeTab === 'validated'">
              <TransactionTable
                :transactions="validatedTransactions"
                :loading="clotureStore.loading"
                :show-filters="true"
                title="Clôtures Validées"
                @view-details="viewClotureDetails"
              />
            </div>

            <!-- Deposited -->
            <div v-if="activeTab === 'deposited'">
              <TransactionTable
                :transactions="depositedTransactions"
                :loading="clotureStore.loading"
                :show-filters="true"
                title="Dépôts Bancaires Confirmés"
                @view-details="viewClotureDetails"
              />
            </div>

            <!-- Rejected -->
            <div v-if="activeTab === 'rejected'">
              <TransactionTable
                :transactions="clotureStore.rejectedClotures"
                :loading="clotureStore.loading"
                :show-filters="true"
                title="Clôtures Rejetées"
                @view-details="viewClotureDetails"
              />
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Validation Modal -->
    <div v-if="showValidationModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
          Valider la clôture de caisse
        </h3>
        
        <div class="mb-4">
          <p class="text-sm text-gray-600 mb-2">
            Agent: {{ selectedCloture?.agentNom }} {{ selectedCloture?.agentPrenom }}
          </p>
          <p class="text-sm text-gray-600">
            Montant à valider: {{ formatCurrency(selectedCloture?.montantDeclare) }}
          </p>
        </div>

        <form @submit.prevent="validateCloture">
          <div class="mb-4">
            <label class="form-label">Commentaire (optionnel)</label>
            <textarea
              v-model="validationForm.commentaire"
              rows="3"
              class="form-input"
              placeholder="Ajouter un commentaire..."
            ></textarea>
          </div>
          
          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="closeValidationModal"
              class="btn-secondary"
            >
              Annuler
            </button>
            <button
              type="submit"
              :disabled="validating"
              class="btn-success"
            >
              {{ validating ? 'Validation...' : 'Valider' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Rejection Modal -->
    <div v-if="showRejectionModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">
          Rejeter la clôture de caisse
        </h3>
        
        <form @submit.prevent="rejectCloture">
          <div class="mb-4">
            <label class="form-label">Motif du rejet *</label>
            <textarea
              v-model="rejectionForm.commentaire"
              rows="3"
              required
              class="form-input"
              placeholder="Expliquer le motif du rejet..."
            ></textarea>
          </div>
          
          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="closeRejectionModal"
              class="btn-secondary"
            >
              Annuler
            </button>
            <button
              type="submit"
              :disabled="rejecting"
              class="btn-danger"
            >
              {{ rejecting ? 'Rejet...' : 'Rejeter' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Cloture Details Modal -->
    <div v-if="showDetailsModal && selectedCloture" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold text-gray-900">
            Détails de la Clôture de Caisse
          </h3>
          <button
            @click="showDetailsModal = false"
            class="text-gray-400 hover:text-gray-600"
          >
            <X class="w-6 h-6" />
          </button>
        </div>
        
        <div class="space-y-6">
          <!-- Header Info -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="bg-gray-50 rounded-lg p-4">
              <h4 class="font-medium text-gray-900 mb-3">Informations générales</h4>
              <div class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Agent:</span>
                  <span class="text-sm font-medium text-gray-900">{{ selectedCloture.agentNom }} {{ selectedCloture.agentPrenom }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Date de clôture:</span>
                  <span class="text-sm font-medium text-gray-900">{{ formatDate(selectedCloture.dateCloture) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Statut:</span>
                  <StatusBadge :status="selectedCloture.statut" type="cloture" />
                </div>
              </div>
            </div>
            
            <div class="bg-gray-50 rounded-lg p-4">
              <h4 class="font-medium text-gray-900 mb-3">Montants</h4>
              <div class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Total Espèces:</span>
                  <span class="text-sm font-medium text-gray-900">{{ formatCurrency(selectedCloture.montantTotalEspece) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Total Mobile Money:</span>
                  <span class="text-sm font-medium text-gray-900">{{ formatCurrency(selectedCloture.montantTotalMobileMoney) }}</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Montant Déclaré:</span>
                  <span class="text-sm font-medium text-gray-900">{{ formatCurrency(selectedCloture.montantDeclare) }}</span>
                </div>
                <div v-if="selectedCloture.montantDepose" class="flex justify-between">
                  <span class="text-sm text-gray-600">Montant Déposé:</span>
                  <span class="text-sm font-medium text-gray-900">{{ formatCurrency(selectedCloture.montantDepose) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Comments Section -->
          <div v-if="selectedCloture.commentaireAgent || selectedCloture.commentaireTresor" class="space-y-4">
            <div v-if="selectedCloture.commentaireAgent" class="bg-primary-50 rounded-lg p-4">
              <h5 class="font-medium text-primary-900 mb-2">Commentaire Agent</h5>
              <p class="text-sm text-primary-800">{{ selectedCloture.commentaireAgent }}</p>
            </div>
            
            <div v-if="selectedCloture.commentaireTresor" class="bg-yellow-50 rounded-lg p-4">
              <h5 class="font-medium text-yellow-900 mb-2">Commentaire Trésor</h5>
              <p class="text-sm text-yellow-800">{{ selectedCloture.commentaireTresor }}</p>
            </div>
          </div>

          <!-- Transaction Details -->
          <div class="bg-gray-50 rounded-lg p-4">
            <h4 class="font-medium text-gray-900 mb-3">Détails des transactions</h4>
            <div class="text-sm text-gray-600">
              <p>Nombre total de transactions: {{ selectedCloture.nombreTransactions || 0 }}</p>
              <p v-if="selectedCloture.dateDepotBanque">Date de dépôt: {{ formatDate(selectedCloture.dateDepotBanque) }}</p>
              <p v-if="selectedCloture.referenceDepot">Référence de dépôt: {{ selectedCloture.referenceDepot }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useClotureStore } from '@/stores/cloture'
import { useAgentStore } from '@/stores/agents'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import TransactionTable from '@/components/TransactionTable.vue'
import {
  Clock,
  CheckCircle,
  XCircle,
  Banknote,
  RefreshCw,
  Download,
  User,
  X,
  Check
} from 'lucide-vue-next'

const clotureStore = useClotureStore()
const agentStore = useAgentStore()

// State
const activeTab = ref('pending')
const loading = ref(false)
const showValidationModal = ref(false)
const showRejectionModal = ref(false)
const selectedCloture = ref(null)
const validating = ref(false)
const rejecting = ref(false)

const validationForm = ref({
  commentaire: ''
})

const rejectionForm = ref({
  commentaire: ''
})

const showDetailsModal = ref(false)

const filters = ref({
  startDate: null,
  endDate: null
})

// Computed
const tabs = computed(() => [
  {
    key: 'pending',
    label: 'En attente de validation',
    count: clotureStore.pendingValidation.length
  },
  {
    key: 'validated',
    label: 'Validées'
  },
  {
    key: 'deposited',
    label: 'Déposées en banque'
  },
  {
    key: 'rejected',
    label: 'Rejetées'
  }
])

const validatedToday = computed(() => {
  const today = new Date().toISOString().split('T')[0]
  return clotureStore.validatedClotures.filter(c => 
    c.dateValidationTresor?.startsWith(today)
  ).length
})

const validatedTransactions = computed(() => {
  return clotureStore.validatedClotures.map(cloture => ({
    ...cloture,
    numeroRecu: `CL-${cloture.id}`,
    dateCreation: cloture.dateCloture,
    contribuableNom: '-',
    contribuablePrenom: '-',
    agentNom: cloture.agentNom,
    agentPrenom: cloture.agentPrenom,
    montant: cloture.montantTotal,
    modePaiement: 'MIXTE',
    statut: cloture.statut
  }))
})

const depositedTransactions = computed(() => {
  return clotureStore.depositedClotures.map(cloture => ({
    ...cloture,
    numeroRecu: `DEP-${cloture.id}`,
    dateCreation: cloture.dateDepotBanque,
    contribuableNom: '-',
    contribuablePrenom: '-',
    agentNom: cloture.agentNom,
    agentPrenom: cloture.agentPrenom,
    montant: cloture.montantDepose,
    modePaiement: 'DEPOT',
    statut: cloture.statut
  }))
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

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  })
}

const refreshData = async () => {
  loading.value = true
  try {
    await clotureStore.refreshClotureData()
  } catch (error) {
    console.error('Erreur lors du rafraîchissement:', error)
  } finally {
    loading.value = false
  }
}

const showValidateModal = (cloture) => {
  selectedCloture.value = cloture
  validationForm.value.commentaire = ''
  showValidationModal.value = true
}

const showRejectModal = (cloture) => {
  selectedCloture.value = cloture
  rejectionForm.value.commentaire = ''
  showRejectionModal.value = true
}

const closeValidationModal = () => {
  showValidationModal.value = false
  selectedCloture.value = null
  validationForm.value.commentaire = ''
}

const closeRejectionModal = () => {
  showRejectionModal.value = false
  selectedCloture.value = null
  rejectionForm.value.commentaire = ''
}

const validateCloture = async () => {
  validating.value = true
  try {
    // Simuler l'ID de l'admin qui valide (à remplacer par l'authentification)
    const adminId = 1
    await clotureStore.validateCloture(
      selectedCloture.value.id,
      adminId,
      validationForm.value.commentaire
    )
    closeValidationModal()
  } catch (error) {
    console.error('Erreur lors de la validation:', error)
  } finally {
    validating.value = false
  }
}

const rejectCloture = async () => {
  rejecting.value = true
  try {
    // Simuler l'ID de l'admin qui rejette (à remplacer par l'authentification)
    const adminId = 1
    await clotureStore.rejectCloture(
      selectedCloture.value.id,
      adminId,
      rejectionForm.value.commentaire
    )
    closeRejectionModal()
  } catch (error) {
    console.error('Erreur lors du rejet:', error)
  } finally {
    rejecting.value = false
  }
}

const viewClotureDetails = (cloture) => {
  selectedCloture.value = cloture
  showDetailsModal.value = true
}

const exportDeposits = async () => {
  try {
    const startDate = filters.startDate || new Date(new Date().setDate(new Date().getDate() - 30))
    const endDate = filters.endDate || new Date()
    
    const response = await clotureService.exportDeposits(startDate, endDate, 'PDF')
    
    // Créer un blob et télécharger le fichier
    const blob = new Blob([response.data], { type: 'application/pdf' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `reversements_${new Date().toISOString().split('T')[0]}.pdf`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    
    console.log('Export des reversements réussi')
  } catch (error) {
    console.error('Erreur lors de l\'exportation des reversements:', error)
    // Afficher une notification d'erreur à l'utilisateur
    alert('Erreur lors de l\'exportation. Veuillez réessayer.')
  }
}

// Lifecycle
onMounted(() => {
  clotureStore.fetchClotures()
})
</script>
