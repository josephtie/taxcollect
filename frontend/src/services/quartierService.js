import { BaseService } from './baseService'

class QuartierService extends BaseService {
  constructor() {
    super('/api/taxcollect/quartier')
  }

  // Récupérer tous les quartiers
  async getAllQuartiers() {
    return this.get()
  }

  // Récupérer un quartier par ID
  async getQuartierById(id) {
    return this.get(`/${id}`)
  }

  // Créer un nouveau quartier
  async createQuartier(quartierData) {
    return this.post('', quartierData)
  }

  // Mettre à jour un quartier
  async updateQuartier(id, quartierData) {
    return this.put(`/${id}`, quartierData)
  }

  // Supprimer un quartier
  async deleteQuartier(id) {
    return this.delete(`/${id}`)
  }

  // Restaurer un quartier supprimé
  async restoreQuartier(id) {
    return this.post(`/${id}/restore`)
  }

  // Récupérer tous les quartiers y compris les supprimés
  async getAllQuartiersIncludingDeleted() {
    return this.get('/including-deleted')
  }

  // Récupérer les secteurs d'un quartier
  async getQuartierSecteurs(quartierId) {
    return this.get(`/${quartierId}/secteurs`)
  }

  // Récupérer les quartiers par zone
  async getQuartiersByZone(zoneId) {
    return this.get(`/zone/${zoneId}`)
  }
}

class CommuneService extends BaseService {
  constructor() {
    super('/api/taxcollect/commune')
  }

  // Récupérer toutes les communes
  async getAllCommunes() {
    return this.get()
  }

  // Récupérer une commune par ID
  async getCommuneById(id) {
    return this.get(`/${id}`)
  }

  // Créer une nouvelle commune
  async createCommune(communeData) {
    return this.post('', communeData)
  }

  // Mettre à jour une commune
  async updateCommune(id, communeData) {
    return this.put(`/${id}`, communeData)
  }

  // Supprimer une commune
  async deleteCommune(id) {
    return this.delete(`/${id}`)
  }

  // Récupérer les zones d'une commune
  async getCommuneZones(communeId) {
    return this.get(`/${communeId}/zones`)
  }
}

export const quartierService = new QuartierService()
export const communeService = new CommuneService()
