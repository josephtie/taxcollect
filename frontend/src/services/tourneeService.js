import { BaseService } from './baseService'

/**
 * Service des tournées — mappé sur TourneeController
 * (backend : /api/taxcollect/tournee)
 */
class TourneeService extends BaseService {
  constructor() {
    super('/api/taxcollect/tournee')
  }

  // Lister toutes les tournées
  async getTournees() {
    return this.get('/')
  }

  // Détails d'une tournée
  async getTournee(id) {
    return this.get(`/${id}`)
  }

  // Tournées d'un agent
  async getTourneesByAgent(agentId) {
    return this.get(`/agent/${agentId}`)
  }

  // Tournées par date
  async getTourneesByDate(date) {
    return this.get(`/date/${date}`)
  }

  // Créer une tournée
  async createTournee(data) {
    return this.post('/', data)
  }

  // Mettre à jour une tournée
  async updateTournee(id, data) {
    return this.put(`/${id}`, data)
  }

  // Démarrer une tournée
  async demarrerTournee(id) {
    return this.post(`/${id}/demarrer`)
  }

  // Terminer une tournée
  async terminerTournee(id) {
    return this.post(`/${id}/terminer`)
  }

  // Supprimer une tournée
  async deleteTournee(id) {
    return this.delete(`/${id}`)
  }

  // Restaurer une tournée supprimée
  async restoreTournee(id) {
    return this.post(`/${id}/restore`)
  }
}

export const tourneeService = new TourneeService()
