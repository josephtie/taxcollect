<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Réclamations</h1>
            <p class="text-xs text-gray-500">Traitement des contestations des contribuables</p>
          </div>
          <button
            @click="loadReclamations"
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
        <!-- KPI -->
        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
          <StatsCard title="En attente" :value="statutCount('EN_ATTENTE')" :icon="Clock" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="En examen" :value="statutCount('EN_EXAMEN')" :icon="Eye" icon-color="text-info-600" icon-bg-color="bg-info-50" />
          <StatsCard title="Transmises" :value="statutCount('TRANSMISE')" :icon="Send" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="Clôturées" :value="statutCount('CLOTUREE')" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
        </div>

        <!-- Liste -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="reclamations.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune réclamation.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="r in reclamations" :key="r.id" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-start justify-between gap-4">
                <div class="flex items-start gap-3 min-w-0 flex-1">
                  <div :class="['shrink-0 w-10 h-10 rounded-lg flex items-center justify-center', statutBg(r.statut)]">
                    <MessageSquare :class="['w-5 h-5', statutText(r.statut)]" />
                  </div>
                  <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                      <p class="text-sm font-semibold text-gray-900">Réclamation #{{ r.id }}</p>
                      <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', statutBadge(r.statut)]">
                        {{ statutLabel(r.statut) }}
                      </span>
                    </div>
                    <p class="text-sm text-gray-600 mt-1">{{ r.contribuableNom }} — {{ r.motif }}</p>
                    <div class="flex items-center gap-3 mt-1 text-xs text-gray-500">
                      <span class="flex items-center gap-1"><Wallet class="w-3.5 h-3.5" />{{ formatCurrency(r.montant) }}</span>
                      <span class="flex items-center gap-1"><Calendar class="w-3.5 h-3.5" />{{ formatDate(r.date) }}</span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center gap-2 shrink-0" v-if="r.statut !== 'CLOTUREE'">
                  <button
                    v-if="r.statut === 'EN_ATTENTE'"
                    @click="openAction(r, 'examiner')"
                    class="px-3 py-1.5 text-xs font-medium text-info-700 bg-info-50 hover:bg-info-100 rounded-md"
                  >
                    Examiner
                  </button>
                  <button
                    @click="openAction(r, 'transmettre')"
                    class="px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-md"
                  >
                    Transmettre
                  </button>
                  <button
                    @click="openAction(r, 'cloturer')"
                    class="px-3 py-1.5 text-xs font-medium text-success-700 bg-success-50 hover:bg-success-100 rounded-md"
                  >
                    Clôturer
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Modal action -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-lg flex flex-col max-h-[80vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">{{ actionTitle }}</h3>
            <p class="text-xs text-gray-500 mt-0.5">Réclamation #{{ selectedReclamation?.id }} — {{ selectedReclamation?.contribuableNom }}</p>
          </div>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="p-5 space-y-4">
          <div class="bg-gray-50 rounded-lg p-3 text-sm text-gray-600 space-y-1">
            <p><span class="font-medium">Motif :</span> {{ selectedReclamation?.motif }}</p>
            <p><span class="font-medium">Montant :</span> {{ formatCurrency(selectedReclamation?.montant) }}</p>
          </div>
          <div v-if="actionType === 'transmettre'" class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Service destinataire</label>
            <select v-model="serviceDestinataire" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Sélectionner...</option>
              <option value="TRESOR">Trésor</option>
              <option value="ADMIN">Administration</option>
              <option value="ADMINISTRATION_FISCALE">Administration fiscale</option>
            </select>
          </div>
          <textarea
            v-model="commentaire"
            rows="4"
            :placeholder="commentairePlaceholder"
            class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
          ></textarea>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModal" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
            Annuler
          </button>
          <button
            @click="submitAction"
            :disabled="submitting"
            class="px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50"
          >
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />
            Confirmer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  Clock, Eye, Send, CheckCircle, MessageSquare, Wallet, Calendar,
  RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { signalementService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const reclamations = ref([])
const showModal = ref(false)
const selectedReclamation = ref(null)
const actionType = ref('')
const commentaire = ref('')
const serviceDestinataire = ref('')

const statutCount = (statut) => reclamations.value.filter(r => r.statut === statut).length

const actionTitle = computed(() => ({
  examiner: 'Examiner la réclamation',
  transmettre: 'Transmettre la réclamation',
  cloturer: 'Clôturer la réclamation'
}[actionType.value] || 'Action'))

const commentairePlaceholder = computed(() => ({
  examiner: 'Résultat de l\'examen...',
  transmettre: 'Note de transmission...',
  cloturer: 'Résolution / motif de clôture...'
}[actionType.value] || 'Commentaire...'))

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : ''

const statutBg = (s) => ({ EN_ATTENTE: 'bg-warning-50', EN_EXAMEN: 'bg-info-50', TRANSMISE: 'bg-primary-50', CLOTUREE: 'bg-success-50' }[s] || 'bg-gray-100')
const statutText = (s) => ({ EN_ATTENTE: 'text-warning-600', EN_EXAMEN: 'text-info-600', TRANSMISE: 'text-primary-600', CLOTUREE: 'text-success-600' }[s] || 'text-gray-500')
const statutBadge = (s) => ({ EN_ATTENTE: 'bg-warning-100 text-warning-800', EN_EXAMEN: 'bg-info-100 text-info-800', TRANSMISE: 'bg-primary-100 text-primary-800', CLOTUREE: 'bg-success-100 text-success-800' }[s] || 'bg-gray-100 text-gray-600')
const statutLabel = (s) => ({ EN_ATTENTE: 'En attente', EN_EXAMEN: 'En examen', TRANSMISE: 'Transmise', CLOTUREE: 'Clôturée' }[s] || s)

async function loadReclamations() {
  loading.value = true
  try {
    // Les "réclamations" frontend correspondent aux signalements backend.
    const response = await signalementService.getSignalements()
    reclamations.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement réclamations:', e)
  } finally {
    loading.value = false
  }
}

function openAction(r, action) {
  selectedReclamation.value = r
  actionType.value = action
  commentaire.value = ''
  serviceDestinataire.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedReclamation.value = null
}

async function submitAction() {
  submitting.value = true
  try {
    const id = selectedReclamation.value.id
    // Mapping vers SignalementController : tout passe par /traiter
    if (actionType.value === 'examiner') {
      await signalementService.traiterSignalement(id, { action: 'examiner', commentaire: commentaire.value })
    } else if (actionType.value === 'transmettre') {
      await signalementService.traiterSignalement(id, { action: 'transmettre', serviceDestinataire: serviceDestinataire.value })
    } else if (actionType.value === 'cloturer') {
      await signalementService.traiterSignalement(id, { action: 'cloturer', commentaire: commentaire.value })
    }
    updateLocalStatut(id)
    closeModal()
  } catch (e) {
    console.error('Erreur action réclamation:', e)
  } finally {
    submitting.value = false
  }
}

function updateLocalStatut(id) {
  const idx = reclamations.value.findIndex(r => r.id === id)
  if (idx === -1) return
  if (actionType.value === 'examiner') reclamations.value[idx].statut = 'EN_EXAMEN'
  else if (actionType.value === 'transmettre') reclamations.value[idx].statut = 'TRANSMISE'
  else if (actionType.value === 'cloturer') reclamations.value[idx].statut = 'CLOTUREE'
}

onMounted(() => loadReclamations())
</script>
