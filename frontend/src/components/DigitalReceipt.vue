<template>
  <div class="bg-white rounded-lg shadow p-6 max-w-md mx-auto">
    <div class="text-center mb-6">
      <div class="inline-flex items-center justify-center w-12 h-12 bg-green-100 rounded-full mb-3">
        <CheckCircle class="w-6 h-6 text-green-600" />
      </div>
      <h3 class="text-lg font-semibold text-gray-900">Reçu de paiement</h3>
      <p class="text-sm text-gray-500">N° {{ receipt.receiptNumber }}</p>
    </div>

    <div class="space-y-3 border-t border-b border-gray-200 py-4">
      <div class="flex justify-between text-sm">
        <span class="text-gray-500">Montant:</span>
        <span class="font-semibold text-gray-900">{{ formatCurrency(receipt.amount) }}</span>
      </div>
      <div class="flex justify-between text-sm">
        <span class="text-gray-500">Devise:</span>
        <span class="font-medium text-gray-900">{{ receipt.currency || 'XOF' }}</span>
      </div>
      <div class="flex justify-between text-sm">
        <span class="text-gray-500">Provider:</span>
        <span class="font-medium text-gray-900">{{ receipt.provider }}</span>
      </div>
      <div class="flex justify-between text-sm">
        <span class="text-gray-500">Transaction:</span>
        <span class="font-medium text-gray-900">{{ receipt.providerTransactionId }}</span>
      </div>
      <div class="flex justify-between text-sm">
        <span class="text-gray-500">Date:</span>
        <span class="font-medium text-gray-900">{{ formatDate(receipt.issuedAt) }}</span>
      </div>
    </div>

    <div class="mt-6 flex gap-3">
      <button
        v-permission="'receipts.download'"
        @click="$emit('download', receipt.receiptNumber)"
        class="flex-1 px-4 py-2 bg-primary-600 text-white text-sm font-medium rounded-lg hover:bg-primary-700 transition-colors"
      >
        Télécharger PDF
      </button>
      <button
        @click="$emit('close')"
        class="flex-1 px-4 py-2 bg-gray-100 text-gray-700 text-sm font-medium rounded-lg hover:bg-gray-200 transition-colors"
      >
        Fermer
      </button>
    </div>
  </div>
</template>

<script setup>
import { CheckCircle } from 'lucide-vue-next'

defineProps({
  receipt: { type: Object, required: true }
})
defineEmits(['download', 'close'])

function formatCurrency(amount) {
  if (!amount) return 'N/A'
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(amount)
}

function formatDate(dateStr) {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleString('fr-FR')
}
</script>
