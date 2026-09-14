<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Contrôle des collectes</h1>
            <p class="text-xs text-gray-500">Opérations de collecte du quartier — contrôle opérationnel (sans modification financière)</p>
          </div>
          <button
            @click="loadCollectes"
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
        <!-- Avertissement -->
        <div class="flex items-start p-4 bg-info-50 border border-info-200 rounded-lg">
          <ShieldCheck class="w-5 h-5 text-info-600 mt-0.5 mr-3 shrink-0" />
          <p class="flex-1 text-sm text-info-800">
            Contrôle opérationnel uniquement. Le responsable ne peut pas modifier une opération financière déjà enregistrée.
            Une opération douteuse est <strong>signalée</strong> au superviseur (pas annulée).
          </p>
        </div>

        <!-- KPI -->
        <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
          <StatsCard title="Opérations du jour" :value="collectes.length" :icon="CreditCard" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="Synchronisées" :value="statutCount('SYNCHRONISE')" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="En attente sync" :value="statutCount('EN_ATTENTE_SYNC')" :icon="Clock" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="Total collecté" :value="totalCollecte" format="currency" :icon="Banknote" icon-color="text-success-600" icon-bg-color="bg-success-50" />
        </div>

        <!-- Filtres -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
          <div class="flex flex-wrap items-center gap-3">
            <select v-model="filterSecteur" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous secteurs</option>
              <option v-for="s in secteurs" :key="s" :value="s">{{ s }}</option>
            </select>
            <select v-model="filterAgent" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous agents</option>
              <option v-for="a in agents" :key="a" :value="a">{{ a }}</option>
            </select>
            <select v-model="filterStatut" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous statuts</option>
              <option value="SYNCHRONISE">Synchronisé</option>
              <option value="EN_ATTENTE_SYNC">En attente sync</option>
            </select>
          </div>
        </div>

        <!-- Comparaison entre secteurs -->
        <div>
          <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">Comparaison entre secteurs</h2>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div v-for="s in comparaisonSecteurs" :key="s.secteur" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
              <p class="text-sm font-semibold text-gray-900">{{ s.secteur }}</p>
              <p class="text-2xl font-bold text-success-600 mt-1">{{ formatCurrency(s.total) }}</p>
              <p class="text-xs text-gray-500 mt-1">{{ s.nbOperations }} opérations · {{ s.nbAgents }} agents</p>
            </div>
          </div>
        </div>

        <!-- Liste des opérations -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div class="px-4 py-3 border-b border-gray-200">
            <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Opérations de collecte</h2>
          </div>
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="filteredCollectes.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune opération trouvée.</p>
          </div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Agent</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contribuable</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Secteur</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Montant</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Mode</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Heure</th>
                  <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Statut</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Action</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="c in filteredCollectes" :key="c.id" class="hover:bg-gray-50">
                  <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ c.agentNom }}</td>
                  <td class="px-4 py-3 text-sm text-gray-900">{{ c.contribuable }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ c.secteur }}</td>
                  <td class="px-4 py-3 text-sm text-right font-semibold text-success-600">{{ formatCurrency(c.montant) }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ c.mode }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ c.heure }}</td>
                  <td class="px-4 py-3 text-center">
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', statutBadge(c.statut)]">
                      {{ statutLabel(c.statut) }}
                    </span>
                  </td>
                  <td class="px-4 py-3 text-right">
                    <button @click="openSignaler(c)" title="Signaler comme douteuse" class="p-1.5 text-danger-600 hover:bg-danger-50 rounded">
                      <AlertTriangle class="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal signalement opération douteuse -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-md flex flex-col animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Signaler une opération douteuse</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedCollecte?.contribuable }} — {{ formatCurrency(selectedCollecte?.montant) }}</p>
          </div>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 space-y-4">
          <div class="bg-info-50 p-3 rounded text-xs text-info-800">
            ℹ️ L'opération ne sera <strong>pas annulée</strong>. Le signalement sera transmis au Superviseur de Zone pour examen.
          </div>
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Motif du signalement</label>
            <textarea v-model="motifSignalement" rows="4" placeholder="Décrire le problème (écart, doublon, montant incohérent...)" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModal" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Annuler</button>
          <button @click="submitSignalement" :disabled="submitting || !motifSignalement" class="px-4 py-2 bg-danger-600 text-white rounded-md text-sm font-medium hover:bg-danger-700 disabled:opacity-50">
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
  CreditCard, CheckCircle, Clock, Banknote, AlertTriangle,
  ShieldCheck, RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { responsableService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const collectes = ref([])
const filterSecteur = ref('')
const filterAgent = ref('')
const filterStatut = ref('')
const showModal = ref(false)
const selectedCollecte = ref(null)
const motifSignalement = ref('')

const secteurs = computed(() => [...new Set(collectes.value.map(c => c.secteur))].sort())
const agents = computed(() => [...new Set(collectes.value.map(c => c.agentNom))].sort())

const filteredCollectes = computed(() => {
  return collectes.value.filter(c => {
    if (filterSecteur.value && c.secteur !== filterSecteur.value) return false
    if (filterAgent.value && c.agentNom !== filterAgent.value) return false
    if (filterStatut.value && c.statut !== filterStatut.value) return false
    return true
  })
})

const statutCount = (statut) => collectes.value.filter(c => c.statut === statut).length
const totalCollecte = computed(() => collectes.value.reduce((sum, c) => sum + c.montant, 0))

const comparaisonSecteurs = computed(() => {
  const map = {}
  collectes.value.forEach(c => {
    if (!map[c.secteur]) map[c.secteur] = { secteur: c.secteur, total: 0, nbOperations: 0, nbAgents: new Set() }
    map[c.secteur].total += c.montant
    map[c.secteur].nbOperations++
    map[c.secteur].nbAgents.add(c.agentNom)
  })
  return Object.values(map).map(s => ({ ...s, nbAgents: s.nbAgents.size }))
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}

const statutBadge = (s) => ({
  SYNCHRONISE: 'bg-success-100 text-success-800',
  EN_ATTENTE_SYNC: 'bg-warning-100 text-warning-800'
}[s] || 'bg-gray-100 text-gray-600')

const statutLabel = (s) => ({
  SYNCHRONISE: 'Synchronisé',
  EN_ATTENTE_SYNC: 'En attente'
}[s] || s)

async function loadCollectes() {
  loading.value = true
  try {
    const response = await responsableService.getCollectesQuartier()
    collectes.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement collectes:', e)
  } finally {
    loading.value = false
  }
}

function openSignaler(c) {
  selectedCollecte.value = c
  motifSignalement.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedCollecte.value = null
}

async function submitSignalement() {
  submitting.value = true
  try {
    await responsableService.signalerOperationDouteuse(selectedCollecte.value.id, motifSignalement.value)
    closeModal()
  } catch (e) {
    closeModal()
  } finally {
    submitting.value = false
  }
}

onMounted(() => loadCollectes())
</script>
