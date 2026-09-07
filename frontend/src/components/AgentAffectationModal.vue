<template>
  <div v-if="show" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg w-full max-w-2xl max-h-[85vh] flex flex-col">
      <div class="flex items-center justify-between px-6 py-4 border-b border-gray-200">
        <div>
          <h3 class="text-lg font-semibold text-gray-900">Agents assignés</h3>
          <p class="text-sm text-gray-500">
            {{ territoryTypeLabel }} : {{ territoryName }}
          </p>
        </div>
        <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">
          <X class="w-5 h-5" />
        </button>
      </div>

      <div class="flex-1 overflow-y-auto p-6">
        <div v-if="loading" class="flex items-center justify-center py-8">
          <RefreshCw class="w-5 h-5 text-gray-400 animate-spin" />
          <span class="ml-2 text-sm text-gray-500">Chargement...</span>
        </div>

        <template v-else>
          <!-- Assigned agents -->
          <div class="mb-6">
            <h4 class="text-sm font-semibold text-gray-700 mb-3">
              Agents assignés ({{ assignedAgents.length }})
            </h4>
            <div v-if="assignedAgents.length === 0" class="text-sm text-gray-400 py-4 text-center bg-gray-50 rounded-lg">
              Aucun agent assigné à ce territoire
            </div>
            <div v-else class="space-y-2">
              <div
                v-for="agent in assignedAgents"
                :key="agent.agentId"
                class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <div class="flex items-center space-x-3">
                  <div class="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center text-primary-700 text-xs font-semibold">
                    {{ agent.agentInitials || initials(agent) }}
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ agent.agentPrenom }} {{ agent.agentNom }}</p>
                    <p class="text-xs text-gray-500">{{ agent.agentEmail || agent.agentTelephone || '—' }}</p>
                  </div>
                </div>
                <button
                  @click="handleUnassign(agent)"
                  :disabled="busyIds.includes(agent.agentId)"
                  class="text-danger-600 hover:text-danger-800 disabled:opacity-50 p-1.5 rounded-lg hover:bg-danger-50 transition-colors"
                  title="Retirer"
                >
                  <UserMinus class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          <!-- Available agents -->
          <div>
            <h4 class="text-sm font-semibold text-gray-700 mb-3">Agents disponibles</h4>
            <div class="relative mb-3">
              <Search class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                v-model="searchQuery"
                type="text"
                placeholder="Rechercher un agent..."
                class="form-input pl-9"
              />
            </div>
            <div v-if="filteredAvailable.length === 0" class="text-sm text-gray-400 py-4 text-center bg-gray-50 rounded-lg">
              Aucun agent disponible
            </div>
            <div v-else class="space-y-2 max-h-48 overflow-y-auto">
              <div
                v-for="agent in filteredAvailable"
                :key="agent.id"
                class="flex items-center justify-between p-3 border border-gray-200 rounded-lg hover:border-primary-300 transition-colors"
              >
                <div class="flex items-center space-x-3">
                  <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-gray-600 text-xs font-semibold">
                    {{ agentInitials(agent) }}
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ agent.prenom }} {{ agent.nom }}</p>
                    <p class="text-xs text-gray-500">{{ agent.email || agent.telephone || '—' }}</p>
                  </div>
                </div>
                <button
                  @click="handleAssign(agent)"
                  :disabled="busyIds.includes(agent.id)"
                  class="text-primary-600 hover:text-primary-800 disabled:opacity-50 p-1.5 rounded-lg hover:bg-primary-50 transition-colors"
                  title="Assigner"
                >
                  <UserPlus class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </template>
      </div>

      <div class="px-6 py-4 border-t border-gray-200 flex justify-end">
        <button @click="$emit('close')" class="btn-secondary">Fermer</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { affectationService, agentService } from '@/services'
import { X, Search, UserPlus, UserMinus, RefreshCw } from 'lucide-vue-next'

