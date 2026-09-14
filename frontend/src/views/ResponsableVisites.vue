<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Visites terrain</h1>
            <p class="text-xs text-gray-500">Suivi quotidien des visites et couverture des secteurs</p>
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
        <!-- Couverture par secteur -->
        <div>
          <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">Couverture par secteur</h2>
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div v-for="s in couverture" :key="s.secteur" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
              <div class="flex items-center justify-between mb-2">
                <p class="text-sm font-semibold text-gray-900">{{ s.secteur }}</p>
                <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', s.statut === 'OK' ? 'bg-success-100 text-success-800' : 'bg-warning-100 text-warning-800']">
                  {{ s.statut === 'OK' ? 'OK' : '⚠ Attention' }}
                </span>
              </div>
              <p class="text-2xl font-bold text-gray-900">{{ s.tauxCouverture }}%</p>
              <div class="w-full bg-gray-200 rounded-full h-2 mt-2">
                <div :class="s.statut === 'OK' ? 'bg-success-500' : 'bg-warning-500'" class="h-2 rounded-full transition-all duration-500" :style="{ width: `${s.tauxCouverture}%` }"></div>
              </div>
              <p class="text-xs text-gray-500 mt-2">{{ s.visites }} / {{ s.contribuables }} visités</p>
            </div>
          </div>
        </div>

        <!-- Filtres -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
          <div class="flex flex-wrap items-center gap-3">
            <select v-model="filterSecteur" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous secteurs</option>
              <option v-for="s in secteurs" :key="s" :value="s">{{ s }}</option>
            </select>
            <select v-model="filterResultat" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous résultats</option>
              <option value="PAYE">Payé</option>
              <option value="REFUS">Refus</option>
              <option value="ABSENT">Absent</option>
              <option value="PROMESSE">Promesse</option>
            </select>
          </div>
        </div>

        <!-- Liste des visites -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="filteredVisites.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune visite enregistrée.</p>
          </div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Agent</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Secteur</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contribuable</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Heure</th>
                  <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Résultat</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Montant</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Observation</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="v in filteredVisites" :key="v.id" class="hover:bg-gray-50">
                  <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ v.agentNom }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ v.secteur }}</td>
                  <td class="px-4 py-3 text-sm text-gray-900">{{ v.contribuable }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ v.heure }}</td>
                  <td class="px-4 py-3 text-center">
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', resultatBadge(v.resultat)]">
                      {{ resultatLabel(v.resultat) }}
                    </span>
                  </td>
                  <td class="px-4 py-3 text-sm text-right" :class="v.montant > 0 ? 'font-semibold text-success-600' : 'text-gray-400'">
                    {{ v.montant > 0 ? formatCurrency(v.montant) : '—' }}
                  </td>
                  <td class="px-4 py-3 text-sm text-gray-500 max-w-xs truncate">{{ v.observation || '—' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { RefreshCw, Loader2, Inbox } from 'lucide-vue-next'
import { responsableService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'

const loading = ref(false)
const visites = ref([])
const couverture = ref([])
const filterSecteur = ref('')
const filterResultat = ref('')

const secteurs = computed(() => [...new Set(visites.value.map(v => v.secteur))].sort())

const filteredVisites = computed(() => {
  return visites.value.filter(v => {
    if (filterSecteur.value && v.secteur !== filterSecteur.value) return false
    if (filterResultat.value && v.resultat !== filterResultat.value) return false
    return true
  })
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}

const resultatBadge = (r) => ({
  PAYE: 'bg-success-100 text-success-800',
  REFUS: 'bg-danger-100 text-danger-800',
  ABSENT: 'bg-warning-100 text-warning-800',
  PROMESSE: 'bg-info-100 text-info-800'
}[r] || 'bg-gray-100 text-gray-600')

const resultatLabel = (r) => ({
  PAYE: 'Payé',
  REFUS: 'Refus',
  ABSENT: 'Absent',
  PROMESSE: 'Promesse'
}[r] || r)

async function loadData() {
  loading.value = true
  try {
    const [v, c] = await Promise.all([
      responsableService.getVisitesTerrain(),
      responsableService.getSecteursCouverture()
    ])
    visites.value = v.data || []
    couverture.value = c.data || []
  } catch (e) {
    console.error('Erreur chargement visites:', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadData())
</script>
