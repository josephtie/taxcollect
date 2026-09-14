<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Anomalies</h1>
            <p class="text-xs text-gray-500">Contrôle opérationnel et signalements de la zone</p>
          </div>
          <button
            @click="loadAnomalies"
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
          <StatsCard title="Anomalies ouvertes" :value="stats.ouvertes" :icon="AlertTriangle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="En cours" :value="stats.enCours" :icon="Clock" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
          <StatsCard title="Haute sévérité" :value="stats.haute" :icon="AlertOctagon" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          <StatsCard title="Clôturées" :value="stats.cloturees" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
        </div>

        <!-- Filtres -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
          <div class="flex flex-wrap items-center gap-3">
            <div class="relative flex-1 min-w-[12rem]">
              <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Rechercher une anomalie..."
                class="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <select v-model="filterType" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous les types</option>
              <option v-for="t in typesAnomalie" :key="t" :value="t">{{ typeLabel(t) }}</option>
            </select>
            <select v-model="filterSeverite" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Toutes sévérités</option>
              <option value="HAUTE">Haute</option>
              <option value="MOYENNE">Moyenne</option>
              <option value="BASSE">Basse</option>
            </select>
            <select v-model="filterStatut" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous statuts</option>
              <option value="OUVERTE">Ouverte</option>
              <option value="EN_COURS">En cours</option>
              <option value="CLOTUREE">Clôturée</option>
            </select>
          </div>
        </div>

        <!-- Liste des anomalies -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="filteredAnomalies.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune anomalie trouvée.</p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li
              v-for="anomalie in filteredAnomalies"
              :key="anomalie.id"
              class="px-4 py-4 hover:bg-gray-50"
            >
              <div class="flex items-start gap-4">
                <div :class="['shrink-0 w-10 h-10 rounded-lg flex items-center justify-center', severiteBg(anomalie.severite)]">
                  <AlertTriangle :class="['w-5 h-5', severiteText(anomalie.severite)]" />
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2 flex-wrap">
                    <span class="text-sm font-semibold text-gray-900">{{ typeLabel(anomalie.type) }}</span>
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', severiteBadge(anomalie.severite)]">
                      {{ anomalie.severite }}
                    </span>
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', statutBadge(anomalie.statut)]">
                      {{ statutLabel(anomalie.statut) }}
                    </span>
                  </div>
                  <p class="text-sm text-gray-600 mt-1">{{ anomalie.description }}</p>
                  <div class="flex items-center gap-4 mt-2 text-xs text-gray-500">
                    <span class="flex items-center gap-1"><User class="w-3.5 h-3.5" />{{ anomalie.agentNom }}</span>
                    <span class="flex items-center gap-1"><Clock class="w-3.5 h-3.5" />{{ formatDateTime(anomalie.dateDetection) }}</span>
                  </div>
                </div>
                <div class="flex items-center gap-2 shrink-0">
                  <button
                    v-if="anomalie.statut !== 'CLOTUREE'"
                    @click="openTraitement(anomalie, 'traiter')"
                    class="px-3 py-1.5 text-xs font-medium text-primary-700 bg-primary-50 hover:bg-primary-100 rounded-md"
                  >
                    Traiter
                  </button>
                  <button
                    v-if="anomalie.statut !== 'CLOTUREE'"
                    @click="openTraitement(anomalie, 'demander_justification')"
                    class="px-3 py-1.5 text-xs font-medium text-warning-700 bg-warning-50 hover:bg-warning-100 rounded-md"
                  >
                    Justification
                  </button>
                  <button
                    v-if="anomalie.statut !== 'CLOTUREE'"
                    @click="openTraitement(anomalie, 'transmettre_tresor')"
                    class="px-3 py-1.5 text-xs font-medium text-info-700 bg-info-50 hover:bg-info-100 rounded-md"
                  >
                    Transmettre Trésor
                  </button>
                </div>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Modal de traitement -->
    <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-lg flex flex-col max-h-[80vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">{{ actionTitle }}</h3>
            <p class="text-xs text-gray-500 mt-0.5">{{ selectedAnomalie?.description }}</p>
          </div>
          <button @click="closeModal" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>
        <div class="p-5 space-y-4">
          <div class="bg-gray-50 rounded-lg p-3 text-sm text-gray-600">
            <p><span class="font-medium">Type :</span> {{ typeLabel(selectedAnomalie?.type) }}</p>
            <p><span class="font-medium">Agent :</span> {{ selectedAnomalie?.agentNom }}</p>
            <p><span class="font-medium">Sévérité :</span> {{ selectedAnomalie?.severite }}</p>
          </div>
          <textarea
            v-model="commentaire"
            rows="4"
            :placeholder="actionPlaceholder"
            class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
          ></textarea>
          <p v-if="actionType === 'transmettre_tresor'" class="text-xs text-info-600 bg-info-50 p-2 rounded">
            ℹ️ La transmission au Trésor permet la validation financière. Le superviseur ne valide pas financièrement.
          </p>
        </div>
        <div class="px-5 py-3 border-t border-gray-200 flex justify-end gap-2">
          <button @click="closeModal" class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
            Annuler
          </button>
          <button
            @click="submitTraitement"
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
  AlertTriangle, AlertOctagon, CheckCircle, Clock, User, Search,
  RefreshCw, Loader2, Inbox, X
} from 'lucide-vue-next'
import { supervisionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const submitting = ref(false)
const anomalies = ref([])
const searchTerm = ref('')
const filterType = ref('')
const filterSeverite = ref('')
const filterStatut = ref('')
const showModal = ref(false)
const selectedAnomalie = ref(null)
const actionType = ref('')
const commentaire = ref('')

const typesAnomalie = [
  'DOUBLON_CONTRIBUABLE', 'PAIEMENT_SUSPECT', 'MONTANT_INHABITUEL',
  'GPS_INCOHERENT', 'VISITE_TROP_RAPIDE', 'ACTIVITE_INEXISTANTE',
  'CONTRIBUABLE_DOUBLE_AFFECTATION', 'CONFLIT_SYNC', 'SYNC_ECHOUEE',
  'RECU_NON_GENERE', 'ECART_CAISSE', 'AGENT_INACTIF'
]

const typeLabels = {
  DOUBLON_CONTRIBUABLE: 'Doublon contribuable',
  PAIEMENT_SUSPECT: 'Paiement suspect',
  MONTANT_INHABITUEL: 'Montant inhabituel',
  GPS_INCOHERENT: 'GPS incohérent',
  VISITE_TROP_RAPIDE: 'Visite trop rapide',
  ACTIVITE_INEXISTANTE: 'Activité inexistante',
  CONTRIBUABLE_DOUBLE_AFFECTATION: 'Contribuable affecté à 2 agents',
  CONFLIT_SYNC: 'Conflit de synchronisation',
  SYNC_ECHOUEE: 'Synchronisation échouée',
  RECU_NON_GENERE: 'Reçu non généré',
  ECART_CAISSE: 'Écart de caisse',
  AGENT_INACTIF: 'Agent inactif'
}

const typeLabel = (t) => typeLabels[t] || t

const stats = computed(() => ({
  ouvertes: anomalies.value.filter(a => a.statut === 'OUVERTE').length,
  enCours: anomalies.value.filter(a => a.statut === 'EN_COURS').length,
  haute: anomalies.value.filter(a => a.severite === 'HAUTE' && a.statut !== 'CLOTUREE').length,
  cloturees: anomalies.value.filter(a => a.statut === 'CLOTUREE').length
}))

const filteredAnomalies = computed(() => {
  return anomalies.value.filter(a => {
    if (filterType.value && a.type !== filterType.value) return false
    if (filterSeverite.value && a.severite !== filterSeverite.value) return false
    if (filterStatut.value && a.statut !== filterStatut.value) return false
    if (searchTerm.value) {
      const needle = searchTerm.value.toLowerCase()
      return a.description?.toLowerCase().includes(needle) || a.agentNom?.toLowerCase().includes(needle) || typeLabel(a.type).toLowerCase().includes(needle)
    }
    return true
  })
})

const actionTitle = computed(() => {
  const titles = {
    traiter: 'Traiter l\'anomalie',
    demander_justification: 'Demander une justification',
    transmettre_tresor: 'Transmettre au Trésor'
  }
  return titles[actionType.value] || 'Action'
})

const actionPlaceholder = computed(() => {
  const placeholders = {
    traiter: 'Décrivez l\'action de traitement...',
    demander_justification: 'Demande de justification à l\'agent...',
    transmettre_tresor: 'Note de transmission au Trésor...'
  }
  return placeholders[actionType.value] || 'Commentaire...'
})

const severiteBg = (s) => ({ HAUTE: 'bg-danger-50', MOYENNE: 'bg-warning-50', BASSE: 'bg-gray-100' }[s] || 'bg-gray-100')
const severiteText = (s) => ({ HAUTE: 'text-danger-600', MOYENNE: 'text-warning-600', BASSE: 'text-gray-500' }[s] || 'text-gray-500')
const severiteBadge = (s) => ({ HAUTE: 'bg-danger-100 text-danger-800', MOYENNE: 'bg-warning-100 text-warning-800', BASSE: 'bg-gray-100 text-gray-600' }[s] || 'bg-gray-100 text-gray-600')
const statutBadge = (s) => ({ OUVERTE: 'bg-red-100 text-red-800', EN_COURS: 'bg-yellow-100 text-yellow-800', CLOTUREE: 'bg-green-100 text-green-800' }[s] || 'bg-gray-100 text-gray-600')
const statutLabel = (s) => ({ OUVERTE: 'Ouverte', EN_COURS: 'En cours', CLOTUREE: 'Clôturée' }[s] || s)

const formatDateTime = (dt) => {
  if (!dt) return ''
  return new Date(dt).toLocaleString('fr-FR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' })
}

