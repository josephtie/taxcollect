import api from './api'
import { permissionService } from './permissionService'

export const authService = {
  // URL de l'API backend (via proxy Nginx)
  apiUrl: import.meta.env.VITE_API_URL || '',

  // Connexion via l'API backend (qui communique avec Keycloak)
  async login(username, password) {
    try {
      console.log('Tentative de connexion vers:', `${this.apiUrl}/auth/login`)
      
      const response = await fetch(`${this.apiUrl}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          username: username,
          password: password
        })
      })

      console.log('Response status:', response.status)
      console.log('Response headers:', response.headers)

      if (!response.ok) {
        // Gérer les erreurs HTTP
        const errorText = await response.text()
        console.error('Erreur HTTP:', response.status, errorText)
        
        let errorMessage = 'Identifiants invalides'
        try {
          const errorData = JSON.parse(errorText)
          errorMessage = errorData.error || errorData.message || errorMessage
        } catch (parseError) {
          console.error('Erreur parsing JSON:', parseError)
          errorMessage = `Erreur serveur: ${response.status}`
        }
        
        throw new Error(errorMessage)
      }

      // Vérifier si la réponse contient du contenu
      const responseText = await response.text()
      console.log('Response text:', responseText)
      
      if (!responseText) {
        throw new Error('Réponse vide du serveur')
      }
      
      let data
      try {
        data = JSON.parse(responseText)
      } catch (parseError) {
        console.error('Erreur parsing JSON response:', parseError)
        throw new Error('Réponse invalide du serveur')
      }
      
      console.log('Parsed data:', data)
      
      // Stocker le token
      if (data.access_token) {
        localStorage.setItem('authToken', data.access_token)
        if (data.refresh_token) {
          localStorage.setItem('refreshToken', data.refresh_token)
        }
        
        // Récupérer les infos utilisateur depuis le token JWT
        const userInfo = this.parseJWT(data.access_token)
        console.log('UserInfo parsed:', userInfo)
        localStorage.setItem('user', JSON.stringify(userInfo))
        
        // Initialiser les permissions basées sur le rôle
        permissionService.init(userInfo)
        console.log('Permissions initialisées:', permissionService.userPermissions)
        
        return { success: true, user: userInfo }
      } else {
        throw new Error('Token non trouvé dans la réponse')
      }
    } catch (error) {
      console.error('Erreur de connexion:', error)
      return { success: false, error: error.message }
    }
  },

  // Parser le token JWT pour extraire les infos utilisateur
  parseJWT(token) {
    try {
      const base64Url = token.split('.')[1]
      const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
      const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
      }).join(''))
      
      const payload = JSON.parse(jsonPayload)
      return {
        username: payload.preferred_username || payload.sub,
        email: payload.email,
        nom: payload.family_name || payload.given_name || '',
        prenom: payload.given_name || '',
        role: this.extractRoleFromToken(payload)
      }
    } catch (error) {
      console.error('Erreur parsing JWT:', error)
      return {
        username: 'Unknown',
        email: '',
        nom: '',
        prenom: '',
        role: 'USER'
      }
    }
  },

  // Extraire le rôle depuis le token
  extractRoleFromToken(payload) {
    console.log('Payload JWT:', payload)
    
    // Ordre de priorité des rôles métier. Doit rester aligné sur les rôles du realm
    // Keycloak (realm-mairie.json) et sur JwtAuthConverter côté backend.
    const ROLE_PRIORITY = [
      'ADMIN',
      'SUPERVISEUR',
      'TRESOR',
      'RESPONSABLE_QUARTIER',
      'AGENT',
      'CONTRIBUABLE'
    ]

    // Le backend lit realm_access.roles : on le privilégie pour rester cohérent,
    // avec resource_access['tax-backend'] en repli.
    const realmRoles = payload.realm_access?.roles || []
    const clientRoles = payload.resource_access?.['tax-backend']?.roles || []
    const roles = [...realmRoles, ...clientRoles]
    console.log('Roles from token:', roles)

    const role = ROLE_PRIORITY.find(r => roles.includes(r)) || 'USER'
    console.log('Role determined:', role)
    return role
  },

  // Récupérer l'utilisateur courant depuis le stockage local
  getCurrentUser() {
    try {
      const raw = localStorage.getItem('user')
      return raw ? JSON.parse(raw) : null
    } catch (error) {
      console.error('Erreur lecture utilisateur courant:', error)
      return null
    }
  },

  // Déconnexion
  logout() {
    localStorage.removeItem('authToken')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('user')
    permissionService.reset()
    window.location.href = '/login'
  },

  // Vérifier si l'utilisateur est connecté
  isAuthenticated() {
    return !!localStorage.getItem('authToken')
  },

  // Obtenir le token actuel
  getToken() {
    return localStorage.getItem('authToken')
  },

  // Rafraîchir le token via /auth/refresh (échange refresh_token côté Keycloak)
  async refreshToken() {
    const refreshToken = localStorage.getItem('refreshToken')
    if (!refreshToken) {
      this.logout()
      return null
    }

    try {
      const response = await fetch(`${this.apiUrl}/auth/refresh`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ refresh_token: refreshToken })
      })

      if (!response.ok) {
        this.logout()
        return null
      }

      const data = await response.json()
      if (!data.access_token) {
        this.logout()
        return null
      }

      localStorage.setItem('authToken', data.access_token)
      if (data.refresh_token) {
        localStorage.setItem('refreshToken', data.refresh_token)
      }

      const userInfo = this.parseJWT(data.access_token)
      localStorage.setItem('user', JSON.stringify(userInfo))
      permissionService.init(userInfo)

      return data.access_token
    } catch (error) {
      console.error('Erreur rafraîchissement du token:', error)
      this.logout()
      return null
    }
  }
}
