<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Carte des Contribuables - Grand-Bassam</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="refreshData"
              :disabled="loading"
              class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Actualiser
            </button>
            <button
              @click="exportData"
              data-testid="export-csv"
              class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              Exporter
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

      <!-- Contribuables Content -->
      <div class="flex-1 p-6">
        <!-- Tabs -->
        <div class="mb-6">
          <div class="border-b border-gray-200">
            <nav class="-mb-px flex space-x-8" aria-label="Tabs">
              <button
                @click="activeTab = 'carte'"
                :class="[
                  activeTab === 'carte'
                    ? 'border-primary-500 text-primary-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
                  'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm'
                ]"
              >
                <svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
                </svg>
                Carte & Zones
              </button>
              <button
                @click="activeTab = 'liste'"
                :class="[
                  activeTab === 'liste'
                    ? 'border-primary-500 text-primary-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
                  'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm'
                ]"
              >
                <svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                </svg>
                Liste des Contribuables
              </button>
            </nav>
          </div>
        </div>

        <!-- Tab: Carte -->
        <div v-show="activeTab === 'carte'">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-primary-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Contribuables</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.totalContribuables }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Zones</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.totalZones }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Collecteurs</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.totalCollecteurs }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Moyenne/Zone</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ stats.moyenneParZone }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Map and Zones Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Map Section -->
          <div class="lg:col-span-2">
            <div class="bg-white shadow rounded-lg overflow-hidden">
              <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Carte des Zones - Grand-Bassam</h3>
                <p class="mt-1 max-w-2xl text-sm text-gray-500">
                  Visualisation interactive des quartiers de Grand-Bassam avec répartition des contribuables et collecteurs
                </p>
              </div>
              <div class="p-4">
                <!-- Interactive Map -->
                <InteractiveMap
                  :zones="zones"
                  :selected-zone="selectedZone"
                  @zone-selected="selectZone"
                  @zone-clicked="onZoneClicked"
                />
              </div>
            </div>
          </div>

          <!-- Zones List -->
          <div class="lg:col-span-1">
            <div class="bg-white shadow rounded-lg">
              <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Liste des Zones</h3>
                <p class="mt-1 text-sm text-gray-500">Détails par zone de collecte</p>
              </div>
              <div class="p-4 max-h-96 overflow-y-auto">
                <div v-if="loading" class="text-center py-4">
                  <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
                </div>
                <div v-else class="space-y-3">
                  <div 
                    v-for="zone in zones" 
                    :key="zone.id"
                    @click="selectZone(zone)"
                    :class="[
                      'p-3 rounded-lg border cursor-pointer transition-colors',
                      selectedZone?.id === zone.id 
                        ? 'border-primary-500 bg-primary-50' 
                        : 'border-gray-200 hover:border-gray-300'
                    ]"
                  >
                    <div class="flex justify-between items-start mb-2">
                      <h4 class="font-medium text-gray-900">{{ zone.nom }}</h4>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        {{ zone.contribuables }} contribuables
                      </span>
                    </div>
                    <p class="text-sm text-gray-600 mb-2">{{ zone.description }}</p>
                    <div class="flex items-center justify-between text-sm">
                      <span class="text-gray-500">{{ zone.quartier }}</span>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        {{ zone.collecteurs }} collecteurs
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>

        <!-- Tab: Liste des Contribuables -->
        <div v-show="activeTab === 'liste'">
          <!-- Toolbar -->
          <div class="mb-4 flex items-center justify-between">
            <div class="flex items-center space-x-3 flex-1">
              <div class="relative flex-1 max-w-md">
                <input
                  v-model="searchQuery"
                  @input="onSearchInput"
                  data-testid="search-input"
                  type="text"
                  placeholder="Rechercher par nom, téléphone, numéro..."
                  class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                />
                <svg class="w-5 h-5 text-gray-400 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </div>
              <select v-model="filterType" @change="loadContribuables" data-testid="filter-type" class="border border-gray-300 rounded-md text-sm py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500">
                <option value="">Tous les types</option>
                <option value="ENTREPRISE">Entreprise</option>
                <option value="MARCHE_PLACE">Place de marché</option>
                <option value="MARCHAND_AMBULANT">Marchand ambulant</option>
                <option value="COMMERCANT">Commerçant</option>
                <option value="PROPRIETAIRE_FONCIER">Propriétaire foncier</option>
              </select>
            </div>
            <button
              @click="openCreateModal"
              class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
              Nouveau Contribuable
            </button>
          </div>

          <!-- Table -->
          <div data-testid="contribuables-table" class="bg-white shadow rounded-lg overflow-hidden">
            <div v-if="contribuableLoading" class="text-center py-12">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
              <p class="mt-2 text-sm text-gray-500">Chargement...</p>
            </div>
            <div v-else-if="contribuables.length === 0" class="text-center py-12">
              <p class="text-gray-500">Aucun contribuable trouvé</p>
            </div>
            <table v-else class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">N° Contribuable</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nom</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Téléphone</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Activité</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Base imposable</th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="c in contribuables" :key="c.id" class="hover:bg-gray-50">
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ c.numeroContribuable || '—' }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ c.nom }} {{ c.prenom }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ c.telephone || '—' }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm">
                    <span :class="getTypeBadgeClass(c.typeContribuable)" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium">
                      {{ formatType(c.typeContribuable) }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ c.activite || '—' }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ c.baseImposable ? formatMoney(c.baseImposable) : '—' }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button @click="openEditModal(c)" class="text-primary-600 hover:text-primary-900 mr-3">Modifier</button>
                    <button @click="confirmDelete(c)" class="text-red-600 hover:text-red-900">Supprimer</button>
                  </td>
                </tr>
              </tbody>
            </table>
            <!-- Pagination -->
            <div class="px-6 py-3 border-t border-gray-200 flex items-center justify-between">
              <div class="flex items-center text-sm text-gray-600">
                <span>Affichage de </span>
                <span class="font-medium mx-1">{{ rangeStart }}</span>
                <span>à</span>
                <span class="font-medium mx-1">{{ rangeEnd }}</span>
                <span>sur</span>
                <span class="font-medium mx-1">{{ totalElements }}</span>
                <span>contribuable(s)</span>
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
                  :disabled="currentPage === 0 || contribuableLoading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Première page"
                >
                  <ChevronsLeft class="w-4 h-4" />
                </button>
                <button
                  @click="goToPage(currentPage - 1)"
                  :disabled="currentPage === 0 || contribuableLoading"
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
                  :disabled="isLastPage || contribuableLoading"
                  data-testid="pagination-next"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Page suivante"
                >
                  <ChevronRight class="w-4 h-4" />
                </button>
                <button
                  @click="goToPage(totalPages - 1)"
                  :disabled="isLastPage || contribuableLoading"
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

    <!-- Modal Create/Edit -->
    <div v-if="showModal" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="closeModal"></div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">
              {{ editingContribuable ? 'Modifier' : 'Nouveau' }} Contribuable
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Nom *</label>
                <input v-model="formData.nom" type="text" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Prénom *</label>
                <input v-model="formData.prenom" type="text" required class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Téléphone</label>
                <input v-model="formData.telephone" type="text" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Email</label>
                <input v-model="formData.email" type="email" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Type *</label>
                <select v-model="formData.typeContribuable" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500">
                  <option value="ENTREPRISE">Entreprise</option>
                  <option value="MARCHE_PLACE">Place de marché</option>
                  <option value="MARCHAND_AMBULANT">Marchand ambulant</option>
                  <option value="COMMERCANT">Commerçant</option>
                  <option value="PROPRIETAIRE_FONCIER">Propriétaire foncier</option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Activité</label>
                <input v-model="formData.activite" type="text" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Zone *</label>
                <select v-model="formData.zoneId" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500">
                  <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.nom }}</option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Base imposable (FCFA)</label>
                <input v-model="formData.baseImposable" type="number" step="0.01" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">Type de pièce</label>
                <input v-model="formData.typePieceIdentite" type="text" placeholder="CNI, RC, etc." class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700">N° de pièce</label>
                <input v-model="formData.numeroPiece" type="text" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
              <div class="md:col-span-2">
                <label class="block text-sm font-medium text-gray-700">Adresse</label>
                <input v-model="formData.adresse" type="text" class="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" />
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button @click="saveContribuable" :disabled="modalLoading" type="button" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-primary-600 text-base font-medium text-white hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50">
              {{ modalLoading ? 'Enregistrement...' : 'Enregistrer' }}
            </button>
            <button @click="closeModal" type="button" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">Annuler</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete confirmation -->
    <div v-if="showDeleteConfirm" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="showDeleteConfirm = false"></div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                <h3 class="text-lg leading-6 font-medium text-gray-900">Supprimer le contribuable</h3>
                <div class="mt-2">
                  <p class="text-sm text-gray-500">Êtes-vous sûr de vouloir supprimer <strong>{{ contribuableToDelete?.nom }} {{ contribuableToDelete?.prenom }}</strong> ? Cette action est irréversible.</p>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button @click="deleteContribuable" type="button" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm">Supprimer</button>
            <button @click="showDeleteConfirm = false" type="button" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">Annuler</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { agentService, zoneService, contribuableService } from '@/services'
