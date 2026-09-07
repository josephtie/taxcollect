import { BaseService } from './baseService'

class ContribuableService extends BaseService {
  constructor() {
    super('/api/taxcollect/contribuable')
  }

  // Récupérer tous les contribuables (avec pagination optionnelle)
  async getAllContribuables(params = {}) {
    if (params.page !== undefined || params.size !== undefined) {
      return this.get('/page', { page: params.page || 0, size: params.size || 20, ...params })
    }
    return this.get('/all')
  }

  // Récupérer un contribuable par ID
  async getContribuableById(id) {
    return this.get(`/${id}`)
  }

  // Récupérer les contribuables par zone
  async getContribuablesByZone(zoneId) {
    return this.get(`/zone/${zoneId}`)
  }

  // Créer un nouveau contribuable
  async createContribuable(contribuableData) {
    return this.post('', contribuableData)
  }

  // Mettre à jour un contribuable
  async updateContribuable(id, contribuableData) {
    return this.put(`/${id}`, contribuableData)
  }

  // Supprimer un contribuable
  async deleteContribuable(id) {
    return this.delete(`/${id}`)
  }

  // Récupérer les statistiques des contribuables
  async getContribuableStats() {
    return this.get('/stats')
  }

  // Exporter les contribuables
  async exportContribuables(filters = {}) {
    return this.get('/export', filters)
  }

  // Rechercher des contribuables
  async searchContribuables(query, filters = {}) {
    return this.get('/search', { searchTerm: query, ...filters })
  }
}

// Zones management
class ZoneService extends BaseService {
  constructor() {
    super('/api/taxcollect/zonecollect')
  }

  // Récupérer toutes les zones
  async getAllZones() {
    return this.get()
  }

  // Récupérer une zone par ID
  async getZoneById(id) {
    return this.get(`/${id}`)
  }

  // Créer une nouvelle zone
  async createZone(zoneData) {
    return this.post('', zoneData)
  }

  // Mettre à jour une zone
  async updateZone(id, zoneData) {
    return this.put(`/${id}`, zoneData)
  }

  // Supprimer une zone
  async deleteZone(id) {
    return this.delete(`/${id}`)
  }

  // Récupérer les contribuables d'une zone
  async getZoneContribuables(zoneId) {
    return this.get(`/${zoneId}/contribuables`)
  }

  // Récupérer les collecteurs d'une zone
  async getZoneCollecteurs(zoneId) {
    return this.get(`/${zoneId}/collecteurs`)
  }

  // Assigner un collecteur à une zone
  async assignCollecteurToZone(zoneId, collecteurId) {
    return this.post(`/${zoneId}/assign-collecteur`, { collecteurId })
  }

  // Désassigner un collecteur d'une zone
  async unassignCollecteurFromZone(zoneId, collecteurId) {
    return this.delete(`/${zoneId}/collecteur/${collecteurId}`)
  }

  // Récupérer les statistiques d'une zone
  async getZoneStats(zoneId) {
    return this.get(`/${zoneId}/stats`)
  }

  // Exporter les données d'une zone
  async exportZoneData(zoneId, format = 'json') {
    return this.get(`/${zoneId}/export?format=${format}`)
  }
}

export const contribuableService = new ContribuableService()
export const zoneService = new ZoneService()
