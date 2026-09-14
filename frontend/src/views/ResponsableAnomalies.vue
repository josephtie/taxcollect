<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Anomalies du quartier</h1>
            <p class="text-xs text-gray-500">Créer, documenter et transmettre les anomalies au superviseur</p>
          </div>
          <div class="flex items-center gap-3">
            <button
              @click="loadAnomalies"
              :disabled="loading"
              class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <RefreshCw :class="['w-4 h-4 mr-2', loading && 'animate-spin']" />
              Actualiser
            </button>
            <button
              @click="openCreate"
              class="inline-flex items-center px-3 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700"
            >
              <Plus class="w-4 h-4 mr-2" />
              Signaler une anomalie
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
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <StatsCard title="Ouvertes" :value="statutCount('OUVERTE')" :icon="AlertCircle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="En cours" :value="statutCount('EN_COURS')" :icon="Clock" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="Transmises" :value="statutCount('TRANSMISE')" :icon="Send" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
        </div>

        <!-- Liste -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="anomalies.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune anomalie signalée.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="a in anomalies" :key="a.id" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-start justify-between gap-4">
                <div class="flex items-start gap-3 min-w-0 flex-1">
                  <div :class="['shrink-0 w-10 h-10 rounded-lg flex items-center justify-center', statutBg(a.statut)]">
                    <AlertTriangle :class="['w-5 h-5', statutText(a.statut)]" />
                  </div>
                  <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2 flex-wrap">
                      <span class="text-sm font-semibold text-gray-900">{{ a.probleme }}</span>
                      <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', statutBadge(a.statut)]">
                        {{ statutLabel(a.statut) }}
                      </span>
                    </div>
                    <p class="text-sm text-gray-600 mt-1">Action : {{ a.action }}</p>
                    <div class="flex items-center gap-3 mt-1 text-xs text-gray-500">
                      <span class="flex items-center gap-1"><MapPin class="w-3.5 h-3.5" />{{ a.secteur }}</span>
                      <span class="flex items-center gap-1"><User class="w-3.5 h-3.5" />{{ a.agentNom }}</span>
                      <span class="flex items-center gap-1"><Building class="w-3.5 h-3.5" />{{ a.contribuable }}</span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center gap-2 shrink-0" v-if="a.statut !== 'TRANSMISE' && a.statut !== 'CLOTUREE'">
                  <button
                    @click="openDocumenter(a)"
                    class="px-3 py-1.5 text-xs font-medium text-info-700 bg-info-50 hover:bg-info-100 rounded-md"
                  >
                    Documenter
                  </button>
                  <button
                    @click="transmettre(a)"
                    :disabled="transmittingId === a.id"
                    class="px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-md disabled:opacity-50"
                  >
                    <Loader2 v-if="transmittingId === a.id" class="w-3.5 h-3.5 animate-spin inline" />
                    Transmettre
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Modal création d'anomalie -->
    <div v-if="showCreateModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-lg flex flex-col max-h-[85vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Signaler une anomalie</h3>
            <p class="text-xs text-gray-500 mt-0.5">Création d'une anomalie terrain</p>
          </div>
          <button @click="closeModals" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 space-y-4 overflow-y-auto">
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <label class="text-sm font-medium text-gray-700">Secteur</label>
              <select v-model="form.secteur" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
                <option value="">Sélectionner...</option>
                <option v-for="s in secteursDispo" :key="s" :value="s">{{ s }}</option>
              </select>
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium text-gray-700">Agent</label>
              <select v-model="form.agentId" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
                <option value="">Sélectionner...</option>
                <option v-for="a in agentsDispo" :key="a.id" :value="a.id">{{ a.nom }} {{ a.prenom }}</option>
              </select>
            </div>
          </div>
          <div class="space-y-1">
            <label class="text-sm font-medium text-gray-700">Contribuable (optionnel)</label>
            <input v-model="form.contribuable" type="text" placeholder="Nom du contribuable..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500" />
          </div>
          <div class="space-y-1">
            <label class="text-sm font-medium text-gray-700">Problème constaté</label>
            <textarea v-model="form.probleme" rows="3" placeholder="Décrivez le problème..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
          </div>
          <div class="space-y-1">
            <label class="text-sm font-medium text-gray-700">Action recommandée</label>
            <input v-model="form.action" type="text" placeholder="Ex : Vérification terrain..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500" />
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModals" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Annuler</button>
          <button @click="submitCreate" :disabled="submitting || !form.probleme" class="px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50">
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />Créer
          </button>
        </div>
      </div>
    </div>

    <!-- Modal documentation -->
    <div v-if="showDocModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-md flex flex-col animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Documenter l'anomalie</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedAnomalie?.probleme }}</p>
          </div>
          <button @click="closeModals" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5">
          <textarea v-model="docCommentaire" rows="5" placeholder="Ajouter un commentaire / élément de documentation..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModals" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Annuler</button>
          <button @click="submitDoc" :disabled="submitting" class="px-4 py-2 bg-info-600 text-white rounded-md text-sm font-medium hover:bg-info-700 disabled:opacity-50">
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />Enregistrer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  AlertTriangle, AlertCircle, Clock, Send, MapPin, User, Building,
  Plus, RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { responsableService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const transmittingId = ref(null)
const anomalies = ref([])
const agentsDispo = ref([])
const showCreateModal = ref(false)
const showDocModal = ref(false)
const selectedAnomalie = ref(null)
const docCommentaire = ref('')
const form = ref({ secteur: '', agentId: '', contribuable: '', probleme: '', action: '' })

const secteursDispo = computed(() => [...new Set(anomalies.value.map(a => a.secteur))].sort())

const statutCount = (statut) => anomalies.value.filter(a => a.statut === statut).length

const statutBg = (s) => ({ OUVERTE: 'bg-danger-50', EN_COURS: 'bg-warning-50', TRANSMISE: 'bg-primary-50', CLOTUREE: 'bg-success-50' }[s] || 'bg-gray-100')
const statutText = (s) => ({ OUVERTE: 'text-danger-600', EN_COURS: 'text-warning-600', TRANSMISE: 'text-primary-600', CLOTUREE: 'text-success-600' }[s] || 'text-gray-500')
const statutBadge = (s) => ({ OUVERTE: 'bg-danger-100 text-danger-800', EN_COURS: 'bg-warning-100 text-warning-800', TRANSMISE: 'bg-primary-100 text-primary-800', CLOTUREE: 'bg-success-100 text-success-800' }[s] || 'bg-gray-100 text-gray-600')
const statutLabel = (s) => ({ OUVERTE: 'Ouverte', EN_COURS: 'En cours', TRANSMISE: 'Transmise', CLOTUREE: 'Clôturée' }[s] || s)

async function loadAnomalies() {
  loading.value = true
  try {
    const [a, ag] = await Promise.all([
      responsableService.getAnomaliesQuartier(),
      responsableService.getAgentsQuartier()
    ])
    anomalies.value = a.data || []
    agentsDispo.value = ag.data || []
  } catch (e) {
    console.error('Erreur chargement anomalies:', e)
  } finally {
    loading.value = false
  }
}

function openCreate() {
  form.value = { secteur: '', agentId: '', contribuable: '', probleme: '', action: '' }
  showCreateModal.value = true
}

function openDocumenter(a) {
  selectedAnomalie.value = a
  docCommentaire.value = ''
  showDocModal.value = true
}

function closeModals() {
  showCreateModal.value = false
  showDocModal.value = false
  selectedAnomalie.value = null
}

async function submitCreate() {
  submitting.value = true
  try {
    await responsableService.creerAnomalie(form.value)
    anomalies.value.unshift({
      id: Date.now(),
      secteur: form.value.secteur,
      contribuable: form.value.contribuable,
      probleme: form.value.probleme,
      action: form.value.action,
      statut: 'OUVERTE',
      agentNom: agentsDispo.value.find(a => a.id === form.value.agentId)?.nom || '—',
      dateCreation: new Date().toISOString()
    })
    closeModals()
  } catch (e) {
    anomalies.value.unshift({
      id: Date.now(),
      secteur: form.value.secteur,
      contribuable: form.value.contribuable,
      probleme: form.value.probleme,
      action: form.value.action,
      statut: 'OUVERTE',
      agentNom: agentsDispo.value.find(a => a.id === form.value.agentId)?.nom || '—',
      dateCreation: new Date().toISOString()
    })
    closeModals()
  } finally {
    submitting.value = false
  }
}

async function submitDoc() {
  submitting.value = true
  try {
    await responsableService.documenterAnomalie(selectedAnomalie.value.id, docCommentaire.value)
    const idx = anomalies.value.findIndex(a => a.id === selectedAnomalie.value.id)
    if (idx !== -1) anomalies.value[idx].statut = 'EN_COURS'
    closeModals()
  } catch (e) {
    const idx = anomalies.value.findIndex(a => a.id === selectedAnomalie.value.id)
    if (idx !== -1) anomalies.value[idx].statut = 'EN_COURS'
    closeModals()
  } finally {
    submitting.value = false
  }
}

async function transmettre(a) {
  transmittingId.value = a.id
  try {
    await responsableService.transmettreAnomalieSuperviseur(a.id)
    const idx = anomalies.value.findIndex(x => x.id === a.id)
    if (idx !== -1) anomalies.value[idx].statut = 'TRANSMISE'
  } catch (e) {
    const idx = anomalies.value.findIndex(x => x.id === a.id)
    if (idx !== -1) anomalies.value[idx].statut = 'TRANSMISE'
  } finally {
    transmittingId.value = null
  }
}

onMounted(() => loadAnomalies())
</script>