import InteractiveMap from '@/components/InteractiveMap.vue'
import Sidebar from '@/components/Sidebar.vue'
import {
  ChevronLeft, ChevronRight, ChevronsLeft, ChevronsRight
} from 'lucide-vue-next'

// Active tab
const activeTab = ref('carte')

// Reactive data
const loading = ref(false)
const zones = ref([])
const selectedZone = ref(null)
const agents = ref([])

// Contribuables CRUD state
const contribuables = ref([])
const contribuableLoading = ref(false)
const searchQuery = ref('')
const filterType = ref('')
const currentPage = ref(0)
const totalPages = ref(0)
const pageSize = ref(10)
let searchTimeout = null

// Modal state
const showModal = ref(false)
const modalLoading = ref(false)
const editingContribuable = ref(null)
const showDeleteConfirm = ref(false)
const contribuableToDelete = ref(null)

const emptyForm = {
  nom: '',
  prenom: '',
  telephone: '',
  email: '',
  typeContribuable: 'COMMERCANT',
  activite: '',
  zoneId: null,
  baseImposable: null,
  typePieceIdentite: '',
  numeroPiece: '',
  adresse: '',
}
const formData = ref({ ...emptyForm })

// Stats computed
const stats = computed(() => {
  const totalContribuables = zones.value.reduce((sum, zone) => sum + zone.contribuables, 0)
  const totalZones = zones.value.length
  const totalCollecteurs = zones.value.reduce((sum, zone) => sum + zone.collecteurs, 0)
  const moyenneParZone = totalZones > 0 ? Math.round(totalContribuables / totalZones) : 0

  return {
    totalContribuables,
    totalZones,
    totalCollecteurs,
    moyenneParZone
  }
})

