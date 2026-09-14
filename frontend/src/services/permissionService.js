// Définition des permissions par rôle
// Chaîne hiérarchique à 4 niveaux opérationnels :
//   AGENT = collecte | RESPONSABLE_QUARTIER = management terrain | SUPERVISEUR = pilotage zone | TRESOR = validation financière
// Le SUPERVISEUR n'a JAMAIS de permissions de validation financière (payments.validate/reject/cancel/refund).
// Le RESPONSABLE_QUARTIER ne voit QUE son quartier (scope territorial quartier_id).
// Le SUPERVISEUR ne voit QUE sa zone (scope territorial zone_id).
export const ROLE_PERMISSIONS = {
  ADMIN: [
    'dashboard.view',
    'agents.view',
    'agents.create',
    'agents.edit',
    'agents.delete',
    'agents.assign',
    'agents.unassign',
    'agents.suspend',
    'zones.view',
    'zones.create',
    'zones.edit',
    'zones.delete',
    'zones.supervise',
    'transactions.view',
    'transactions.create',
    'transactions.edit',
    'transactions.delete',
    'transactions.supervise',
    'transactions.validate',
    'cloture.view',
    'cloture.create',
    'cloture.edit',
    'cloture.delete',
    'cloture.validate',
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
    'payments.validate',
    'payments.reject',
    'payments.field_check',
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
    'assessments.manage',
    'assessments.validate',
    'contribuables.validate',
    'anomalies.view',
    'anomalies.manage',
    'tournees.view',
    'tournees.manage',
    'recouvrement.view',
    'recouvrement.manage',
    'promesses.view',
    'promesses.manage',
    'reclamations.view',
    'reclamations.manage',
    'audit.view',
    'sync.view',
    'sync.manage',
    // Gestion des responsables de quartier
    'quartiers.assign_responsable',
    'quartiers.view_responsables'
  ],
  SUPERVISEUR: [
    // Tableau de bord & vues générales
    'dashboard.view',
    'taxes.view',
    'reports.view',
    'reports.export',
    // Agents : contrôle opérationnel (pas de création/suppression)
    'agents.view',
    'agents.assign',
    'agents.unassign',
    'agents.suspend',
    // Zones : supervision (pas de création/modification/suppression)
    'zones.view',
    'zones.supervise',
    // Supervision & affectation
    'supervision.view',
    'supervision.assign',
    'supervision.unassign',
    // Transactions : vue & supervision (PAS de validation financière)
    'transactions.view',
    'transactions.supervise',
    'cloture.view',
    'cloture.supervise',
    // Paiements : vue & contrôle opérationnel uniquement (PAS de validation/rejet/annulation)
    'payments.view',
    'payments.field_check',
    'collection-orders.view',
    'receipts.view',
    'reconciliation.view',
    // Contribuables & évaluations : validation opérationnelle
    'contribuables.validate',
    'assessments.view',
    'assessments.validate',
    // Modules superviseur
    'anomalies.view',
    'anomalies.manage',
    'tournees.view',
    'tournees.manage',
    'recouvrement.view',
    'recouvrement.manage',
    'promesses.view',
    'promesses.manage',
    'reclamations.view',
    'reclamations.manage',
    'audit.view',
    'sync.view',
    'sync.manage',
    // Gestion des responsables de quartier (affectation responsable → quartier)
    'quartiers.assign_responsable',
    'quartiers.view_responsables'
  ],
  RESPONSABLE_QUARTIER: [
    // Tableau de bord du quartier
    'dashboard.view',
    // Vue limitée au quartier (scope territorial quartier_id)
    'quartiers.view',
    'secteurs.view',
    // Agents du quartier : suivi + proposition d'affectation (validation par superviseur)
    'agents.view',
    'agents.propose_assignment',
    'agents.supervise',
    // Contribuables du quartier : consultation uniquement (pas de suppression)
    'contribuables.view',
    // Visites terrain : suivi quotidien
    'visites.view',
    // Collectes : contrôle opérationnel (PAS de modification financière)
    'payments.view',
    'transactions.view',
    'collection-orders.view',
    // Anomalies : créer, documenter, suivre, transmettre au superviseur
    'anomalies.view',
    'anomalies.create',
    'anomalies.manage',
    'anomalies.escalate',
    // Taxes : consultation
    'taxes.view',
    // Rapports : quartier uniquement
    'reports.view',
    'reports.export'
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
    // Validation financière des paiements (réservé au Trésor)
    'payments.view',
    'payments.create',
    'payments.validate',
    'payments.reject',
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

  // Vérifier si l'utilisateur est responsable de quartier
  isResponsable() {
    return this.userRole === 'RESPONSABLE_QUARTIER'
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
