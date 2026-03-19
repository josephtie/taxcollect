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

  // Mettre à jour une transaction
  async updateTransaction(id, transactionData) {
    return this.put(`/${id}`, transactionData)
  }

  // Supprimer une transaction
  async deleteTransaction(id) {
    return this.delete(`/${id}`)
  }

  // Récupérer les transactions par période
  async getTransactionsByDateRange(startDate, endDate) {
    return this.get('/range', {
      debut: startDate.toISOString(),
      fin: endDate.toISOString()
    })
  }

  // Récupérer les transactions d'un agent par période
  async getTransactionsByAgentAndDateRange(agentId, startDate, endDate) {
    return this.get(`/agent/${agentId}/range`, {
      debut: startDate.toISOString(),
      fin: endDate.toISOString()
    })
  }

  // Synchroniser les transactions hors-ligne
  async syncTransaction(transactionData) {
    return this.post('/sync', transactionData)
  }

  // Vérifier l'intégrité d'une transaction
  async verifyTransaction(id) {
    return this.get(`/${id}/verify`)
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
}

export const transactionService = new TransactionService()