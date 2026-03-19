<template>
  <div class="logical-deletion-actions">
    <!-- Badge de statut -->
    <span v-if="showStatusBadge" :class="statusClass" class="status-badge">
      {{ statusText }}
    </span>

    <!-- Actions pour les éléments actifs -->
    <div v-if="!entity.deletedAt" class="active-actions">
      <button 
        v-if="canDelete"
        @click="confirmDelete"
        class="btn btn-sm btn-outline-danger"
        :disabled="loading"
        title="Supprimer"
      >
        <i class="fas fa-trash"></i>
        Supprimer
      </button>
    </div>

    <!-- Actions pour les éléments supprimés -->
    <div v-else class="deleted-actions">
      <div class="deleted-info">
        <small class="text-muted">
          Supprimé le {{ formatDate(entity.deletedAt) }}
          <span v-if="entity.deletedBy"> par {{ entity.deletedBy }}</span>
        </small>
      </div>
      
      <button 
        v-if="canRestore"
        @click="confirmRestore"
        class="btn btn-sm btn-outline-success"
        :disabled="loading"
        title="Restaurer"
      >
        <i class="fas fa-undo"></i>
        Restaurer
      </button>
    </div>

    <!-- Modal de confirmation de suppression -->
    <div v-if="showDeleteModal" class="modal fade show" style="display: block;">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Confirmation de suppression</h5>
            <button type="button" class="btn-close" @click="showDeleteModal = false"></button>
          </div>
          <div class="modal-body">
            <p>Êtes-vous sûr de vouloir supprimer {{ entityName }} "{{ getEntityDisplay() }}" ?</p>
            <p class="text-warning">
              <i class="fas fa-exclamation-triangle"></i>
              Cette action peut être annulée via la fonction de restauration.
            </p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showDeleteModal = false">
              Annuler
            </button>
            <button 
              type="button" 
              class="btn btn-danger" 
              @click="handleDelete"
              :disabled="loading"
            >
              <span v-if="loading">
                <i class="fas fa-spinner fa-spin"></i> Suppression...
              </span>
              <span v-else>
                <i class="fas fa-trash"></i> Supprimer
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de confirmation de restauration -->
    <div v-if="showRestoreModal" class="modal fade show" style="display: block;">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Confirmation de restauration</h5>
            <button type="button" class="btn-close" @click="showRestoreModal = false"></button>
          </div>
          <div class="modal-body">
            <p>Êtes-vous sûr de vouloir restaurer {{ entityName }} "{{ getEntityDisplay() }}" ?</p>
            <p class="text-info">
              <i class="fas fa-info-circle"></i>
              Cette entité sera de nouveau disponible dans l'application.
            </p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showRestoreModal = false">
              Annuler
            </button>
            <button 
              type="button" 
              class="btn btn-success" 
              @click="handleRestore"
              :disabled="loading"
            >
              <span v-if="loading">
                <i class="fas fa-spinner fa-spin"></i> Restauration...
              </span>
              <span v-else>
                <i class="fas fa-undo"></i> Restaurer
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import LogicalDeletionService from '@/services/logicalDeletionService.js';

export default {
  name: 'LogicalDeletionActions',
  props: {
    entity: {
      type: Object,
      required: true
    },
    endpoint: {
      type: String,
      required: true
    },
    entityName: {
      type: String,
      default: 'cet élément'
    },
    canDelete: {
      type: Boolean,
      default: true
    },
    canRestore: {
      type: Boolean,
      default: true
    },
    showStatusBadge: {
      type: Boolean,
      default: true
    },
    displayField: {
      type: String,
      default: 'nom'
    }
  },
  data() {
    return {
      loading: false,
      showDeleteModal: false,
      showRestoreModal: false
    };
  },
  computed: {
    statusText() {
      return this.entity.deletedAt ? 'Supprimé' : 'Actif';
    },
    statusClass() {
      return this.entity.deletedAt 
        ? 'badge bg-danger' 
        : 'badge bg-success';
    }
  },
  methods: {
    getEntityDisplay() {
      return this.entity[this.displayField] || `ID ${this.entity.id}`;
    },
    
    formatDate(dateString) {
      if (!dateString) return '';
      return new Date(dateString).toLocaleString('fr-FR');
    },
    
    confirmDelete() {
      this.showDeleteModal = true;
    },
    
    confirmRestore() {
      this.showRestoreModal = true;
    },
    
    async handleDelete() {
      try {
        this.loading = true;
        await LogicalDeletionService.deleteLogical(this.endpoint, this.entity.id);
        
        this.$emit('deleted', this.entity);
        this.showDeleteModal = false;
        
        this.$toast.success(`${this.entityName} supprimé avec succès`);
      } catch (error) {
        console.error('Erreur lors de la suppression:', error);
        this.$toast.error('Erreur lors de la suppression');
      } finally {
        this.loading = false;
      }
    },
    
    async handleRestore() {
      try {
        this.loading = true;
        await LogicalDeletionService.restore(this.endpoint, this.entity.id);
        
        this.$emit('restored', this.entity);
        this.showRestoreModal = false;
        
        this.$toast.success(`${this.entityName} restauré avec succès`);
      } catch (error) {
        console.error('Erreur lors de la restauration:', error);
        this.$toast.error('Erreur lors de la restauration');
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.logical-deletion-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-badge {
  font-size: 0.75rem;
}

.deleted-info {
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.active-actions,
.deleted-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.modal {
  background-color: rgba(0, 0, 0, 0.5);
}

.modal-dialog {
  max-width: 500px;
}

.btn:disabled {
  cursor: not-allowed;
}
</style>
