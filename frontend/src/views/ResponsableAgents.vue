<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Mes agents</h1>
            <p class="text-xs text-gray-500">Organisation et suivi des agents du quartier — propositions d'affectation (validation superviseur)</p>
          </div>
          <button
            @click="loadAgents"
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
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <StatsCard title="Agents actifs" :value="actifsCount" :icon="UserCheck" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="Agents absents" :value="absentsCount" :icon="UserX" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Propositions en attente" :value="propositions.length" :icon="Clock" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
        </div>

        <!-- Liste des agents -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div class="px-4 py-3 border-b border-gray-200">
            <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Agents du quartier</h2>
          </div>
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="agents.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucun agent dans ce quartier.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="agent in agents" :key="agent.id" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-center justify-between gap-4">
                <div class="flex items-center gap-3 min-w-0">
                  <div :class="['shrink-0 w-10 h-10 rounded-full flex items-center justify-center', agent.statut === 'ACTIF' ? 'bg-success-100' : 'bg-danger-100']">
                    <span class="text-xs font-semibold" :class="agent.statut === 'ACTIF' ? 'text-success-700' : 'text-danger-700'">{{ agent.nom?.slice(-2) }}</span>
                  </div>
                  <div class="min-w-0">
                    <p class="text-sm font-semibold text-gray-900">{{ agent.nom }} {{ agent.prenom }}</p>
                    <div class="flex items-center gap-3 mt-1 text-xs text-gray-500">
                      <span class="flex items-center gap-1"><MapPin class="w-3.5 h-3.5" />{{ agent.secteur }}</span>
                      <span class="flex items-center gap-1"><Clock class="w-3.5 h-3.5" />{{ agent.derniereActivite }}</span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center gap-4 shrink-0">
                  <div class="text-right">
                    <p class="text-xs text-gray-500">{{ agent.visitesJour }} visites · {{ agent.paiementsJour }} paiements</p>
                    <p class="text-sm font-semibold text-gray-900">{{ formatCurrency(agent.collecteJour) }}</p>
                  </div>
                  <span :class="['inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium', agent.statut === 'ACTIF' ? 'bg-success-100 text-success-800' : 'bg-danger-100 text-danger-800']">
                    {{ agent.statut === 'ACTIF' ? 'Actif' : 'Absent' }}
                  </span>
                  <div class="flex items-center gap-1">
                    <button @click="openProposition(agent)" title="Proposer une réaffectation" class="p-1.5 text-primary-600 hover:bg-primary-50 rounded">
                      <Shuffle class="w-4 h-4" />
                    </button>
                    <button v-if="agent.statut === 'ACTIF'" @click="openAbsence(agent)" title="Signaler une absence" class="p-1.5 text-warning-600 hover:bg-warning-50 rounded">
                      <UserX class="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            </li>
          </ul>
        </div>

        <!-- Propositions en attente de validation superviseur -->
        <div v-if="propositions.length > 0" class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div class="px-4 py-3 border-b border-gray-200">
            <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Propositions d'affectation en attente</h2>
            <p class="text-xs text-gray-500 mt-0.5">Validation requise par le Superviseur de Zone</p>
          </div>
          <ul class="divide-y divide-gray-100">
            <li v-for="prop in propositions" :key="prop.id" class="px-4 py-3 flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-gray-900">{{ prop.agentNom }} → {{ prop.secteurNom }}</p>
                <p class="text-xs text-gray-500">{{ prop.motif || 'Sans motif' }}</p>
              </div>
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-warning-100 text-warning-800">
                En attente
              </span>
            </li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Modal proposition d'affectation -->
    <div v-if="showPropModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-md flex flex-col animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Proposer une réaffectation</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedAgent?.nom }} {{ selectedAgent?.prenom }} — secteur actuel : {{ selectedAgent?.secteur }}</p>
          </div>
          <button @click="closeModals" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 space-y-4">
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Nouveau secteur</label>
            <select v-model="nouveauSecteur" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Sélectionner...</option>
              <option v-for="s in secteursDisponibles" :key="s" :value="s">{{ s }}</option>
            </select>
          </div>
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Motif (optionnel)</label>
            <textarea v-model="motifProp" rows="3" placeholder="Justification de la réaffectation..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
          </div>
          <p class="text-xs text-info-600 bg-info-50 p-2 rounded">ℹ️ Cette proposition doit être validée par le Superviseur de Zone.</p>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModals" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Annuler</button>
          <button @click="submitProposition" :disabled="submitting || !nouveauSecteur" class="px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50">
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />Proposer
          </button>
        </div>
      </div>
    </div>

    <!-- Modal signalement d'absence -->
    <div v-if="showAbsenceModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-md flex flex-col animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Signaler une absence</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedAgent?.nom }} {{ selectedAgent?.prenom }}</p>
          </div>
          <button @click="closeModals" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 space-y-4">
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Date</label>
            <input type="date" v-model="absenceDate" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500" />
          </div>
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Motif</label>
            <textarea v-model="absenceMotif" rows="3" placeholder="Motif de l'absence..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModals" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Annuler</button>
          <button @click="submitAbsence" :disabled="submitting" class="px-4 py-2 bg-warning-600 text-white rounded-md text-sm font-medium hover:bg-warning-700 disabled:opacity-50">
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />Signaler
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  UserCheck, UserX, Clock, MapPin, RefreshCw, Loader2,
  Inbox, X, Shuffle
} from 'lucide-vue-next'
import { responsableService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const agents = ref([])
const propositions = ref([])
const showPropModal = ref(false)
const showAbsenceModal = ref(false)
const selectedAgent = ref(null)
const nouveauSecteur = ref('')
const motifProp = ref('')
const absenceDate = ref('')
const absenceMotif = ref('')

const actifsCount = computed(() => agents.value.filter(a => a.statut === 'ACTIF').length)
const absentsCount = computed(() => agents.value.filter(a => a.statut !== 'ACTIF').length)
const secteursDisponibles = computed(() => [...new Set(agents.value.map(a => a.secteur))].sort())

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}

