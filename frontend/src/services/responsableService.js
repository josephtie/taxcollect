import { BaseService } from './baseService'

/**
 * Service Responsable de Quartier / Chef d'Équipe — E-CollecteTaxe
 *
 * Hiérarchie : ZONE → SUPERVISEUR → QUARTIERS → RESPONSABLE → SECTEURS → AGENTS → CONTRIBUABLES
 *
 * Le Responsable de Quartier pilote le terrain d'UN seul quartier.
 * Il peut : organiser, accompagner, contrôler, signaler, rendre compte.
 * Il peut PROPOSER une affectation d'agent (validation par le Superviseur).
 * Il NE peut PAS : valider financièrement, supprimer un contribuable, modifier la structure territoriale,
 *                  accéder aux autres quartiers ou zones.
 *
 * Toutes les routes ci-dessous sont implémentées par ResponsableController
 * (backend : /api/taxcollect/responsable). Aucune donnée de fallback.
 */
class ResponsableService extends BaseService {
  constructor() {
    super('/api/taxcollect/responsable')
  }

  // ─── Tableau de bord du quartier ───────────────────────────────

  async getDashboardQuartier() {
    return this.get('/dashboard')
  }

  // ─── Agents du quartier ────────────────────────────────────────

  async getAgentsQuartier() {
    return this.get('/agents')
  }

  async proposerAffectation(agentId, secteurId, motif = null) {
    return this.post('/agents/proposer-affectation', { agentId, secteurId, motif })
  }

  async getPropositionsEnAttente() {
    return this.get('/agents/propositions')
  }

  async signalerAbsence(agentId, date, motif) {
    return this.post('/agents/absence', { agentId, date, motif })
  }

  // ─── Contribuables du quartier ─────────────────────────────────

  async getContribuablesQuartier(filters = {}) {
    return this.get('/contribuables', filters)
  }

  async signalerErreurAffectation(contribuableId, secteurCorrect, commentaire) {
    return this.post('/contribuables/erreur-affectation', { contribuableId, secteurCorrect, commentaire })
  }

  // ─── Suivi des visites terrain ─────────────────────────────────

  async getVisitesTerrain(filters = {}) {
    return this.get('/visites', filters)
  }

  async getSecteursCouverture() {
    return this.get('/secteurs/couverture')
  }

  // ─── Contrôle des collectes ────────────────────────────────────

  async getCollectesQuartier(filters = {}) {
    return this.get('/collectes', filters)
  }

  async signalerOperationDouteuse(transactionId, motif) {
    return this.post('/collectes/signaler-douteuse', { transactionId, motif })
  }

  // ─── Anomalies (créer, documenter, transmettre) ────────────────

  async getAnomaliesQuartier(filters = {}) {
    return this.get('/anomalies', filters)
  }

  async creerAnomalie(data) {
    return this.post('/anomalies', data)
  }

  async documenterAnomalie(anomalieId, commentaire) {
    return this.post(`/anomalies/${anomalieId}/documenter`, { commentaire })
  }

  async transmettreAnomalieSuperviseur(anomalieId, commentaire = null) {
    return this.post(`/anomalies/${anomalieId}/transmettre`, { commentaire })
  }

  async affecterActionAnomalie(anomalieId, agentId, action) {
    return this.post(`/anomalies/${anomalieId}/affecter`, { agentId, action })
  }

  // ─── Rapports du quartier ─────────────────────────────────────

  async getRapportQuartier(filters = {}) {
    return this.get('/rapports', filters)
  }

  async exporterRapportQuartier(format = 'pdf', filters = {}) {
    return this.download('/rapports/export', { format, ...filters })
  }
}

export const responsableService = new ResponsableService()
