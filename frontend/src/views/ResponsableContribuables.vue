<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Contribuables du quartier</h1>
            <p class="text-xs text-gray-500">Recherche, suivi et situation de paiement</p>
          </div>
          <button
            @click="loadContribuables"
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
        <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
          <StatsCard title="Total" :value="contribuables.length" :icon="Building" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
          <StatsCard title="À jour" :value="statutCount('A_JOUR')" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
          <StatsCard title="Impayés" :value="statutCount('IMPAYE')" :icon="AlertCircle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Non visités" :value="statutCount('NON_VISITE')" :icon="MapPin" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
        </div>

        <!-- Filtres + recherche -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
          <div class="flex flex-wrap items-center gap-3">
            <div class="relative flex-1 min-w-[14rem]">
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
            <select v-model="filterStatut" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous statuts</option>
              <option value="A_JOUR">À jour</option>
              <option value="IMPAYE">Impayé</option>
              <option value="NON_VISITE">Non visité</option>
              <option value="NOUVEAU">Nouveau</option>
            </select>
          </div>
        </div>

        <!-- Liste -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="filteredContribuables.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucun contribuable trouvé.</p>
          </div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contribuable</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Secteur</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Agent</th>
                  <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Statut</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Dernière visite</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="c in filteredContribuables" :key="c.id" class="hover:bg-gray-50">
                  <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ c.nom }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ c.secteur }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ c.agentNom || '—' }}</td>
                  <td class="px-4 py-3 text-center">
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', statutBadge(c.statut)]">
                      {{ statutLabel(c.statut) }}
                    </span>
                  </td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ c.derniereVisite ? formatDate(c.derniereVisite) : '—' }}</td>
                  <td class="px-4 py-3 text-right">
                    <button @click="openFiche(c)" title="Voir la fiche" class="p-1.5 text-info-600 hover:bg-info-50 rounded">
                      <Eye class="w-4 h-4" />
                    </button>
                    <button @click="openSignaler(c)" title="Signaler une erreur d'affectation" class="p-1.5 text-warning-600 hover:bg-warning-50 rounded">
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

    <!-- Modal fiche contribuable -->
    <div v-if="showFicheModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-lg flex flex-col max-h-[85vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">{{ selectedContribuable?.nom }}</h3>
            <p class="text-xs text-gray-500 mt-0.5">Fiche contribuable</p>
          </div>
          <button @click="closeModals" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 space-y-3 overflow-y-auto">
          <div class="grid grid-cols-2 gap-4">
            <div><p class="text-xs text-gray-500">Secteur</p><p class="text-sm font-medium text-gray-900">{{ selectedContribuable?.secteur }}</p></div>
            <div><p class="text-xs text-gray-500">Agent</p><p class="text-sm font-medium text-gray-900">{{ selectedContribuable?.agentNom || '—' }}</p></div>
            <div><p class="text-xs text-gray-500">Statut</p>
              <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', statutBadge(selectedContribuable?.statut)]">{{ statutLabel(selectedContribuable?.statut) }}</span>
            </div>
            <div><p class="text-xs text-gray-500">Dernière visite</p><p class="text-sm font-medium text-gray-900">{{ selectedContribuable?.derniereVisite ? formatDate(selectedContribuable.derniereVisite) : 'Jamais' }}</p></div>
          </div>
          <div class="border-t border-gray-100 pt-3">
            <p class="text-xs text-gray-500 mb-2">Historique des visites</p>
            <ul class="space-y-2 text-sm text-gray-600">
              <li v-for="v in historiqueVisites" :key="v.id" class="flex items-center gap-2">
                <span class="text-gray-400">{{ formatDate(v.date) }}</span>
                <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', resultatBadge(v.resultat)]">{{ v.resultat }}</span>
                <span class="text-gray-500">{{ v.agentNom }}</span>
              </li>
            </ul>
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end">
          <button @click="closeModals" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Fermer</button>
        </div>
      </div>
    </div>

    <!-- Modal signalement erreur d'affectation -->
    <div v-if="showSignalerModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-md flex flex-col animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Signaler une erreur d'affectation</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedContribuable?.nom }}</p>
          </div>
          <button @click="closeModals" class="text-gray-400 hover:text-gray-600"><X class="w-5 h-5" /></button>
        </div>
        <div class="p-5 space-y-4">
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Secteur correct</label>
            <select v-model="secteurCorrect" class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Sélectionner...</option>
              <option v-for="s in secteurs" :key="s" :value="s">{{ s }}</option>
            </select>
          </div>
          <div class="space-y-2">
            <label class="text-sm font-medium text-gray-700">Commentaire</label>
            <textarea v-model="signalementCommentaire" rows="3" placeholder="Expliquer l'erreur..." class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"></textarea>
          </div>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModals" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Annuler</button>
          <button @click="submitSignalement" :disabled="submitting || !secteurCorrect" class="px-4 py-2 bg-warning-600 text-white rounded-md text-sm font-medium hover:bg-warning-700 disabled:opacity-50">
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
  Building, CheckCircle, AlertCircle, MapPin, Search, Eye,
  AlertTriangle, RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { responsableService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const contribuables = ref([])
const searchTerm = ref('')
const filterSecteur = ref('')
const filterStatut = ref('')
const showFicheModal = ref(false)
const showSignalerModal = ref(false)
const selectedContribuable = ref(null)
const secteurCorrect = ref('')
const signalementCommentaire = ref('')
const historiqueVisites = ref([])

const secteurs = computed(() => [...new Set(contribuables.value.map(c => c.secteur))].sort())

const filteredContribuables = computed(() => {
  return contribuables.value.filter(c => {
    if (filterSecteur.value && c.secteur !== filterSecteur.value) return false
    if (filterStatut.value && c.statut !== filterStatut.value) return false
    if (searchTerm.value) {
      return c.nom?.toLowerCase().includes(searchTerm.value.toLowerCase())
    }
    return true
  })
})

const statutCount = (statut) => contribuables.value.filter(c => c.statut === statut).length

const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : ''

const statutBadge = (s) => ({
  A_JOUR: 'bg-success-100 text-success-800',
  IMPAYE: 'bg-danger-100 text-danger-800',
  NON_VISITE: 'bg-warning-100 text-warning-800',
  NOUVEAU: 'bg-info-100 text-info-800'
}[s] || 'bg-gray-100 text-gray-600')

const statutLabel = (s) => ({
  A_JOUR: 'À jour',
  IMPAYE: 'Impayé',
  NON_VISITE: 'Non visité',
  NOUVEAU: 'Nouveau'
}[s] || s)

const resultatBadge = (r) => ({
  PAYE: 'bg-success-100 text-success-800',
  REFUS: 'bg-danger-100 text-danger-800',
  ABSENT: 'bg-warning-100 text-warning-800',
  PROMESSE: 'bg-info-100 text-info-800'
}[r] || 'bg-gray-100 text-gray-600')

async function loadContribuables() {
  loading.value = true
  try {
    const response = await responsableService.getContribuablesQuartier()
    contribuables.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement contribuables:', e)
  } finally {
    loading.value = false
  }
}

function openFiche(c) {
  selectedContribuable.value = c
  // Historique de visites non disponible côté backend : on initialise à vide.
  historiqueVisites.value = []
  showFicheModal.value = true
}

function openSignaler(c) {
  selectedContribuable.value = c
  secteurCorrect.value = ''
  signalementCommentaire.value = ''
  showSignalerModal.value = true
}

function closeModals() {
  showFicheModal.value = false
  showSignalerModal.value = false
  selectedContribuable.value = null
}

async function submitSignalement() {
  submitting.value = true
  try {
    await responsableService.signalerErreurAffectation(
      selectedContribuable.value.id,
      secteurCorrect.value,
      signalementCommentaire.value
    )
    closeModals()
  } catch (e) {
    closeModals()
  } finally {
    submitting.value = false
  }
}

onMounted(() => loadContribuables())
</script>
