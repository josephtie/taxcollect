<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Gestion des Taxes</h1>
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
              v-if="canCreateTaxe"
              @click="showCreateModal = true"
              class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
              Nouvelle Taxe
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

      <!-- Taxes Content -->
      <div class="flex-1 p-6">
        <!-- Tabs -->
        <div class="border-b border-gray-200 mb-6">
          <nav class="-mb-px flex space-x-8">
            <button
              @click="activeTab = 'taxes'"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'taxes'
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              Taxes
            </button>
            <button
              v-permission="'assessments.view'"
              @click="activeTab = 'avis'; loadAvisForTaxe()"
              :class="[
                'py-2 px-1 border-b-2 font-medium text-sm',
                activeTab === 'avis'
                  ? 'border-primary-500 text-primary-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              ]"
            >
              Avis d'imposition
            </button>
          </nav>
        </div>

        <!-- Alert for read-only users -->
        <div v-if="!canCreateTaxe && activeTab === 'taxes'" class="bg-primary-50 border border-primary-200 rounded-lg p-4 mb-6">
          <div class="flex">
            <div class="flex-shrink-0">
              <svg class="h-5 w-5 text-primary-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-primary-800">Mode consultation</h3>
              <div class="mt-2 text-sm text-primary-700">
                <p>Vous pouvez consulter les taxes mais pas les modifier. Contactez un administrateur pour toute modification.</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Stats Cards -->
        <div v-if="activeTab === 'taxes'" class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-primary-500 rounded-md flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Total Taxes</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ taxes.length }}</dd>
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
                    <dt class="text-sm font-medium text-gray-500 truncate">Taux Moyen</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ tauxMoyen }}%</dd>
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
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Catégories</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ categories.length }}</dd>
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
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Périodicités</dt>
                    <dd class="text-lg font-medium text-gray-900">{{ periodicites.length }}</dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Filters -->
        <div v-if="activeTab === 'taxes'" class="bg-white shadow rounded-lg mb-6 p-4">
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Recherche</label>
              <input
                v-model="filters.search"
                type="text"
                placeholder="Nom ou description..."
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie</label>
              <select
                v-model="filters.categorie"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Toutes</option>
                <option v-for="cat in categories" :key="cat" :value="cat">
                  {{ formatCategorie(cat) }}
                </option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Périodicité</label>
              <select
                v-model="filters.periodicite"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Toutes</option>
                <option v-for="per in periodicites" :key="per" :value="per">
                  {{ formatPeriodicite(per) }}
                </option>
              </select>
            </div>
            <div class="flex items-end">
              <button
                @click="applyFilters"
                class="w-full px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
              >
                Filtrer
              </button>
            </div>
          </div>
        </div>

        <!-- Taxes Table -->
        <div v-if="activeTab === 'taxes'" data-testid="taxes-table" class="bg-white shadow rounded-lg overflow-hidden">
          <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
            <h3 class="text-lg leading-6 font-medium text-gray-900">Liste des Taxes</h3>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Nom
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Description
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Valeur
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Catégorie
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Périodicité
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-if="loading">
                  <td colspan="6" class="px-6 py-4 text-center">
                    <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
                  </td>
                </tr>
                <tr v-else-if="paginatedTaxes.length === 0">
                  <td colspan="6" class="px-6 py-4 text-center text-gray-500">
                    Aucune taxe trouvée
                  </td>
                </tr>
                <tr v-else v-for="taxe in paginatedTaxes" :key="taxe.id" class="hover:bg-gray-50">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium text-gray-900">{{ taxe.nom }}</div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="text-sm text-gray-500 max-w-xs truncate">{{ taxe.description || '-' }}</div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span v-if="taxe.typeCalcul === 'TAUX'" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                      {{ (taxe.taux * 100).toFixed(1) }}%
                    </span>
                    <span v-else-if="taxe.typeCalcul === 'MONTANT'" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      {{ formatMontant(taxe.montantFixe) }} FCFA
                    </span>
                    <span v-else class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                      -
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                      {{ formatCategorie(taxe.categorie) }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      {{ formatPeriodicite(taxe.periodicite) }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div class="flex items-center space-x-2">
                      <!-- Actions de base -->
                      <button
                        @click="viewTaxeDetails(taxe)"
                        class="text-primary-600 hover:text-primary-900"
                        title="Voir les détails"
                      >
                        <Eye class="w-4 h-4" />
                      </button>
                      <button
                        @click="editTaxe(taxe)"
                        class="text-warning-600 hover:text-warning-900"
                        title="Modifier"
                      >
                        <Edit class="w-4 h-4" />
                      </button>
                       <!-- Actions de suppression logique -->
                      <LogicalDeletionActions
                        :entity="taxe"
                        endpoint="taxe"
                        entity-name="la taxe"
                        :can-delete="canDeleteTaxe"
                        :can-restore="canRestoreTaxe"
                        :display-field="'nom'"
                        @deleted="handleTaxeDeleted"
                        @restored="handleTaxeRestored"
                      />
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <!-- Taxes Pagination -->
          <div class="px-6 py-3 border-t border-gray-200 flex items-center justify-between">
            <div class="flex items-center text-sm text-gray-600">
              <span>Affichage de </span>
              <span class="font-medium mx-1">{{ taxesRangeStart }}</span>
              <span>à</span>
              <span class="font-medium mx-1">{{ taxesRangeEnd }}</span>
              <span>sur</span>
              <span class="font-medium mx-1">{{ taxesTotalElements }}</span>
              <span>taxe(s)</span>
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
                :disabled="currentPage === 0 || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Première page"
              >
                <ChevronsLeft class="w-4 h-4" />
              </button>
              <button
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 0 || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Page précédente"
              >
                <ChevronLeft class="w-4 h-4" />
              </button>
              <span class="text-sm text-gray-700 px-2">
                Page <span class="font-medium">{{ currentPage + 1 }}</span> / <span class="font-medium">{{ taxesTotalPages }}</span>
              </span>
              <button
                @click="goToPage(currentPage + 1)"
                :disabled="taxesIsLastPage || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Page suivante"
              >
                <ChevronRight class="w-4 h-4" />
              </button>
              <button
                @click="goToPage(taxesTotalPages - 1)"
                :disabled="taxesIsLastPage || loading"
                class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                title="Dernière page"
              >
                <ChevronsRight class="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
        <div v-if="activeTab === 'avis'">
          <!-- Avis Controls -->
          <div class="bg-white shadow rounded-lg mb-6 p-4">
            <div class="flex flex-wrap items-center gap-4">
              <div class="flex-1 min-w-48">
                <label class="block text-sm font-medium text-gray-700 mb-1">Taxe</label>
                <select
                  v-model="avisFilter.taxeId"
                  @change="loadAvisForTaxe"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                >
                  <option value="">Toutes les taxes</option>
                  <option v-for="taxe in taxes" :key="taxe.id" :value="taxe.id">
                    {{ taxe.nom }} ({{ formatPeriodicite(taxe.periodicite) }})
                  </option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Période début</label>
                <input
                  type="date"
                  v-model="avisFilter.periodStart"
                  @change="loadAvisForTaxe"
                  class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Période fin</label>
                <input
                  type="date"
                  v-model="avisFilter.periodEnd"
                  @change="loadAvisForTaxe"
                  class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <div class="flex items-end gap-2">
                <button
              v-permission="'assessments.generate'"
              @click="generateAvis"
              :disabled="avisGenerating"
              data-testid="generate-avis"
              class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 disabled:opacity-50 text-sm font-medium"
            >
                  {{ avisGenerating ? 'Génération...' : 'Générer les avis' }}
                </button>
                <button
                  v-permission="'assessments.manage'"
                  @click="markOverdueAvis"
                  class="px-4 py-2 border border-orange-300 text-orange-700 bg-orange-50 rounded-md hover:bg-orange-100 text-sm font-medium"
                >
                  Marquer en retard
                </button>
              </div>
            </div>
          </div>

          <!-- Avis Stats -->
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div class="bg-white rounded-lg shadow p-4">
              <p class="text-sm text-gray-500">Total avis</p>
              <p class="text-xl font-semibold text-gray-900">{{ avisList.length }}</p>
            </div>
            <div class="bg-white rounded-lg shadow p-4">
              <p class="text-sm text-gray-500">Impayés</p>
              <p class="text-xl font-semibold text-yellow-600">{{ avisList.filter(a => a.statut === 'IMPAYE').length }}</p>
            </div>
            <div class="bg-white rounded-lg shadow p-4">
              <p class="text-sm text-gray-500">En retard</p>
              <p class="text-xl font-semibold text-red-600">{{ avisList.filter(a => a.statut === 'EN_RETARD').length }}</p>
            </div>
            <div class="bg-white rounded-lg shadow p-4">
              <p class="text-sm text-gray-500">Payés</p>
              <p class="text-xl font-semibold text-green-600">{{ avisList.filter(a => a.statut === 'PAYE').length }}</p>
            </div>
          </div>

          <!-- Avis Table -->
          <div data-testid="avis-table" class="bg-white shadow rounded-lg overflow-hidden">
            <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
              <h3 class="text-lg leading-6 font-medium text-gray-900">Avis d'imposition</h3>
            </div>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Référence</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contribuable</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Taxe</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Période</th>
                    <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Montant</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Échéance</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Statut</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-if="avisLoading">
                    <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                      <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-primary-600 mx-auto"></div>
                    </td>
                  </tr>
                  <tr v-else-if="paginatedAvis.length === 0">
                    <td colspan="7" class="px-6 py-12 text-center text-gray-500">
                      Aucun avis trouvé pour cette période
                    </td>
                  </tr>
                  <tr v-else v-for="avis in paginatedAvis" :key="avis.id" class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ avis.reference || '—' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      Contribuable #{{ avis.contribuableId }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {{ avis.taxType || '—' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div v-if="avis.periodStart">
                        {{ formatDate(avis.periodStart) }} → {{ formatDate(avis.periodEnd) }}
                      </div>
                      <div v-else>{{ avis.periodeConcernee || '—' }}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-right font-medium text-gray-900">
                      {{ formatMontant(avis.montant) }} FCFA
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <span :class="{ 'text-red-600 font-medium': isAvisOverdue(avis) }">
                        {{ formatDate(avis.dueDate) }}
                      </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <StatusBadge :status="avis.statut" type="assessment" />
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <!-- Avis Pagination -->
            <div class="px-6 py-3 border-t border-gray-200 flex items-center justify-between">
              <div class="flex items-center text-sm text-gray-600">
                <span>Affichage de </span>
                <span class="font-medium mx-1">{{ avisRangeStart }}</span>
                <span>à</span>
                <span class="font-medium mx-1">{{ avisRangeEnd }}</span>
                <span>sur</span>
                <span class="font-medium mx-1">{{ avisTotalElements }}</span>
                <span>avis</span>
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
                  :disabled="currentPage === 0 || avisLoading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Première page"
                >
                  <ChevronsLeft class="w-4 h-4" />
                </button>
                <button
                  @click="goToPage(currentPage - 1)"
                  :disabled="currentPage === 0 || avisLoading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Page précédente"
                >
                  <ChevronLeft class="w-4 h-4" />
                </button>
                <span class="text-sm text-gray-700 px-2">
                  Page <span class="font-medium">{{ currentPage + 1 }}</span> / <span class="font-medium">{{ avisTotalPages }}</span>
                </span>
                <button
                  @click="goToPage(currentPage + 1)"
                  :disabled="avisIsLastPage || avisLoading"
                  class="p-1.5 rounded-md border border-gray-300 text-gray-600 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed"
                  title="Page suivante"
                >
                  <ChevronRight class="w-4 h-4" />
                </button>
                <button
                  @click="goToPage(avisTotalPages - 1)"
                  :disabled="avisIsLastPage || avisLoading"
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

    <!-- Create/Edit Modal -->
    <div v-if="showCreateModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="modal-header">
          {{ editingTaxe ? 'Modifier' : 'Créer' }} une Taxe
        </h3>
        
        <form @submit.prevent="saveTaxe">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nom de la taxe *</label>
              <input
                v-model="taxeForm.nom"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                placeholder="Ex: Taxe de marché"
              />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Description</label>
              <textarea
                v-model="taxeForm.description"
                rows="3"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                placeholder="Description de la taxe..."
              ></textarea>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Type de calcul *</label>
              <select
                v-model="taxeForm.typeCalcul"
                required
                @change="onTypeCalculChange"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="TAUX">Taux (%)</option>
                <option value="MONTANT">Montant fixe</option>
              </select>
            </div>
            
            <div v-if="taxeForm.typeCalcul === 'TAUX'">
              <label class="block text-sm font-medium text-gray-700 mb-1">Taux (%) *</label>
              <input
                v-model.number="taxeForm.taux"
                type="number"
                step="0.01"
                min="0"
                max="100"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                placeholder="Ex: 10"
              />
            </div>
            
            <div v-if="taxeForm.typeCalcul === 'MONTANT'">
              <label class="block text-sm font-medium text-gray-700 mb-1">Montant fixe (FCFA) *</label>
              <input
                v-model.number="taxeForm.montantFixe"
                type="number"
                step="100"
                min="0"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
                placeholder="Ex: 5000"
              />
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Catégorie *</label>
              <select
                v-model="taxeForm.categorie"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Sélectionner une catégorie</option>
                <option v-for="cat in categories" :key="cat" :value="cat">
                  {{ formatCategorie(cat) }}
                </option>
              </select>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Périodicité *</label>
              <select
                v-model="taxeForm.periodicite"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">Sélectionner une periodicité</option>
                <option v-for="per in periodicites" :key="per" :value="per">
                  {{ formatPeriodicite(per) }}
                </option>
              </select>
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 mt-6">
            <button
              type="button"
              @click="closeModal"
              class="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              Annuler
            </button>
            <button
              type="submit"
              :disabled="saving"
              class="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
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
import { ref, computed, onMounted, watch } from 'vue'
import { taxeService, permissionService, assessmentService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import LogicalDeletionActions from '@/components/LogicalDeletionActions.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { Eye, Edit, ChevronLeft, ChevronRight, ChevronsLeft, ChevronsRight } from 'lucide-vue-next'

// State
const loading = ref(false)
const showCreateModal = ref(false)
const editingTaxe = ref(null)
const saving = ref(false)
const taxes = ref([])
const activeTab = ref('taxes')

// Pagination state (shared, reset on tab switch)
const currentPage = ref(0)
const pageSize = ref(10)

// Avis state
const avisList = ref([])
const avisLoading = ref(false)
const avisGenerating = ref(false)
const avisFilter = ref({
  taxeId: '',
  periodStart: '',
  periodEnd: ''
})

const filters = ref({
  search: '',
  categorie: '',
  periodicite: ''
})

const taxeForm = ref({
  nom: '',
  description: '',
  taux: '',
  montantFixe: '',
  typeCalcul: 'TAUX',
  categorie: '',
  periodicite: ''
})

// Constants
const categories = [
  'MARCHE_PLACE',
  'MARCHAND_AMBULANT',
  'COMMERCANT',
  'PROPRIETAIRE_FONCIER',
  'ENTREPRISE',
  'AUTRE'
]

const periodicites = [
  'JOURNALIERE',
  'MENSUELLE',
  'TRIMESTRIELLE',
  'ANNUELLE'
]

// Computed
const canCreateTaxe = computed(() => permissionService.hasPermission('taxes.create'))
const canEditTaxe = computed(() => permissionService.hasPermission('taxes.edit'))
const canDeleteTaxe = computed(() => permissionService.hasPermission('taxes.delete'))
const canRestoreTaxe = computed(() => permissionService.hasPermission('taxes.restore'))

const filteredTaxes = computed(() => {
  let filtered = taxes.value

  if (filters.value.search) {
    const search = filters.value.search.toLowerCase()
    filtered = filtered.filter(taxe => 
      taxe.nom.toLowerCase().includes(search) ||
      (taxe.description && taxe.description.toLowerCase().includes(search))
    )
  }

  if (filters.value.categorie) {
    filtered = filtered.filter(taxe => taxe.categorie === filters.value.categorie)
  }

  if (filters.value.periodicite) {
    filtered = filtered.filter(taxe => taxe.periodicite === filters.value.periodicite)
  }

  return filtered
})

// Taxes pagination computed
const taxesTotalPages = computed(() => Math.max(1, Math.ceil(filteredTaxes.value.length / pageSize.value)))
const taxesTotalElements = computed(() => filteredTaxes.value.length)
const taxesIsLastPage = computed(() => currentPage.value >= taxesTotalPages.value - 1)
const taxesRangeStart = computed(() => taxesTotalElements.value === 0 ? 0 : currentPage.value * pageSize.value + 1)
const taxesRangeEnd = computed(() => Math.min((currentPage.value + 1) * pageSize.value, taxesTotalElements.value))

const paginatedTaxes = computed(() => {
  const start = currentPage.value * pageSize.value
  return filteredTaxes.value.slice(start, start + pageSize.value)
})

// Avis pagination computed
const avisTotalPages = computed(() => Math.max(1, Math.ceil(filteredAvis.value.length / pageSize.value)))
const avisTotalElements = computed(() => filteredAvis.value.length)
const avisIsLastPage = computed(() => currentPage.value >= avisTotalPages.value - 1)
const avisRangeStart = computed(() => avisTotalElements.value === 0 ? 0 : currentPage.value * pageSize.value + 1)
const avisRangeEnd = computed(() => Math.min((currentPage.value + 1) * pageSize.value, avisTotalElements.value))

const paginatedAvis = computed(() => {
  const start = currentPage.value * pageSize.value
  return filteredAvis.value.slice(start, start + pageSize.value)
})

const filteredAvis = computed(() => {
  return avisList.value
})

// Reset page when filters change
watch([() => filters.value.search, () => filters.value.categorie, () => filters.value.periodicite], () => {
  currentPage.value = 0
})
watch(activeTab, () => {
  currentPage.value = 0
})

function goToPage(page) {
  if (page < 0) return
  if (activeTab.value === 'taxes' && page >= taxesTotalPages.value) return
  if (activeTab.value === 'avis' && page >= avisTotalPages.value) return
  currentPage.value = page
}

function onPageSizeChange() {
  currentPage.value = 0
}

const tauxMoyen = computed(() => {
  if (taxes.value.length === 0) return 0
  const total = taxes.value.reduce((sum, taxe) => sum + taxe.taux, 0)
  return ((total / taxes.value.length) * 100).toFixed(1)
})

// Methods
const formatCategorie = (categorie) => {
  const labels = {
    'MARCHE_PLACE': 'Marché Place',
    'MARCHAND_AMBULANT': 'Marchand Ambulant',
    'COMMERCANT': 'Commerçant',
    'PROPRIETAIRE_FONCIER': 'Propriétaire Foncier',
    'ENTREPRISE': 'Entreprise',
    'AUTRE': 'Autre'
  }
  return labels[categorie] || categorie
}

const formatPeriodicite = (periodicite) => {
  const labels = {
    'JOURNALIERE': 'Journalière',
    'MENSUELLE': 'Mensuelle',
    'TRIMESTRIELLE': 'Trimestrielle',
    'ANNUELLE': 'Annuelle'
  }
  return labels[periodicite] || periodicite
}

const formatMontant = (montant) => {
  return new Intl.NumberFormat('fr-FR').format(montant || 0)
}

const onTypeCalculChange = () => {
  // Réinitialiser les valeurs quand on change de type
  if (taxeForm.value.typeCalcul === 'TAUX') {
    taxeForm.value.montantFixe = ''
  } else {
    taxeForm.value.taux = ''
  }
}

const fetchTaxes = async () => {
  try {
    loading.value = true
    const response = await taxeService.getAllTaxes()
    taxes.value = response.data || []
  } catch (error) {
    console.error('Erreur chargement taxes:', error)
    // Fallback avec données mock
    taxes.value = [
      {
        id: 1,
        nom: 'Taxe de Marché Central',
        description: 'Taxe pour les commerçants du marché central',
        taux: 0.10,
        montantFixe: null,
        typeCalcul: 'TAUX',
        categorie: 'MARCHE_PLACE',
        periodicite: 'MENSUELLE'
      },
      {
        id: 2,
        nom: 'Taxe Ambulante',
        description: 'Taxe pour les marchands ambulants',
        taux: null,
        montantFixe: 5000,
        typeCalcul: 'MONTANT',
        categorie: 'MARCHAND_AMBULANT',
        periodicite: 'JOURNALIERE'
      },
      {
        id: 3,
        nom: 'Taxe Commerçant',
        description: 'Taxe fixe pour les commerçants',
        taux: null,
        montantFixe: 25000,
        typeCalcul: 'MONTANT',
        categorie: 'COMMERCANT',
        periodicite: 'MENSUELLE'
      },
      {
        id: 4,
        nom: 'Taxe Foncière',
        description: 'Taxe sur la propriété',
        taux: 0.15,
        montantFixe: null,
        typeCalcul: 'TAUX',
        categorie: 'PROPRIETAIRE_FONCIER',
        periodicite: 'ANNUELLE'
      }
    ]
  } finally {
    loading.value = false
  }
}

const refreshData = async () => {
  await fetchTaxes()
}

const applyFilters = () => {
  // Les filtres sont appliqués automatiquement via le computed
}

const editTaxe = (taxe) => {
  editingTaxe.value = taxe
  taxeForm.value = {
    nom: taxe.nom,
    description: taxe.description || '',
    taux: taxe.taux ? (taxe.taux * 100).toFixed(1) : '',
    montantFixe: taxe.montantFixe || '',
    typeCalcul: taxe.typeCalcul || 'TAUX',
    categorie: taxe.categorie,
    periodicite: taxe.periodicite
  }
  showCreateModal.value = true
}

const deleteTaxe = async (taxe) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer la taxe "${taxe.nom}"?`)) {
    try {
      await taxeService.deleteTaxe(taxe.id)
      await fetchTaxes()
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
    }
  }
}

const saveTaxe = async () => {
  saving.value = true
  try {
    // Validation des champs obligatoires
    if (!taxeForm.value.categorie) {
      alert('Veuillez sélectionner une catégorie')
      saving.value = false
      return
    }
    if (!taxeForm.value.periodicite) {
      alert('Veuillez sélectionner une périodicité')
      saving.value = false
      return
    }
    if (!taxeForm.value.typeCalcul) {
      alert('Veuillez sélectionner un type de calcul')
      saving.value = false
      return
    }

    const taxeData = {
      nom: taxeForm.value.nom,
      description: taxeForm.value.description,
      categorie: taxeForm.value.categorie,
      periodicite: taxeForm.value.periodicite,
      typeCalcul: taxeForm.value.typeCalcul
    }

    // Ajouter soit le taux soit le montant fixe selon le type
    if (taxeForm.value.typeCalcul === 'TAUX') {
      taxeData.taux = taxeForm.value.taux / 100 // Convertir en décimal
      taxeData.montantFixe = null
    } else {
      taxeData.montantFixe = taxeForm.value.montantFixe
      taxeData.taux = null
    }

    const response = editingTaxe.value 
      ? await taxeService.updateTaxe(editingTaxe.value.id, taxeData)
      : await taxeService.createTaxe(taxeData)
    
    console.log(editingTaxe.value ? 'Taxe mise à jour avec succès:' : 'Taxe créée avec succès:', response.data)
    
    await fetchTaxes()
    closeModal()
  } catch (error) {
    console.error('Erreur lors de l\'enregistrement:', error)
    const errorMessage = error.response?.data || error.message
    const action = editingTaxe.value ? 'mise à jour' : 'création'
    alert('Erreur lors de la ' + action + ': ' + errorMessage)
  } finally {
    saving.value = false
  }
}

const closeModal = () => {
  showCreateModal.value = false
  editingTaxe.value = null
  taxeForm.value = {
    nom: '',
    description: '',
    taux: '',
    montantFixe: '',
    typeCalcul: 'TAUX',
    categorie: '',
    periodicite: ''
  }
  console.log('Modal fermé et formulaire réinitialisé')
}

// Méthodes pour la suppression logique
const handleTaxeDeleted = (taxe) => {
  console.log('Taxe supprimée:', taxe)
  // Rafraîchir la liste des taxes
  fetchTaxes()
  // Afficher une notification de succès
  alert('Taxe supprimée avec succès')
}

const handleTaxeRestored = (taxe) => {
  console.log('Taxe restaurée:', taxe)
  // Rafraîchir la liste des taxes
  fetchTaxes()
  // Afficher une notification de succès
  alert('Taxe restaurée avec succès')
}

const viewTaxeDetails = (taxe) => {
  // Implémenter la vue des détails
  console.log('View taxe:', taxe)
}

// Avis methods
const formatDate = (dateStr) => {
  if (!dateStr) return '—'
  return new Date(dateStr).toLocaleDateString('fr-FR')
}

const isAvisOverdue = (avis) => {
  if (!avis.dueDate) return false
  return new Date(avis.dueDate) < new Date() && avis.statut !== 'PAYE'
}

const loadAvisForTaxe = async () => {
  avisLoading.value = true
  try {
    const today = new Date()
    const start = avisFilter.value.periodStart || new Date(today.getFullYear(), today.getMonth() - 3, 1).toISOString().split('T')[0]
    const end = avisFilter.value.periodEnd || new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString().split('T')[0]

    const response = await assessmentService.findByPeriod(start, end)
    let allAvis = Array.isArray(response.data) ? response.data : []

    if (avisFilter.value.taxeId) {
      const taxe = taxes.value.find(t => t.id === avisFilter.value.taxeId)
      if (taxe) {
        allAvis = allAvis.filter(a => a.taxType === taxe.nom)
      }
    }

    avisList.value = allAvis
  } catch (err) {
    console.error('Error loading avis:', err)
    avisList.value = []
  } finally {
    avisLoading.value = false
  }
}

const generateAvis = async () => {
  avisGenerating.value = true
  try {
    const today = new Date().toISOString().split('T')[0]
    if (avisFilter.value.taxeId) {
      await assessmentService.generateForTaxe(avisFilter.value.taxeId, today)
    } else {
      await assessmentService.generateForAll(today)
    }
    await loadAvisForTaxe()
  } catch (err) {
    console.error('Error generating avis:', err)
    alert('Erreur lors de la génération: ' + (err.response?.data?.message || err.message))
  } finally {
    avisGenerating.value = false
  }
}

const markOverdueAvis = async () => {
  try {
    await assessmentService.markOverdue()
    await loadAvisForTaxe()
  } catch (err) {
    console.error('Error marking overdue:', err)
  }
}

// Lifecycle
onMounted(() => {
  fetchTaxes()
})
</script>
