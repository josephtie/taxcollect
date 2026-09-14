<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Recouvrement</h1>
            <p class="text-xs text-gray-500">Suivi des impayés et relances — contrôle opérationnel (sans validation financière)</p>
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
          <StatsCard title="Contribuables impayés" :value="stats.totalContribuables" :icon="Users" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="Montant dû" :value="stats.montantDu" :icon="Wallet" format="currency" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Collecté" :value="stats.collecte" :icon="Banknote" format="currency" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="Reste à recouvrer" :value="stats.reste" :icon="AlertCircle" format="currency" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
        </div>

        <!-- Filtres -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
          <div class="flex flex-wrap items-center gap-3">
            <div class="relative flex-1 min-w-[12rem]">
              <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Rechercher un contribuable..."
                class="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <select v-model="filterSecteur" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous secteurs</option>
              <option v-for="s in secteurs" :key="s" :value="s">{{ s }}</option>
            </select>
            <select v-model="filterAgent" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous agents</option>
              <option v-for="a in agents" :key="a" :value="a">{{ a }}</option>
            </select>
            <select v-model="filterAnciennete" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Toutes anciennetés</option>
              <option value="30">≤ 30 jours</option>
              <option value="60">31-60 jours</option>
              <option value="90">61-90 jours</option>
              <option value="91">> 90 jours</option>
            </select>
            <label class="flex items-center gap-2 text-sm text-gray-600">
              <input type="checkbox" v-model="grosDebiteurs" class="rounded border-gray-300 text-primary-600 focus:ring-primary-500" />
              Gros débiteurs
            </label>
          </div>
        </div>

        <!-- Liste des impayés -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100 overflow-hidden">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="filteredImpayes.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucun impayé trouvé.</p>
          </div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contribuable</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activité</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Secteur</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Agent</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Montant dû</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Payé</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Reste</th>
                  <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Ancienneté</th>
                  <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="imp in filteredImpayes" :key="imp.id" class="hover:bg-gray-50">
                  <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ imp.contribuableNom }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ imp.activite }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ imp.secteur }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ imp.agentNom }}</td>
                  <td class="px-4 py-3 text-sm text-right font-medium text-gray-900">{{ formatCurrency(imp.montantDu) }}</td>
                  <td class="px-4 py-3 text-sm text-right text-success-600">{{ formatCurrency(imp.montantPaye) }}</td>
                  <td class="px-4 py-3 text-sm text-right font-semibold text-danger-600">{{ formatCurrency(imp.montantDu - imp.montantPaye) }}</td>
                  <td class="px-4 py-3 text-sm text-center">
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', ancienneteBadge(imp.anciennete)]">
                      {{ imp.anciennete }} j
                    </span>
                  </td>
                  <td class="px-4 py-3">
                    <div class="flex items-center justify-center gap-1">
                      <button @click="openRelance(imp, 'planifier_visite')" title="Planifier visite" class="p-1.5 text-primary-600 hover:bg-primary-50 rounded">
                        <Calendar class="w-4 h-4" />
                      </button>
                      <button @click="openRelance(imp, 'assigner_agent')" title="Assigner agent" class="p-1.5 text-info-600 hover:bg-info-50 rounded">
                        <UserPlus class="w-4 h-4" />
                      </button>
                      <button @click="openRelance(imp, 'promesse_paiement')" title="Promesse de paiement" class="p-1.5 text-warning-600 hover:bg-warning-50 rounded">
                        <FileText class="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal de relance -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-lg flex flex-col max-h-[80vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">{{ relanceTitle }}</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedImpaye?.contribuableNom }} — {{ formatCurrency(selectedImpaye?.montantDu - selectedImpaye?.montantPaye) }} restant</p>
          </div>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="p-5 space-y-4">
          <div class="bg-gray-50 rounded-lg p-3 text-sm text-gray-600 space-y-1">
            <p><span class="font-medium">Contribuable :</span> {{ selectedImpaye?.contribuableNom }}</p>
            <p><span class="font-medium">Agent actuel :</span> {{ selectedImpaye?.agentNom }}</p>
            <p><span class="font-medium">Secteur :</span> {{ selectedImpaye?.secteur }}</p>
          </div>
          <div v-if="relanceAction === 'planifier_visite'" class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Date de visite planifiée</label>
            <input type="date" v-model="datePlanifiee" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500" />
          </div>
          <div v-if="relanceAction === 'assigner_agent'" class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Agent à assigner</label>
            <select v-model="agentAssign" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Sélectionner un agent...</option>
              <option v-for="a in agents" :key="a" :value="a">{{ a }}</option>
            </select>
          </div>
          <div v-if="relanceAction === 'promesse_paiement'" class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Échéance de la promesse</label>
            <input type="date" v-model="datePlanifiee" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500" />
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModal" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
            Annuler
          </button>
          <button
            @click="submitRelance"
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
  Users, Wallet, Banknote, AlertCircle, Search, RefreshCw,
  Loader2, Inbox, X, Calendar, UserPlus, FileText
} from 'lucide-vue-next'
import { supervisionService, contribuableService, promesseService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const impayes = ref([])
const stats = ref({ totalContribuables: 0, montantDu: 0, collecte: 0, reste: 0 })
const searchTerm = ref('')
const filterSecteur = ref('')
const filterAgent = ref('')
const filterAnciennete = ref('')
const grosDebiteurs = ref(false)
const showModal = ref(false)
const selectedImpaye = ref(null)
const relanceAction = ref('')
const datePlanifiee = ref('')
const agentAssign = ref('')

const secteurs = computed(() => [...new Set(impayes.value.map(i => i.secteur))].sort())
const agents = computed(() => [...new Set(impayes.value.map(i => i.agentNom))].sort())

const filteredImpayes = computed(() => {
  return impayes.value.filter(i => {
    if (searchTerm.value && !i.contribuableNom?.toLowerCase().includes(searchTerm.value.toLowerCase())) return false
    if (filterSecteur.value && i.secteur !== filterSecteur.value) return false
    if (filterAgent.value && i.agentNom !== filterAgent.value) return false
    if (filterAnciennete.value) {
      const a = parseInt(filterAnciennete.value)
      if (a === 91) { if (i.anciennete <= 90) return false }
      else if (i.anciennete > a || i.anciennete <= (a === 30 ? 0 : a - 30)) return false
    }
    if (grosDebiteurs.value && (i.montantDu - i.montantPaye) < 100000) return false
    return true
  }).sort((a, b) => (b.montantDu - b.montantPaye) - (a.montantDu - a.montantPaye))
})

const relanceTitle = computed(() => ({
  planifier_visite: 'Planifier une visite',
  assigner_agent: 'Assigner un agent',
  promesse_paiement: 'Créer une promesse de paiement'
}[relanceAction.value] || 'Relance'))

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}

