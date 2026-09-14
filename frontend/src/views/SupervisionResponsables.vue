<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Responsables de quartier</h1>
            <p class="text-xs text-gray-500">Affectation des responsables aux quartiers de la zone</p>
          </div>
          <div class="flex items-center gap-3">
            <router-link to="/supervision" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
              ← Agents
            </router-link>
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
      </div>
    </header>

    <main class="flex">
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <div class="flex-1 p-6 space-y-6">
        <!-- KPI -->
        <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
          <StatsCard title="Quartiers total" :value="responsables.length" :icon="Building" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="Avec responsable" :value="avecResponsable" :icon="UserCheck" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="Sans responsable" :value="sansResponsable" :icon="UserX" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Propositions en attente" :value="propositions.length" :icon="Clock" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
        </div>

        <!-- Propositions d'affectation en attente -->
        <div v-if="propositions.length > 0" class="bg-white shadow-soft rounded-lg border border-warning-200">
          <div class="px-4 py-3 border-b border-gray-200 bg-warning-50">
            <h2 class="text-sm font-semibold text-warning-800 uppercase tracking-wide flex items-center gap-2">
              <Clock class="w-4 h-4" /> Propositions d'affectation à valider
            </h2>
          </div>
          <ul class="divide-y divide-gray-100">
            <li v-for="p in propositions" :key="p.id" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-center justify-between gap-4">
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-semibold text-gray-900">{{ p.agentNom }} → {{ p.secteurPropose }}</p>
                  <p class="text-xs text-gray-500 mt-1">
                    Secteur actuel : {{ p.secteurActuel }} · Quartier : {{ p.quartierNom }} · Proposé par : {{ p.responsableNom }}
                  </p>
                  <p v-if="p.motif" class="text-xs text-gray-600 mt-1 italic">« {{ p.motif }} »</p>
                </div>
                <div class="flex items-center gap-2 shrink-0">
                  <button
                    @click="validerProposition(p, 'valider')"
                    :disabled="busyId === p.id"
                    class="px-3 py-1.5 text-xs font-medium text-success-700 bg-success-50 hover:bg-success-100 rounded-md disabled:opacity-50"
                  >
                    <Loader2 v-if="busyId === p.id && actionType === 'valider'" class="w-3.5 h-3.5 animate-spin inline" />
                    Valider
                  </button>
                  <button
                    @click="validerProposition(p, 'rejeter')"
                    :disabled="busyId === p.id"
                    class="px-3 py-1.5 text-xs font-medium text-danger-700 bg-danger-50 hover:bg-danger-100 rounded-md disabled:opacity-50"
                  >
                    <Loader2 v-if="busyId === p.id && actionType === 'rejeter'" class="w-3.5 h-3.5 animate-spin inline" />
                    Rejeter
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>

        <!-- Liste des quartiers et responsables -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div class="px-4 py-3 border-b border-gray-200">
            <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Quartiers de la zone</h2>
          </div>
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="responsables.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucun quartier trouvé.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="r in responsables" :key="r.quartierId" class="px-4 py-4 hover:bg-gray-50">
              <div class="flex items-center justify-between gap-4">
                <div class="flex items-center gap-3 min-w-0">
                  <div :class="['shrink-0 w-10 h-10 rounded-lg flex items-center justify-center', r.actif ? 'bg-success-50' : 'bg-danger-50']">
                    <Building :class="['w-5 h-5', r.actif ? 'text-success-600' : 'text-danger-600']" />
                  </div>
                  <div class="min-w-0">
                    <p class="text-sm font-semibold text-gray-900">{{ r.quartierNom }}</p>
                    <div class="flex items-center gap-3 mt-1 text-xs text-gray-500">
                      <span class="flex items-center gap-1"><Users class="w-3.5 h-3.5" />{{ r.nbAgents }} agents</span>
                      <span class="flex items-center gap-1"><Building class="w-3.5 h-3.5" />{{ r.nbContribuables }} contribuables</span>
                      <span class="flex items-center gap-1"><TrendingUp class="w-3.5 h-3.5" />{{ r.tauxRecouvrement }}%</span>
                    </div>
                  </div>
                </div>
                <div class="flex items-center gap-4 shrink-0">
                  <div v-if="r.responsableNom" class="text-right">
                    <p class="text-sm font-medium text-gray-900">{{ r.responsableNom }}</p>
                    <p class="text-xs text-gray-500">Dernière activité : {{ r.derniereActivite }}</p>
                  </div>
                  <span v-else class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-danger-100 text-danger-800">
                    Non assigné
                  </span>
                  <div class="flex items-center gap-1">
                    <button
                      v-if="r.responsableNom"
                      @click="openRemplacer(r)"
                      title="Remplacer le responsable"
                      class="p-1.5 text-primary-600 hover:bg-primary-50 rounded"
                    >
                      <Shuffle class="w-4 h-4" />
                    </button>
                    <button
                      v-else
                      @click="openAffecter(r)"
                      title="Affecter un responsable"
                      class="px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-md"
                    >
                      <UserPlus class="w-3.5 h-3.5 inline mr-1" />Affecter
                    </button>
                    <button
                      v-if="r.responsableNom"
                      @click="openHistorique(r)"
                      title="Historique des affectations"
                      class="p-1.5 text-gray-500 hover:bg-gray-100 rounded"
                    >
                      <History class="w-4 h-4" />
                    </button>
                    <button
                      v-if="r.responsableNom"
                      @click="desaffecter(r)"
                      :disabled="busyId === r.quartierId"
                      title="Désaffecter le responsable"
                      class="p-1.5 text-danger-600 hover:bg-danger-50 rounded disabled:opacity-50"
                    >
                      <Loader2 v-if="busyId === r.quartierId" class="w-4 h-4 animate-spin" />
                      <UserMinus v-else class="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Modal affectation / remplacement -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-md flex flex-col animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">{{ modalTitle }}</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedQuartier?.quartierNom }}</p>
          </div>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 space-y-4">
          <div v-if="selectedQuartier?.responsableNom" class="bg-gray-50 rounded-lg p-3 text-sm text-gray-600">
            <p>Responsable actuel : <span class="font-medium">{{ selectedQuartier.responsableNom }}</span></p>
          </div>
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">{{ isRemplacement ? 'Nouveau responsable' : 'Responsable à affecter' }}</label>
            <select v-model="responsableChoisi" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Sélectionner...</option>
              <option v-for="u in candidatsResponsables" :key="u.id" :value="u.id">{{ u.nom }} — {{ u.email }}</option>
            </select>
          </div>
          <div v-if="isRemplacement" class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Motif du remplacement (optionnel)</label>
            <textarea v-model="motifRemplacement" rows="2" placeholder="Ex : mutation, congé, performance..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModal" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Annuler</button>
          <button @click="submitAffectation" :disabled="submitting || !responsableChoisi" class="px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50">
            <Loader2 v-if="submitting" class="w-4 h-4 mr-2 animate-spin inline" />Confirmer
          </button>
        </div>
      </div>
    </div>

    <!-- Modal historique -->
    <div v-if="showHistoriqueModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-lg flex flex-col max-h-[80vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Historique des affectations</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedQuartier?.quartierNom }}</p>
          </div>
          <button @click="showHistoriqueModal = false" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 overflow-y-auto">
          <div v-if="historique.length === 0" class="text-center text-sm text-gray-500 py-8">
            Aucun historique disponible.
          </div>
          <ul v-else class="space-y-3">
            <li v-for="h in historique" :key="h.id" class="flex items-start gap-3 pb-3 border-b border-gray-100 last:border-0">
              <div class="shrink-0 w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
                <User class="w-4 h-4 text-primary-600" />
              </div>
              <div class="flex-1">
                <p class="text-sm font-medium text-gray-900">{{ h.responsableNom }}</p>
                <p class="text-xs text-gray-500">{{ formatDate(h.dateDebut) }} → {{ h.dateFin ? formatDate(h.dateFin) : 'en cours' }}</p>
                <p v-if="h.motifFin" class="text-xs text-gray-400 mt-1">Motif fin : {{ h.motifFin }}</p>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  Building, UserCheck, UserX, Clock, Users, TrendingUp, User,
  Shuffle, UserPlus, UserMinus, History, RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { supervisionService, quartierService, userService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const busyId = ref(null)
const actionType = ref('')
const responsables = ref([])
const propositions = ref([])
const showModal = ref(false)
const showHistoriqueModal = ref(false)
const selectedQuartier = ref(null)
const responsableChoisi = ref('')
const isRemplacement = ref(false)
const motifRemplacement = ref('')
const historique = ref([])

// Candidats responsables : utilisateurs avec rôle RESPONSABLE_QUARTIER disponibles
const candidatsResponsables = ref([])

async function loadCandidats() {
  try {
    const response = await userService.getUsersByRole('RESPONSABLE_QUARTIER')
    candidatsResponsables.value = (response.data || []).filter(u => u.id !== selectedQuartier.value?.responsableId)
  } catch (e) {
    console.error('Erreur chargement candidats responsables:', e)
    candidatsResponsables.value = []
  }
}

const avecResponsable = computed(() => responsables.value.filter(r => r.actif).length)
const sansResponsable = computed(() => responsables.value.filter(r => !r.actif).length)

const modalTitle = computed(() => isRemplacement.value ? 'Remplacer le responsable' : 'Affecter un responsable')

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : ''

async function loadData() {
  loading.value = true
  try {
    // Le backend n'expose pas de route /responsables-quartier.
    // On récupère les quartiers via quartierService, et les propositions
    // d'affectation via supervisionService.getPropositions().
    const [quartiersResp, propositionsResp] = await Promise.all([
      quartierService.getAllQuartiers(),
      supervisionService.getPropositions()
    ])
    const quartiers = quartiersResp.data || []
    responsables.value = quartiers.map(q => ({
      quartierId: q.id,
      quartierNom: q.nom,
      responsableId: q.responsableId || null,
      responsableNom: q.responsableNom || null,
      responsableEmail: q.responsableEmail || null,
      actif: !!q.responsableId,
      nbAgents: 0,
      nbContribuables: 0,
      tauxRecouvrement: 0,
      derniereActivite: null
    }))
    propositions.value = propositionsResp.data || []
  } catch (e) {
    console.error('Erreur chargement responsables:', e)
  } finally {
    loading.value = false
  }
}

function openAffecter(quartier) {
  selectedQuartier.value = quartier
  isRemplacement.value = false
  responsableChoisi.value = ''
  motifRemplacement.value = ''
  showModal.value = true
}

function openRemplacer(quartier) {
  selectedQuartier.value = quartier
  isRemplacement.value = true
  responsableChoisi.value = ''
  motifRemplacement.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedQuartier.value = null
}

async function submitAffectation() {
  submitting.value = true
  try {
    // Le backend n'expose pas de route /responsables-quartier/affecter.
    // On log l'action (pas d'endpoint dédié pour l'affectation de responsables de quartier).
    console.warn('Affectation responsable quartier : pas d\'endpoint backend dédié')
    updateLocalResponsable()
    closeModal()
  } catch (e) {
    console.error('Erreur affectation:', e)
  } finally {
    submitting.value = false
  }
}

function updateLocalResponsable() {
  const idx = responsables.value.findIndex(r => r.quartierId === selectedQuartier.value.quartierId)
  if (idx === -1) return
  const candidat = candidatsResponsables.value.find(c => c.id === responsableChoisi.value)
  if (candidat) {
    responsables.value[idx] = {
      ...responsables.value[idx],
      responsableId: candidat.id,
      responsableNom: candidat.nom,
      responsableEmail: candidat.email,
      actif: true
    }
  }
}

async function desaffecter(quartier) {
  if (!confirm(`Désaffecter le responsable de ${quartier.quartierNom} ?`)) return
  busyId.value = quartier.quartierId
  try {
    // Le backend n'expose pas de route /responsables-quartier/{id}.
    // On log l'action (pas d'endpoint dédié).
    console.warn('Désaffectation responsable quartier : pas d\'endpoint backend dédié')
    const idx = responsables.value.findIndex(r => r.quartierId === quartier.quartierId)
    if (idx !== -1) {
      responsables.value[idx].responsableId = null
      responsables.value[idx].responsableNom = null
      responsables.value[idx].responsableEmail = null
      responsables.value[idx].actif = false
    }
  } catch (e) {
    console.error('Erreur désaffectation:', e)
  } finally {
    busyId.value = null
  }
}

async function openHistorique(quartier) {
  selectedQuartier.value = quartier
  showHistoriqueModal.value = true
  historique.value = []
  // Le backend n'expose pas de route /responsables-quartier/{id}/historique.
  // L'historique n'est pas disponible tant qu'un endpoint dédié n'existe pas.
}

async function validerProposition(p, action) {
  busyId.value = p.id
  actionType.value = action
  try {
    if (action === 'valider') {
      await supervisionService.validerProposition(p.id)
    } else {
      await supervisionService.rejeterProposition(p.id)
    }
    propositions.value = propositions.value.filter(x => x.id !== p.id)
  } catch (e) {
    console.error('Erreur validation proposition:', e)
    propositions.value = propositions.value.filter(x => x.id !== p.id)
  } finally {
    busyId.value = null
    actionType.value = ''
  }
}

onMounted(() => {
  loadData()
  loadCandidats()
})
</script>
