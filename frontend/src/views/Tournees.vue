<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Tournées</h1>
            <p class="text-xs text-gray-500">Planification et suivi des tournées de collecte</p>
          </div>
          <div class="flex items-center gap-3">
            <button
              @click="loadTournees"
              :disabled="loading"
              class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <RefreshCw :class="['w-4 h-4 mr-2', loading && 'animate-spin']" />
              Actualiser
            </button>
            <button
              @click="openCreateModal"
              class="inline-flex items-center px-3 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700"
            >
              <Plus class="w-4 h-4 mr-2" />
              Nouvelle tournée
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
          <StatsCard title="Total tournées" :value="tournees.length" :icon="Route" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="En cours" :value="statutCount('EN_COURS')" :icon="Play" icon-color="text-info-600" icon-bg-color="bg-info-50" />
          <StatsCard title="Planifiées" :value="statutCount('PLANIFIEE')" :icon="Calendar" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="Terminées" :value="statutCount('TERMINEE')" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
        </div>

        <!-- Liste des tournées -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="tournees.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune tournée planifiée.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="t in tournees" :key="t.id" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-center justify-between gap-4">
                <div class="flex items-center gap-3 min-w-0">
                  <div :class="['shrink-0 w-10 h-10 rounded-lg flex items-center justify-center', statutBg(t.statut)]">
                    <Route :class="['w-5 h-5', statutText(t.statut)]" />
                  </div>
                  <div class="min-w-0">
                    <p class="text-sm font-semibold text-gray-900">Tournée #{{ t.id }}</p>
                    <div class="flex items-center gap-3 mt-1 text-xs text-gray-500">
                      <span class="flex items-center gap-1"><User class="w-3.5 h-3.5" />{{ t.agentNom }}</span>
                      <span class="flex items-center gap-1"><MapPin class="w-3.5 h-3.5" />{{ t.zoneNom }}</span>
                      <span class="flex items-center gap-1"><Calendar class="w-3.5 h-3.5" />{{ formatDate(t.date) }}</span>
                      <span class="flex items-center gap-1"><Users class="w-3.5 h-3.5" />{{ t.nbContribuables }} contrib.</span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center gap-4 shrink-0">
                  <div class="text-right">
                    <p class="text-xs text-gray-500">Objectif</p>
                    <p class="text-sm font-semibold text-gray-900">{{ formatCurrency(t.objectif) }}</p>
                  </div>
                  <span :class="['inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium', statutBadge(t.statut)]">
                    {{ statutLabel(t.statut) }}
                  </span>
                  <button
                    v-if="t.statut === 'TERMINEE'"
                    @click="viewRapport(t)"
                    class="px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-md"
                  >
                    Rapport
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Modal création de tournée -->
    <div v-if="showCreateModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-xl flex flex-col max-h-[85vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Nouvelle tournée</h3>
            <p class="text-xs text-gray-500 mt-0.5">Planifier une tournée de collecte</p>
          </div>
          <button @click="closeCreateModal" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="p-5 space-y-4 overflow-y-auto">
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-1">
              <label class="text-sm font-medium text-gray-700">Agent</label>
              <select v-model="form.agentId" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
                <option value="">Sélectionner...</option>
                <option v-for="a in agentOptions" :key="a" :value="a">{{ a }}</option>
              </select>
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium text-gray-700">Date</label>
              <input type="date" v-model="form.date" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500" />
            </div>
          </div>
          <div class="space-y-1">
            <label class="text-sm font-medium text-gray-700">Objectif (FCFA)</label>
            <input type="number" v-model="form.objectif" placeholder="250000" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500" />
          </div>
          <div class="space-y-1">
            <label class="text-sm font-medium text-gray-700">Contribuables à inclure</label>
            <textarea v-model="form.contribuables" rows="5" placeholder="ETS KOUASSI&#10;MAQUIS LA PAIX&#10;GARAGE ABC..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
            <p class="text-xs text-gray-500">Un contribuable par ligne</p>
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeCreateModal" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
            Annuler
          </button>
          <button
            @click="submitCreate"
            :disabled="submitting"
            class="px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50"
          >
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />
            Créer la tournée
          </button>
        </div>
      </div>
    </div>

    <!-- Modal rapport de tournée -->
    <div v-if="showRapportModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-lg flex flex-col max-h-[80vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Rapport de tournée #{{ rapportTournee?.id }}</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ rapportTournee?.agentNom }} — {{ formatDate(rapportTournee?.date) }}</p>
          </div>
          <button @click="showRapportModal = false" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="p-5 space-y-4">
          <div v-if="rapport" class="space-y-3">
            <div class="grid grid-cols-2 gap-3">
              <div class="bg-gray-50 rounded-lg p-3 text-center">
                <p class="text-xs text-gray-500">Contribuables</p>
                <p class="text-xl font-bold text-gray-900">{{ rapport.contribuables }}</p>
              </div>
              <div class="bg-gray-50 rounded-lg p-3 text-center">
                <p class="text-xs text-gray-500">Visités</p>
                <p class="text-xl font-bold text-primary-600">{{ rapport.visites }}</p>
              </div>
              <div class="bg-success-50 rounded-lg p-3 text-center">
                <p class="text-xs text-gray-500">Payés</p>
                <p class="text-xl font-bold text-success-600">{{ rapport.payes }}</p>
              </div>
              <div class="bg-danger-50 rounded-lg p-3 text-center">
                <p class="text-xs text-gray-500">Refus</p>
                <p class="text-xl font-bold text-danger-600">{{ rapport.refus }}</p>
              </div>
            </div>
            <div class="bg-gray-50 rounded-lg p-4 space-y-2">
              <div class="flex justify-between text-sm">
                <span class="text-gray-500">Montant attendu</span>
                <span class="font-medium text-gray-900">{{ formatCurrency(rapport.montantAttendu) }}</span>
              </div>
              <div class="flex justify-between text-sm">
                <span class="text-gray-500">Collecté</span>
                <span class="font-semibold text-success-600">{{ formatCurrency(rapport.collecte) }}</span>
              </div>
              <div class="flex justify-between text-sm border-t border-gray-200 pt-2">
                <span class="text-gray-500">Taux</span>
                <span class="font-bold text-primary-600">{{ rapport.taux }}%</span>
              </div>
            </div>
          </div>
          <div v-else class="text-center text-sm text-gray-500 py-8">
            Rapport non disponible pour cette tournée.
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  Route, Play, Calendar, CheckCircle, User, MapPin, Users,
  Plus, RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { tourneeService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const tournees = ref([])
const showCreateModal = ref(false)
const showRapportModal = ref(false)
const rapportTournee = ref(null)
const rapport = ref(null)
const form = ref({ agentId: '', date: '', objectif: '', contribuables: '' })

const agentOptions = computed(() => [...new Set(tournees.value.map(t => t.agentNom))].sort())

const statutCount = (statut) => tournees.value.filter(t => t.statut === statut).length

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : ''

const statutBg = (s) => ({ EN_COURS: 'bg-info-50', PLANIFIEE: 'bg-warning-50', TERMINEE: 'bg-success-50' }[s] || 'bg-gray-100')
const statutText = (s) => ({ EN_COURS: 'text-info-600', PLANIFIEE: 'text-warning-600', TERMINEE: 'text-success-600' }[s] || 'text-gray-500')
const statutBadge = (s) => ({ EN_COURS: 'bg-info-100 text-info-800', PLANIFIEE: 'bg-warning-100 text-warning-800', TERMINEE: 'bg-success-100 text-success-800' }[s] || 'bg-gray-100 text-gray-600')
const statutLabel = (s) => ({ EN_COURS: 'En cours', PLANIFIEE: 'Planifiée', TERMINEE: 'Terminée' }[s] || s)

async function loadTournees() {
  loading.value = true
  try {
    const response = await tourneeService.getTournees()
    tournees.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement tournées:', e)
  } finally {
    loading.value = false
  }
}

function openCreateModal() {
  form.value = { agentId: '', date: new Date().toISOString().slice(0, 10), objectif: '', contribuables: '' }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

async function submitCreate() {
  submitting.value = true
  try {
    const contribuables = form.value.contribuables.split('\n').map(c => c.trim()).filter(Boolean)
    const newTournee = {
      id: `${new Date().toISOString().slice(2, 10).replace(/-/g, '')}-${String(tournees.value.length + 1).padStart(2, '0')}`,
      agentNom: form.value.agentId,
      zoneNom: 'Zone 03',
      date: form.value.date,
      objectif: parseInt(form.value.objectif) || 0,
      nbContribuables: contribuables.length,
      statut: 'PLANIFIEE'
    }
    await tourneeService.createTournee(newTournee)
    tournees.value.unshift(newTournee)
    closeCreateModal()
  } catch (e) {
    console.error('Erreur création tournée:', e)
    closeCreateModal()
  } finally {
    submitting.value = false
  }
}

async function viewRapport(t) {
  rapportTournee.value = t
  rapport.value = null
  showRapportModal.value = true
  try {
    // Le backend n'expose pas de route /rapport : on utilise les détails de la tournée.
    const response = await tourneeService.getTournee(t.id)
    rapport.value = response.data || t
  } catch (e) {
    console.error('Erreur chargement rapport:', e)
    rapport.value = t
  }
}

onMounted(() => loadTournees())
</script>
