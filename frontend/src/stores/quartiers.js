import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { quartierService } from '@/services/quartierService'

export const useQuartierStore = defineStore('quartiers', () => {
  // State
  const quartiers = ref([])
  const loading = ref(false)
  const error = ref(null)
  const pagination = ref({
    page: 0,
    size: 20,
    totalElements: 0,
    totalPages: 0
  })

  // Getters
  const quartierCount = computed(() => quartiers.value?.length || 0)
  
  const quartierStats = computed(() => {
    if (!quartiers.value) return []
    return quartiers.value.map(quartier => ({
      id: quartier.id,
      nom: quartier.nom,
      commune: quartier.commune?.nom || 'Non défini',
      zoneCount: quartier.zones?.length || 0
    }))
  })

  const quartiersByCommune = computed(() => {
    if (!quartiers.value) return {}
    return quartiers.value.reduce((acc, quartier) => {
      const communeName = quartier.commune?.nom || 'Non défini'
      if (!acc[communeName]) {
        acc[communeName] = []
      }
      acc[communeName].push(quartier)
      return acc
    }, {})
  })

  // Actions
  const fetchQuartiers = async (page = 0, size = 20) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await quartierService.getAllQuartiers()
      quartiers.value = response.data || []
    } catch (err) {
      error.value = err.message
      console.error('Erreur lors du chargement des quartiers:', err)
      quartiers.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchQuartiersPaginated = async (page = 0, size = 20, sort = 'nom,asc') => {
    loading.value = true
    error.value = null
    
    try {
      const response = await quartierService.getAllQuartiers()
      quartiers.value = response.data || []
      pagination.value = {
        page: 0,
        size: 20,
        totalElements: response.data?.length || 0,
        totalPages: 1
      }
    } catch (err) {
      error.value = err.message
      console.error('Erreur lors du chargement paginé des quartiers:', err)
      quartiers.value = []
    } finally {
      loading.value = false
    }
  }

  const createQuartier = async (quartierData) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await quartierService.createQuartier(quartierData)
      const newQuartier = response.data
      quartiers.value.push(newQuartier)
      return newQuartier
    } catch (err) {
      error.value = err.message
      console.error('Erreur lors de la création du quartier:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const updateQuartier = async (id, quartierData) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await quartierService.updateQuartier(id, quartierData)
      const updatedQuartier = response.data
      
      const index = quartiers.value.findIndex(q => q.id === id)
      if (index !== -1) {
        quartiers.value[index] = updatedQuartier
      }
      
      return updatedQuartier
    } catch (err) {
      error.value = err.message
      console.error('Erreur lors de la mise à jour du quartier:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const deleteQuartier = async (id) => {
    loading.value = true
    error.value = null
    
    try {
      await quartierService.deleteQuartier(id)
      quartiers.value = quartiers.value.filter(q => q.id !== id)
    } catch (err) {
      error.value = err.message
      console.error('Erreur lors de la suppression du quartier:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const getQuartierById = (id) => {
    if (!quartiers.value) return null
    return quartiers.value.find(q => q.id === id)
  }

  const searchQuartiers = (searchTerm) => {
    if (!quartiers.value) return []
    const term = searchTerm.toLowerCase()
    return quartiers.value.filter(quartier => 
      quartier.nom?.toLowerCase().includes(term) ||
      quartier.commune?.nom?.toLowerCase().includes(term)
    )
  }

  return {
    // State
    quartiers,
    loading,
    error,
    pagination,
    
    // Getters
    quartierCount,
    quartierStats,
    quartiersByCommune,
    
    // Actions
    fetchQuartiers,
    fetchQuartiersPaginated,
    createQuartier,
    updateQuartier,
    deleteQuartier,
    getQuartierById,
    searchQuartiers
  }
})
