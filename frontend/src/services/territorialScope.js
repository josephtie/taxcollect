/**
 * Helper de scope territorial — E-CollecteTaxe
 *
 * Gère l'extraction et la vérification du scope territorial de l'utilisateur
 * à partir du token JWT (Keycloak) ou des données utilisateur.
 *
 * Hiérarchie :
 *   ADMIN          → scope global (pas de restriction)
 *   SUPERVISEUR    → scope zone_id (voit tous les quartiers de sa zone)
 *   RESPONSABLE    → scope quartier_id (voit uniquement son quartier)
 *   AGENT          → scope secteur_id (voit uniquement son secteur)
 *   TRESOR         → scope global financier (pas de restriction territoriale)
 *
 * Le scope est injecté par Keycloak dans le token JWT sous forme de claims :
 *   - zone_id       (pour SUPERVISEUR)
 *   - quartier_id   (pour RESPONSABLE_QUARTIER)
 *   - secteur_id    (pour AGENT)
 *
 * Côté frontend, on lit ces claims depuis le token décodé ou depuis
 * l'objet user fourni par l'authentification.
 */

import { authService } from './authService'

/**
 * Décode un token JWT (sans vérification — côté client uniquement).
 * @param {string} token
 * @returns {object|null}
 */
function decodeJwt(token) {
  if (!token) return null
  try {
    const parts = token.split('.')
    if (parts.length !== 3) return null
    const payload = parts[1]
    // Base64Url → Base64
    const base64 = payload.replace(/-/g, '+').replace(/_/g, '/')
    const json = decodeURIComponent(
      atob(base64)
        .split('')
        .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    )
    return JSON.parse(json)
  } catch (e) {
    console.warn('Impossible de décoder le token JWT:', e)
    return null
  }
}

/**
 * Récupère le scope territorial de l'utilisateur courant.
 *
 * @returns {{
 *   role: string,
 *   zoneId: number|null,
 *   quartierId: number|null,
 *   secteurId: number|null,
 *   isGlobal: boolean,
 *   scopeType: 'global'|'zone'|'quartier'|'secteur'|'none'
 * }}
 */
export function getTerritorialScope() {
  let role = null
  let zoneId = null
  let quartierId = null
  let secteurId = null

  // 1. Essayer via authService (objet user)
  try {
    const user = authService?.getCurrentUser?.() || authService?.user
    if (user) {
      role = user.role
      zoneId = user.zone_id ?? user.zoneId ?? null
      quartierId = user.quartier_id ?? user.quartierId ?? null
      secteurId = user.secteur_id ?? user.secteurId ?? null
    }
  } catch (e) {
    // authService non disponible
  }

  // 2. Essayer via le token JWT
  if (!role) {
    try {
      const token = localStorage.getItem('authToken') || localStorage.getItem('token')
      const decoded = decodeJwt(token)
      if (decoded) {
        role = decoded.role || decoded.realm_access?.roles?.find(r =>
          ['ADMIN', 'SUPERVISEUR', 'RESPONSABLE_QUARTIER', 'AGENT', 'TRESOR'].includes(r)
        ) || null
        zoneId = decoded.zone_id ?? null
        quartierId = decoded.quartier_id ?? null
        secteurId = decoded.secteur_id ?? null
      }
    } catch (e) {
      // Token non disponible
    }
  }

  // 3. Fallback via localStorage direct
  if (!role) {
    role = localStorage.getItem('userRole')
    zoneId = zoneId || (parseInt(localStorage.getItem('zoneId')) || null)
    quartierId = quartierId || (parseInt(localStorage.getItem('quartierId')) || null)
    secteurId = secteurId || (parseInt(localStorage.getItem('secteurId')) || null)
  }

  // Détermination du scope
  const isGlobal = role === 'ADMIN' || role === 'TRESOR'
  let scopeType = 'none'
  if (isGlobal) scopeType = 'global'
  else if (zoneId) scopeType = 'zone'
  else if (quartierId) scopeType = 'quartier'
  else if (secteurId) scopeType = 'secteur'

  return {
    role,
    zoneId,
    quartierId,
    secteurId,
    isGlobal,
    scopeType
  }
}

/**
 * Vérifie si l'utilisateur courant peut accéder à une entité territoriale.
 *
 * @param {object} entity - L'entité à vérifier (doit contenir zoneId et/ou quartierId et/ou secteurId)
 * @returns {boolean}
 */
export function canAccessEntity(entity) {
  const scope = getTerritorialScope()

  if (scope.isGlobal) return true
  if (scope.scopeType === 'none') return false

  if (scope.scopeType === 'zone') {
    // SUPERVISEUR : voit tout ce qui est dans sa zone
    return entity.zoneId === scope.zoneId || entity.zone_id === scope.zoneId
  }

  if (scope.scopeType === 'quartier') {
    // RESPONSABLE : voit uniquement son quartier
    return entity.quartierId === scope.quartierId || entity.quartier_id === scope.quartierId
  }

  if (scope.scopeType === 'secteur') {
    // AGENT : voit uniquement son secteur
    return entity.secteurId === scope.secteurId || entity.secteur_id === scope.secteurId
  }

  return false
}

/**
 * Ajoute le scope territorial aux paramètres de requête API.
 * Permet au backend de filtrer automatiquement les données.
 *
 * @param {object} params - Paramètres de requête existants
 * @returns {object} Paramètres enrichis avec le scope
 */
export function withScope(params = {}) {
  const scope = getTerritorialScope()
  if (scope.isGlobal) return params

  return {
    ...params,
    ...(scope.zoneId && { zone_id: scope.zoneId }),
    ...(scope.quartierId && { quartier_id: scope.quartierId }),
    ...(scope.secteurId && { secteur_id: scope.secteurId })
  }
}

/**
 * Filtre une liste d'entités selon le scope territorial de l'utilisateur.
 * Utile pour le filtrage côté frontend (double sécurité avec le backend).
 *
 * @param {Array} entities - Liste d'entités
 * @param {object} keys - Mapping des clés : { zoneId, quartierId, secteurId }
 * @returns {Array} Liste filtrée
 */
export function filterByScope(entities, keys = {}) {
  const scope = getTerritorialScope()
  if (scope.isGlobal || scope.scopeType === 'none') return entities

  const zoneKey = keys.zoneId || 'zoneId'
  const quartierKey = keys.quartierId || 'quartierId'
  const secteurKey = keys.secteurId || 'secteurId'

  return entities.filter(e => {
    if (scope.scopeType === 'zone') return e[zoneKey] === scope.zoneId
    if (scope.scopeType === 'quartier') return e[quartierKey] === scope.quartierId
    if (scope.scopeType === 'secteur') return e[secteurKey] === scope.secteurId
    return false
  })
}

export default {
  getTerritorialScope,
  canAccessEntity,
  withScope,
  filterByScope
}