async function loadAnomalies() {
  loading.value = true
  try {
    const response = await supervisionService.getAnomalies()
    anomalies.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement anomalies:', e)
  } finally {
    loading.value = false
  }
}

function openTraitement(anomalie, action) {
  selectedAnomalie.value = anomalie
  actionType.value = action
  commentaire.value = ''
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  selectedAnomalie.value = null
  commentaire.value = ''
}

async function submitTraitement() {
  submitting.value = true
  try {
    // Mapping vers les routes backend réelles :
    //   - 'cloturer' / 'traiter' -> POST /anomalies/{id}/cloturer
    //   - 'transmettre_tresor' / 'demander_justification' -> POST /anomalies/{id}/escaler
    if (actionType.value === 'transmettre_tresor' || actionType.value === 'demander_justification') {
      await supervisionService.escalerAnomalie(selectedAnomalie.value.id, commentaire.value || null)
    } else {
      await supervisionService.cloturerAnomalie(selectedAnomalie.value.id, null, commentaire.value || null)
    }
    // Mise à jour locale
    const idx = anomalies.value.findIndex(a => a.id === selectedAnomalie.value.id)
    if (idx !== -1) {
      if (actionType.value === 'transmettre_tresor') {
        anomalies.value[idx].statut = 'CLOTUREE'
      } else {
        anomalies.value[idx].statut = 'EN_COURS'
      }
    }
    closeModal()
  } catch (e) {
    console.error('Erreur traitement anomalie:', e)
  } finally {
    submitting.value = false
  }
}

onMounted(() => loadAnomalies())
</script>