const props = defineProps({
  show: { type: Boolean, default: false },
  territoryType: { type: String, required: true },
  territoryId: { type: [Number, String], required: true },
  territoryName: { type: String, default: '' }
})

const emit = defineEmits(['close', 'updated'])

const loading = ref(false)
const assignedAgents = ref([])
const availableAgents = ref([])
const searchQuery = ref('')
const busyIds = ref([])

const territoryTypeLabel = computed(() => {
  const labels = { ZONE: 'Zone', QUARTIER: 'Quartier', SECTEUR: 'Secteur' }
  return labels[props.territoryType] || props.territoryType
})

const agentInitials = (agent) => {
  let i = ''
  if (agent.prenom) i += agent.prenom.charAt(0)
  if (agent.nom) i += agent.nom.charAt(0)
  return i.toUpperCase()
}

const initials = (dto) => dto.agentInitials || agentInitials({ prenom: dto.agentPrenom, nom: dto.agentNom })

const filteredAvailable = computed(() => {
  const q = searchQuery.value.trim().toLowerCase()
  if (!q) return availableAgents.value
  return availableAgents.value.filter(a =>
    `${a.prenom} ${a.nom}`.toLowerCase().includes(q) ||
    (a.email || '').toLowerCase().includes(q) ||
    (a.telephone || '').toLowerCase().includes(q)
  )
})

const loadData = async () => {
  if (!props.territoryId) return
  loading.value = true
  try {
    const [assignedRes, allRes] = await Promise.all([
      affectationService.getByTerritory(props.territoryType, props.territoryId),
      agentService.getAllAgentsLegacy()
    ])
    assignedAgents.value = assignedRes.data || []
    const assignedIds = new Set(assignedAgents.value.map(a => a.agentId))
    const allAgents = Array.isArray(allRes) ? allRes : (allRes.data || [])
    availableAgents.value = allAgents.filter(a => !assignedIds.has(a.id) && !a.deletedAt)
  } catch (e) {
    console.error('Erreur chargement affectations:', e)
    assignedAgents.value = []
    availableAgents.value = []
  } finally {
    loading.value = false
  }
}

const handleAssign = async (agent) => {
  busyIds.value = [...busyIds.value, agent.id]
  try {
    await affectationService.assign(agent.id, props.territoryType, props.territoryId)
    assignedAgents.value.push({
      agentId: agent.id,
      agentNom: agent.nom,
      agentPrenom: agent.prenom,
      agentEmail: agent.email,
      agentTelephone: agent.telephone,
      agentInitials: agentInitials(agent),
      territoryType: props.territoryType,
      territoryId: props.territoryId
    })
    availableAgents.value = availableAgents.value.filter(a => a.id !== agent.id)
    emit('updated')
  } catch (e) {
    console.error('Erreur assignation:', e)
    alert('Erreur lors de l\'assignation de l\'agent')
  } finally {
    busyIds.value = busyIds.value.filter(id => id !== agent.id)
  }
}

const handleUnassign = async (agent) => {
  busyIds.value = [...busyIds.value, agent.agentId]
  try {
    await affectationService.unassign(agent.agentId, props.territoryType, props.territoryId)
    assignedAgents.value = assignedAgents.value.filter(a => a.agentId !== agent.agentId)
    availableAgents.value.push({
      id: agent.agentId,
      nom: agent.agentNom,
      prenom: agent.agentPrenom,
      email: agent.agentEmail,
      telephone: agent.agentTelephone
    })
    emit('updated')
  } catch (e) {
    console.error('Erreur retrait:', e)
    alert('Erreur lors du retrait de l\'agent')
  } finally {
    busyIds.value = busyIds.value.filter(id => id !== agent.agentId)
  }
}

watch(() => [props.show, props.territoryId], ([show]) => {
  if (show) {
    searchQuery.value = ''
    loadData()
  }
}, { immediate: true })
</script>
