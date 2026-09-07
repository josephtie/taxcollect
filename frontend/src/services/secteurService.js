import { BaseService } from './baseService'

class SecteurService extends BaseService {
  constructor() {
    super('/api/taxcollect/secteur')
  }

  async getAllSecteurs() {
    return this.get()
  }

  async getSecteurById(id) {
    return this.get(`/${id}`)
  }

  async createSecteur(secteurData) {
    return this.post('', secteurData)
  }

  async updateSecteur(id, secteurData) {
    return this.put(`/${id}`, secteurData)
  }

  async deleteSecteur(id) {
    return this.delete(`/${id}`)
  }

  async restoreSecteur(id) {
    return this.post(`/${id}/restore`)
  }

  async getAllSecteursIncludingDeleted() {
    return this.get('/including-deleted')
  }

  async getSecteursByQuartier(quartierId) {
    return this.get(`/quartier/${quartierId}`)
  }

  async locateByGps(lat, lng) {
    return this.get(`/locate?lat=${lat}&lng=${lng}`)
  }
}

export const secteurService = new SecteurService()
