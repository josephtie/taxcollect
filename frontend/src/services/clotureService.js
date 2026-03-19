import { BaseService } from './baseService'

class ClotureService extends BaseService {
  constructor() {
    super('/api/cloture-caisse')
  }

  // Récupérer toutes les clôtures (paginé)
  async getAllClotures(page = 0, size = 20, sort = 'dateCloture,desc') {
    try {
      const response = await this.get('', {
        params: { page, size, sort }
      })
      return response.data
    } catch (error) {
      console.error('GET /cloture-caisse error:', error)
      throw error
    }
  }

  // Récupérer toutes les clôtures (non paginé - pour compatibilité)
  async getAllCloturesLegacy() {
    try {
      const response = await this.get('')
      return response.data
    } catch (error) {
      console.error('GET /cloture-caisse error:', error)
      throw error
    }
  }

  // Récupérer une clôture par ID
  async getClotureById(id) {
    return this.get(`/${id}`)
  }

  // Récupérer les clôtures par statut
  async getCloturesByStatus(status) {
    return this.get(`/statut/${status}`)
  }

  // Récupérer les clôtures par période
  async getCloturesByDateRange(startDate, endDate) {
    return this.get('/range', {
      debut: startDate.toISOString().split('T')[0],
      fin: endDate.toISOString().split('T')[0]
    })
  }

  // Initier une clôture de caisse
  async initiateCloture(agentId, dateCloture) {
    return this.post('/initier', null, {
      agentId,
      dateCloture: dateCloture.toISOString().split('T')[0]
    })
  }

  // Soumettre une clôture de caisse
  async submitCloture(clotureId, montantDeclare, commentaireAgent) {
    return this.post(`/${clotureId}/soumettre`, null, {
      montantDeclare,
      commentaireAgent
    })
  }

  // Valider une clôture de caisse
  async validateCloture(clotureId, valideParId, commentaireTresor) {
    return this.post(`/${clotureId}/valider`, null, {
      valideParId,
      commentaireTresor
    })
  }

  // Rejeter une clôture de caisse
  async rejectCloture(clotureId, valideParId, commentaireTresor) {
    return this.post(`/${clotureId}/rejeter`, null, {
      valideParId,
      commentaireTresor
    })
  }

  // Confirmer le dépôt bancaire
  async confirmDeposit(clotureId, montantDepose, referenceDepot) {
    return this.post(`/${clotureId}/confirmer-depot`, null, {
      montantDepose,
      referenceDepot
    })
  }

  // Récupérer les clôtures par agent et date
  async getClotureByAgentAndDate(agentId, date) {
    return this.get('/agent-date', {
      agentId,
      date: date.toISOString().split('T')[0]
    })
  }

  // Récupérer les clôtures d'un agent
  async getCloturesByAgent(agentId) {
    return this.get(`/agent/${agentId}`)
  }

  // Récupérer les statistiques de clôtures
  async getClotureStats(startDate, endDate) {
    return this.get('/stats', {
      debut: startDate?.toISOString().split('T')[0],
      fin: endDate?.toISOString().split('T')[0]
    })
  }

  // Exporter les bordereaux de reversement
  async exportDeposits(startDate, endDate, format = 'PDF') {
    return this.get('/export', {
      debut: startDate.toISOString().split('T')[0],
      fin: endDate.toISOString().split('T')[0],
      format
    })
  }
}

export const clotureService = new ClotureService()
