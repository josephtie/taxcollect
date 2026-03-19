import { BaseService } from './baseService'

class ZoneService extends BaseService {
  constructor() {
    super('/api/taxcollect/zone')
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

  // Restaurer une zone supprimée
  async restoreZone(id) {
    return this.post(`/${id}/restore`)
  }

  // Récupérer toutes les zones y compris les supprimées
  async getAllZonesIncludingDeleted() {
    return this.get('/including-deleted')
  }

  // Récupérer les zones d'un quartier
  async getQuartierZones(quartierId) {
    return this.get(`/quartier/${quartierId}`)
  }

  // Rechercher des zones
  async searchZones(searchTerm, filters = {}) {
    const params = new URLSearchParams()
    if (searchTerm) params.append('search', searchTerm)
    Object.keys(filters).forEach(key => {
      if (filters[key]) params.append(key, filters[key])
    })
    return this.get(`/search?${params.toString()}`)
  }
}

export const zoneService = new ZoneService()
