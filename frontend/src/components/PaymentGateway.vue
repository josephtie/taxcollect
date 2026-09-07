<template>
  <div class="bg-white rounded-lg shadow p-6 max-w-md mx-auto">
    <div class="mb-6">
      <h3 class="text-lg font-semibold text-gray-900">Paiement</h3>
      <p class="text-sm text-gray-500 mt-1">Référence: {{ order?.reference }}</p>
      <p class="text-sm font-semibold text-gray-900 mt-2">Montant: {{ formatCurrency(order?.amount) }}</p>
    </div>

    <div v-if="step === 'method'" class="space-y-3">
      <p class="text-sm text-gray-600 mb-3">Choisissez votre méthode de paiement:</p>
      <button
        v-for="method in paymentMethods"
        :key="method.value"
        @click="selectMethod(method.value)"
        :disabled="loading"
        class="w-full flex items-center px-4 py-3 border border-gray-200 rounded-lg hover:border-primary-500 hover:bg-primary-50 transition-colors disabled:opacity-50"
      >
        <component :is="method.icon" class="w-5 h-5 mr-3 text-gray-600" />
        <span class="text-sm font-medium text-gray-900">{{ method.label }}</span>
      </button>
    </div>

    <div v-else-if="step === 'processing'" class="text-center py-8">
      <div class="inline-flex items-center justify-center w-12 h-12 bg-yellow-100 rounded-full mb-3">
        <Loader2 class="w-6 h-6 text-yellow-600 animate-spin" />
      </div>
      <p class="text-sm text-gray-600">Paiement en cours de traitement...</p>
      <p class="text-xs text-gray-400 mt-1">Ne fermez pas cette page</p>
    </div>

    <div v-else-if="step === 'success'" class="text-center py-8">
      <div class="inline-flex items-center justify-center w-12 h-12 bg-green-100 rounded-full mb-3">
        <CheckCircle class="w-6 h-6 text-green-600" />
      </div>
      <p class="text-sm font-medium text-gray-900">Paiement réussi!</p>
      <p class="text-xs text-gray-500 mt-1">Reçu N° {{ payment?.receiptNumber }}</p>
    </div>

    <div v-else-if="step === 'failed'" class="text-center py-8">
      <div class="inline-flex items-center justify-center w-12 h-12 bg-red-100 rounded-full mb-3">
        <XCircle class="w-6 h-6 text-red-600" />
      </div>
      <p class="text-sm font-medium text-gray-900">Paiement échoué</p>
      <p class="text-xs text-gray-500 mt-1">{{ payment?.failureReason || 'Une erreur est survenue' }}</p>
      <button
        @click="step = 'method'"
        class="mt-4 px-4 py-2 bg-primary-600 text-white text-sm font-medium rounded-lg hover:bg-primary-700"
      >
        Réessayer
      </button>
    </div>

    <button
      v-if="step !== 'processing'"
      @click="$emit('cancel')"
      class="mt-4 w-full px-4 py-2 text-sm text-gray-500 hover:text-gray-700"
    >
      Annuler
    </button>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { usePaymentStore } from '@/stores/payment'
import { Smartphone, CreditCard, Building2, Wallet, CheckCircle, XCircle, Loader2 } from 'lucide-vue-next'

const props = defineProps({
  order: { type: Object, required: true }
})
const emit = defineEmits(['cancel', 'success'])

const paymentStore = usePaymentStore()
const loading = computed(() => paymentStore.loading)
const step = ref('method')
const selectedMethod = ref(null)
const payment = ref(null)

const paymentMethods = [
  { value: 'MOBILE_MONEY', label: 'Mobile Money', icon: Smartphone },
  { value: 'CARD', label: 'Carte bancaire', icon: CreditCard },
  { value: 'BANK_TRANSFER', label: 'Virement bancaire', icon: Building2 },
  { value: 'DIRECT_PAYMENT', label: 'Paiement direct', icon: Wallet }
]

async function selectMethod(method) {
  selectedMethod.value = method
  step.value = 'processing'
  try {
    const result = await paymentStore.initiatePayment(props.order.id, method)
    payment.value = result
    if (result.status === 'SUCCESS') {
      step.value = 'success'
      emit('success', result)
    } else if (result.status === 'FAILED') {
      step.value = 'failed'
    } else {
      pollStatus(result.providerTransactionId)
    }
  } catch (err) {
    step.value = 'failed'
    payment.value = { failureReason: err.message }
  }
}

async function pollStatus(providerTransactionId) {
  const maxAttempts = 30
  for (let i = 0; i < maxAttempts; i++) {
    await new Promise(resolve => setTimeout(resolve, 3000))
    try {
      const status = await paymentStore.getPaymentStatus(providerTransactionId)
      payment.value = status
      if (status.status === 'SUCCESS') {
        step.value = 'success'
        emit('success', status)
        return
      }
      if (status.status === 'FAILED' || status.status === 'EXPIRED') {
        step.value = 'failed'
        return
      }
    } catch (err) {
      console.error('Polling error:', err)
    }
  }
  step.value = 'failed'
  payment.value = { failureReason: 'Délai d\'attente dépassé' }
}

function formatCurrency(amount) {
  if (!amount) return 'N/A'
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(amount)
}
</script>
