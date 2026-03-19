import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { agentService } from '@/services'

export const useAgentStore = defineStore('agents', () => {
  // State
  const agents = ref([])
  const loading = ref(false)
  const error = ref(null)
  const selectedAgent = ref(null)
  const pagination = ref(null)
  const filters = ref({})

  // Getters
  const activeAgents = computed(() => {
    return agents.value ? agents.value.filter(agent => agent.statut === 'ACTIF') : []
  })

  const agentsByZone = computed(() => {
    if (!agents.value) return {}
    
    const grouped = {}
    agents.value.forEach(agent => {
      const zoneName = agent.zoneCollecte?.nom || 'Non assigné'
      if (!grouped[zoneName]) {
        grouped[zoneName] = []
      }
      grouped[zoneName].push(agent)
    })
    return grouped
  })

  const onlineAgents = computed(() => {
    return agents.value ? agents.value.filter(agent => agent.enLigne === true) : []
  })

  const offlineAgents = computed(() => {
    return agents.value ? agents.value.filter(agent => agent.enLigne === false) : []
  })

  const agentStats = computed(() => {
    if (!agents.value) return []
    
    const today = new Date().toISOString().split('T')[0]
    
    return agents.value.map(agent => {
      // Ces données viendraient normalement de l'API
      const todayTotal = agent.totalCollecteDuJour || 0
      const transactionCount = agent.nombreTransactionsDuJour || 0
      
      return {
        ...agent,
        todayTotal,
        transactionCount,
        status: agent.enLigne ? 'En ligne' : 'Hors ligne',
        statusColor: agent.enLigne ? 'success' : 'gray'
      }
    })
  })

  const getAgentById = computed(() => {
    return (agentId) => agents.value ? agents.value.find(agent => agent.id === agentId) : null
  })

  // Actions
  const fetchAgents = async (page = 0, size = 20, sort = 'nom,asc') => {
    loading.value = true
    error.value = null
    
    try {
      const response = await agentService.getAllAgents(page, size, sort)
      // S'assurer que c'est toujours un tableau
      agents.value = Array.isArray(response.content) ? response.content : []
      
      // Stocker les métadonnées de pagination
      pagination.value = {
        page: response.page,
        size: response.size,
        totalElements: response.totalElements,
        totalPages: response.totalPages,
        first: response.first,
        last: response.last
      }
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des agents'
      console.error('Error fetching agents:', err)
      // S'assurer que agents est toujours un tableau même en cas d'erreur
      agents.value = []
      pagination.value = null
    } finally {
      loading.value = false
    }
  }

  const fetchAgentById = async (agentId) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await agentService.getAgentById(agentId)
      selectedAgent.value = response.data
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement de l\'agent'
      console.error('Error fetching agent:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const createAgent = async (agentData) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await agentService.createAgent(agentData)
      agents.value.push(response.data)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la création de l\'agent'
      console.error('Error creating agent:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const updateAgent = async (agentId, agentData) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await agentService.updateAgent(agentId, agentData)
      const index = agents.value.findIndex(agent => agent.id === agentId)
      if (index !== -1) {
        agents.value[index] = response.data
      }
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la mise à jour de l\'agent'
      console.error('Error updating agent:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const deleteAgent = async (agentId) => {
    loading.value = true
    error.value = null
    
    try {
      await agentService.deleteAgent(agentId)
      agents.value = agents.value.filter(agent => agent.id !== agentId)
    } catch (err) {
      error.value = err.message || 'Erreur lors de la suppression de l\'agent'
      console.error('Error deleting agent:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const updateAgentStatus = async (agentId, status) => {
    try {
      await updateAgent(agentId, { statut: status })
    } catch (err) {
      console.error('Error updating agent status:', err)
      throw err
    }
  }

  const assignZoneToAgent = async (agentId, zoneId) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await agentService.assignZoneToAgent(agentId, zoneId)
      const index = agents.value.findIndex(agent => agent.id === agentId)
      if (index !== -1) {
        agents.value[index] = response.data
      }
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de l\'assignation de la zone'
      console.error('Error assigning zone:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const removeZoneFromAgent = async (agentId, zoneId) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await agentService.removeZoneFromAgent(agentId, zoneId)
      const index = agents.value.findIndex(agent => agent.id === agentId)
      if (index !== -1) {
        agents.value[index] = response.data
      }
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du retrait de la zone'
      console.error('Error removing zone:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const refreshAgentData = async () => {
    await fetchAgents()
  }

  const fetchAgentsLegacy = async () => {
    loading.value = true
    error.value = null
    
    try {
      const response = await agentService.getAllAgentsLegacy()
      agents.value = Array.isArray(response.data) ? response.data : []
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des agents'
      console.error('Error fetching agents legacy:', err)
      agents.value = []
    } finally {
      loading.value = false
    }
  }

  const clearSelectedAgent = () => {
    selectedAgent.value = null
  }

  return {
    // State
    agents,
    loading,
    error,
    selectedAgent,
    pagination,
    filters,
    
    // Getters
    activeAgents,
    agentsByZone,
    onlineAgents,
    offlineAgents,
    agentStats,
    getAgentById,
    
    // Actions
    fetchAgents,
    fetchAgentsLegacy,
    fetchAgentById,
    createAgent,
    updateAgent,
    deleteAgent,
    updateAgentStatus,
    assignZoneToAgent,
    removeZoneFromAgent,
    refreshAgentData,
    clearSelectedAgent
  }
})
