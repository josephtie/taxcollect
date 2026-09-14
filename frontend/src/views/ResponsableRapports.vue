<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Rapports du quartier</h1>
            <p class="text-xs text-gray-500">Statistiques et export — quartier {{ rapport?.quartier?.nom || '' }}</p>
          </div>
          <div class="flex items-center gap-3">
            <button
              @click="exporter('pdf')"
              :disabled="exporting"
              class="inline-flex items-center px-3 py-2 bg-danger-600 text-white rounded-md text-sm font-medium hover:bg-danger-700 disabled:opacity-50"
            >
              <FileText class="w-4 h-4 mr-2" />
              Export PDF
            </button>
            <button
              @click="exporter('excel')"
              :disabled="exporting"
              class="inline-flex items-center px-3 py-2 bg-success-600 text-white rounded-md text-sm font-medium hover:bg-success-700 disabled:opacity-50"
            >
              <FileSpreadsheet class="w-4 h-4 mr-2" />
              Export Excel
            </button>
            <button
              @click="loadRapport"
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
        <div v-if="loading" class="flex justify-center py-12">
          <Loader2 class="w-8 h-8 text-primary-600 animate-spin" />
        </div>
        <template v-else-if="rapport">
          <!-- Filtre période -->
          <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
            <div class="flex flex-wrap items-center gap-3">
              <div class="space-y-1">
                <label class="text-xs font-medium text-gray-500">Période</label>
                <select v-model="periode" @change="loadRapport" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
                  <option value="jour">Aujourd'hui</option>
                  <option value="semaine">Cette semaine</option>
                  <option value="mois">Ce mois</option>
                  <option value="trimestre">Ce trimestre</option>
                </select>
              </div>
              <div class="text-sm text-gray-500">
                {{ formatDate(rapport.periode.debut) }} → {{ formatDate(rapport.periode.fin) }}
              </div>
            </div>
          </div>

          <!-- Synthèse -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">Synthèse</h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
              <StatsCard title="Contribuables" :value="rapport.synthese.contribuablesTotal" :icon="Building" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
              <StatsCard title="Visités" :value="rapport.synthese.contribuablesVisites" :icon="MapPin" icon-color="text-info-600" icon-bg-color="bg-info-50" />
              <StatsCard title="Couverture" :value="rapport.synthese.tauxCouverture + '%'" :icon="TrendingUp" icon-color="text-success-600" icon-bg-color="bg-success-50" />
              <StatsCard title="Collecté" :value="rapport.synthese.montantCollecte" format="currency" :icon="Banknote" icon-color="text-success-600" icon-bg-color="bg-success-50" />
              <StatsCard title="Impayés" :value="rapport.synthese.impayes" format="currency" :icon="AlertCircle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
              <StatsCard title="Anomalies" :value="rapport.synthese.nbAnomalies" :icon="AlertTriangle" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
            </div>
          </div>

          <!-- Par secteur -->
          <div class="bg-white shadow-soft rounded-lg border border-gray-100">
            <div class="px-4 py-3 border-b border-gray-200">
              <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Performance par secteur</h2>
            </div>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Secteur</th>
                    <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Contribuables</th>
                    <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Visités</th>
                    <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Couverture</th>
                    <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Collecté</th>
                    <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Impayés</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                  <tr v-for="s in rapport.parSecteur" :key="s.secteur" class="hover:bg-gray-50">
                    <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ s.secteur }}</td>
                    <td class="px-4 py-3 text-sm text-right text-gray-500">{{ s.contribuables }}</td>
                    <td class="px-4 py-3 text-sm text-right text-gray-500">{{ s.visites }}</td>
                    <td class="px-4 py-3 text-center">
                      <div class="flex items-center gap-2">
                        <div class="flex-1 bg-gray-200 rounded-full h-2 max-w-[80px]">
                          <div class="bg-primary-600 h-2 rounded-full" :style="{ width: `${s.tauxCouverture}%` }"></div>
                        </div>
                        <span class="text-xs text-gray-600">{{ s.tauxCouverture }}%</span>
                      </div>
                    </td>
                    <td class="px-4 py-3 text-sm text-right font-medium text-success-600">{{ formatCurrency(s.collecte) }}</td>
                    <td class="px-4 py-3 text-sm text-right text-danger-600">{{ formatCurrency(s.impayes) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Par agent -->
          <div class="bg-white shadow-soft rounded-lg border border-gray-100">
            <div class="px-4 py-3 border-b border-gray-200">
              <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Performance par agent</h2>
            </div>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Agent</th>
                    <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Visites</th>
                    <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Paiements</th>
                    <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Collecté</th>
                    <th class="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Taux de conversion</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                  <tr v-for="a in rapport.parAgent" :key="a.agent" class="hover:bg-gray-50">
                    <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ a.agent }}</td>
                    <td class="px-4 py-3 text-sm text-right text-gray-500">{{ a.visites }}</td>
                    <td class="px-4 py-3 text-sm text-right text-gray-500">{{ a.paiements }}</td>
                    <td class="px-4 py-3 text-sm text-right font-medium text-success-600">{{ formatCurrency(a.collecte) }}</td>
                    <td class="px-4 py-3 text-center">
                      <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', tauxBadge(a.taux)]">{{ a.taux }}%</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  Building, MapPin, TrendingUp, Banknote, AlertCircle, AlertTriangle,
  FileText, FileSpreadsheet, RefreshCw, Loader2
} from 'lucide-vue-next'
import { responsableService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const exporting = ref(false)
const rapport = ref(null)
const periode = ref('mois')

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF', minimumFractionDigits: 0, maximumFractionDigits: 0 }).format(amount || 0)
}
const formatDate = (d) => d ? new Date(d).toLocaleDateString('fr-FR') : ''

