import { BaseService } from './baseService'

/**
 * Service de synchronisation — mappé sur SyncItemController
 * (backend : /api/taxcollect/sync)
 */
class SyncService extends BaseService {
  constructor() {
    super('/api/taxcollect/sync')
  }

  // Items de synchronisation d'un agent
  async getSyncByAgent(agentId) {
    return this.get(`/agent/${agentId}`)
  }

  // Items par agent et statut
  async getSyncByAgentAndStatut(agentId, statut) {
    return this.get(`/agent/${agentId}/statut/${statut}`)
  }

  // Items par statut
  async getSyncByStatut(statut) {
    return this.get(`/statut/${statut}`)
  }

  // Compteur d'items en attente pour un agent
  async getPendingCount(agentId) {
    return this.get(`/agent/${agentId}/pending/count`)
  }

  // Détails d'un item
  async getSyncItem(id) {
    return this.get(`/${id}`)
  }

  // Créer un item de synchronisation
  async createSyncItem(data) {
    return this.post('/', data)
  }

  // Marquer un item comme synchronisé
  async markSynced(id) {
    return this.post(`/${id}/synced`)
  }

  // Marquer un item comme échoué
  async markFailed(id) {
    return this.post(`/${id}/failed`)
  }

  // Supprimer un item
  async deleteSyncItem(id) {
    return this.delete(`/${id}`)
  }
}

export const syncService = new SyncService()
