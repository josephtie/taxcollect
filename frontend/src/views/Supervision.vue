<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Supervision des Zones</h1>
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

      <!-- Supervision Content -->
      <div class="flex-1 p-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Zones Supervisées -->
        <div class="bg-white shadow rounded-lg">
          <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Mes Zones</h3>
            <p class="mt-1 text-sm text-gray-500">Zones sous votre supervision</p>
          </div>
          <div class="p-4">
            <div v-if="loading" class="text-center py-8">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
            </div>
            <div v-else class="space-y-4">
              <div v-for="zone in supervisedZones" :key="zone.id" class="border rounded-lg p-4">
                <div class="flex justify-between items-start mb-3">
                  <div>
                    <h4 class="font-medium text-gray-900">{{ zone.nom }}</h4>
                    <p class="text-sm text-gray-500">{{ zone.quartier?.nom }}</p>
                  </div>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    {{ zone.agents?.length || 0 }} agents
                  </span>
                </div>
                
                <!-- Agents assignés -->
                <div class="space-y-2">
                  <div v-for="agent in zone.agents" :key="agent.id" class="flex items-center justify-between p-2 bg-gray-50 rounded">
                    <div class="flex items-center">
                      <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                        <span class="text-xs font-medium text-purple-600">{{ agent.initials }}</span>
                      </div>
                      <div class="ml-3">
                        <p class="text-sm font-medium text-gray-900">{{ agent.nom }}</p>
                        <p class="text-xs text-gray-500">{{ agent.contact }}</p>
                      </div>
                    </div>
                    <button
                      @click="unassignAgent(zone.id, agent.id)"
                      class="text-red-600 hover:text-red-800 text-sm"
                    >
                      Retirer
                    </button>
                  </div>
                </div>

                <!-- Ajouter un agent -->
                <div class="mt-3 pt-3 border-t">
                  <select
                    v-model="selectedAgents[zone.id]"
                    class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm"
                  >
                    <option value="">Sélectionner un agent à ajouter</option>
                    <option
                      v-for="agent in availableAgents"
                      :key="agent.id"
                      :value="agent.id"
                    >
                      {{ agent.nom }}
                    </option>
                  </select>
                  <button
                    @click="assignAgent(zone.id)"
                    :disabled="!selectedAgents[zone.id]"
                    class="mt-2 w-full px-3 py-2 bg-primary-600 text-white rounded-md text-sm hover:bg-primary-700 disabled:opacity-50"
                  >
                    Ajouter l'agent
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Agents Disponibles -->
        <div class="bg-white shadow rounded-lg">
          <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Agents Disponibles</h3>
            <p class="mt-1 text-sm text-gray-500">Agents non assignés à vos zones</p>
          </div>
          <div class="p-4">
            <div class="space-y-3">
              <div v-for="agent in availableAgents" :key="agent.id" class="flex items-center justify-between p-3 border rounded-lg">
                <div class="flex items-center">
                  <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                    <span class="text-sm font-medium text-blue-600">{{ agent.initials }}</span>
                  </div>
                  <div class="ml-3">
                    <p class="text-sm font-medium text-gray-900">{{ agent.nom }}</p>
                    <p class="text-xs text-gray-500">{{ agent.contact }}</p>
                  </div>
                </div>
                <div class="flex items-center space-x-2">
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                    Disponible
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supervisionService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'

const loading = ref(false)
const supervisedZones = ref([])
const availableAgents = ref([])
const selectedAgents = ref({})

const fetchSupervisedZones = async () => {
  try {
    loading.value = true
    const response = await supervisionService.getSupervisedZones()
    supervisedZones.value = response.data
  } catch (error) {
    console.error('Erreur chargement zones supervisées:', error)
    // Fallback avec données mock
    supervisedZones.value = [
      {
        id: 1,
        nom: 'Zone Centre-Ville',
        quartier: { nom: 'Centre Ville' },
        agents: [
          { id: 1, nom: 'Kouadio Konan', contact: 'kouadio@tax.ci', initials: 'KK' },
          { id: 2, nom: 'Awa Touré', contact: 'awa@tax.ci', initials: 'AT' }
        ]
      }
    ]
  } finally {
    loading.value = false
  }
}

const fetchAvailableAgents = async () => {
  try {
    const response = await supervisionService.getAvailableAgents()
    availableAgents.value = response.data
  } catch (error) {
    console.error('Erreur chargement agents disponibles:', error)
    // Fallback avec données mock
    availableAgents.value = [
      { id: 3, nom: 'Yao Brou', contact: 'yao@tax.ci', initials: 'YB' },
      { id: 4, nom: 'Patrice Ouattara', contact: 'patrice@tax.ci', initials: 'PO' }
    ]
  }
}

const assignAgent = async (zoneId) => {
  const agentId = selectedAgents.value[zoneId]
  if (!agentId) return
  
  try {
    await supervisionService.assignAgentToZone(zoneId, agentId)
    await Promise.all([fetchSupervisedZones(), fetchAvailableAgents()])
    selectedAgents.value[zoneId] = ''
  } catch (error) {
    console.error('Erreur affectation agent:', error)
  }
}

const unassignAgent = async (zoneId, agentId) => {
  try {
    await supervisionService.unassignAgentFromZone(zoneId, agentId)
    await Promise.all([fetchSupervisedZones(), fetchAvailableAgents()])
  } catch (error) {
    console.error('Erreur retrait agent:', error)
  }
}

onMounted(() => {
  Promise.all([fetchSupervisedZones(), fetchAvailableAgents()])
})
</script>
