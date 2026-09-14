<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Audit</h1>
            <p class="text-xs text-gray-500">Journal immuable — Qui a fait quoi, quand et où</p>
          </div>
          <button
            @click="loadAudit"
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
        <!-- Avertissement immuabilité -->
        <div class="flex items-start p-4 bg-info-50 border border-info-200 rounded-lg">
          <ShieldCheck class="w-5 h-5 text-info-600 mt-0.5 mr-3 shrink-0" />
          <p class="flex-1 text-sm text-info-800">
            Ce journal est <strong>immuable</strong>. Il trace toutes les opérations de la zone et ne peut être ni modifié ni supprimé.
          </p>
        </div>

        <!-- Filtres -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4">
          <div class="flex flex-wrap items-center gap-3">
            <div class="relative flex-1 min-w-[12rem]">
              <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Rechercher (acteur, action, détails)..."
                class="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <select v-model="filterActeur" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700">
              <option value="">Tous acteurs</option>
              <option v-for="a in acteurs" :key="a" :value="a">{{ a }}</option>
            </select>
            <input type="date" v-model="filterDate" class="px-3 py-2 border border-gray-300 rounded-md text-sm text-gray-700" />
          </div>
        </div>

        <!-- Journal -->
        <div class="bg-white shadow-soft rounded-lg border border-gray-100">
          <div v-if="loading" class="p-12 flex justify-center">
            <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
          </div>
          <div v-else-if="filteredLogs.length === 0" class="p-12 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">Aucune entrée d'audit.</p>
          </div>
          <div v-else class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Horodatage</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acteur</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Détails</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Zone</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="log in filteredLogs" :key="log.id" class="hover:bg-gray-50">
                  <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">{{ formatDateTime(log.horodatage) }}</td>
                  <td class="px-4 py-3">
                    <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium', acteurBadge(log.acteur)]">
                      {{ log.acteur }}
                    </span>
                  </td>
                  <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ log.action }}</td>
                  <td class="px-4 py-3 text-sm text-gray-600">{{ log.details }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500">{{ log.zone }}</td>
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
import {
  ShieldCheck, Search, RefreshCw, Loader2, Inbox
} from 'lucide-vue-next'
import { auditService, authService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'

const loading = ref(false)
const logs = ref([])
const searchTerm = ref('')
const filterActeur = ref('')
const filterDate = ref('')

const acteurs = computed(() => [...new Set(logs.value.map(l => l.acteur))].sort())

const filteredLogs = computed(() => {
  return logs.value.filter(l => {
    if (filterActeur.value && l.acteur !== filterActeur.value) return false
    if (filterDate.value) {
      const logDate = new Date(l.horodatage).toISOString().slice(0, 10)
      if (logDate !== filterDate.value) return false
    }
    if (searchTerm.value) {
      const needle = searchTerm.value.toLowerCase()
      return l.acteur?.toLowerCase().includes(needle) ||
             l.action?.toLowerCase().includes(needle) ||
             l.details?.toLowerCase().includes(needle)
    }
    return true
  })
})

const formatDateTime = (dt) => {
  if (!dt) return ''
  return new Date(dt).toLocaleString('fr-FR', {
    day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit'
  })
}

const acteurBadge = (acteur) => {
  if (acteur?.startsWith('SUP')) return 'bg-primary-100 text-primary-800'
  if (acteur?.startsWith('AG')) return 'bg-info-100 text-info-800'
  if (acteur?.startsWith('TRES')) return 'bg-success-100 text-success-800'
  if (acteur?.startsWith('ADMIN')) return 'bg-gray-200 text-gray-800'
  return 'bg-gray-100 text-gray-600'
}

async function loadAudit() {
  loading.value = true
  try {
    // Le backend AuditEntryController n'expose pas de route "liste globale".
    // On filtre par utilisateur courant ou par agent selon le contexte.
    const user = await authService.getCurrentUser()
    const userId = user?.id || user?.sub || user?.userId
    let response
    if (userId) {
      response = await auditService.getAuditByUser(userId)
    } else {
      response = await auditService.getPendingSync()
    }
    logs.value = response.data || []
  } catch (e) {
    console.error('Erreur chargement audit:', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadAudit())
</script>