async function loadAgents() {
  loading.value = true
  try {
    const [a, p] = await Promise.all([
      responsableService.getAgentsQuartier(),
      responsableService.getPropositionsEnAttente()
    ])
    agents.value = a.data || []
    propositions.value = p.data || []
  } catch (e) {
    console.error('Erreur chargement agents:', e)
  } finally {
    loading.value = false
  }
}

function openProposition(agent) {
  selectedAgent.value = agent
  nouveauSecteur.value = ''
  motifProp.value = ''
  showPropModal.value = true
}

function openAbsence(agent) {
  selectedAgent.value = agent
  absenceDate.value = new Date().toISOString().slice(0, 10)
  absenceMotif.value = ''
  showAbsenceModal.value = true
}

function closeModals() {
  showPropModal.value = false
  showAbsenceModal.value = false
  selectedAgent.value = null
}

async function submitProposition() {
  submitting.value = true
  try {
    await responsableService.proposerAffectation(selectedAgent.value.id, nouveauSecteur.value, motifProp.value || null)
    propositions.value.push({
      id: Date.now(),
      agentNom: `${selectedAgent.value.nom} ${selectedAgent.value.prenom}`,
      secteurNom: nouveauSecteur.value,
      motif: motifProp.value
    })
    closeModals()
  } catch (e) {
    console.error('Erreur proposition affectation:', e)
  } finally {
    submitting.value = false
  }
}

async function submitAbsence() {
  submitting.value = true
  try {
    await responsableService.signalerAbsence(selectedAgent.value.id, absenceDate.value, absenceMotif.value)
    const idx = agents.value.findIndex(a => a.id === selectedAgent.value.id)
    if (idx !== -1) agents.value[idx].statut = 'ABSENT'
    closeModals()
  } catch (e) {
    console.error('Erreur signalement absence:', e)
  } finally {
    submitting.value = false
  }
}

onMounted(() => loadAgents())
</script>
