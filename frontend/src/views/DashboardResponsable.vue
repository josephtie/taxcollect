<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Tableau de bord — {{ dashboard?.quartier?.nom || 'Quartier' }}</h1>
            <p class="text-xs text-gray-500">Responsable de quartier — suivi opérationnel terrain</p>
          </div>
          <button
            @click="loadDashboard"
            :disabled="loading"
            class="p-2 text-gray-600 hover:text-gray-900 transition-colors"
            title="Rafraîchir"
          >
            <RefreshCw :class="{ 'animate-spin': loading }" class="w-5 h-5" />
          </button>
        </div>
      </div>
    </header>

    <main class="flex">
      <aside class="w-64 min-h-screen bg-gray-900">
        <Sidebar />
      </aside>

      <div class="flex-1 p-6 space-y-6">
        <div v-if="loading" class="flex justify-center py-12">
          <Loader2 class="w-8 h-8 text-primary-600 animate-spin" />
        </div>
        <template v-else-if="dashboard">
          <!-- Progression du quartier -->
          <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-6">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide">Progression du quartier</h2>
              <span class="text-2xl font-bold text-primary-600">{{ dashboard.progression }}%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3">
              <div class="bg-primary-600 h-3 rounded-full transition-all duration-500" :style="{ width: `${Math.min(dashboard.progression, 100)}%` }"></div>
            </div>
            <p class="text-xs text-gray-500 mt-2">{{ dashboard.contribuables.visites }} / {{ dashboard.contribuables.total }} contribuables visités</p>
          </div>

          <!-- Secteurs & Agents -->
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <StatsCard title="Secteurs" :value="dashboard.secteurs.total" :icon="Map" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
            <StatsCard title="Agents actifs" :value="dashboard.agents.actifs" :icon="UserCheck" icon-color="text-success-600" icon-bg-color="bg-success-50" />
            <StatsCard title="Agents absents" :value="dashboard.agents.absents" :icon="UserX" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
          </div>

          <!-- Contribuables -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <Building class="w-4 h-4" /> Contribuables
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
              <StatsCard title="Total" :value="dashboard.contribuables.total" :icon="Building" icon-color="text-primary-600" icon-bg-color="bg-primary-50" />
              <StatsCard title="Visités" :value="dashboard.contribuables.visites" :icon="CheckCircle" icon-color="text-success-600" icon-bg-color="bg-success-50" />
              <StatsCard title="Non visités" :value="dashboard.contribuables.nonVisites" :icon="AlertCircle" icon-color="text-warning-600" icon-bg-color="bg-warning-50" />
              <StatsCard title="Nouveaux" :value="dashboard.contribuables.nouveaux" :icon="PlusCircle" icon-color="text-info-600" icon-bg-color="bg-info-50" />
              <StatsCard title="Impayés" :value="dashboard.contribuables.impayes" :icon="AlertTriangle" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
            </div>
          </div>

          <!-- Collecte -->
          <div>
            <h2 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3 flex items-center gap-2">
              <Wallet class="w-4 h-4" /> Collecte du jour
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <StatsCard title="Montant collecté" :value="dashboard.collecte.montantCollecte" :icon="Banknote" format="currency" icon-color="text-success-600" icon-bg-color="bg-success-50" />
              <StatsCard title="Impayés" :value="dashboard.collecte.impayes" :icon="AlertCircle" format="currency" icon-color="text-danger-600" icon-bg-color="bg-danger-50" />
              <StatsCard title="Paiements du jour" :value="dashboard.collecte.paiementsJour" :icon="CreditCard" icon-color="text-info-600" icon-bg-color="bg-info-50" />
            </div>
          </div>

          <!-- Anomalies -->
          <div class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 flex items-center gap-4">
            <div class="p-3 bg-danger-50 rounded-lg">
              <AlertTriangle class="w-6 h-6 text-danger-600" />
            </div>
            <div class="flex-1">
              <p class="text-sm font-medium text-gray-700">Anomalies signalées</p>
              <p class="text-2xl font-bold text-danger-600">{{ dashboard.anomalies }}</p>
            </div>
            <router-link to="/responsable-anomalies" class="px-4 py-2 bg-danger-600 text-white rounded-md text-sm font-medium hover:bg-danger-700">
              Gérer
            </router-link>
          </div>

          <!-- Raccourcis -->
          <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
            <router-link to="/responsable-agents" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <Users class="w-6 h-6 text-primary-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Mes agents</p>
            </router-link>
            <router-link to="/responsable-visites" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <MapPin class="w-6 h-6 text-info-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Visites terrain</p>
            </router-link>
            <router-link to="/responsable-anomalies" class="bg-white shadow-soft rounded-lg border border-gray-100 p-4 text-center hover:border-primary-300 hover:shadow-md transition-all">
              <AlertTriangle class="w-6 h-6 text-danger-600 mx-auto mb-2" />
              <p class="text-xs font-medium text-gray-700">Anomalies</p>
            </router-link>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  Map, UserCheck, UserX, Building, CheckCircle, AlertCircle,
  PlusCircle, AlertTriangle, Wallet, Banknote, CreditCard,
  Users, MapPin, RefreshCw, Loader2
} from 'lucide-vue-next'
import { responsableService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import StatsCard from '@/components/StatsCard.vue'

const loading = ref(false)
const dashboard = ref(null)

async function loadDashboard() {
  loading.value = true
  try {
    const response = await responsableService.getDashboardQuartier()
    dashboard.value = response.data
  } catch (e) {
    console.error('Erreur chargement dashboard:', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => loadDashboard())
</script>
