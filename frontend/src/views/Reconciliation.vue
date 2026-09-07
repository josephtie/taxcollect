<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Réconciliation</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="loadReconciliations"
              :disabled="loading"
              class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Actualiser
            </button>
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

      <!-- Reconciliation Content -->
      <div class="flex-1 p-6">
        <p class="text-sm text-gray-500 mb-6">Rapprochement des transactions internes et provider</p>

    <div class="bg-white rounded-lg shadow">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Référence</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Période</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Provider</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Transactions</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Divergences</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Statut</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="recon in reconciliations" :key="recon.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ recon.reference }}</td>
              <td class="px-6 py-4 text-sm text-gray-500">
                {{ formatDate(recon.periodStart) }} - {{ formatDate(recon.periodEnd) }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-500">{{ recon.provider }}</td>
              <td class="px-6 py-4 text-sm text-gray-900">{{ recon.totalTransactions }}</td>
              <td class="px-6 py-4">
                <span
                  v-if="recon.discrepancyCount > 0"
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
                >
                  {{ recon.discrepancyCount }}
                </span>
                <span v-else class="text-sm text-green-600">Aucune</span>
              </td>
              <td class="px-6 py-4">
                <span
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  :class="statusClass(recon.status)"
                >
                  {{ recon.status }}
                </span>
              </td>
            </tr>
            <tr v-if="reconciliations.length === 0">
              <td colspan="6" class="px-6 py-8 text-center text-sm text-gray-400">
                Aucune réconciliation disponible
              </td>
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
import { ref, onMounted } from 'vue'
import { reconciliationService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'

const reconciliations = ref([])
const loading = ref(false)

onMounted(async () => {
  await loadReconciliations()
})

async function loadReconciliations() {
  loading.value = true
  try {
    const response = await reconciliationService.getAllReconciliations()
    reconciliations.value = Array.isArray(response.data) ? response.data : []
  } catch (err) {
    console.error('Error loading reconciliations:', err)
  } finally {
    loading.value = false
  }
}

function statusClass(status) {
  const classes = {
    MATCHED: 'bg-green-100 text-green-800',
    DISCREPANCY: 'bg-red-100 text-red-800',
    RESOLVED: 'bg-blue-100 text-blue-800',
    ESCALATED: 'bg-orange-100 text-orange-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

function formatDate(dateStr) {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleDateString('fr-FR')
}
</script>
