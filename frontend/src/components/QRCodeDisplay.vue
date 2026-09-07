<template>
  <div class="bg-white rounded-lg shadow p-6 max-w-md mx-auto">
    <div class="text-center mb-4">
      <h3 class="text-lg font-semibold text-gray-900">QR Code de Paiement</h3>
      <p class="text-sm text-gray-500 mt-1">Scannez pour payer</p>
    </div>

    <div class="flex justify-center mb-4">
      <div class="p-4 bg-white border-2 border-gray-200 rounded-lg">
        <img
          :src="qrCodeUrl"
          alt="QR Code de paiement"
          class="w-48 h-48"
        />
      </div>
    </div>

    <div class="space-y-2 text-sm">
      <div class="flex justify-between">
        <span class="text-gray-500">Référence:</span>
        <span class="font-medium text-gray-900">{{ qrCode.token }}</span>
      </div>
      <div class="flex justify-between">
        <span class="text-gray-500">Montant:</span>
        <span class="font-medium text-gray-900">{{ formatCurrency(qrCode.amount) }}</span>
      </div>
      <div class="flex justify-between">
        <span class="text-gray-500">Expire le:</span>
        <span class="font-medium text-gray-900">{{ formatDate(qrCode.expiresAt) }}</span>
      </div>
    </div>

    <div v-if="expired" class="mt-4 p-3 bg-red-50 border border-red-200 rounded-lg text-center">
      <p class="text-sm text-red-700 font-medium">Ce QR code a expiré</p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  qrCode: { type: Object, required: true }
})

const qrCodeUrl = computed(() => {
  const payload = encodeURIComponent(props.qrCode.payload || props.qrCode.token)
  return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${payload}`
})

const expired = computed(() => {
  if (!props.qrCode.expiresAt) return false
  return new Date(props.qrCode.expiresAt) < new Date()
})

function formatCurrency(amount) {
  if (!amount) return 'N/A'
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(amount)
}

function formatDate(dateStr) {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleString('fr-FR')
}
</script>
