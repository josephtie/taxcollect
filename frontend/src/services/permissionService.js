// Définition des permissions par rôle
export const ROLE_PERMISSIONS = {
  ADMIN: [
    'dashboard.view',
    'agents.view',
    'agents.create',
    'agents.edit',
    'agents.delete',
    'zones.view',
    'zones.create',
    'zones.edit',
    'zones.delete',
    'transactions.view',
    'transactions.create',
    'transactions.edit',
    'transactions.delete',
    'cloture.view',
    'cloture.create',
    'cloture.edit',
    'cloture.delete',
    'supervision.view',
    'supervision.assign',
    'supervision.unassign',
    'taxes.view',
    'taxes.create',
    'taxes.edit',
    'taxes.delete',
    'settings.view',
    'settings.manage',
    'reports.view',
    'reports.export',
    'payments.view',
    'payments.create',
    'payments.cancel',
    'payments.refund',
    'collection-orders.view',
    'collection-orders.create',
    'qr.generate',
    'qr.view',
    'receipts.view',
    'receipts.download',
    'reconciliation.view',
    'reconciliation.manage',
    'assessments.view',
    'assessments.generate',
    'assessments.manage'
  ],
  SUPERVISEUR: [
    'dashboard.view',
    'agents.view',
    'agents.assign',
    'agents.unassign',
    'zones.view',
    'zones.supervise',
    'transactions.view',
    'transactions.supervise',
    'cloture.view',
    'cloture.supervise',
    'supervision.view',
    'supervision.assign',
    'supervision.unassign',
    'taxes.view',
    'reports.view',
    'reports.export',
    'payments.view',
    'collection-orders.view',
    'receipts.view',
    'reconciliation.view'
  ],
  TRESOR: [
    'dashboard.view',
    'transactions.view',
    'transactions.validate',
    'cloture.view',
    'cloture.validate',
    'taxes.view',
    'reports.view',
    'reports.export',
    'payments.view',
    'payments.create',
    'payments.cancel',
    'payments.refund',
    'collection-orders.view',
    'collection-orders.create',
    'receipts.view',
    'receipts.download',
    'reconciliation.view',
    'reconciliation.manage',
    'assessments.view',
    'assessments.generate',
    'assessments.manage'
  ],
  AGENT: [
    'dashboard.view',
    'transactions.create',
    'transactions.edit',
    'profile.view',
    'profile.edit',
    'payments.view',
    'payments.create',
    'collection-orders.view',
    'collection-orders.create',
    'qr.generate',
    'qr.view',
    'receipts.view',
    'receipts.download',
    'assessments.view'
  ],
  CONTRIBUABLE: [
    'payments.view',
    'payments.create',
    'collection-orders.view',
    'qr.view',
    'receipts.view',
    'receipts.download',
    'profile.view',
    'profile.edit'
  ]
}

export class PermissionService {
  constructor() {
    this.userPermissions = []
    this.userRole = null
  }

  // Initialiser les permissions de l'utilisateur
  init(user) {
    this.userRole = user.role
    this.userPermissions = ROLE_PERMISSIONS[this.userRole] || []
  }

  // Vérifier si l'utilisateur a une permission spécifique
  hasPermission(permission) {
    return this.userPermissions.includes(permission)
  }

  // Vérifier si l'utilisateur a une des permissions requises
  hasAnyPermission(permissions) {
    return permissions.some(permission => this.userPermissions.includes(permission))
  }

  // Vérifier si l'utilisateur a toutes les permissions requises
  hasAllPermissions(permissions) {
    return permissions.every(permission => this.userPermissions.includes(permission))
  }

  // Obtenir les permissions de l'utilisateur
  getUserPermissions() {
    return this.userPermissions
  }

  // Obtenir le rôle de l'utilisateur
  getRole() {
    return this.userRole
  }

  // Vérifier si l'utilisateur est admin
  isAdmin() {
    return this.userRole === 'ADMIN'
  }

  // Vérifier si l'utilisateur est trésor
  isTresor() {
    return this.userRole === 'TRESOR'
  }

  // Vérifier si l'utilisateur est agent
  isAgent() {
    return this.userRole === 'AGENT'
  }

  // Vérifier si l'utilisateur est superviseur
  isSuperviseur() {
    return this.userRole === 'SUPERVISEUR'
  }

  // Vérifier si l'utilisateur est contribuable
  isContribuable() {
    return this.userRole === 'CONTRIBUABLE'
  }

  // Obtenir les permissions disponibles pour le rôle
  getAvailablePermissions(role) {
    return ROLE_PERMISSIONS[role] || []
  }

  // Réinitialiser les permissions (déconnexion)
  reset() {
    this.userPermissions = []
    this.userRole = null
  }
}

export const permissionService = new PermissionService()
