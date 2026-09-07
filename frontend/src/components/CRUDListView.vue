<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">{{ title }}</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="showCreateModal = true"
              class="btn-primary"
            >
              <Plus class="w-4 h-4 mr-2" />
              {{ newItemText }}
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex">
      <!-- Sidebar -->
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <!-- Content -->
      <div class="flex-1 p-6">
        <!-- Stats Cards -->
        <div v-if="statsCards && statsCards.length" class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <StatsCard
            v-for="stat in statsCards"
            :key="stat.title"
            :title="stat.title"
            :value="stat.value"
            :icon="stat.icon"
            :icon-color="stat.iconColor"
            :icon-bg-color="stat.iconBgColor"
            :format="stat.format"
          />
        </div>

        <!-- Table -->
        <div class="bg-white rounded-lg shadow-soft border border-gray-100">
          <div class="px-6 py-4 border-b border-gray-200">
            <div class="flex items-center justify-between">
              <h3 class="text-lg font-semibold text-gray-900">{{ tableTitle }}</h3>
              <div class="flex items-center space-x-3">
                <input
                  v-if="showSearch"
                  v-model="searchQuery"
                  type="text"
                  :placeholder="searchPlaceholder"
                  class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                />
                <select
                  v-if="filters && filters.length"
                  v-model="selectedFilter"
                  class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="">{{ filterAllText }}</option>
                  <option v-for="filter in filters" :key="filter.value" :value="filter.value">
                    {{ filter.label }}
                  </option>
                </select>
              </div>
            </div>
          </div>
          
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th 
                    v-for="column in columns" 
                    :key="column.key"
                    class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                  >
                    {{ column.label }}
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-if="loading" class="text-center">
                  <td :colspan="columns.length" class="px-6 py-12">
                    <div class="flex items-center justify-center">
                      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                      <span class="ml-2 text-gray-600">Chargement...</span>
                    </div>
                  </td>
                </tr>
                <tr 
                  v-else
                  v-for="item in filteredItems" 
                  :key="item.id"
                  class="hover:bg-gray-50 transition-colors"
                >
                  <td 
                    v-for="column in columns" 
                    :key="column.key"
                    class="px-6 py-4 whitespace-nowrap"
                    :class="column.className"
                  >
                    <!-- Slot pour personnaliser le contenu des cellules -->
                    <slot 
                      :name="`cell-${column.key}`" 
                      :item="item" 
                      :column="column"
                    >
                      <!-- Affichage par défaut -->
                      <span v-if="!column.component">{{ getNestedValue(item, column.key) }}</span>
                      <component 
                        v-else 
                        :is="column.component" 
                        v-bind="column.props || {}"
                        v-model="item[column.key]"
                      />
                    </slot>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="modal-header">
          {{ editingItem ? 'Modifier' : 'Créer' }} {{ modalTitle }}
        </h3>
        
        <form @submit.prevent="saveItem">
          <div class="space-y-4">
            <div v-for="field in formFields" :key="field.key">
              <label class="form-label">{{ field.label }}</label>
              
              <!-- Input text -->
              <input
                v-if="field.type === 'text' || field.type === 'email' || field.type === 'tel'"
                v-model="itemForm[field.key]"
                :type="field.type"
                :required="field.required"
                :placeholder="field.placeholder"
                class="form-input"
              />
              
              <!-- Select -->
              <select
                v-else-if="field.type === 'select'"
                v-model="itemForm[field.key]"
                :required="field.required"
                class="form-input"
              >
                <option v-for="option in field.options" :key="option.value" :value="option.value">
                  {{ option.label }}
                </option>
              </select>
              
              <!-- Custom component -->
              <component
                v-else-if="field.component"
                :is="field.component"
                v-model="itemForm[field.key]"
                v-bind="field.props || {}"
              />
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 mt-6">
            <button
              type="button"
              @click="closeModal"
              class="btn-secondary"
            >
              Annuler
            </button>
            <button
              type="submit"
              :disabled="saving"
              class="btn-primary"
            >
              {{ saving ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Plus } from 'lucide-vue-next'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

// Props
const props = defineProps({
  // Configuration de base
  title: { type: String, required: true },
  newItemText: { type: String, default: 'Nouvel élément' },
  tableTitle: { type: String, default: 'Liste des éléments' },
  modalTitle: { type: String, default: 'élément' },
  
  // Configuration du tableau
  columns: { type: Array, required: true },
  items: { type: Array, default: () => [] },
  loading: { type: Boolean, default: false },
  
  // Configuration de la recherche
  showSearch: { type: Boolean, default: true },
  searchPlaceholder: { type: String, default: 'Rechercher...' },
  searchFields: { type: Array, default: () => [] },
  
  // Configuration des filtres
  filters: { type: Array, default: () => [] },
  filterAllText: { type: String, default: 'Tous' },
  filterField: { type: String, default: 'statut' },
  
  // Configuration des statistiques
  statsCards: { type: Array, default: () => [] },
  
  // Configuration du formulaire
  formFields: { type: Array, required: true },
  
  // Méthodes du store
  fetchItems: { type: Function, required: true },
  createItem: { type: Function, required: true },
  updateItem: { type: Function, required: true },
  deleteItem: { type: Function, required: true }
})

// State
const searchQuery = ref('')
const selectedFilter = ref('')
const showCreateModal = ref(false)
const editingItem = ref(null)
const saving = ref(false)
const itemForm = ref({})

// Initialiser le formulaire avec les valeurs par défaut
const initForm = () => {
  const form = {}
  props.formFields.forEach(field => {
    form[field.key] = field.defaultValue || ''
  })
  itemForm.value = form
}

// Computed
const filteredItems = computed(() => {
  let items = props.items || []
  
  // Filtrage par recherche
  if (searchQuery.value && props.searchFields.length > 0) {
    const query = searchQuery.value.toLowerCase()
    items = items.filter(item => 
      props.searchFields.some(field => {
        const value = getNestedValue(item, field)
        return value && value.toString().toLowerCase().includes(query)
      })
    )
  }
  
  // Filtrage par statut
  if (selectedFilter.value && props.filterField) {
    items = items.filter(item => item[props.filterField] === selectedFilter.value)
  }
  
  return items
})

// Methods
const getNestedValue = (obj, path) => {
  return path.split('.').reduce((current, key) => current?.[key], obj)
}

const editItem = (item) => {
  editingItem.value = item
  itemForm.value = { ...item }
  showCreateModal.value = true
}

const deleteItem = async (item) => {
  const itemName = item.nom || item.libelle || `l'élément ${item.id}`
  if (confirm(`Êtes-vous sûr de vouloir supprimer ${itemName}?`)) {
    try {
      await props.deleteItem(item.id)
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const saveItem = async () => {
  saving.value = true
  try {
    if (editingItem.value) {
      await props.updateItem(editingItem.value.id, itemForm.value)
    } else {
      await props.createItem(itemForm.value)
    }
    closeModal()
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement:', error)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingItem.value = null
  initForm()
}

// Lifecycle
onMounted(() => {
  initForm()
  props.fetchItems()
})
</script>