// Methods
const refreshData = async () => {
  await Promise.all([fetchZones(), fetchAgents()])
}

const exportData = () => {
  const data = {
    zones: zones.value,
    agents: agents.value,
    stats: stats.value,
    exportDate: new Date().toISOString()
  }
  
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `contribuables-zones-${new Date().toISOString().split('T')[0]}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

const selectZone = (zone) => {
  selectedZone.value = zone
}

const onZoneClicked = (zone) => {
  selectZone(zone)
}

const fetchZones = async () => {
  try {
    loading.value = true
    const response = await zoneService.getAllZones()
    const zoneData = response.data || []
    
    zones.value = zoneData.map(zone => ({
      id: zone.id,
      nom: zone.nom || '—',
      description: zone.description || '',
      quartier: zone.quartier || zone.secteur?.nom || '',
      contribuables: zone.nombreContribuables || 0,
      collecteurs: zone.nombreCollecteurs || 0,
      coordinates: zone.coordinates || null
    }))
  } catch (error) {
    console.error('Erreur lors du chargement des zones:', error)
    zones.value = []
  } finally {
    loading.value = false
  }
}

const fetchAgents = async () => {
  try {
    const response = await agentService.getAllAgents()
    agents.value = response.data || []
  } catch (error) {
    console.error('Erreur lors du chargement des agents:', error)
    agents.value = []
  }
}

// --- Contribuables CRUD ---
const loadContribuables = async () => {
  contribuableLoading.value = true
  try {
    let response
    const pageParams = { page: currentPage.value, size: pageSize.value }

    if (searchQuery.value && searchQuery.value.trim()) {
      // Recherche par terme
      const filters = {}
      if (filterType.value) filters.typeContribuable = filterType.value
      response = await contribuableService.searchContribuables(searchQuery.value.trim(), {
        ...pageParams,
        ...filters,
      })
    } else if (filterType.value) {
      // Filtrage par type
      response = await contribuableService.get('/filter', { typeContribuable: filterType.value, ...pageParams })
    } else {
      // Pagination simple
      response = await contribuableService.getAllContribuables(pageParams)
    }

    const data = response.data
    if (Array.isArray(data)) {
      contribuables.value = data
      totalPages.value = 1
      totalElementsServer.value = data.length
    } else if (data && data.content) {
      contribuables.value = data.content
      totalPages.value = data.totalPages || 1
      totalElementsServer.value = data.totalElements || data.content.length
    } else {
      contribuables.value = []
      totalPages.value = 1
    }
  } catch (error) {
    console.error('Erreur lors du chargement des contribuables:', error)
    contribuables.value = []
  } finally {
    contribuableLoading.value = false
  }
}

const onSearchInput = () => {
  if (searchTimeout) clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    currentPage.value = 0
    loadContribuables()
  }, 300)
}

const changePage = (page) => {
  if (page < 0 || page >= totalPages.value) return
  currentPage.value = page
  loadContribuables()
}

const goToPage = (page) => {
  changePage(page)
}

const onPageSizeChange = () => {
  currentPage.value = 0
  loadContribuables()
}

const isLastPage = computed(() => currentPage.value >= totalPages.value - 1)
const rangeStart = computed(() => {
  if (totalElements.value === 0) return 0
  return currentPage.value * pageSize.value + 1
})
const rangeEnd = computed(() => Math.min((currentPage.value + 1) * pageSize.value, totalElements.value))
const totalElementsServer = ref(0)
const totalElements = computed(() => {
  if (totalPages.value <= 1) return contribuables.value.length
  return totalElementsServer.value || totalPages.value * pageSize.value
})

const openCreateModal = () => {
  editingContribuable.value = null
  formData.value = { ...emptyForm, zoneId: zones.value[0]?.id || null }
  showModal.value = true
}

const openEditModal = (contribuable) => {
  editingContribuable.value = contribuable
  formData.value = {
    nom: contribuable.nom || '',
    prenom: contribuable.prenom || '',
    telephone: contribuable.telephone || '',
    email: contribuable.email || '',
    typeContribuable: contribuable.typeContribuable || 'COMMERCANT',
    activite: contribuable.activite || '',
    zoneId: contribuable.zoneId || null,
    baseImposable: contribuable.baseImposable || null,
    typePieceIdentite: contribuable.typePieceIdentite || '',
    numeroPiece: contribuable.numeroPiece || '',
    adresse: contribuable.adresse || '',
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingContribuable.value = null
}

const saveContribuable = async () => {
  if (!formData.value.nom || !formData.value.prenom) {
    alert('Le nom et le prénom sont obligatoires')
    return
  }
  modalLoading.value = true
  try {
    const payload = { ...formData.value }
    if (payload.baseImposable) payload.baseImposable = Number(payload.baseImposable)
    if (payload.zoneId) payload.zoneId = Number(payload.zoneId)

    if (editingContribuable.value) {
      await contribuableService.updateContribuable(editingContribuable.value.id, payload)
    } else {
      await contribuableService.createContribuable(payload)
    }
    showModal.value = false
    await loadContribuables()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
    alert('Erreur lors de la sauvegarde du contribuable')
  } finally {
    modalLoading.value = false
  }
}

const confirmDelete = (contribuable) => {
  contribuableToDelete.value = contribuable
  showDeleteConfirm.value = true
}

const deleteContribuable = async () => {
  if (!contribuableToDelete.value) return
  try {
    await contribuableService.deleteContribuable(contribuableToDelete.value.id)
    showDeleteConfirm.value = false
    contribuableToDelete.value = null
    await loadContribuables()
  } catch (error) {
    console.error('Erreur lors de la suppression:', error)
    alert('Erreur lors de la suppression du contribuable')
  }
}

const formatType = (type) => {
  const labels = {
    ENTREPRISE: 'Entreprise',
    MARCHE_PLACE: 'Place de marché',
    MARCHAND_AMBULANT: 'Marchand ambulant',
    COMMERCANT: 'Commerçant',
    PROPRIETAIRE_FONCIER: 'Propriétaire foncier',
  }
  return labels[type] || type || '—'
}

const getTypeBadgeClass = (type) => {
  const classes = {
    ENTREPRISE: 'bg-purple-100 text-purple-800',
    MARCHE_PLACE: 'bg-blue-100 text-blue-800',
    MARCHAND_AMBULANT: 'bg-yellow-100 text-yellow-800',
    COMMERCANT: 'bg-green-100 text-green-800',
    PROPRIETAIRE_FONCIER: 'bg-indigo-100 text-indigo-800',
  }
  return classes[type] || 'bg-gray-100 text-gray-800'
}

const formatMoney = (value) => {
  if (!value && value !== 0) return '—'
  return new Intl.NumberFormat('fr-FR').format(value) + ' FCFA'
}

// Load contribuables when switching to list tab
watch(activeTab, (newTab) => {
  if (newTab === 'liste' && contribuables.value.length === 0) {
    loadContribuables()
  }
})

// Lifecycle
onMounted(() => {
  fetchZones()
  fetchAgents()
})
</script>

<style scoped>
#map {
  height: 400px;
  border-radius: 0.5rem;
}

/* Custom scrollbar */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>