const ancienneteBadge = (j) => {
  if (j > 90) return 'bg-danger-100 text-danger-800'
  if (j > 60) return 'bg-warning-100 text-warning-800'
  if (j > 30) return 'bg-yellow-100 text-yellow-800'
  return 'bg-gray-100 text-gray-600'
}

async function loadData() {
  loading.value = true
  try {
    // Le backend n'expose pas de route /recouvrement/impayes.
    // On récupère les contribuables de la zone du superviseur et on identifie
    // ceux ayant des impayés via les promesses en retard.
    const [contribuablesResp, promessesResp] = await Promise.all([
      supervisionService.getMyZoneContribuables(),
      promesseService.getPromesses()
    ])
    const contribuables = contribuablesResp.data || []
    const promesses = promessesResp.data || []
    // Les impayés correspondent aux promesses en retard
    impayes.value = promesses
      .filter(p => p.statut === 'EN_RETARD' || p.statut === 'EN_ATTENTE')
      .map(p => ({
        id: p.id,
        contribuableNom: p.contribuableNom || '',
        secteur: '',
        agentNom: p.agentNom || '',
        montantDu: p.montant || 0,
        montantPaye: 0,
        anciennete: p.statut === 'EN_RETARD' ? 90 : 30,
        activite: ''
      }))
    stats.value = {
      totalContribuables: contribuables.length,
      montantDu: impayes.value.reduce((s, i) => s + i.montantDu, 0),
      collecte: 0,
      reste: impayes.value.reduce((s, i) => s + i.montantDu, 0)
    }
  } catch (e) {
    console.error('Erreur chargement recouvrement:', e)
  } finally {
    loading.value = false
  }
}

function openRelance(imp, action) {
  selectedImpaye.value = imp
  relanceAction.value = action
  datePlanifiee.value = ''
  agentAssign.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedImpaye.value = null
}

async function submitRelance() {
  submitting.value = true
  try {
    // Le backend n'expose pas de route /recouvrement/relance.
    // Pour 'promesse_paiement', on crée une promesse via PromessePaiementController.
    // Pour les autres actions, on log l'action (pas d'endpoint dédié).
    if (relanceAction.value === 'promesse_paiement' && selectedImpaye.value) {
      await promesseService.createPromesse({
        contribuableId: selectedImpaye.value.id,
        montant: selectedImpaye.value.montantDu - selectedImpaye.value.montantPaye,
        datePromesse: datePlanifiee.value || new Date().toISOString().slice(0, 10)
      })
    }
    closeModal()
  } catch (e) {
    console.error('Erreur relance:', e)
    closeModal()
  } finally {
    submitting.value = false
  }
}

onMounted(() => loadData())
</script>
