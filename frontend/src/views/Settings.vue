<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">Paramètres</h1>
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

      <!-- Settings Content -->
      <div class="flex-1 p-6">
        <div class="max-w-4xl mx-auto">
          <!-- Settings Tabs -->
          <div class="bg-white rounded-lg shadow-soft border border-gray-100">
            <div class="border-b border-gray-200">
              <nav class="flex -mb-px">
                <button
                  v-for="tab in settingsTabs"
                  :key="tab.key"
                  @click="activeTab = tab.key"
                  class="py-4 px-6 text-sm font-medium border-b-2 transition-colors"
                  :class="[
                    activeTab === tab.key
                      ? 'border-primary-500 text-primary-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  ]"
                >
                  {{ tab.label }}
                </button>
              </nav>
            </div>

            <!-- Tab Content -->
            <div class="p-6">
              <!-- General Settings -->
              <div v-if="activeTab === 'general'">
                <h3 class="text-lg font-semibold text-gray-900 mb-6">Paramètres généraux</h3>
                
                <div class="space-y-6">
                  <div>
                    <label class="form-label">Nom de l'organisation</label>
                    <input
                      v-model="generalSettings.organizationName"
                      type="text"
                      class="form-input"
                      placeholder="Trésor Public"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Adresse email de contact</label>
                    <input
                      v-model="generalSettings.contactEmail"
                      type="email"
                      class="form-input"
                      placeholder="contact@taxcollect.gov"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Téléphone de contact</label>
                    <input
                      v-model="generalSettings.contactPhone"
                      type="tel"
                      class="form-input"
                      placeholder="+225 27 20 00 00 00"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Devise par défaut</label>
                    <select
                      v-model="generalSettings.defaultCurrency"
                      class="form-input"
                    >
                      <option value="XOF">XOF - Franc CFA</option>
                      <option value="EUR">EUR - Euro</option>
                      <option value="USD">USD - Dollar Américain</option>
                    </select>
                  </div>
                </div>
              </div>

              <!-- Tax Settings -->
              <div v-if="activeTab === 'taxes'">
                <h3 class="text-lg font-semibold text-gray-900 mb-6">Paramètres des taxes</h3>
                
                <div class="space-y-6">
                  <div>
                    <label class="form-label">Montant minimum de taxe</label>
                    <input
                      v-model="taxSettings.minAmount"
                      type="number"
                      class="form-input"
                      placeholder="100"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Montant maximum de taxe</label>
                    <input
                      v-model="taxSettings.maxAmount"
                      type="number"
                      class="form-input"
                      placeholder="1000000"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Types de taxes autorisées</label>
                    <div class="space-y-2 mt-2">
                      <label class="flex items-center">
                        <input
                          v-model="taxSettings.allowedTypes"
                          type="checkbox"
                          value="MARCHÉ"
                          class="mr-2"
                        />
                        Taxe de marché
                      </label>
                      <label class="flex items-center">
                        <input
                          v-model="taxSettings.allowedTypes"
                          type="checkbox"
                          value="STATIONNEMENT"
                          class="mr-2"
                        />
                        Taxe de stationnement
                      </label>
                      <label class="flex items-center">
                        <input
                          v-model="taxSettings.allowedTypes"
                          type="checkbox"
                          value="PUBLICITÉ"
                          class="mr-2"
                        />
                        Taxe de publicité
                      </label>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Notification Settings -->
              <div v-if="activeTab === 'notifications'">
                <h3 class="text-lg font-semibold text-gray-900 mb-6">Paramètres de notification</h3>
                
                <div class="space-y-6">
                  <div>
                    <label class="form-label">Notifications email</label>
                    <div class="space-y-2 mt-2">
                      <label class="flex items-center">
                        <input
                          v-model="notificationSettings.emailNewTransaction"
                          type="checkbox"
                          class="mr-2"
                        />
                        Nouvelles transactions
                      </label>
                      <label class="flex items-center">
                        <input
                          v-model="notificationSettings.emailValidation"
                          type="checkbox"
                          class="mr-2"
                        />
                        Demandes de validation
                      </label>
                      <label class="flex items-center">
                        <input
                          v-model="notificationSettings.emailSystem"
                          type="checkbox"
                          class="mr-2"
                        />
                        Alertes système
                      </label>
                    </div>
                  </div>
                  
                  <div>
                    <label class="form-label">Notifications SMS</label>
                    <div class="space-y-2 mt-2">
                      <label class="flex items-center">
                        <input
                          v-model="notificationSettings.smsValidation"
                          type="checkbox"
                          class="mr-2"
                        />
                        Validation de clôture
                      </label>
                      <label class="flex items-center">
                        <input
                          v-model="notificationSettings.smsUrgent"
                          type="checkbox"
                          class="mr-2"
                        />
                        Alertes urgentes
                      </label>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Security Settings -->
              <div v-if="activeTab === 'security'">
                <h3 class="text-lg font-semibold text-gray-900 mb-6">Paramètres de sécurité</h3>
                
                <div class="space-y-6">
                  <div>
                    <label class="form-label">Durée de session (minutes)</label>
                    <input
                      v-model="securitySettings.sessionTimeout"
                      type="number"
                      class="form-input"
                      placeholder="480"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Mot de passe requis après</label>
                    <select
                      v-model="securitySettings.passwordRequiredAfter"
                      class="form-input"
                    >
                      <option value="15">15 minutes</option>
                      <option value="30">30 minutes</option>
                      <option value="60">1 heure</option>
                      <option value="120">2 heures</option>
                    </select>
                  </div>
                  
                  <div>
                    <label class="form-label">Authentification à deux facteurs</label>
                    <div class="space-y-2 mt-2">
                      <label class="flex items-center">
                        <input
                          v-model="securitySettings.twoFactorAuth"
                          type="checkbox"
                          class="mr-2"
                        />
                        Activer 2FA pour les administrateurs
                      </label>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Backup Settings -->
              <div v-if="activeTab === 'backup'">
                <h3 class="text-lg font-semibold text-gray-900 mb-6">Sauvegarde et export</h3>
                
                <div class="space-y-6">
                  <div>
                    <label class="form-label">Sauvegarde automatique</label>
                    <div class="space-y-2 mt-2">
                      <label class="flex items-center">
                        <input
                          v-model="backupSettings.autoBackup"
                          type="checkbox"
                          class="mr-2"
                        />
                        Activer la sauvegarde automatique quotidienne
                      </label>
                    </div>
                  </div>
                  
                  <div v-if="backupSettings.autoBackup">
                    <label class="form-label">Heure de sauvegarde</label>
                    <input
                      v-model="backupSettings.backupTime"
                      type="time"
                      class="form-input"
                    />
                  </div>
                  
                  <div>
                    <label class="form-label">Rétention des sauvegardes</label>
                    <select
                      v-model="backupSettings.retentionDays"
                      class="form-input"
                    >
                      <option value="7">7 jours</option>
                      <option value="30">30 jours</option>
                      <option value="90">90 jours</option>
                      <option value="365">1 an</option>
                    </select>
                  </div>
                  
                  <div class="flex space-x-4">
                    <button
                      @click="createBackup"
                      class="btn-primary"
                    >
                      <Download class="w-4 h-4 mr-2" />
                      Créer une sauvegarde maintenant
                    </button>
                    
                    <button
                      @click="restoreBackup"
                      class="btn-secondary"
                    >
                      <Upload class="w-4 h-4 mr-2" />
                      Restaurer une sauvegarde
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Save Button -->
            <div class="px-6 py-4 border-t border-gray-200">
              <div class="flex justify-end">
                <button
                  @click="saveSettings"
                  :disabled="saving"
                  class="btn-primary"
                >
                  {{ saving ? 'Enregistrement...' : 'Enregistrer les paramètres' }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import Sidebar from '@/components/Sidebar.vue'
import { Download, Upload } from 'lucide-vue-next'

// State
const activeTab = ref('general')
const saving = ref(false)

const settingsTabs = [
  { key: 'general', label: 'Général' },
  { key: 'taxes', label: 'Taxes' },
  { key: 'notifications', label: 'Notifications' },
  { key: 'security', label: 'Sécurité' },
  { key: 'backup', label: 'Sauvegarde' }
]

const generalSettings = ref({
  organizationName: 'Trésor Public',
  contactEmail: 'contact@taxcollect.gov',
  contactPhone: '+225 27 20 00 00 00',
  defaultCurrency: 'XOF'
})

const taxSettings = ref({
  minAmount: 100,
  maxAmount: 1000000,
  allowedTypes: ['MARCHÉ', 'STATIONNEMENT']
})

const notificationSettings = ref({
  emailNewTransaction: true,
  emailValidation: true,
  emailSystem: true,
  smsValidation: true,
  smsUrgent: false
})

const securitySettings = ref({
  sessionTimeout: 480,
  passwordRequiredAfter: 60,
  twoFactorAuth: false
})

const backupSettings = ref({
  autoBackup: true,
  backupTime: '02:00',
  retentionDays: 30
})

// Methods
const saveSettings = async () => {
  saving.value = true
  try {
    // Simuler la sauvegarde des paramètres
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    localStorage.setItem('settings', JSON.stringify({
      general: generalSettings.value,
      tax: taxSettings.value,
      notifications: notificationSettings.value,
      security: securitySettings.value,
      backup: backupSettings.value
    }))
    
    // Afficher un message de succès
    alert('Paramètres enregistrés avec succès')
  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
    alert('Erreur lors de l\'enregistrement des paramètres')
  } finally {
    saving.value = false
  }
}

const createBackup = () => {
  // Implémenter la création de sauvegarde
  console.log('Create backup')
}

const restoreBackup = () => {
  // Implémenter la restauration de sauvegarde
  console.log('Restore backup')
}

// Lifecycle
onMounted(() => {
  // Charger les paramètres sauvegardés
  const savedSettings = localStorage.getItem('settings')
  if (savedSettings) {
    const settings = JSON.parse(savedSettings)
    generalSettings.value = { ...generalSettings.value, ...settings.general }
    taxSettings.value = { ...taxSettings.value, ...settings.tax }
    notificationSettings.value = { ...notificationSettings.value, ...settings.notifications }
    securitySettings.value = { ...securitySettings.value, ...settings.security }
    backupSettings.value = { ...backupSettings.value, ...settings.backup }
  }
})
</script>
