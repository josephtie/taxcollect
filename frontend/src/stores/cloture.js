import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { clotureService } from '@/services'

export const useClotureStore = defineStore('cloture', () => {
  // State
  const clotures = ref([])
  const loading = ref(false)
  const error = ref(null)
  const pagination = ref(null)
  const filters = ref({
    status: null,
    dateRange: null,
    agentId: null
  })

  // Getters
  const cloturesByStatus = computed(() => {
    const grouped = {}
    clotures.value.forEach(cloture => {
      const status = cloture.statut
      if (!grouped[status]) {
        grouped[status] = []
      }
      grouped[status].push(cloture)
    })
    return grouped
  })

  const pendingValidation = computed(() => {
    return clotures.value.filter(cloture => cloture.statut === 'SOUMISE')
  })

  const validatedClotures = computed(() => {
    return clotures.value.filter(cloture => cloture.statut === 'VALIDEE')
  })

  const rejectedClotures = computed(() => {
    return clotures.value.filter(cloture => cloture.statut === 'REJETEE')
  })

  const depositedClotures = computed(() => {
    return clotures.value.filter(cloture => cloture.statut === 'DEPOSEE')
  })

  const todayTotalDeposits = computed(() => {
    const today = new Date().toISOString().split('T')[0]
    return clotures.value
      .filter(c => c.dateDepotBanque?.startsWith(today))
      .reduce((sum, c) => sum + (c.montantDepose || 0), 0)
  })

  const getClotureById = computed(() => {
    return (clotureId) => clotures.value.find(cloture => cloture.id === clotureId)
  })

  // Actions
  const fetchClotures = async (page = 0, size = 20, sort = 'dateCloture,desc') => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.getAllClotures(page, size, sort)
      // S'assurer que c'est toujours un tableau
      clotures.value = Array.isArray(response.content) ? response.content : []
      
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
      error.value = err.message || 'Erreur lors du chargement des clôtures'
      console.error('Error fetching clotures:', err)
      // S'assurer que clotures est toujours un tableau même en cas d'erreur
      clotures.value = []
      pagination.value = null
    } finally {
      loading.value = false
    }
  }

  const fetchCloturesByStatus = async (status) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.getCloturesByStatus(status)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des clôtures'
      console.error('Error fetching clotures by status:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const fetchCloturesByDateRange = async (startDate, endDate) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.getCloturesByDateRange(startDate, endDate)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des clôtures'
      console.error('Error fetching clotures by date range:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const validateCloture = async (clotureId, valideParId, commentaire) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.validateCloture(clotureId, valideParId, commentaire)
      
      // Update local state
      const index = clotures.value.findIndex(c => c.id === clotureId)
      if (index !== -1) {
        clotures.value[index] = response.data
      }
      
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la validation de la clôture'
      console.error('Error validating cloture:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const rejectCloture = async (clotureId, valideParId, commentaire) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.rejectCloture(clotureId, valideParId, commentaire)
      
      // Update local state
      const index = clotures.value.findIndex(c => c.id === clotureId)
      if (index !== -1) {
        clotures.value[index] = response.data
      }
      
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du rejet de la clôture'
      console.error('Error rejecting cloture:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const confirmDeposit = async (clotureId, montantDepose, referenceDepot) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.confirmDeposit(clotureId, montantDepose, referenceDepot)
      
      // Update local state
      const index = clotures.value.findIndex(c => c.id === clotureId)
      if (index !== -1) {
        clotures.value[index] = response.data
      }
      
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la confirmation du dépôt'
      console.error('Error confirming deposit:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const refreshClotureData = async () => {
    await fetchClotures()
  }

  const initiateCloture = async (agentId, dateCloture) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.initiateCloture(agentId, dateCloture)
      clotures.value.push(response.data)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de l\'initialisation de la clôture'
      console.error('Error initiating cloture:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const submitCloture = async (clotureId, montantDeclare, commentaireAgent) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.submitCloture(clotureId, montantDeclare, commentaireAgent)
      
      // Update local state
      const index = clotures.value.findIndex(c => c.id === clotureId)
      if (index !== -1) {
        clotures.value[index] = response.data
      }
      
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la soumission de la clôture'
      console.error('Error submitting cloture:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const getCloturesByAgent = async (agentId) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.getCloturesByAgent(agentId)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des clôtures de l\'agent'
      console.error('Error fetching agent clotures:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const getClotureStats = async (startDate, endDate) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await clotureService.getClotureStats(startDate, endDate)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des statistiques'
      console.error('Error fetching cloture stats:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  return {
    // State
    clotures,
    loading,
    error,
    pagination,
    filters,
    
    // Getters
    cloturesByStatus,
    pendingValidation,
    validatedClotures,
    rejectedClotures,
    depositedClotures,
    todayTotalDeposits,
    getClotureById,
    
    // Actions
    fetchClotures,
    fetchCloturesByStatus,
    fetchCloturesByDateRange,
    validateCloture,
    rejectCloture,
    confirmDeposit,
    refreshClotureData,
    initiateCloture,
    submitCloture,
    getCloturesByAgent,
    getClotureStats
  }
})
