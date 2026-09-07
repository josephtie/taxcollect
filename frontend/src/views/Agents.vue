<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Agents</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="exportExcel"
              :disabled="exporting"
              class="inline-flex items-center px-3 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <FileSpreadsheet class="w-4 h-4 mr-2" />
              {{ exporting ? 'Export...' : 'Export Excel' }}
            </button>
            <button
              @click="showCreateModal = true"
              class="btn-primary"
            >
              <Plus class="w-4 h-4 mr-2" />
              Nouvel Agent
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

      <!-- Agents Content -->
      <div class="flex-1 p-6 overflow-hidden">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <StatsCard
            title="Agents Actifs"
            :value="(agentStore.activeAgents || []).length"
            :icon="Users"
            icon-color="text-success-600"
            icon-bg-color="bg-success-50"
          />
          
          <StatsCard
            title="Agents en Ligne"
            :value="(agentStore.onlineAgents || []).length"
            :icon="Wifi"
            icon-color="text-primary-600"
            icon-bg-color="bg-primary-50"
          />
          
          <StatsCard
            title="Total Collecté Aujourd'hui"
            :value="totalCollectedToday"
            :icon="DollarSign"
            format="currency"
            icon-color="text-warning-600"
            icon-bg-color="bg-warning-50"
          />
        </div>

        <!-- Side Panel + Table -->
        <div class="flex gap-6">
          <!-- Side Panel (Drawer) -->
          <transition name="slide-panel">
            <div v-if="showCreateModal" class="w-96 flex-shrink-0 bg-white rounded-lg shadow-soft border border-gray-100 max-h-[calc(100vh-200px)] overflow-y-auto">
              <div class="sticky top-0 z-10">
                <h3 class="modal-header">
                  {{ editingAgent ? 'Modifier' : 'Créer' }} un Agent
                </h3>
              </div>
              
              <form @submit.prevent="saveAgent" class="p-6 pt-4">
                <div class="space-y-4">
                  <!-- Photo preview -->
                  <div v-if="agentForm.photo" class="flex justify-center">
                    <img :src="photoFullUrl" alt="Photo" class="w-20 h-20 rounded-full object-cover border-2 border-gray-200" />
                  </div>

                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="form-label">Nom</label>
                      <input
                        v-model="agentForm.nom"
                        type="text"
                        required
                        class="form-input"
                      />
                    </div>
                    
                    <div>
                      <label class="form-label">Prénom</label>
                      <input
                        v-model="agentForm.prenom"
                        type="text"
                        required
                        class="form-input"
                      />
                    </div>
                  </div>

                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="form-label">Matricule</label>
                      <input
                        v-model="agentForm.matricule"
                        type="text"
                        class="form-input"
                        placeholder="Ex: AG-001"
                      />
                    </div>
                    
                    <div>
                      <label class="form-label">Fonction</label>
                      <input
                        v-model="agentForm.fonction"
                        type="text"
                        class="form-input"
                        placeholder="Ex: Collecteur"
                      />
                    </div>
                  </div>

                  <div class="grid grid-cols-2 gap-4">
                    <div>
                      <label class="form-label">Date de naissance</label>
                      <input
                        v-model="agentForm.dateNaissance"
                        type="date"
                        class="form-input"
                      />
                    </div>
                    
                    <div>
                      <label class="form-label">Statut</label>
                      <select
                        v-model="agentForm.statut"
                        required
                        class="form-input"
                      >
                        <option value="ACTIF">Actif</option>
                        <option value="INACTIF">Inactif</option>
                        <option value="SUSPENDU">Suspendu</option>
                      </select>
                    </div>
                  </div>
                  
                  <div>
                    <label class="form-label">Email</label>
                    <input
                      v-model="agentForm.email"
                      type="email"
                      required
                      class="form-input"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Téléphone</label>
                    <input
                      v-model="agentForm.telephone"
                      type="tel"
                      required
                      class="form-input"
                    />
                  </div>

                  <div>
                    <label class="form-label">Photo</label>
                    <div class="flex items-center space-x-3">
                      <div v-if="agentForm.photo" class="relative">
                        <img :src="photoFullUrl" alt="Photo" class="w-16 h-16 rounded-full object-cover border-2 border-gray-200" />
                        <button type="button" @click="agentForm.photo = ''" class="absolute -top-1 -right-1 w-5 h-5 bg-red-500 text-white rounded-full text-xs flex items-center justify-center hover:bg-red-600">
                          ×
                        </button>
                      </div>
                      <label class="cursor-pointer px-3 py-2 border border-gray-300 rounded-lg text-sm text-gray-700 hover:bg-gray-50">
                        <span>{{ uploadingPhoto ? 'Upload...' : 'Choisir un fichier' }}</span>
                        <input
                          type="file"
                          accept="image/*"
                          class="hidden"
                          @change="handlePhotoUpload"
                          :disabled="uploadingPhoto"
                        />
                      </label>
                    </div>
                    <p v-if="photoError" class="text-xs text-red-500 mt-1">{{ photoError }}</p>
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
          </transition>

          <!-- Agents Table -->
          <div :class="showCreateModal ? 'flex-1 min-w-0' : 'flex-1'" class="bg-white rounded-lg shadow-soft border border-gray-100">
            <div class="px-6 py-4 border-b border-gray-200">
              <div class="flex items-center justify-between">
                <h3 class="text-lg font-semibold text-gray-900">Liste des Agents</h3>
                <div class="flex items-center space-x-3">
                  <input
                    v-model="searchQuery"
                    type="text"
                    placeholder="Rechercher (nom, prénom, email, matricule)..."
                    class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500 w-64"
                  />
                  <select
                    v-model="statusFilter"
                    class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                  >
                    <option value="">Tous les statuts</option>
                    <option value="ACTIF">Actif</option>
                    <option value="INACTIF">Inactif</option>
                    <option value="SUSPENDU">Suspendu</option>
                  </select>
                  <select
                    v-model="fonctionFilter"
                    class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                  >
                    <option value="">Toutes les fonctions</option>
                    <option v-for="f in fonctions" :key="f" :value="f">{{ f }}</option>
                  </select>
                  <select
                    v-model="zoneFilter"
                    class="px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                  >
                    <option value="">Toutes les zones</option>
                    <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.nom }}</option>
                  </select>
                  <button
                    @click="resetFilters"
                    class="px-3 py-2 text-sm text-gray-500 hover:text-gray-700"
                    title="Réinitialiser les filtres"
                  >
                    <RotateCcw class="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
            
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Agent
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Matricule
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Fonction / Naissance
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Contact
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Zone
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Statut
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Connexion
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Total Aujourd'hui
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Transactions
                    </th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-if="agentStore.loading" class="text-center">
                    <td colspan="10" class="px-6 py-12">
                      <div class="flex items-center justify-center">
                        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                        <span class="ml-2 text-gray-600">Chargement...</span>
                      </div>
                    </td>
                  </tr>
                  <tr v-else-if="paginatedAgents.length === 0" class="text-center">
                    <td colspan="10" class="px-6 py-12">
                      <Users class="w-10 h-10 text-gray-300 mx-auto mb-2" />
                      <p class="text-gray-500">Aucun agent trouvé</p>
                    </td>
                  </tr>
                  <tr 
                    v-else
                    v-for="agent in paginatedAgents" 
                    :key="agent.id"
                    :class="[editingAgent?.id === agent.id ? 'bg-primary-50' : 'hover:bg-gray-50', 'transition-colors']"
                  >
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="flex items-center">
                        <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-3 overflow-hidden">
                          <img v-if="agent.photo" :src="agent.photo.startsWith('http') ? agent.photo : `http://localhost:9091${agent.photo}`" :alt="agent.nom" class="w-full h-full object-cover" />
                          <span v-else class="text-sm font-medium text-gray-600">
                            {{ agent.nom[0] }}{{ agent.prenom[0] }}
                          </span>
                        </div>
                        <div>
                          <div class="text-sm font-medium text-gray-900">
                            {{ agent.nom }} {{ agent.prenom }}
                          </div>
                          <div class="text-xs text-gray-500">ID: {{ agent.id }}</div>
                        </div>
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ agent.matricule || '—' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      <div>{{ agent.fonction || '—' }}</div>
                      <div v-if="agent.dateNaissance" class="text-xs text-gray-500">{{ formatDate(agent.dateNaissance) }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <div class="text-sm text-gray-900">{{ agent.email }}</div>
                      <div class="text-xs text-gray-500">{{ agent.telephone }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ agent.zoneCollecte?.nom || 'Non assigné' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <StatusBadge 
                        :status="agent.statut || 'ACTIF'" 
                        type="agent"
                      />
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <span
                        :class="agent.enLigne ? 'bg-success-100 text-success-800' : 'bg-gray-100 text-gray-800'"
                        class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                      >
                        <span :class="agent.enLigne ? 'bg-success-500' : 'bg-gray-400'" class="w-2 h-2 rounded-full mr-1.5"></span>
                        {{ agent.enLigne ? 'En ligne' : 'Hors ligne' }}
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ formatCurrency(agent.totalCollecteDuJour || 0) }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ agent.nombreTransactionsDuJour || 0 }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div class="flex items-center space-x-2">
                        <button
                          @click="viewAgentDetails(agent)"
                          class="text-primary-600 hover:text-primary-900"
                          title="Voir les détails"
                        >
                          <Eye class="w-4 h-4" />
                        </button>
                        <button
                          @click="editAgent(agent)"
                          class="text-warning-600 hover:text-warning-900"
                          title="Modifier"
                        >
                          <Edit class="w-4 h-4" />
                        </button>
                        <button
                          v-if="agent.statut !== 'SUSPENDU'"
                          @click="toggleAgentStatus(agent, 'SUSPENDU')"
                          :disabled="statusBusyIds.includes(agent.id)"
                          class="text-orange-600 hover:text-orange-900 disabled:opacity-50"
                          title="Suspendre"
                        >
                          <Loader2 v-if="statusBusyIds.includes(agent.id)" class="w-4 h-4 animate-spin" />
                          <Ban v-else class="w-4 h-4" />
                        </button>
                        <button
                          v-if="agent.statut === 'SUSPENDU' || agent.statut === 'INACTIF'"
                          @click="toggleAgentStatus(agent, 'ACTIF')"
                          :disabled="statusBusyIds.includes(agent.id)"
                          class="text-success-600 hover:text-success-900 disabled:opacity-50"
                          title="Réactiver"
                        >
                          <Loader2 v-if="statusBusyIds.includes(agent.id)" class="w-4 h-4 animate-spin" />
                          <CheckCircle v-else class="w-4 h-4" />
                        </button>
                        <button
                          @click="deleteAgent(agent)"
                          class="text-danger-600 hover:text-danger-900"
                          title="Supprimer"
                        >
                          <Trash2 class="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            
            <!-- Pagination -->
            <div class="px-6 py-3 border-t border-gray-200 flex items-center justify-between">
              <div class="flex items-center text-sm text-gray-600">
                <span>Affichage de </span>
                <span class="font-medium mx-1">{{ rangeStart }}</span>
                <span>à</span>
                <span class="font-medium mx-1">{{ rangeEnd }}</span>
                <span>sur</span>
                <span class="font-medium mx-1">{{ totalElements }}</span>
                <span>agent(s)</span>
              </div>
              <div class="flex items-center space-x-2">
                <select
                  v-model="pageSize"
                  @change="onPageSizeChange"
                  class="px-2 py-1 border border-gray-300 rounded-md text-sm focus:ring-primary-500 focus:border-primary-500"
                >
                  <option :value="10">10 / page</option>
                  <option :value="20">20 / page</option>
                  <option :value="50">50 / page</option>
                  <option :value="100">100 / page</option>
                </select>
                <button
                  @click="goToPage(0)"
                  :disabled="currentPage === 0 || agentStore.loading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Première page"
                >
                  <ChevronsLeft class="w-4 h-4" />
                </button>
                <button
                  @click="goToPage(currentPage - 1)"
                  :disabled="currentPage === 0 || agentStore.loading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Page précédente"
                >
                  <ChevronLeft class="w-4 h-4" />
                </button>
                <span class="text-sm text-gray-700 px-2">
                  Page <span class="font-medium">{{ currentPage + 1 }}</span> / <span class="font-medium">{{ totalPages }}</span>
                </span>
                <button
                  @click="goToPage(currentPage + 1)"
                  :disabled="isLastPage || agentStore.loading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Page suivante"
                >
                  <ChevronRight class="w-4 h-4" />
                </button>
                <button
                  @click="goToPage(totalPages - 1)"
                  :disabled="isLastPage || agentStore.loading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Dernière page"
                >
                  <ChevronsRight class="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
    <!-- Agent Details Modal -->
    <div v-if="showDetailsModal" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/50">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-2xl max-h-[85vh] overflow-y-auto">
        <div class="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <div>
            <h3 class="text-lg font-semibold text-gray-900">Détails de l'agent</h3>
            <p v-if="detailsAgent" class="text-sm text-gray-500 mt-0.5">
              {{ detailsAgent.nom }} {{ detailsAgent.prenom }}
            </p>
          </div>
          <button @click="showDetailsModal = false" class="text-gray-400 hover:text-gray-600">
            <X class="w-5 h-5" />
          </button>
        </div>

        <div v-if="detailsLoading" class="p-12 flex justify-center">
          <Loader2 class="w-8 h-8 text-primary-600 animate-spin" />
        </div>

        <div v-else-if="detailsAgent" class="p-6 space-y-6">
          <!-- Agent info -->
          <div class="flex items-center gap-4">
            <div class="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
              <img v-if="detailsAgent.photo" :src="detailsAgent.photo.startsWith('http') ? detailsAgent.photo : `http://localhost:9091${detailsAgent.photo}`" :alt="detailsAgent.nom" class="w-full h-full object-cover" />
              <span v-else class="text-xl font-semibold text-gray-600">{{ detailsAgent.nom?.[0] }}{{ detailsAgent.prenom?.[0] }}</span>
            </div>
            <div class="flex-1">
              <p class="text-lg font-semibold text-gray-900">{{ detailsAgent.nom }} {{ detailsAgent.prenom }}</p>
              <p class="text-sm text-gray-500">{{ detailsAgent.email }} · {{ detailsAgent.telephone }}</p>
              <div class="flex items-center gap-2 mt-1">
                <StatusBadge :status="detailsAgent.statut || 'ACTIF'" type="agent" />
                <span v-if="detailsAgent.zoneCollecte" class="text-xs text-gray-500">Zone: {{ detailsAgent.zoneCollecte.nom }}</span>
              </div>
            </div>
          </div>

          <!-- Stats grid -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div class="bg-gray-50 rounded-lg p-4">
              <p class="text-xs text-gray-500 mb-1">Total collecté</p>
              <p class="text-lg font-bold text-gray-900">{{ formatCurrency(agentStatsData.totalCollecte || 0) }}</p>
            </div>
            <div class="bg-gray-50 rounded-lg p-4">
              <p class="text-xs text-gray-500 mb-1">Transactions</p>
              <p class="text-lg font-bold text-gray-900">{{ agentStatsData.nombreTransactions || 0 }}</p>
            </div>
            <div class="bg-gray-50 rounded-lg p-4">
              <p class="text-xs text-gray-500 mb-1">Montant moyen</p>
              <p class="text-lg font-bold text-gray-900">{{ formatCurrency(agentStatsData.montantMoyen || 0) }}</p>
            </div>
            <div class="bg-gray-50 rounded-lg p-4">
              <p class="text-xs text-gray-500 mb-1">Collecte aujourd'hui</p>
              <p class="text-lg font-bold text-gray-900">{{ formatCurrency(detailsAgent.totalCollecteDuJour || 0) }}</p>
            </div>
          </div>

          <!-- Payment method breakdown -->
          <div v-if="agentStatsData.repartitionPaiement" class="bg-gray-50 rounded-lg p-4">
            <h4 class="text-sm font-semibold text-gray-700 mb-3">Répartition par mode de paiement</h4>
            <div class="space-y-2">
              <div v-for="(amount, method) in agentStatsData.repartitionPaiement" :key="method" class="flex items-center justify-between">
                <span class="text-sm text-gray-600">{{ method }}</span>
                <span class="text-sm font-medium text-gray-900">{{ formatCurrency(amount) }}</span>
              </div>
            </div>
          </div>

          <!-- Period selector for stats -->
          <div class="flex items-center gap-3">
            <select v-model="statsPeriod" @change="loadAgentStats" class="px-3 py-2 border border-gray-300 rounded-md text-sm">
              <option value="today">Aujourd'hui</option>
              <option value="week">7 derniers jours</option>
              <option value="month">30 derniers jours</option>
            </select>
            <button @click="loadAgentStats" class="text-sm text-primary-600 hover:text-primary-800">
              Actualiser
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAgentStore } from '@/stores/agents'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import api from '@/services/api'
import {
  Users,
  Wifi,
  DollarSign,
  Plus,
  Eye,
  Edit,
  Trash2,
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  FileSpreadsheet,
  RotateCcw,
  Ban,
  CheckCircle,
  Loader2,
  X
} from 'lucide-vue-next'
import * as XLSX from 'xlsx'
import { agentService, zoneService } from '@/services'