const tauxBadge = (t) => {
  if (t >= 75) return 'bg-success-100 text-success-800'
  if (t >= 50) return 'bg-warning-100 text-warning-800'
  if (t > 0) return 'bg-danger-100 text-danger-800'
  return 'bg-gray-100 text-gray-600'
}

async function loadRapport() {
  loading.value = true
  try {
    const response = await responsableService.getRapportQuartier({ periode: periode.value })
    rapport.value = response.data
  } catch (e) {
    console.error('Erreur chargement rapport:', e)
  } finally {
    loading.value = false
  }
}

async function exporter(format) {
  exporting.value = true
  try {
    await responsableService.exporterRapportQuartier(format, { periode: periode.value })
  } catch (e) {
    console.warn('Export non disponible côté backend. Téléchargement simulé.')
    // Fallback : générer un fichier texte
    const contenu = genererContenuRapport()
    const blob = new Blob([contenu], { type: format === 'pdf' ? 'application/pdf' : 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `rapport_quartier_${periode.value}.${format === 'pdf' ? 'txt' : 'csv'}`
    a.click()
    URL.revokeObjectURL(url)
  } finally {
    exporting.value = false
  }
}

function genererContenuRapport() {
  if (!rapport.value) return ''
  const r = rapport.value
  const lignes = [
    `RAPPORT DU QUARTIER — ${r.quartier.nom}`,
    `Période : ${formatDate(r.periode.debut)} → ${formatDate(r.periode.fin)}`,
    '',
    'SYNTHÈSE',
    `Contribuables total : ${r.synthese.contribuablesTotal}`,
    `Visités : ${r.synthese.contribuablesVisites}`,
    `Taux de couverture : ${r.synthese.tauxCouverture}%`,
    `Montant collecté : ${formatCurrency(r.synthese.montantCollecte)}`,
    `Impayés : ${formatCurrency(r.synthese.impayes)}`,
    `Paiements : ${r.synthese.nbPaiements}`,
    `Anomalies : ${r.synthese.nbAnomalies}`,
    '',
    'PAR SECTEUR',
    ...r.parSecteur.map(s => `${s.secteur} | ${s.visites}/${s.contribuables} | ${s.tauxCouverture}% | ${formatCurrency(s.collecte)} | impayés: ${formatCurrency(s.impayes)}`),
    '',
    'PAR AGENT',
    ...r.parAgent.map(a => `${a.agent} | visites: ${a.visites} | paiements: ${a.paiements} | ${formatCurrency(a.collecte)} | taux: ${a.taux}%`)
  ]
  return lignes.join('\n')
}

onMounted(() => loadRapport())
</script>
