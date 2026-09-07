import { BaseService } from './baseService'

class SupervisionService extends BaseService {
  constructor() {
    super('/api/taxcollect/supervision')
  }

  // Récupérer les zones supervisées par l'utilisateur courant
  async getSupervisedZones() {
    return this.get('/zones/supervised')
  }

  // Récupérer les agents disponibles pour l'affectation
  async getAvailableAgents() {
    return this.get('/agents/available')
  }

  // Affecter un agent à une zone
  async assignAgentToZone(zoneId, agentId) {
    return this.post('/assign-agent', { zoneId, agentId })
  }

  // Retirer un agent d'une zone
  async unassignAgentFromZone(zoneId, agentId) {
    return this.delete(`/unassign-agent/${zoneId}/${agentId}`)
  }

  // Récupérer les zones non assignées au superviseur courant
  async getUnassignedZones() {
    return this.get('/zones/unassigned')
  }

  // Affecter une zone à un superviseur (ADMIN)
  async assignZoneToSuperviseur(zoneId, superviseurId) {
    return this.post(`/zones/${zoneId}/assign-superviseur`, { superviseurId })
  }
}

export const supervisionService = new SupervisionService()
