import { BaseService } from './baseService'

/**
 * Service de supervision des zones — E-CollecteTaxe
 *
 * Chaîne de contrôle à 3 niveaux :
 *   AGENT = collecte | SUPERVISEUR = contrôle opérationnel | TRESOR = validation financière
 *
 * Ce service ne contient AUCUNE méthode de validation financière.
 * Le superviseur peut : voir, contrôler, signaler, demander justification, transmettre au Trésor.
 * Le superviseur ne peut PAS : valider/rejeter/annuler un paiement, modifier un montant, émettre un reçu définitif.
 *
 * Toutes les routes ci-dessous sont implémentées par SupervisionController
 * (backend : /api/taxcollect/supervision).
 */
class SupervisionService extends BaseService {
  constructor() {
    super('/api/taxcollect/supervision')
  }

  // ─── Zones supervisées ─────────────────────────────────────────

  // Récupérer les zones supervisées par l'utilisateur courant
  async getSupervisedZones() {
    return this.get('/zones/supervised')
  }

  // Récupérer les zones non assignées au superviseur courant
  async getUnassignedZones() {
    return this.get('/zones/unassigned')
  }

  // Affecter une zone à un superviseur (ADMIN)
  async assignZoneToSuperviseur(zoneId, superviseurId) {
    return this.post(`/zones/${zoneId}/assign-superviseur`, { superviseurId })
  }

  // ─── Données de la zone du superviseur ─────────────────────────

  // Récupérer les contribuables des zones du superviseur connecté
  async getMyZoneContribuables() {
    return this.get('/my-zone/contribuables')
  }

  // Récupérer les collecteurs des zones du superviseur connecté
  async getMyZoneAgents() {
    return this.get('/my-zone/agents')
  }

  // ─── Gestion des agents ────────────────────────────────────────

  // Récupérer les agents disponibles pour l'affectation
  async getAvailableAgents() {
    return this.get('/agents/available')
  }

  // Affecter un agent à une zone
  async assignAgentToZone(zoneId, agentId) {
    return this.post('/assign-agent', { zoneId, agentId })
  }

  // Retirer un agent d'une zone
  async unassignAgentFromZone(zoneId, agentId) {
    return this.delete(`/unassign-agent/${zoneId}/${agentId}`)
  }

  // Performance des agents de la zone
  async getAgentPerformance(zoneId) {
    return this.get(`/agents/performance/${zoneId}`)
  }

  // ─── Tableau de bord de zone ───────────────────────────────────

  // Tableau de bord de la zone supervisée
  async getDashboardZone(zoneId) {
    return this.get(`/dashboard/${zoneId}`)
  }

  // Comparaison des performances des quartiers
  async comparerQuartiers(zoneId) {
    return this.get(`/quartiers/comparaison/${zoneId}`)
  }

  // ─── Anomalies ─────────────────────────────────────────────────

  // Toutes les anomalies (filtrable par statut)
  async getAnomalies(filters = {}) {
    return this.get('/anomalies', filters)
  }

  // Clôturer une anomalie
  async cloturerAnomalie(anomalieId, clotureePar = null, commentaire = null) {
    return this.post(`/anomalies/${anomalieId}/cloturer`, { clotureePar, commentaire })
  }

  // Escalader une anomalie à la hiérarchie
  async escalerAnomalie(anomalieId, commentaire = null) {
    return this.post(`/anomalies/${anomalieId}/escaler`, { commentaire })
  }

  // ─── Propositions d'affectation ────────────────────────────────

  // Propositions d'affectation en attente (filtrable par quartierId, statut)
  async getPropositions(filters = {}) {
    return this.get('/propositions', filters)
  }

  // Valider une proposition d'affectation
  async validerProposition(propositionId, valideePar = null, commentaire = null) {
    return this.post(`/propositions/${propositionId}/valider`, { valideePar, commentaire })
  }

  // Rejeter une proposition d'affectation
  async rejeterProposition(propositionId, valideePar = null, commentaire = null) {
    return this.post(`/propositions/${propositionId}/rejeter`, { valideePar, commentaire })
  }
}

export const supervisionService = new SupervisionService()