const agentStore = useAgentStore()

// State
const searchQuery = ref('')
const statusFilter = ref('')
const fonctionFilter = ref('')
const zoneFilter = ref('')
const showCreateModal = ref(false)
const editingAgent = ref(null)
const saving = ref(false)
const uploadingPhoto = ref(false)
const photoError = ref('')
const exporting = ref(false)
const statusBusyIds = ref([])
const showDetailsModal = ref(false)
const detailsAgent = ref(null)
const detailsLoading = ref(false)
const agentStatsData = ref({})
const statsPeriod = ref('week')
const currentPage = ref(0)
const pageSize = ref(10)
const sortField = ref('nom')
const sortDir = ref('asc')
const zones = ref([])
let searchDebounce = null

const agentForm = ref({
  nom: '',
  prenom: '',
  email: '',
  telephone: '',
  statut: 'ACTIF',
  matricule: '',
  photo: '',
  dateNaissance: '',
  fonction: ''
})

// Computed
const fonctions = computed(() => {
  const all = agentStore.agents || []
  const unique = [...new Set(all.map(a => a.fonction).filter(Boolean))]
  return unique.sort()
})

const paginatedAgents = computed(() => {
  let agents = agentStore.agents || []
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    agents = agents.filter(agent => 
      agent.nom?.toLowerCase().includes(query) ||
      agent.prenom?.toLowerCase().includes(query) ||
      agent.email?.toLowerCase().includes(query) ||
      agent.matricule?.toLowerCase().includes(query)
    )
  }
  
  if (statusFilter.value) {
    agents = agents.filter(agent => agent.statut === statusFilter.value)
  }
  
  if (fonctionFilter.value) {
    agents = agents.filter(agent => agent.fonction === fonctionFilter.value)
  }
  
  if (zoneFilter.value) {
    agents = agents.filter(agent => agent.zoneCollecte?.id == zoneFilter.value)
  }
  
  return agents
})

