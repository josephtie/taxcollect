import { BaseService } from './baseService'

/**
 * Service des signalements — mappé sur SignalementController
 * (backend : /api/taxcollect/signalement)
 *
 * Les "réclamations" côté frontend correspondent aux signalements côté backend.
 */
class SignalementService extends BaseService {
  constructor() {
    super('/api/taxcollect/signalement')
  }

  // Lister tous les signalements (filtrable par statut)
  async getSignalements(filters = {}) {
    return this.get('/', filters)
  }

  // Détails d'un signalement
  async getSignalement(id) {
    return this.get(`/${id}`)
  }

  // Signalements d'un agent
  async getSignalementsByAgent(agentId) {
    return this.get(`/agent/${agentId}`)
  }

  // Signalements par statut
  async getSignalementsByStatut(statut) {
    return this.get(`/statut/${statut}`)
  }

  // Créer un signalement
  async createSignalement(data) {
    return this.post('/', data)
  }

  // Traiter un signalement
  async traiterSignalement(id, data) {
    return this.post(`/${id}/traiter`, data)
  }

  // Supprimer un signalement
  async deleteSignalement(id) {
    return this.delete(`/${id}`)
  }
}

export const signalementService = new SignalementService()
