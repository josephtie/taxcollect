<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Promesses de paiement</h1>
            <p class="text-xs text-gray-500">Suivi des échéances et réaffectation des relances</p>
          </div>
          <button
            @click="loadData"
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
          <StatsCard title="Aujourd'hui" :value="stats.aujourdhui" :icon="Calendar" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="Échéance demain" :value="stats.echeanceDemain" :icon="Clock" icon-color="text-info-600" icon-bg-color="bg-info-50" />
          <StatsCard title="En retard" :value="stats.enRetard" :icon="AlertTriangle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Montant total" :value="stats.montantTotal" :icon="Wallet" format="currency" icon-color="text-success-600" icon-bg-color="bg-success-50" />
        </div>

        <!-- Onglets -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div class="border-b border-gray-200">
            <nav class="flex">
              <button
                v-for="tab in tabs" :key="tab.key"
                @click="activeTab = tab.key"
                :class="[
                  'px-4 py-3 text-sm font-medium border-b-2 transition-colors',
                  activeTab === tab.key ? 'border-primary-500 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700'
                ]"
              >
                {{ tab.label }}
                <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium" :class="tab.countClass">{{ tab.count }}</span>
              </button>
            </nav>
          </div>

          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="filteredPromesses.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune promesse dans cette catégorie.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="p in filteredPromesses" :key="p.id" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-center justify-between gap-4">
                <div class="flex items-center gap-3 min-w-0">
                  <div :class="['shrink-0 w-10 h-10 rounded-lg flex items-center justify-center', statutBg(p.statut)]">
                    <FileText :class="['w-5 h-5', statutText(p.statut)]" />
                  </div>
                  <div class="min-w-0">
                    <p class="text-sm font-semibold text-gray-900 truncate">{{ p.contribuableNom }}</p>
                    <div class="flex items-center gap-3 mt-1 text-xs text-gray-500">
                      <span class="flex items-center gap-1"><User class="w-3.5 h-3.5" />{{ p.agentNom }}</span>
                      <span class="flex items-center gap-1"><Calendar class="w-3.5 h-3.5" />Éch. {{ formatDate(p.echeance) }}</span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center gap-4 shrink-0">
                  <div class="text-right">
                    <p class="text-sm font-semibold text-gray-900">{{ formatCurrency(p.montant) }}</p>
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium mt-1', statutBadge(p.statut)]">
                      {{ statutLabel(p.statut) }}
                    </span>
                  </div>
                  <button
                    v-if="p.statut === 'EN_RETARD'"
                    @click="openReaffectation(p)"
                    class="px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-md whitespace-nowrap"
                  >
                    Réaffecter
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Modal réaffectation -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-md flex flex-col animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Réaffecter la relance</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedPromesse?.contribuableNom }}</p>
          </div>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="p-5 space-y-4">
          <div class="bg-gray-50 rounded-lg p-3 text-sm text-gray-600 space-y-1">
            <p><span class="font-medium">Agent actuel :</span> {{ selectedPromesse?.agentNom }}</p>
            <p><span class="font-medium">Montant :</span> {{ formatCurrency(selectedPromesse?.montant) }}</p>
            <p><span class="font-medium">Échéance :</span> {{ formatDate(selectedPromesse?.echeance) }}</p>
          </div>
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Nouvel agent responsable</label>
            <select v-model="nouvelAgent" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Sélectionner un agent...</option>
              <option v-for="a in agentOptions" :key="a" :value="a">{{ a }}</option>
            </select>
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModal" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
            Annuler
          </button>
          <button
            @click="submitReaffectation"
            :disabled="submitting || !nouvelAgent"
            class="px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50"
          >
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />
            Réaffecter
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  Calendar, Clock, AlertTriangle, Wallet, FileText, User,
  RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { promesseService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const promesses = ref([])
const stats = ref({ aujourdhui: 0, echeanceDemain: 0, enRetard: 0, montantTotal: 0 })
const activeTab = ref('toutes')
const showModal = ref(false)
const selectedPromesse = ref(null)
const nouvelAgent = ref('')

const agentOptions = computed(() => [...new Set(promesses.value.map(p => p.agentNom))].sort())

const tabs = computed(() => [
  { key: 'toutes', label: 'Toutes', count: promesses.value.length, countClass: 'bg-gray-100 text-gray-600' },
  { key: 'EN_ATTENTE', label: 'En attente', count: promesses.value.filter(p => p.statut === 'EN_ATTENTE').length, countClass: 'bg-primary-100 text-primary-700' },
  { key: 'EN_RETARD', label: 'En retard', count: promesses.value.filter(p => p.statut === 'EN_RETARD').length, countClass: 'bg-danger-100 text-danger-800' }
])

const filteredPromesses = computed(() => {
  if (activeTab.value === 'toutes') return promesses.value
  return promesses.value.filter(p => p.statut === activeTab.value)
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : ''

const statutBg = (s) => ({ EN_ATTENTE: 'bg-primary-50', EN_RETARD: 'bg-danger-50', HONOREE: 'bg-success-50' }[s] || 'bg-gray-100')
const statutText = (s) => ({ EN_ATTENTE: 'text-primary-600', EN_RETARD: 'text-danger-600', HONOREE: 'text-success-600' }[s] || 'text-gray-500')
const statutBadge = (s) => ({ EN_ATTENTE: 'bg-primary-100 text-primary-800', EN_RETARD: 'bg-danger-100 text-danger-800', HONOREE: 'bg-success-100 text-success-800' }[s] || 'bg-gray-100 text-gray-600')
const statutLabel = (s) => ({ EN_ATTENTE: 'En attente', EN_RETARD: 'En retard', HONOREE: 'Honorée' }[s] || s)

async function loadData() {
  loading.value = true
  try {
    const response = await promesseService.getPromesses()
    promesses.value = response.data || []
    // Le backend n'expose pas de route /stats pour les promesses :
    // on calcule les statistiques localement.
    const now = new Date()
    const tomorrow = new Date(now)
    tomorrow.setDate(tomorrow.getDate() + 1)
    const statsData = {
      aujourdhui: promesses.value.filter(p => p.echeance === now.toISOString().slice(0, 10) && p.statut === 'EN_ATTENTE').length,
      echeanceDemain: promesses.value.filter(p => p.echeance === tomorrow.toISOString().slice(0, 10) && p.statut === 'EN_ATTENTE').length,
      enRetard: promesses.value.filter(p => p.statut === 'EN_RETARD').length,
      montantTotal: promesses.value.reduce((sum, p) => sum + (p.montant || 0), 0)
    }
    stats.value = statsData
  } catch (e) {
    console.error('Erreur chargement promesses:', e)
  } finally {
    loading.value = false
  }
}

function openReaffectation(p) {
  selectedPromesse.value = p
  nouvelAgent.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedPromesse.value = null
}

async function submitReaffectation() {
  submitting.value = true
  try {
    // Le backend n'expose pas de route /reaffecter pour les promesses.
    // On met à jour la promesse via PUT /api/taxcollect/promesse/{id}.
    await promesseService.updatePromesse(selectedPromesse.value.id, { agentId: nouvelAgent.value })
    const idx = promesses.value.findIndex(p => p.id === selectedPromesse.value.id)
    if (idx !== -1) promesses.value[idx].agentNom = nouvelAgent.value
    closeModal()
  } catch (e) {
    console.error('Erreur réaffectation:', e)
  } finally {
    submitting.value = false
  }
}

onMounted(() => loadData())
</script>