const totalElements = computed(() => agentStore.pagination?.totalElements ?? paginatedAgents.value.length)
const totalPages = computed(() => {
  const storePages = agentStore.pagination?.totalPages
  if (storePages && storePages > 0) return storePages
  return Math.max(1, Math.ceil(paginatedAgents.value.length / pageSize.value))
})
const isLastPage = computed(() => {
  if (agentStore.pagination) return agentStore.pagination.last
  return currentPage.value >= totalPages.value - 1
})
const rangeStart = computed(() => {
  if (totalElements.value === 0) return 0
  return currentPage.value * pageSize.value + 1
})
const rangeEnd = computed(() => {
  const end = (currentPage.value + 1) * pageSize.value
  return Math.min(end, totalElements.value)
})

const totalCollectedToday = computed(() => {
  const stats = agentStore.agentStats || []
  return stats.reduce((sum, agent) => sum + (agent.todayTotal || 0), 0)
})

// Methods
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(amount)
}

const photoFullUrl = computed(() => {
  if (!agentForm.value.photo) return ''
  if (agentForm.value.photo.startsWith('http')) return agentForm.value.photo
  return `http://localhost:9091${agentForm.value.photo}`
})

const handlePhotoUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  photoError.value = ''
  uploadingPhoto.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    const response = await api.post('/api/taxcollect/upload/agent-photo', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    agentForm.value.photo = response.data.url
  } catch (error) {
    photoError.value = 'Erreur lors de l\'upload de la photo'
    console.error('Upload error:', error)
  } finally {
    uploadingPhoto.value = false
    event.target.value = ''
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

const viewAgentDetails = async (agent) => {
  detailsAgent.value = agent
  showDetailsModal.value = true
  agentStatsData.value = {}
  await loadAgentStats()
}

const loadAgentStats = async () => {
  if (!detailsAgent.value) return
  detailsLoading.value = true
  try {
    const now = new Date()
    let startDate
    switch (statsPeriod.value) {
      case 'today':
        startDate = new Date(now)
        startDate.setHours(0, 0, 0, 0)
        break
      case 'week':
        startDate = new Date(now)
        startDate.setDate(startDate.getDate() - 7)
        break
      case 'month':
        startDate = new Date(now)
        startDate.setDate(startDate.getDate() - 30)
        break
      default:
        startDate = new Date(now)
        startDate.setDate(startDate.getDate() - 7)
    }
    const response = await agentService.getAgentStats(detailsAgent.value.id, startDate, now)
    agentStatsData.value = response.data || {}
  } catch (error) {
    console.error('Erreur chargement stats agent:', error)
    agentStatsData.value = {}
  } finally {
    detailsLoading.value = false
  }
}

const toggleAgentStatus = async (agent, newStatus) => {
  statusBusyIds.value = [...statusBusyIds.value, agent.id]
  try {
    await agentService.updateAgentStatus(agent.id, newStatus)
    agent.statut = newStatus
    await loadPage()
  } catch (error) {
    console.error('Erreur changement statut:', error)
    alert(`Erreur lors du changement de statut: ${error.response?.data?.message || error.message}`)
  } finally {
    statusBusyIds.value = statusBusyIds.value.filter(id => id !== agent.id)
  }
}

const editAgent = (agent) => {
  editingAgent.value = agent
  agentForm.value = { 
    ...agent,
    statut: agent.statut || 'ACTIF',
    matricule: agent.matricule || '',
    photo: agent.photo || '',
    dateNaissance: agent.dateNaissance || '',
    fonction: agent.fonction || ''
  }
  showCreateModal.value = true
}

const deleteAgent = async (agent) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer l'agent ${agent.nom} ${agent.prenom}?`)) {
    try {
      await agentStore.deleteAgent(agent.id)
      // Afficher une notification de succès
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const saveAgent = async () => {
  saving.value = true
  try {
    console.log('Agent form data:', agentForm.value) // Debug
    if (editingAgent.value) {
      await agentStore.updateAgent(editingAgent.value.id, agentForm.value)
    } else {
      await agentStore.createAgent(agentForm.value)
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
  editingAgent.value = null
  agentForm.value = {
    nom: '',
    prenom: '',
    email: '',
    telephone: '',
    statut: 'ACTIF',
    matricule: '',
    photo: '',
    dateNaissance: '',
    fonction: ''
  }
}

// Pagination methods
const loadPage = async () => {
  const sort = `${sortField.value},${sortDir.value}`
  await agentStore.fetchAgents(currentPage.value, pageSize.value, sort)
}

const goToPage = (page) => {
  if (page < 0 || page >= totalPages.value || page === currentPage.value) return
  currentPage.value = page
  loadPage()
}

const onPageSizeChange = () => {
  currentPage.value = 0
  loadPage()
}

const onSearchInput = () => {
  if (searchDebounce) clearTimeout(searchDebounce)
  searchDebounce = setTimeout(() => {
    currentPage.value = 0
    loadPage()
  }, 400)
}

watch(searchQuery, onSearchInput)
watch(statusFilter, () => {
  currentPage.value = 0
  loadPage()
})
watch(fonctionFilter, () => {
  currentPage.value = 0
})
watch(zoneFilter, () => {
  currentPage.value = 0
})

// Reset filters
const resetFilters = () => {
  searchQuery.value = ''
  statusFilter.value = ''
  fonctionFilter.value = ''
  zoneFilter.value = ''
  currentPage.value = 0
  loadPage()
}

// Excel export
const exportExcel = async () => {
  exporting.value = true
  try {
    const response = await agentService.getAllAgentsLegacy()
    const allAgents = Array.isArray(response) ? response : (response.data || [])
    
    const data = allAgents.map(a => ({
      'Matricule': a.matricule || '',
      'Nom': a.nom || '',
      'Prénom': a.prenom || '',
      'Email': a.email || '',
      'Téléphone': a.telephone || '',
      'Fonction': a.fonction || '',
      'Statut': a.statut || '',
      'Zone': a.zoneCollecte?.nom || 'Non assigné',
      'Date de naissance': a.dateNaissance ? formatDate(a.dateNaissance) : '',
    }))
    
    const ws = XLSX.utils.json_to_sheet(data)
    ws['!cols'] = [
      { wch: 12 }, { wch: 20 }, { wch: 20 }, { wch: 30 }, { wch: 15 },
      { wch: 15 }, { wch: 12 }, { wch: 20 }, { wch: 15 }
    ]
    
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Agents')
    
    const dateStr = new Date().toISOString().split('T')[0]
    XLSX.writeFile(wb, `agents_export_${dateStr}.xlsx`)
  } catch (error) {
    console.error('Erreur export Excel:', error)
    alert('Erreur lors de l\'export Excel')
  } finally {
    exporting.value = false
  }
}

// Fetch zones for filter
const fetchZones = async () => {
  try {
    const response = await zoneService.getAllZones()
    zones.value = response.data || []
  } catch (error) {
    console.error('Erreur chargement zones:', error)
    zones.value = []
  }
}

// Lifecycle
onMounted(() => {
  loadPage()
  fetchZones()
})
</script>

<style scoped>
.slide-panel-enter-active,
.slide-panel-leave-active {
  transition: all 0.3s ease;
}
.slide-panel-enter-from,
.slide-panel-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}
</style>
