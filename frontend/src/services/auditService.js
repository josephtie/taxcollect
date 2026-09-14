import { BaseService } from './baseService'

/**
 * Service d'audit — mappé sur AuditEntryController
 * (backend : /api/taxcollect/audit)
 */
class AuditService extends BaseService {
  constructor() {
    super('/api/taxcollect/audit')
  }

  // Entrées d'audit d'un agent
  async getAuditByAgent(agentId) {
    return this.get(`/agent/${agentId}`)
  }

  // Entrées d'audit d'un agent depuis une date
  async getAuditByAgentSince(agentId, since) {
    return this.get(`/agent/${agentId}/since`, { since })
  }

  // Détails d'une entrée
  async getAuditEntry(id) {
    return this.get(`/${id}`)
  }

  // Entrées en attente de synchronisation
  async getPendingSync() {
    return this.get('/pending-sync')
  }

  // Créer une entrée d'audit
  async createAuditEntry(data) {
    return this.post('/', data)
  }

  // Supprimer une entrée
  async deleteAuditEntry(id) {
    return this.delete(`/${id}`)
  }

  // Entrées par type d'entité
  async getAuditByEntity(entityType) {
    return this.get(`/entity/${entityType}`)
  }

  // Entrées par type d'entité et ID
  async getAuditByEntityId(entityType, entityId) {
    return this.get(`/entity/${entityType}/${entityId}`)
  }

  // Entrées par utilisateur
  async getAuditByUser(userId) {
    return this.get(`/user/${userId}`)
  }

  // Entrées par plage de dates
  async getAuditByDateRange(startDate, endDate) {
    return this.get('/date-range', { startDate, endDate })
  }

  // Entrées par zone
  async getAuditByZone(zoneId) {
    return this.get(`/zone/${zoneId}`)
  }

  // Entrées par quartier
  async getAuditByQuartier(quartierId) {
    return this.get(`/quartier/${quartierId}`)
  }

  // Entrées par type
  async getAuditByType(type) {
    return this.get(`/type/${type}`)
  }
}

export const auditService = new AuditService()
