import { BaseService } from './baseService.js';

/**
 * Service pour gérer la suppression logique dans le frontend
 */
class LogicalDeletionService {
    
    constructor() {
        this.baseService = new BaseService();
    }
    
    /**
     * Supprime logiquement une entité
     * @param {string} endpoint - L'endpoint de l'entité (ex: 'agent', 'taxe')
     * @param {number} id - L'ID de l'entité à supprimer
     * @returns {Promise} - La promesse de la suppression
     */
    async deleteLogical(endpoint, id) {
        try {
            const response = await this.baseService.delete(`${endpoint}/${id}`);
            return response;
        } catch (error) {
            console.error(`Erreur lors de la suppression logique de ${endpoint} ${id}:`, error);
            throw error;
        }
    }

    /**
     * Restaure une entité supprimée
     * @param {string} endpoint - L'endpoint de l'entité (ex: 'agent', 'taxe')
     * @param {number} id - L'ID de l'entité à restaurer
     * @returns {Promise} - La promesse de la restauration
     */
    async restore(endpoint, id) {
        try {
            const response = await this.baseService.post(`${endpoint}/${id}/restore`);
            return response;
        } catch (error) {
            console.error(`Erreur lors de la restauration de ${endpoint} ${id}:`, error);
            throw error;
        }
    }

    /**
     * Récupère toutes les entités y compris celles supprimées
     * @param {string} endpoint - L'endpoint de l'entité (ex: 'agent', 'taxe')
     * @returns {Promise} - La promesse des données
     */
    async findAllIncludingDeleted(endpoint) {
        try {
            const response = await this.baseService.get(`${endpoint}/including-deleted`);
            return response;
        } catch (error) {
            console.error(`Erreur lors de la récupération de ${endpoint} incluant les supprimés:`, error);
            throw error;
        }
    }

    /**
     * Formate le statut d'une entité pour l'affichage
     * @param {Object} entity - L'entité à vérifier
     * @returns {Object} - Objet avec le statut formaté
     */
    formatStatus(entity) {
        const isDeleted = entity.deletedAt !== null && entity.deletedAt !== undefined;
        
        return {
            isDeleted,
            status: isDeleted ? 'Supprimé' : 'Actif',
            statusClass: isDeleted ? 'deleted' : 'active',
            deletedAt: entity.deletedAt,
            deletedBy: entity.deletedBy
        };
    }

    /**
     * Génère un badge de statut pour l'affichage
     * @param {Object} entity - L'entité à vérifier
     * @returns {string} - HTML du badge
     */
    getStatusBadge(entity) {
        const status = this.formatStatus(entity);
        
        if (status.isDeleted) {
            return `<span class="badge bg-danger">Supprimé</span>`;
        } else {
            return `<span class="badge bg-success">Actif</span>`;
        }
    }

    /**
     * Vérifie si l'utilisateur peut restaurer l'entité
     * @param {Object} entity - L'entité à vérifier
     * @param {Object} user - L'utilisateur actuel
     * @returns {boolean} - True si l'utilisateur peut restaurer
     */
    canRestore(entity, user) {
        // Seuls les administrateurs peuvent restaurer
        // ou l'utilisateur qui a supprimé l'entité
        if (!entity.deletedAt) return false;
        
        return user?.role === 'ADMIN' || 
               user?.role === 'SUPERVISEUR' || 
               entity.deletedBy === user?.username;
    }
}

export default new LogicalDeletionService();
