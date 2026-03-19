import { BaseService } from './baseService'

class TaxeService extends BaseService {
  constructor() {
    super('/api/taxcollect/taxe')
  }

  // Récupérer toutes les taxes
  async getAllTaxes() {
    return this.get()
  }

  // Récupérer les taxes avec pagination
  async getTaxesPageable(page = 0, size = 20, sort = 'nom', direction = 'asc') {
    return this.get(`/page?page=${page}&size=${size}&sort=${sort},${direction}`)
  }

  // Récupérer une taxe par ID
  async getTaxeById(id) {
    return this.get(`/${id}`)
  }

  // Créer une nouvelle taxe
  async createTaxe(taxeData) {
    return this.post('', taxeData)
  }

  // Mettre à jour une taxe
  async updateTaxe(id, taxeData) {
    return this.put(`/${id}`, taxeData)
  }

  // Supprimer une taxe
  async deleteTaxe(id) {
    return this.delete(`/${id}`)
  }

  // Restaurer une taxe supprimée
  async restoreTaxe(id) {
    return this.post(`/${id}/restore`)
  }

  // Récupérer toutes les taxes y compris les supprimées
  async getAllTaxesIncludingDeleted() {
    return this.get('/including-deleted')
  }

  // Filtrer les taxes
  async filterTaxes(filters, page = 0, size = 20) {
    const params = new URLSearchParams()
    Object.entries(filters).forEach(([key, value]) => {
      if (value) params.append(key, value)
    })
    params.append('page', page)
    params.append('size', size)
    
    return this.get(`/filter?${params.toString()}`)
  }

  // Récupérer les statistiques des taxes
  async getTaxeStats() {
    return this.get('/stats')
  }

  // Exporter les taxes
  async exportTaxes(format = 'json') {
    return this.get(`/export?format=${format}`)
  }

  // Valider une taxe
  async validateTaxe(id) {
    return this.post(`/${id}/validate`)
  }

  // Désactiver une taxe
  async deactivateTaxe(id) {
    return this.post(`/${id}/deactivate`)
  }

  // Activer une taxe
  async activateTaxe(id) {
    return this.post(`/${id}/activate`)
  }
}

export const taxeService = new TaxeService()
