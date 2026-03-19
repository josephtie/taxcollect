import { BaseService } from './baseService'

class AgentService extends BaseService {
  constructor() {
    super('/api/taxcollect/agent')
  }

  // Récupérer tous les agents (paginé)
  async getAllAgents(page = 0, size = 20, sort = 'nom,asc') {
    try {
      const response = await this.get(`/page?page=${page}&size=${size}&sort=${sort}`)
      return response.data
    } catch (error) {
      console.error('GET /agents/page error:', error)
      throw error
    }
  }

  // Récupérer tous les agents (non paginé - pour compatibilité)
  async getAllAgentsLegacy() {
    try {
      const response = await this.get('/all')
      return response.data
    } catch (error) {
      console.error('GET /agents/all error:', error)
      throw error
    }
  }

  // Récupérer un agent par ID
  async getAgentById(id) {
    return this.get(`/${id}`)
  }

  // Créer un nouvel agent
  async createAgent(agentData) {
    return this.post('', agentData)
  }

  // Mettre à jour un agent
  async updateAgent(id, agentData) {
    return this.put(`/${id}`, agentData)
  }

  // Supprimer un agent
  async deleteAgent(id) {
    return this.delete(`/${id}`)
  }

  // Récupérer les agents par zone
  async getAgentsByZone(zoneId) {
    return this.get(`/zone/${zoneId}`)
  }

  // Mettre à jour le statut d'un agent
  async updateAgentStatus(id, status) {
    return this.put(`/${id}/status`, null, { status })
  }

  // Récupérer les statistiques d'un agent
  async getAgentStats(id, startDate, endDate) {
    return this.get(`/${id}/stats`, {
      debut: startDate?.toISOString(),
      fin: endDate?.toISOString()
    })
  }

  // Récupérer les transactions d'un agent
  async getAgentTransactions(id, startDate, endDate) {
    return this.get(`/${id}/transactions`, {
      debut: startDate?.toISOString(),
      fin: endDate?.toISOString()
    })
  }

  // Assigner une zone à un agent
  async assignZoneToAgent(agentId, zoneId) {
    return this.post(`/${agentId}/zones/${zoneId}`)
  }

  // Retirer une zone à un agent
  async removeZoneFromAgent(agentId, zoneId) {
    return this.delete(`/${agentId}/zones/${zoneId}`)
  }

  // Récupérer les agents actifs
  async getActiveAgents() {
    return this.get('/active')
  }

  // Rechercher des agents
  async searchAgents(searchTerm, filters = {}) {
    return this.get('/search', {
      search: searchTerm,
      ...filters
    })
  }
}

export const agentService = new AgentService()