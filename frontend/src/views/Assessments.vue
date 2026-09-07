<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Avis d'imposition</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              v-permission="'assessments.generate'"
              @click="showGenerateModal = true"
              data-testid="generate-assessments"
              class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700"
            >
              <Plus class="w-4 h-4 mr-2" />
              Générer les avis
            </button>
            <button
              @click="loadAssessments"
              :disabled="loading"
              class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <RefreshCw class="w-4 h-4 mr-2" :class="{ 'animate-spin': loading }" />
              Actualiser
            </button>
            <div class="relative">
              <button
                @click="showExportMenu = !showExportMenu"
                class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
              >
                <Download class="w-4 h-4 mr-2" />
                Exporter
              </button>
              <div
                v-if="showExportMenu"
                class="absolute right-0 mt-2 w-44 bg-white rounded-lg shadow-lg border border-gray-200 z-50"
              >
                <button
                  @click="exportAssessments('csv')"
                  data-testid="export-csv"
                  class="w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-50 rounded-t-lg"
                >
                  Export CSV
                </button>
                <button
                  @click="exportAssessments('xlsx')"
                  data-testid="export-xlsx"
                  class="w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-50 rounded-b-lg"
                >
                  Export Excel
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex">
      <!-- Sidebar -->
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <!-- Assessments Content -->
      <div class="flex-1 p-6">
        <p class="text-sm text-gray-500 mb-6">Gestion des avis d'imposition par périodicité</p>

        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div class="bg-white rounded-lg shadow p-4">
            <div class="flex items-center">
              <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                <FileText class="w-5 h-5 text-blue-600" />
              </div>
              <div class="ml-3">
                <p class="text-sm text-gray-500">Total avis</p>
                <p class="text-xl font-semibold text-gray-900">{{ assessments.length }}</p>
              </div>
            </div>
          </div>
          <div class="bg-white rounded-lg shadow p-4">
            <div class="flex items-center">
              <div class="w-10 h-10 bg-yellow-100 rounded-lg flex items-center justify-center">
                <Clock class="w-5 h-5 text-yellow-600" />
              </div>
              <div class="ml-3">
                <p class="text-sm text-gray-500">Impayés</p>
                <p class="text-xl font-semibold text-gray-900">{{ countByStatus('IMPAYE') }}</p>
              </div>
            </div>
          </div>
          <div class="bg-white rounded-lg shadow p-4">
            <div class="flex items-center">
              <div class="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <AlertCircle class="w-5 h-5 text-red-600" />
              </div>
              <div class="ml-3">
                <p class="text-sm text-gray-500">En retard</p>
                <p class="text-xl font-semibold text-gray-900">{{ countByStatus('EN_RETARD') }}</p>
              </div>
            </div>
          </div>
          <div class="bg-white rounded-lg shadow p-4">
            <div class="flex items-center">
              <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <CheckCircle class="w-5 h-5 text-green-600" />
              </div>
              <div class="ml-3">
                <p class="text-sm text-gray-500">Payés</p>
                <p class="text-xl font-semibold text-gray-900">{{ countByStatus('PAYE') }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Filters -->
        <div class="bg-white rounded-lg shadow mb-6">
          <div class="p-4 border-b border-gray-200">
            <div class="flex flex-wrap items-center gap-4">
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">Période début</label>
                <input
                  type="date"
                  v-model="filters.periodStart"
                  data-testid="filter-period-start"
                  @change="loadAssessments"
                  class="border border-gray-300 rounded-md px-3 py-1.5 text-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">Période fin</label>
                <input
                  type="date"
                  v-model="filters.periodEnd"
                  @change="loadAssessments"
                  class="border border-gray-300 rounded-md px-3 py-1.5 text-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label class="block text-xs font-medium text-gray-500 mb-1">Statut</label>
                <select
                  v-model="filters.statut"
                  data-testid="filter-statut"
                  @change="applyFilters"
                  class="border border-gray-300 rounded-md px-3 py-1.5 text-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="">Tous</option>
                  <option value="IMPAYE">Impayé</option>
                  <option value="EN_RETARD">En retard</option>
                  <option value="PARTIEL">Partiel</option>
                  <option value="PAYE">Payé</option>
                </select>
              </div>
              <button
                v-permission="'assessments.manage'"
                @click="markOverdue"
                class="ml-auto inline-flex items-center px-3 py-1.5 border border-orange-300 rounded-md text-sm font-medium text-orange-700 bg-orange-50 hover:bg-orange-100"
              >
                <AlertCircle class="w-4 h-4 mr-1.5" />
                Marquer en retard
              </button>
            </div>
          </div>
        </div>

        <!-- Assessments Table -->
        <div data-testid="assessments-table" class="bg-white rounded-lg shadow overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Référence</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contribuable</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Taxe</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Période</th>
                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Montant</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Échéance</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Statut</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-if="loading">
                <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                  <RefreshCw class="w-6 h-6 mx-auto animate-spin mb-2" />
                  Chargement...
                </td>
              </tr>
              <tr v-else-if="paginatedAssessments.length === 0">
                <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                  Aucun avis trouvé pour cette période
                </td>
              </tr>
              <tr
                v-for="avis in paginatedAssessments"
                :key="avis.id"
                class="hover:bg-gray-50"
              >
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ avis.reference || '—' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  Contribuable #{{ avis.contribuableId }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {{ avis.taxType || '—' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <div v-if="avis.periodStart">
                    {{ formatDate(avis.periodStart) }} → {{ formatDate(avis.periodEnd) }}
                  </div>
                  <div v-else>{{ avis.periodeConcernee || '—' }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-right font-medium text-gray-900">
                  {{ formatMontant(avis.montant) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <span :class="{ 'text-red-600 font-medium': isOverdue(avis) }">
                    {{ formatDate(avis.dueDate) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <StatusBadge :status="avis.statut" type="assessment" />
                </td>
              </tr>
            </tbody>
          </table>

          <!-- Pagination -->
          <div class="px-6 py-3 border-t border-gray-200 flex items-center justify-between">
            <div class="flex items-center text-sm text-gray-600">
              <span>Affichage de </span>
              <span class="font-medium mx-1">{{ rangeStart }}</span>
              <span>à</span>
              <span class="font-medium mx-1">{{ rangeEnd }}</span>
              <span>sur</span>
              <span class="font-medium mx-1">{{ totalElements }}</span>
              <span>avis</span>
            </div>
            <div class="flex items-center space-x-2">
              <select
                v-model="pageSize"
                @change="onPageSizeChange"
                class="px-2 py-1 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
              >
                <option :value="10">10 / page</option>
                <option :value="20">20 / page</option>
                <option :value="50">50 / page</option>
                <option :value="100">100 / page</option>
              </select>
              <button
                @click="goToPage(0)"
                :disabled="currentPage === 0 || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Première page"
              >
                <ChevronsLeft class="w-4 h-4" />
              </button>
              <button
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 0 || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Page précédente"
              >
                <ChevronLeft class="w-4 h-4" />
              </button>
              <span class="text-sm text-gray-700 px-2">
                Page <span class="font-medium">{{ currentPage + 1 }}</span> / <span class="font-medium">{{ totalPages }}</span>
              </span>
              <button
                @click="goToPage(currentPage + 1)"
                :disabled="isLastPage || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Page suivante"
              >
                <ChevronRight class="w-4 h-4" />
              </button>
              <button
                @click="goToPage(totalPages - 1)"
                :disabled="isLastPage || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Dernière page"
              >
                <ChevronsRight class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Generate Modal -->
    <transition name="fade">
      <div v-if="showGenerateModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white rounded-lg shadow-xl w-full max-w-md p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-semibold text-gray-900">Générer les avis</h2>
            <button @click="showGenerateModal = false" class="text-gray-400 hover:text-gray-600">
              <X class="w-5 h-5" />
            </button>
          </div>

          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Taxe</label>
              <select
                v-model="generateForm.taxeId"
                class="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:ring-primary-500 focus:border-primary-500"
              >
                <option :value="null">Toutes les taxes actives</option>
                <option v-for="taxe in taxes" :key="taxe.id" :value="taxe.id">
                  {{ taxe.nom }} ({{ taxe.periodicite }})
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Date cible</label>
              <input
                type="date"
                v-model="generateForm.targetDate"
                class="w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:ring-primary-500 focus:border-primary-500"
              />
              <p class="text-xs text-gray-500 mt-1">La période sera calculée automatiquement selon la périodicité de la taxe</p>
            </div>

            <div v-if="generateResult" class="rounded-md bg-green-50 p-3 border border-green-200">
              <p class="text-sm text-green-800">
                <CheckCircle class="w-4 h-4 inline mr-1" />
                {{ generateResult.message }}
              </p>
            </div>

            <div v-if="generateError" class="rounded-md bg-red-50 p-3 border border-red-200">
              <p class="text-sm text-red-800">
                <AlertCircle class="w-4 h-4 inline mr-1" />
                {{ generateError }}
              </p>
            </div>
          </div>

          <div class="flex justify-end space-x-3 mt-6">
            <button
              @click="showGenerateModal = false"
              class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
            >
              Fermer
            </button>
            <button
              @click="generateAssessments"
              :disabled="generating"
              class="px-4 py-2 border border-transparent rounded-md text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 disabled:opacity-50"
            >
              <RefreshCw v-if="generating" class="w-4 h-4 inline mr-1 animate-spin" />
              Générer
            </button>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { assessmentService, taxeService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import {
  FileText, Plus, RefreshCw, X, Clock, AlertCircle, CheckCircle, Download,
  ChevronLeft, ChevronRight, ChevronsLeft, ChevronsRight
} from 'lucide-vue-next'

const loading = ref(false)
const generating = ref(false)
const showGenerateModal = ref(false)
const generateResult = ref(null)
const generateError = ref(null)
const assessments = ref([])
const taxes = ref([])

// Pagination state
const currentPage = ref(0)
const pageSize = ref(10)

const totalPages = computed(() => Math.max(1, Math.ceil(filteredAssessments.value.length / pageSize.value)))
const totalElements = computed(() => filteredAssessments.value.length)
const isLastPage = computed(() => currentPage.value >= totalPages.value - 1)
const rangeStart = computed(() => totalElements.value === 0 ? 0 : currentPage.value * pageSize.value + 1)
const rangeEnd = computed(() => Math.min((currentPage.value + 1) * pageSize.value, totalElements.value))

const paginatedAssessments = computed(() => {
  const start = currentPage.value * pageSize.value
  return filteredAssessments.value.slice(start, start + pageSize.value)
})

function goToPage(page) {
  if (page < 0 || page >= totalPages.value) return
  currentPage.value = page
}

function onPageSizeChange() {
  currentPage.value = 0
}

const filters = ref({
  periodStart: '',
  periodEnd: '',
  statut: ''
})

const generateForm = ref({
  taxeId: null,
  targetDate: new Date().toISOString().split('T')[0]
})
const showExportMenu = ref(false)
const exporting = ref(false)

const filteredAssessments = computed(() => {
  return assessments.value.filter(a => {
    if (filters.value.statut && a.statut !== filters.value.statut) return false
    return true
  })
})

// Reset to first page when filters change
watch(filteredAssessments, () => {
  currentPage.value = 0
})

function countByStatus(status) {
  return filteredAssessments.value.filter(a => a.statut === status).length
}

function isOverdue(avis) {
  if (!avis.dueDate) return false
  return new Date(avis.dueDate) < new Date() && avis.statut !== 'PAYE'
}

function formatDate(dateStr) {
  if (!dateStr) return '—'
  return new Date(dateStr).toLocaleDateString('fr-FR')
}

function formatMontant(montant) {
  if (!montant) return '—'
  return new Intl.NumberFormat('fr-FR').format(montant) + ' FCFA'
}

async function loadAssessments() {
  loading.value = true
  try {
    const today = new Date()
    const start = filters.value.periodStart || new Date(today.getFullYear(), today.getMonth() - 3, 1).toISOString().split('T')[0]
    const end = filters.value.periodEnd || new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString().split('T')[0]

    const response = await assessmentService.findByPeriod(start, end)
    assessments.value = Array.isArray(response.data) ? response.data : []
  } catch (err) {
    console.error('Error loading assessments:', err)
    assessments.value = []
  } finally {
    loading.value = false
  }
}

async function loadTaxes() {
  try {
    const response = await taxeService.getAllTaxes()
    taxes.value = Array.isArray(response.data) ? response.data : (response.data?.content || [])
  } catch (err) {
    console.error('Error loading taxes:', err)
    taxes.value = []
  }
}

async function generateAssessments() {
  generating.value = true
  generateResult.value = null
  generateError.value = null
  try {
    let response
    if (generateForm.value.taxeId) {
      response = await assessmentService.generateForTaxe(generateForm.value.taxeId, generateForm.value.targetDate)
    } else {
      response = await assessmentService.generateForAll(generateForm.value.targetDate)
    }
    generateResult.value = response.data
    await loadAssessments()
  } catch (err) {
    generateError.value = err.response?.data?.message || 'Erreur lors de la génération'
  } finally {
    generating.value = false
  }
}

async function markOverdue() {
  try {
    await assessmentService.markOverdue()
    await loadAssessments()
  } catch (err) {
    console.error('Error marking overdue:', err)
  }
}

function applyFilters() {
  // Local filtering only; data already loaded
}

async function exportAssessments(format) {
  showExportMenu.value = false
  exporting.value = true
  try {
    const today = new Date()
    const start = filters.value.periodStart || new Date(today.getFullYear(), today.getMonth() - 3, 1).toISOString().split('T')[0]
    const end = filters.value.periodEnd || new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString().split('T')[0]

    const response = await assessmentService.exportAssessments(format, start, end)
    const blob = new Blob([response.data], {
      type: format === 'csv' ? 'text/csv' : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `avis_imposition_${new Date().toISOString().split('T')[0]}.${format}`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Erreur export:', error)
    alert('Erreur lors de l\'export des avis')
  } finally {
    exporting.value = false
  }
}

onMounted(async () => {
  await Promise.all([loadTaxes(), loadAssessments()])
})
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.2s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
