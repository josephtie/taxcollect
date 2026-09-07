import { BaseService } from './baseService'

class UserService extends BaseService {
  constructor() {
    super('/api/users')
  }

  // Créer un nouvel utilisateur
  async createUser(userData) {
    return this.post('', userData)
  }

  // Récupérer tous les utilisateurs
  async getAllUsers() {
    return this.get()
  }

  // Récupérer un utilisateur par ID
  async getUserById(id) {
    return this.get(`/${id}`)
  }

  // Mettre à jour un utilisateur
  async updateUser(id, userData) {
    return this.put(`/${id}`, userData)
  }

  // Supprimer un utilisateur
  async deleteUser(id) {
    return this.delete(`/${id}`)
  }

  // Mettre à jour le mot de passe d'un utilisateur
  async updatePassword(id, passwordData) {
    return this.put(`/${id}/password`, passwordData)
  }

  // Activer/désactiver un utilisateur
  async toggleUserStatus(id, active) {
    return this.put(`/${id}/status`, null, { active })
  }

  // Assigner des rôles à un utilisateur
  async assignRoles(userId, roles) {
    return this.post(`/${userId}/roles`, { roles })
  }

  // Révoquer des rôles à un utilisateur
  async revokeRoles(userId, roles) {
    return this.delete(`/${userId}/roles`, { roles })
  }

  // Récupérer les rôles d'un utilisateur
  async getUserRoles(userId) {
    return this.get(`/${userId}/roles`)
  }

  // Réinitialiser le mot de passe
  async resetPassword(email) {
    return this.post('/reset-password', { email })
  }

  // Vérifier si un nom d'utilisateur est disponible
  async checkUsernameAvailability(username) {
    return this.get(`/check-username/${username}`)
  }

  // Vérifier si un email est disponible
  async checkEmailAvailability(email) {
    return this.get(`/check-email/${email}`)
  }

  // Récupérer les utilisateurs par rôle
  async getUsersByRole(role) {
    return this.get(`/role/${role}`)
  }

  // Rechercher des utilisateurs
  async searchUsers(searchTerm, filters = {}) {
    return this.get('/search', {
      search: searchTerm,
      ...filters
    })
  }

  // Récupérer les sessions d'un utilisateur
  async getUserSessions(userId) {
    return this.get(`/${userId}/sessions`)
  }
}

export const userService = new UserService()
