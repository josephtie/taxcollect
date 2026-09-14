import { BaseService } from './baseService'

/**
 * Service des promesses de paiement — mappé sur PromessePaiementController
 * (backend : /api/taxcollect/promesse)
 */
class PromesseService extends BaseService {
  constructor() {
    super('/api/taxcollect/promesse')
  }

  // Lister toutes les promesses
  async getPromesses() {
    return this.get('/')
  }

  // Détails d'une promesse
  async getPromesse(id) {
    return this.get(`/${id}`)
  }

  // Promesses d'un contribuable
  async getPromessesByContribuable(contribuableId) {
    return this.get(`/contribuable/${contribuableId}`)
  }

  // Promesses d'un agent
  async getPromessesByAgent(agentId) {
    return this.get(`/agent/${agentId}`)
  }

  // Échéances
  async getEcheances() {
    return this.get('/echeances')
  }

  // Créer une promesse
  async createPromesse(data) {
    return this.post('/', data)
  }

  // Mettre à jour une promesse
  async updatePromesse(id, data) {
    return this.put(`/${id}`, data)
  }

  // Relancer une promesse
  async relancerPromesse(id) {
    return this.post(`/${id}/relance`)
  }

  // Marquer une promesse comme honorée
  async honorerPromesse(id) {
    return this.post(`/${id}/honoree`)
  }

  // Supprimer une promesse
  async deletePromesse(id) {
    return this.delete(`/${id}`)
  }

  // Restaurer une promesse supprimée
  async restorePromesse(id) {
    return this.post(`/${id}/restore`)
  }
}

export const promesseService = new PromesseService()
