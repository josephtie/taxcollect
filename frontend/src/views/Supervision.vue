<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Supervision des Zones</h1>
            <p class="text-xs text-gray-500">Affectation des agents sur vos zones territoriales</p>
          </div>
          <button
            @click="refresh"
            :disabled="loading"
            class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
          >
            <RefreshCw :class="['w-4 h-4 mr-2', loading && 'animate-spin']" />
            Actualiser
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex">
      <!-- Sidebar -->
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <!-- Supervision Content -->
      <div class="flex-1 min-w-0 p-6 space-y-6">
        <!-- Indicateurs -->
        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
          <StatsCard title="Zones supervisées" :value="stats.zones" :icon="MapPin" />
          <StatsCard
            title="Agents affectés"
            :value="stats.assigned"
            :icon="UserCheck"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          <StatsCard
            title="Agents disponibles"
            :value="stats.available"
            :icon="Users"
            icon-color="text-gray-600"
            icon-bg-color="bg-gray-100"
          />
          <StatsCard
            title="Zones sans agent"
            :value="stats.emptyZones"
            :icon="AlertTriangle"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
        </div>

        <!-- Bandeau d'erreur -->
        <div v-if="error" class="flex items-start p-4 bg-danger-50 border border-danger-200 rounded-lg">
          <AlertTriangle class="w-5 h-5 text-danger-600 mt-0.5 mr-3 shrink-0" />
          <p class="flex-1 text-sm font-medium text-danger-800">{{ error }}</p>
          <button @click="error = ''" class="text-danger-600 hover:text-danger-800">
            <X class="w-4 h-4" />
          </button>
        </div>

        <div class="grid grid-cols-1 xl:grid-cols-12 gap-6 items-start">
          <!-- Colonne zones -->
          <section class="xl:col-span-4 bg-white shadow-soft rounded-lg border border-gray-100 flex flex-col">
            <div class="px-4 py-3 border-b border-gray-200">
              <div class="flex items-center justify-between">
                <h2 class="text-sm font-semibold text-gray-900 uppercase tracking-wide">Mes zones</h2>
                <span class="text-xs font-medium text-gray-500">{{ filteredZones.length }} / {{ zones.length }}</span>
              </div>
              <div class="relative mt-3">
                <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  v-model="zoneSearch"
                  type="text"
                  placeholder="Rechercher une zone..."
                  class="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
            </div>

            <div v-if="loading" class="p-8 flex justify-center">
              <Loader2 class="w-6 h-6 text-primary-600 animate-spin" />
            </div>
            <div v-else-if="filteredZones.length === 0" class="p-8 text-center">
              <Inbox class="w-8 h-8 text-gray-300 mx-auto mb-2" />
              <p class="text-sm text-gray-500">
                {{ zones.length === 0 ? 'Aucune zone sous votre supervision.' : 'Aucune zone ne correspond à la recherche.' }}
              </p>
            </div>
            <ul v-else class="divide-y divide-gray-100 overflow-y-auto max-h-[30rem]">
              <li v-for="zone in filteredZones" :key="zone.id">
                <button
                  @click="selectZone(zone.id)"
                  :class="[
                    'w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors border-l-4',
                    zone.id === selectedZoneId ? 'bg-primary-50 border-primary-500' : 'border-transparent'
                  ]"
                >
                  <div class="flex items-center justify-between gap-3">
                    <div class="min-w-0">
                      <p class="text-sm font-medium text-gray-900 truncate">{{ zone.nom }}</p>
                      <p class="text-xs text-gray-500 truncate">{{ zone.communeNom }}</p>
                    </div>
                    <span
                      :class="[
                        'inline-flex items-center shrink-0 px-2 py-0.5 rounded-full text-xs font-medium',
                        agentCount(zone) > 0 ? 'bg-success-100 text-success-800' : 'bg-gray-100 text-gray-600'
                      ]"
                    >
                      {{ agentCount(zone) }}
                    </span>
                  </div>
                </button>
              </li>
            </ul>
          </section>

          <!-- Colonne détail de la zone -->
          <section class="xl:col-span-8 bg-white shadow-soft rounded-lg border border-gray-100 flex flex-col min-w-0">
            <template v-if="selectedZone">
              <div class="px-4 py-3 border-b border-gray-200 flex items-center justify-between gap-4">
                <div class="min-w-0">
                  <h2 class="text-base font-semibold text-gray-900 truncate">{{ selectedZone.nom }}</h2>
                  <p class="text-xs text-gray-500 truncate">
                    {{ selectedZone.communeNom }} · {{ agentCount(selectedZone) }} agent(s) affecté(s)
                  </p>
                </div>
                <button
                  @click="openAssignModal"
                  class="inline-flex items-center shrink-0 px-3 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700"
                >
                  <UserPlus class="w-4 h-4 mr-2" />
                  Affecter
                </button>
              </div>

              <!-- Barre d'outils -->
              <div class="px-4 py-3 border-b border-gray-200 flex flex-wrap items-center gap-3">
                <div class="relative flex-1 min-w-[12rem]">
                  <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    v-model="agentSearch"
                    type="text"
                    placeholder="Rechercher un agent (nom, email, téléphone)..."
                    class="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>
                <select
                  v-model.number="agentPageSize"
                  class="px-2 py-2 border border-gray-300 rounded-md text-sm text-gray-700"
                >
                  <option :value="10">10 / page</option>
                  <option :value="25">25 / page</option>
                  <option :value="50">50 / page</option>
                </select>
                <button
                  v-if="selectedAgentIds.length"
                  @click="removeSelected"
                  :disabled="bulkBusy"
                  class="inline-flex items-center px-3 py-2 bg-danger-600 text-white rounded-md text-sm font-medium hover:bg-danger-700 disabled:opacity-50"
                >
                  <Loader2 v-if="bulkBusy" class="w-4 h-4 mr-2 animate-spin" />
                  <UserMinus v-else class="w-4 h-4 mr-2" />
                  Retirer ({{ selectedAgentIds.length }})
                </button>
              </div>

              <!-- Liste des agents de la zone -->
              <div v-if="filteredZoneAgents.length === 0" class="p-10 text-center">
                <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
                <p class="text-sm text-gray-500">
                  {{ agentCount(selectedZone) === 0 ? 'Aucun agent affecté à cette zone.' : 'Aucun agent ne correspond à la recherche.' }}
                </p>
              </div>
              <div v-else>
                <div class="px-4 py-2 bg-gray-50 border-b border-gray-200 flex items-center gap-3">
                  <input
                    type="checkbox"
                    :checked="allPageSelected"
                    @change="togglePageSelection"
                    class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                  />
                  <span class="text-xs font-medium text-gray-600">
                    {{ filteredZoneAgents.length }} agent(s){{ agentSearch ? ' trouvé(s)' : '' }}
                  </span>
                </div>
                <ul class="divide-y divide-gray-100">
                  <li
                    v-for="agent in pagedZoneAgents"
                    :key="agent.id"
                    class="px-4 py-3 flex items-center gap-3 hover:bg-gray-50"
                  >
                    <input
                      type="checkbox"
                      :checked="selectedAgentIds.includes(agent.id)"
                      @change="toggleAgent(agent.id)"
                      class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                    />
                    <div class="w-9 h-9 shrink-0 bg-primary-100 rounded-full flex items-center justify-center">
                      <span class="text-xs font-semibold text-primary-700">{{ agent.initials }}</span>
                    </div>
                    <div class="min-w-0 flex-1">
                      <p class="text-sm font-medium text-gray-900 truncate">{{ agent.nom }} {{ agent.prenom }}</p>
                      <p class="text-xs text-gray-500 truncate">
                        {{ agent.email }}<span v-if="agent.telephone"> · {{ agent.telephone }}</span>
                      </p>
                    </div>
                    <button
                      @click="removeAgent(agent.id)"
                      :disabled="busyIds.includes(agent.id)"
                      class="shrink-0 inline-flex items-center px-2 py-1 text-xs font-medium text-danger-600 hover:text-danger-800 hover:bg-danger-50 rounded disabled:opacity-50"
                    >
                      <Loader2 v-if="busyIds.includes(agent.id)" class="w-3.5 h-3.5 animate-spin" />
                      <template v-else>Retirer</template>
                    </button>
                  </li>
                </ul>

                <!-- Pagination -->
                <div v-if="totalAgentPages > 1" class="px-4 py-3 border-t border-gray-200 flex items-center justify-between">
                  <p class="text-xs text-gray-500">Page {{ agentPage }} / {{ totalAgentPages }}</p>
                  <div class="flex items-center gap-1">
                    <button
                      @click="agentPage--"
                      :disabled="agentPage === 1"
                      class="p-1.5 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-40"
                    >
                      <ChevronLeft class="w-4 h-4 text-gray-600" />
                    </button>
                    <button
                      @click="agentPage++"
                      :disabled="agentPage >= totalAgentPages"
                      class="p-1.5 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-40"
                    >
                      <ChevronRight class="w-4 h-4 text-gray-600" />
                    </button>
                  </div>
                </div>
              </div>
            </template>

            <div v-else class="p-16 text-center">
              <MapPin class="w-10 h-10 text-gray-300 mx-auto mb-3" />
              <p class="text-sm text-gray-500">Sélectionnez une zone pour gérer ses agents.</p>
            </div>
          </section>
        </div>
      </div>
    </main>

    <!-- Modal d'affectation -->
    <div v-if="showAssignModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-medium w-full max-w-2xl flex flex-col max-h-[85vh] animate-slide-up">
        <div class="px-5 py-4 border-b border-gray-200 flex items-start justify-between">
          <div>
            <h3 class="text-base font-semibold text-gray-900">Affecter des agents</h3>
            <p class="text-xs text-gray-500 mt-0.5">Zone : {{ selectedZone?.nom }}</p>
          </div>
          <button @click="closeAssignModal" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>

        <div class="px-5 py-3 border-b border-gray-200 space-y-3">
          <div class="relative">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              v-model="modalSearch"
              type="text"
              placeholder="Rechercher parmi les agents disponibles..."
              class="w-full pl-9 pr-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
            />
          </div>
          <div class="flex items-center justify-between text-xs">
            <button
              v-if="filteredAvailable.length"
              @click="toggleAllFiltered"
              class="font-medium text-primary-700 hover:text-primary-800"
            >
              {{ allFilteredSelected ? 'Tout désélectionner' : `Tout sélectionner (${filteredAvailable.length})` }}
            </button>
            <span class="text-gray-500">{{ modalSelectedIds.length }} sélectionné(s)</span>
          </div>
        </div>

        <div class="flex-1 overflow-y-auto">
          <div v-if="filteredAvailable.length === 0" class="p-10 text-center">
            <Inbox class="w-10 h-10 text-gray-300 mx-auto mb-3" />
            <p class="text-sm text-gray-500">
              Aucun agent disponible{{ modalSearch ? ' pour cette recherche' : '' }}.
            </p>
          </div>
          <ul v-else class="divide-y divide-gray-100">
            <li v-for="agent in pagedAvailable" :key="agent.id">
              <label class="px-5 py-3 flex items-center gap-3 hover:bg-gray-50 cursor-pointer">
                <input
                  type="checkbox"
                  :checked="modalSelectedIds.includes(agent.id)"
                  @change="toggleModalAgent(agent.id)"
                  class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                />
                <div class="w-9 h-9 shrink-0 bg-gray-100 rounded-full flex items-center justify-center">
                  <span class="text-xs font-semibold text-gray-600">{{ agent.initials }}</span>
                </div>
                <div class="min-w-0 flex-1">
                  <p class="text-sm font-medium text-gray-900 truncate">{{ agent.nom }} {{ agent.prenom }}</p>
                  <p class="text-xs text-gray-500 truncate">
                    {{ agent.email }}<span v-if="agent.telephone"> · {{ agent.telephone }}</span>
                  </p>
                </div>
              </label>
            </li>
          </ul>
        </div>

        <div class="px-5 py-3 border-t border-gray-200 flex items-center justify-between gap-3">
          <div class="flex items-center gap-1">
            <button
              @click="modalPage--"
              :disabled="modalPage === 1"
              class="p-1.5 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-40"
            >
              <ChevronLeft class="w-4 h-4 text-gray-600" />
            </button>
            <span class="text-xs text-gray-500 px-1">{{ modalPage }} / {{ totalModalPages }}</span>
            <button
              @click="modalPage++"
              :disabled="modalPage >= totalModalPages"
              class="p-1.5 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-40"
            >
              <ChevronRight class="w-4 h-4 text-gray-600" />
            </button>
          </div>
          <div class="flex items-center gap-2">
            <button
              @click="closeAssignModal"
              class="px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              Annuler
            </button>
            <button
              @click="assignSelected"
              :disabled="!modalSelectedIds.length || assigning"
              class="inline-flex items-center px-4 py-2 bg-primary-600 text-white rounded-md text-sm font-medium hover:bg-primary-700 disabled:opacity-50"
            >
              <Loader2 v-if="assigning" class="w-4 h-4 mr-2 animate-spin" />
              <UserPlus v-else class="w-4 h-4 mr-2" />
              {{ assigning ? `Affectation ${assignDone}/${assignTotal}...` : `Affecter (${modalSelectedIds.length})` }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import {
  MapPin,
  Users,
  UserCheck,
  UserPlus,
  UserMinus,
  Search,
  RefreshCw,
  X,
  ChevronLeft,
  ChevronRight,
  AlertTriangle,
  Loader2,
  Inbox
} from 'lucide-vue-next'
import { supervisionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const MODAL_PAGE_SIZE = 10
const MAX_PARALLEL_REQUESTS = 5

const loading = ref(false)
const error = ref('')
const zones = ref([])
const availableAgents = ref([])

const selectedZoneId = ref(null)
const zoneSearch = ref('')

const agentSearch = ref('')
const agentPage = ref(1)
const agentPageSize = ref(10)
const selectedAgentIds = ref([])
const busyIds = ref([])
const bulkBusy = ref(false)

const showAssignModal = ref(false)
const modalSearch = ref('')
const modalPage = ref(1)
const modalSelectedIds = ref([])
const assigning = ref(false)
const assignDone = ref(0)
const assignTotal = ref(0)

const agentCount = (zone) => zone?.agents?.length || 0

const normalize = (value) => (value ?? '').toString().toLowerCase()

const agentMatches = (agent, term) => {
  const needle = normalize(term).trim()
  if (!needle) return true
  return (
    normalize(agent.nom).includes(needle) ||
    normalize(agent.prenom).includes(needle) ||
    normalize(agent.email).includes(needle) ||
    normalize(agent.telephone).includes(needle)
  )
}

const filteredZones = computed(() => {
  const needle = normalize(zoneSearch.value).trim()
  if (!needle) return zones.value
  return zones.value.filter(
    (zone) => normalize(zone.nom).includes(needle) || normalize(zone.communeNom).includes(needle)
  )
})

const selectedZone = computed(() => zones.value.find((zone) => zone.id === selectedZoneId.value) || null)

const filteredZoneAgents = computed(() =>
  (selectedZone.value?.agents || []).filter((agent) => agentMatches(agent, agentSearch.value))
)

const totalAgentPages = computed(() =>
  Math.max(1, Math.ceil(filteredZoneAgents.value.length / agentPageSize.value))
)

const pagedZoneAgents = computed(() => {
  const start = (agentPage.value - 1) * agentPageSize.value
  return filteredZoneAgents.value.slice(start, start + agentPageSize.value)
})

const allPageSelected = computed(
  () =>
    pagedZoneAgents.value.length > 0 &&
    pagedZoneAgents.value.every((agent) => selectedAgentIds.value.includes(agent.id))
)

const filteredAvailable = computed(() =>
  availableAgents.value.filter((agent) => agentMatches(agent, modalSearch.value))
)

const totalModalPages = computed(() => Math.max(1, Math.ceil(filteredAvailable.value.length / MODAL_PAGE_SIZE)))

const pagedAvailable = computed(() => {
  const start = (modalPage.value - 1) * MODAL_PAGE_SIZE
  return filteredAvailable.value.slice(start, start + MODAL_PAGE_SIZE)
})

const allFilteredSelected = computed(
  () =>
    filteredAvailable.value.length > 0 &&
    filteredAvailable.value.every((agent) => modalSelectedIds.value.includes(agent.id))
)

const stats = computed(() => ({
  zones: zones.value.length,
  assigned: zones.value.reduce((total, zone) => total + agentCount(zone), 0),
  available: availableAgents.value.length,
  emptyZones: zones.value.filter((zone) => agentCount(zone) === 0).length
}))

watch([agentSearch, agentPageSize, selectedZoneId], () => {
  agentPage.value = 1
})

watch(totalAgentPages, (total) => {
  if (agentPage.value > total) agentPage.value = total
})

watch(modalSearch, () => {
  modalPage.value = 1
})

watch(totalModalPages, (total) => {
  if (modalPage.value > total) modalPage.value = total
})

const runBatched = async (items, task) => {
  const queue = [...items]
  let failures = 0
  const workers = Array.from({ length: Math.min(MAX_PARALLEL_REQUESTS, queue.length) }, async () => {
    while (queue.length) {
      const item = queue.shift()
      try {
        await task(item)
      } catch (err) {
        failures += 1
      }
    }
  })
  await Promise.all(workers)
  return failures
}

const fetchSupervisedZones = async () => {
  const response = await supervisionService.getSupervisedZones()
  zones.value = Array.isArray(response.data) ? response.data : []
}

const fetchAvailableAgents = async () => {
  const response = await supervisionService.getAvailableAgents()
  availableAgents.value = Array.isArray(response.data) ? response.data : []
}

const refresh = async () => {
  loading.value = true
  try {
    await Promise.all([fetchSupervisedZones(), fetchAvailableAgents()])
    if (!zones.value.some((zone) => zone.id === selectedZoneId.value)) {
      selectedZoneId.value = zones.value[0]?.id ?? null
    }
  } catch (err) {
    console.error('Erreur chargement supervision:', err)
    error.value = 'Impossible de charger les données de supervision.'
    zones.value = []
    availableAgents.value = []
  } finally {
    loading.value = false
  }
}

const selectZone = (zoneId) => {
  selectedZoneId.value = zoneId
  selectedAgentIds.value = []
  agentSearch.value = ''
}

const toggleAgent = (agentId) => {
  selectedAgentIds.value = selectedAgentIds.value.includes(agentId)
    ? selectedAgentIds.value.filter((id) => id !== agentId)
    : [...selectedAgentIds.value, agentId]
}

const togglePageSelection = () => {
  const pageIds = pagedZoneAgents.value.map((agent) => agent.id)
  selectedAgentIds.value = allPageSelected.value
    ? selectedAgentIds.value.filter((id) => !pageIds.includes(id))
    : [...new Set([...selectedAgentIds.value, ...pageIds])]
}

const toggleModalAgent = (agentId) => {
  modalSelectedIds.value = modalSelectedIds.value.includes(agentId)
    ? modalSelectedIds.value.filter((id) => id !== agentId)
    : [...modalSelectedIds.value, agentId]
}

const toggleAllFiltered = () => {
  const filteredIds = filteredAvailable.value.map((agent) => agent.id)
  modalSelectedIds.value = allFilteredSelected.value
    ? modalSelectedIds.value.filter((id) => !filteredIds.includes(id))
    : [...new Set([...modalSelectedIds.value, ...filteredIds])]
}

const openAssignModal = () => {
  modalSearch.value = ''
  modalPage.value = 1
  modalSelectedIds.value = []
  assignDone.value = 0
  assignTotal.value = 0
  showAssignModal.value = true
}

const closeAssignModal = () => {
  showAssignModal.value = false
}

const assignSelected = async () => {
  const zoneId = selectedZoneId.value
  const agentIds = [...modalSelectedIds.value]
  if (!zoneId || agentIds.length === 0) return

  assigning.value = true
  assignDone.value = 0
  assignTotal.value = agentIds.length
  error.value = ''

  const failures = await runBatched(agentIds, async (agentId) => {
    await supervisionService.assignAgentToZone(zoneId, agentId)
    assignDone.value += 1
  })

  assigning.value = false
  showAssignModal.value = false
  if (failures > 0) {
    error.value = `${failures} affectation(s) sur ${agentIds.length} ont échoué.`
  }
  await refresh()
}

const removeAgent = async (agentId) => {
  const zoneId = selectedZoneId.value
  if (!zoneId) return

  busyIds.value = [...busyIds.value, agentId]
  error.value = ''
  try {
    await supervisionService.unassignAgentFromZone(zoneId, agentId)
    selectedAgentIds.value = selectedAgentIds.value.filter((id) => id !== agentId)
    await refresh()
  } catch (err) {
    console.error('Erreur retrait agent:', err)
    error.value = 'Impossible de retirer cet agent de la zone.'
  } finally {
    busyIds.value = busyIds.value.filter((id) => id !== agentId)
  }
}

const removeSelected = async () => {
  const zoneId = selectedZoneId.value
  const agentIds = [...selectedAgentIds.value]
  if (!zoneId || agentIds.length === 0) return

  bulkBusy.value = true
  error.value = ''

  const failures = await runBatched(agentIds, (agentId) =>
    supervisionService.unassignAgentFromZone(zoneId, agentId)
  )

  bulkBusy.value = false
  selectedAgentIds.value = []
  if (failures > 0) {
    error.value = `${failures} retrait(s) sur ${agentIds.length} ont échoué.`
  }
  await refresh()
}

onMounted(refresh)
</script>
