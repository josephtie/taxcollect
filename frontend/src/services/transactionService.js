import { BaseService } from './baseService'

class TransactionService extends BaseService {
  constructor() {
    super('/api/transactions')
  }

  // Récupérer toutes les transactions (paginé)
  async getAllTransactions(page = 0, size = 20, sort = 'dateCreation,desc') {
    try {
      const response = await this.get('', {
        params: { page, size, sort }
      })
      return response.data
    } catch (error) {
      console.error('GET /transactions error:', error)
      throw error
    }
  }

  // Récupérer toutes les transactions (non paginé - pour compatibilité)
  async getAllTransactionsLegacy() {
    try {
      const response = await this.get('/filter')
      return response.data
    } catch (error) {
      console.error('GET /transactions/filter error:', error)
      throw error
    }
  }

  // Récupérer une transaction par ID
  async getTransactionById(id) {
    return this.get(`/${id}`)
  }

  // Récupérer une transaction par numéro de reçu
  async getTransactionByReceiptNumber(receiptNumber) {
    return this.get(`/receipt/${receiptNumber}`)
  }

  // Récupérer les transactions d'un agent
  async getTransactionsByAgent(agentId, params = {}) {
    return this.get(`/agent/${agentId}`, params)
  }

  // Créer une nouvelle transaction
  async createTransaction(transactionData) {
    return this.post('', transactionData)
  }

  // Récupérer les transactions d'un agent par période
  async getTransactionsByAgentAndDateRange(agentId, startDate, endDate) {
    return this.get(`/agent/${agentId}/range`, {
      debut: startDate.toISOString(),
      fin: endDate.toISOString()
    })
  }

  // Filtrer les transactions avec pagination
  async filterTransactions(params = {}) {
    return this.get('/filter', params)
  }

  // Vérifier l'intégrité d'une transaction avec hash
  async verifyTransactionHash(transactionId, hash) {
    return this.get(`/${transactionId}/verify`, { hash })
  }

  // Récupérer les statistiques de transactions
  async getTransactionStats(params = {}) {
    return this.get('/stats', params)
  }

  // Synchroniser une transaction hors-ligne
  async synchronizeTransaction(transactionId) {
    return this.put(`/${transactionId}/sync`)
  }

  // Synchroniser toutes les transactions hors-ligne
  async synchronizeAllOfflineTransactions() {
    return this.post('/sync-all')
  }

  // Mettre à jour le statut d'une transaction
  async updateTransactionStatus(transactionId, status) {
    return this.put(`/${transactionId}/status`, null, { status })
  }

  // Compter les transactions hors-ligne
  async countOfflineTransactions() {
    return this.get('/offline/count')
  }

  // Exporter les transactions (CSV ou Excel)
  async exportTransactions(format = 'csv', params = {}) {
    return this.download('/export', { format, ...params })
  }
}

export const transactionService = new TransactionService()