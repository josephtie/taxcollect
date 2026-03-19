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

  // Récupérer les zones d'un quartier
  async getQuartierZones(quartierId) {
    return this.get(`/${quartierId}/zones`)
  }

  // Récupérer les quartiers par commune
  async getQuartiersByCommune(communeId) {
    return this.get(`/commune/${communeId}`)
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

  // Récupérer les quartiers d'une commune
  async getCommuneQuartiers(communeId) {
    return this.get(`/${communeId}/quartiers`)
  }
}

export const quartierService = new QuartierService()
export const communeService = new CommuneService()
