import { BaseService } from './baseService'

class AffectationService extends BaseService {
  constructor() {
    super('/api/taxcollect/affectation')
  }

  async assign(agentId, territoryType, territoryId) {
    return this.post(`/assign?agentId=${agentId}&territoryType=${territoryType}&territoryId=${territoryId}`)
  }

  async unassign(agentId, territoryType, territoryId) {
    return this.delete(`/unassign?agentId=${agentId}&territoryType=${territoryType}&territoryId=${territoryId}`)
  }

  async getByTerritory(territoryType, territoryId) {
    return this.get(`/territory?territoryType=${territoryType}&territoryId=${territoryId}`)
  }

  async getByAgent(agentId) {
    return this.get(`/agent/${agentId}`)
  }

  async getEffectivePerimeter(agentId) {
    return this.get(`/agent/${agentId}/perimeter`)
  }
}

export const affectationService = new AffectationService()
