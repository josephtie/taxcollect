<template>
  <span
    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    :class="statusClasses"
  >
    <span class="w-1.5 h-1.5 rounded-full mr-1.5" :class="dotClasses"></span>
    {{ statusLabel }}
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: { type: String, required: true }
})

const statusConfig = {
  INITIATED:   { label: 'Initié',        classes: 'bg-blue-100 text-blue-800',   dot: 'bg-blue-500' },
  PENDING:     { label: 'En attente',     classes: 'bg-yellow-100 text-yellow-800', dot: 'bg-yellow-500' },
  SUCCESS:     { label: 'Succès',         classes: 'bg-green-100 text-green-800',   dot: 'bg-green-500' },
  FAILED:      { label: 'Échec',          classes: 'bg-red-100 text-red-800',       dot: 'bg-red-500' },
  EXPIRED:     { label: 'Expiré',         classes: 'bg-gray-100 text-gray-800',     dot: 'bg-gray-400' },
  REFUNDED:    { label: 'Remboursé',      classes: 'bg-purple-100 text-purple-800', dot: 'bg-purple-500' },
  PARTIALLY_REFUNDED: { label: 'Remboursé partiellement', classes: 'bg-purple-100 text-purple-800', dot: 'bg-purple-500' },
  ANNULEE:     { label: 'Annulé',         classes: 'bg-gray-100 text-gray-800',     dot: 'bg-gray-400' },
  OPEN:        { label: 'Ouvert',         classes: 'bg-blue-100 text-blue-800',     dot: 'bg-blue-500' },
  PENDING_PAYMENT: { label: 'Paiement en cours', classes: 'bg-yellow-100 text-yellow-800', dot: 'bg-yellow-500' },
  PAID:        { label: 'Payé',           classes: 'bg-green-100 text-green-800',   dot: 'bg-green-500' },
  PARTIALLY_PAID: { label: 'Partiellement payé', classes: 'bg-yellow-100 text-yellow-800', dot: 'bg-yellow-500' },
  CANCELLED:   { label: 'Annulé',         classes: 'bg-red-100 text-red-800',       dot: 'bg-red-500' },
  RTP_CREATED: { label: 'RTP créé',       classes: 'bg-blue-100 text-blue-800',     dot: 'bg-blue-500' },
  RTP_SENT:    { label: 'RTP envoyé',     classes: 'bg-blue-100 text-blue-800',     dot: 'bg-blue-500' },
  RTP_PENDING: { label: 'RTP en attente', classes: 'bg-yellow-100 text-yellow-800', dot: 'bg-yellow-500' },
  RTP_ACCEPTED:{ label: 'RTP accepté',    classes: 'bg-green-100 text-green-800',   dot: 'bg-green-500' },
  RTP_REJECTED:{ label: 'RTP rejeté',     classes: 'bg-red-100 text-red-800',       dot: 'bg-red-500' },
  RTP_EXPIRED: { label: 'RTP expiré',     classes: 'bg-gray-100 text-gray-800',     dot: 'bg-gray-400' },
  RTP_PAID:    { label: 'RTP payé',       classes: 'bg-green-100 text-green-800',   dot: 'bg-green-500' },
  RTP_CANCELLED:{ label: 'RTP annulé',    classes: 'bg-red-100 text-red-800',       dot: 'bg-red-500' }
}

const config = computed(() => statusConfig[props.status] || {
  label: props.status,
  classes: 'bg-gray-100 text-gray-800',
  dot: 'bg-gray-400'
})

const statusClasses = computed(() => config.value.classes)
const dotClasses = computed(() => config.value.dot)
const statusLabel = computed(() => config.value.label)
</script>
