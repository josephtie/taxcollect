import { BaseService } from './baseService'

class SupervisionService extends BaseService {
  constructor() {
    super('/supervision')
  }

  // Récupérer les zones supervisées par l'utilisateur
  async getSupervisedZones() {
    return this.get('/zones')
  }

  // Récupérer les agents disponibles pour l'affectation
  async getAvailableAgents() {
    return this.get('/agents/available')
  }

  // Affecter un agent à une zone
  async assignAgentToZone(zoneId, agentId) {
    return this.post(`/assign-agent`, { zoneId, agentId })
  }

  // Retirer un agent d'une zone
  async unassignAgentFromZone(zoneId, agentId) {
    return this.delete(`/unassign-agent/${zoneId}/${agentId}`)
  }

  // Récupérer les performances des agents
  async getAgentPerformance(agentId, period = 'month') {
    return this.get(`/agents/${agentId}/performance?period=${period}`)
  }

  // Récupérer les statistiques de supervision
  async getSupervisionStats() {
    return this.get('/stats')
  }

  // Récupérer les rapports de supervision
  async getSupervisionReports(filters = {}) {
    return this.get('/reports', filters)
  }

  // Exporter les données de supervision
  async exportSupervisionData(format = 'json') {
    return this.get(`/export?format=${format}`)
  }

  // Valider les affectations
  async validateAssignments(assignments) {
    return this.post('/validate-assignments', { assignments })
  }

  // Récupérer l'historique des affectations
  async getAssignmentHistory(zoneId, agentId) {
    let url = '/assignment-history'
    if (zoneId) url += `?zoneId=${zoneId}`
    if (agentId) url += `${zoneId ? '&' : '?'}agentId=${agentId}`
    return this.get(url)
  }
}

export const supervisionService = new SupervisionService()
