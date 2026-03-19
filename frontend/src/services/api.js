import axios from 'axios'

// Configuration de base d'Axios
const api = axios.create({
  baseURL: 'http://localhost:9090',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Intercepteur pour les requêtes
api.interceptors.request.use(
  (config) => {
    // Ajouter le token d'authentification si disponible
    const token = localStorage.getItem('authToken')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Intercepteur pour les réponses
api.interceptors.response.use(
  (response) => {
    return response
  },
  async (error) => {
    const originalRequest = error.config

    // Si erreur 401 et qu'on n'a pas déjà essayé de rafraîchir le token
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true

      try {
        // Importer authService dynamiquement pour éviter les dépendances circulaires
        const { authService } = await import('./authService')
        const newToken = await authService.refreshToken()
        
        if (newToken) {
          // Mettre à jour le header de la requête originale
          originalRequest.headers.Authorization = `Bearer ${newToken}`
          // Relancer la requête avec le nouveau token
          return api(originalRequest)
        }
      } catch (refreshError) {
        console.error('Erreur refresh token:', refreshError)
        // Rediriger vers login si le refresh échoue
        localStorage.removeItem('authToken')
        localStorage.removeItem('refreshToken')
        window.location.href = '/login'
      }
    }
    
    // Gérer les autres erreurs
    if (error.response?.status === 401) {
      // Rediriger vers la page de connexion
      localStorage.removeItem('authToken')
      localStorage.removeItem('refreshToken')
      window.location.href = '/login'
    }
    
    // Propager l'erreur avec un message formaté
    const errorMessage = error.response?.data?.message || error.message || 'Une erreur est survenue'
    error.userMessage = errorMessage
    
    return Promise.reject(error)
  }
)

export default api
