import api from './api'

export class BaseService {
  constructor(baseUrl) {
    this.baseUrl = baseUrl
  }

  // Méthode GET générique
  async get(endpoint = '', params = {}) {
    try {
      const response = await api.get(`${this.baseUrl}${endpoint}`, { params })
      return response
    } catch (error) {
      console.error(`GET ${this.baseUrl}${endpoint} error:`, error)
      throw error
    }
  }

  // Méthode POST générique
  async post(endpoint = '', data = {}, params = {}) {
    try {
      const response = await api.post(`${this.baseUrl}${endpoint}`, data, { params })
      return response
    } catch (error) {
      console.error(`POST ${this.baseUrl}${endpoint} error:`, error)
      throw error
    }
  }

  // Méthode PUT générique
  async put(endpoint = '', data = {}, params = {}) {
    try {
      const response = await api.put(`${this.baseUrl}${endpoint}`, data, { params })
      return response
    } catch (error) {
      console.error(`PUT ${this.baseUrl}${endpoint} error:`, error)
      throw error
    }
  }

  // Méthode DELETE générique
  async delete(endpoint = '', params = {}) {
    try {
      const response = await api.delete(`${this.baseUrl}${endpoint}`, { params })
      return response
    } catch (error) {
      console.error(`DELETE ${this.baseUrl}${endpoint} error:`, error)
      throw error
    }
  }

  // Méthode pour uploader des fichiers
  async upload(endpoint = '', formData = {}) {
    try {
      const response = await api.post(`${this.baseUrl}${endpoint}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })
      return response
    } catch (error) {
      console.error(`UPLOAD ${this.baseUrl}${endpoint} error:`, error)
      throw error
    }
  }

  // Méthode pour télécharger des fichiers
  async download(endpoint = '', params = {}) {
    try {
      const response = await api.get(`${this.baseUrl}${endpoint}`, { 
        params,
        responseType: 'blob'
      })
      return response
    } catch (error) {
      console.error(`DOWNLOAD ${this.baseUrl}${endpoint} error:`, error)
      throw error
    }
  }
}
