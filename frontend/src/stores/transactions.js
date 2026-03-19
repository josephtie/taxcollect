import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { transactionService } from '@/services'

export const useTransactionStore = defineStore('transactions', () => {
  // State
  const transactions = ref([])
  const loading = ref(false)
  const error = ref(null)
  const pagination = ref(null)
  const filters = ref({
    dateRange: null,
    agentId: null,
    paymentMethod: null,
    status: null
  })

  // Getters
  const totalCollectedToday = computed(() => {
    const today = new Date().toISOString().split('T')[0]
    return (transactions.value || [])
      .filter(t => t.dateCreation?.startsWith(today))
      .reduce((sum, t) => sum + (t.montant || 0), 0)
  })

  const todayTransactionCount = computed(() => {
    const today = new Date().toISOString().split('T')[0]
    return (transactions.value || []).filter(t => 
      t.dateCreation?.startsWith(today)
    ).length
  })

  const paymentMethodStats = computed(() => {
    const today = new Date().toISOString().split('T')[0]
    const todayTransactions = (transactions.value || []).filter(t => 
      t.dateCreation?.startsWith(today)
    )
    
    const cashTotal = todayTransactions
      .filter(t => t.modePaiement === 'ESPECE')
      .reduce((sum, t) => sum + (t.montant || 0), 0)
    
    const mobileMoneyTotal = todayTransactions
      .filter(t => t.modePaiement === 'MOBILE_MONEY')
      .reduce((sum, t) => sum + (t.montant || 0), 0)
    
    const total = cashTotal + mobileMoneyTotal
    
    return {
      cash: cashTotal,
      mobileMoney: mobileMoneyTotal,
      total,
      cashPercentage: total > 0 ? (cashTotal / total) * 100 : 0,
      mobileMoneyPercentage: total > 0 ? (mobileMoneyTotal / total) * 100 : 0
    }
  })

  const last7DaysData = computed(() => {
    const data = []
    const today = new Date()
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today)
      date.setDate(date.getDate() - i)
      const dateStr = date.toISOString().split('T')[0]
      
      const dayTotal = transactions.value
        .filter(t => t.dateCreation?.startsWith(dateStr))
        .reduce((sum, t) => sum + (t.montant || 0), 0)
      
      data.push({
        date: date.toLocaleDateString('fr-FR', { weekday: 'short', day: 'numeric' }),
        amount: dayTotal
      })
    }
    
    return data
  })

  const filteredTransactions = computed(() => {
    let filtered = [...transactions.value]
    
    if (filters.value.dateRange) {
      const [start, end] = filters.value.dateRange
      filtered = filtered.filter(t => {
        const date = new Date(t.dateCreation)
        return date >= new Date(start) && date <= new Date(end)
      })
    }
    
    if (filters.value.agentId) {
      filtered = filtered.filter(t => t.agentId === filters.value.agentId)
    }
    
    if (filters.value.paymentMethod) {
      filtered = filtered.filter(t => t.modePaiement === filters.value.paymentMethod)
    }
    
    if (filters.value.status) {
      filtered = filtered.filter(t => t.statut === filters.value.status)
    }
    
    return filtered
  })

  // Actions
  const fetchTransactions = async (page = 0, size = 20, sort = 'dateCreation,desc') => {
    loading.value = true
    error.value = null
    
    try {
      const response = await transactionService.getAllTransactions(page, size, sort)
      // S'assurer que c'est toujours un tableau
      transactions.value = Array.isArray(response.content) ? response.content : []
      
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
      error.value = err.message || 'Erreur lors du chargement des transactions'
      console.error('Error fetching transactions:', err)
      // S'assurer que transactions est toujours un tableau même en cas d'erreur
      transactions.value = []
      pagination.value = null
    } finally {
      loading.value = false
    }
  }

  const fetchTransactionsByAgent = async (agentId) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await transactionService.getTransactionsByAgent(agentId)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des transactions de l\'agent'
      console.error('Error fetching agent transactions:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const fetchTransactionsByDateRange = async (startDate, endDate) => {
    loading.value = true
    error.value = null
    
    try {
      const response = await transactionService.getTransactionsByDateRange(startDate, endDate)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du chargement des transactions'
      console.error('Error fetching transactions by date range:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  const updateFilters = (newFilters) => {
    filters.value = { ...filters.value, ...newFilters }
  }

  const clearFilters = () => {
    filters.value = {
      dateRange: null,
      agentId: null,
      paymentMethod: null,
      status: null
    }
  }

  const refreshData = async () => {
    await fetchTransactions()
  }

  return {
    // State
    transactions,
    loading,
    error,
    filters,
    
    // Getters
    totalCollectedToday,
    todayTransactionCount,
    paymentMethodStats,
    last7DaysData,
    filteredTransactions,
    
    // Actions
    fetchTransactions,
    fetchTransactionsByAgent,
    fetchTransactionsByDateRange,
    updateFilters,
    clearFilters,
    refreshData
  }
})
