<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Paiements</h1>
          </div>
          <div class="flex items-center space-x-4">
            <button
              @click="loadOrders"
              :disabled="paymentStore.loading"
              class="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 disabled:opacity-50"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Actualiser
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

      <!-- Payments Content -->
      <div class="flex-1 p-6">
        <p class="text-sm text-gray-500 mb-6">Gestion des paiements et ordres de collecte</p>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <div class="lg:col-span-2 space-y-6">
        <div class="bg-white rounded-lg shadow">
          <div class="px-6 py-4 border-b border-gray-200">
            <h2 class="text-lg font-semibold text-gray-900">Ordres de collecte</h2>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Référence</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Montant</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Canal</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Statut</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Expire</th>
                  <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr v-for="order in orders" :key="order.id" class="hover:bg-gray-50">
                  <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ order.reference }}</td>
                  <td class="px-6 py-4 text-sm text-gray-900">{{ formatCurrency(order.amount) }}</td>
                  <td class="px-6 py-4 text-sm text-gray-500">{{ order.channel }}</td>
                  <td class="px-6 py-4"><PaymentStatusBadge :status="order.status" /></td>
                  <td class="px-6 py-4 text-sm text-gray-500">{{ formatDate(order.expiresAt) }}</td>
                  <td class="px-6 py-4 text-right space-x-2">
                    <button
                      v-permission="'payments.create'"
                      v-if="order.status === 'OPEN' || order.status === 'PENDING_PAYMENT'"
                      @click="openPayment(order)"
                      class="text-sm text-primary-600 hover:text-primary-800 font-medium"
                    >
                      Payer
                    </button>
                    <button
                      v-permission="'qr.generate'"
                      v-if="order.status === 'OPEN' || order.status === 'PENDING_PAYMENT'"
                      @click="openQRCode(order)"
                      class="text-sm text-blue-600 hover:text-blue-800 font-medium"
                    >
                      QR Code
                    </button>
                    <button
                      v-permission="'payments.cancel'"
                      v-if="order.status === 'PENDING_PAYMENT'"
                      @click="handleCancel(order)"
                      class="text-sm text-red-600 hover:text-red-800 font-medium"
                    >
                      Annuler
                    </button>
                  </td>
                </tr>
                <tr v-if="orders.length === 0">
                  <td colspan="6" class="px-6 py-8 text-center text-sm text-gray-400">
                    Aucun ordre de collecte
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      </div>

      <!-- Right Panel -->
      <div class="w-96 p-6 bg-gray-50 border-l border-gray-200">
        <div v-if="showPaymentGateway && selectedOrder" class="bg-white rounded-lg shadow">
          <PaymentGateway
            :order="selectedOrder"
            @cancel="closePaymentGateway"
            @success="handlePaymentSuccess"
          />
        </div>

        <div v-if="showQRCode && selectedOrder" class="bg-white rounded-lg shadow">
          <QRCodeDisplay :qr-code="currentQRCode" />
          <div class="p-4 border-t border-gray-200">
            <button
              @click="showQRCode = false"
              class="w-full px-4 py-2 text-sm text-gray-600 hover:text-gray-800"
            >
              Fermer
            </button>
          </div>
        </div>

        <div v-if="showReceipt && currentReceipt" class="bg-white rounded-lg shadow">
          <DigitalReceipt
            :receipt="currentReceipt"
            @download="handleDownloadReceipt"
            @close="showReceipt = false"
          />
        </div>

        <div v-if="!showPaymentGateway && !showQRCode && !showReceipt" class="bg-white rounded-lg shadow p-6">
          <h3 class="text-sm font-semibold text-gray-900 mb-4">Créer un ordre de collecte</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Taxe</label>
              <select
                v-model="selectedTaxeId"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Sélectionner une taxe...</option>
                <option v-for="taxe in availableTaxes" :key="taxe.id" :value="taxe.id">
                  {{ taxe.reference || taxe.id }} - {{ formatCurrency(taxe.montant) }}
                </option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Canal</label>
              <select
                v-model="selectedChannel"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500"
              >
                <option value="DIRECT_PAYMENT">Paiement direct</option>
                <option value="RTP">Request-to-Pay</option>
                <option value="QR_CODE">QR Code</option>
                <option value="MOBILE_APP">Application mobile</option>
                <option value="AGENT">Agent</option>
              </select>
            </div>
            <button
              v-permission="'collection-orders.create'"
              @click="handleCreateOrder"
              :disabled="!selectedTaxeId || paymentStore.loading"
              class="w-full px-4 py-2 bg-primary-600 text-white text-sm font-medium rounded-lg hover:bg-primary-700 disabled:opacity-50"
            >
              Créer l'ordre
            </button>
          </div>
        </div>
      </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { usePaymentStore } from '@/stores/payment'
import { paymentService, collectionOrderService, qrCodeService, receiptService, taxeService } from '@/services'
import Sidebar from '@/components/Sidebar.vue'
import PaymentStatusBadge from '@/components/PaymentStatusBadge.vue'
import PaymentGateway from '@/components/PaymentGateway.vue'
import QRCodeDisplay from '@/components/QRCodeDisplay.vue'
import DigitalReceipt from '@/components/DigitalReceipt.vue'

const paymentStore = usePaymentStore()

const orders = ref([])
const availableTaxes = ref([])
const selectedTaxeId = ref('')
const selectedChannel = ref('DIRECT_PAYMENT')
const selectedOrder = ref(null)
const showPaymentGateway = ref(false)
const showQRCode = ref(false)
const showReceipt = ref(false)
const currentQRCode = ref({})
const currentReceipt = ref(null)

onMounted(async () => {
  await loadOrders()
  await loadTaxes()
})

async function loadOrders() {
  try {
    const response = await collectionOrderService.getCollectionOrder('')
    orders.value = Array.isArray(response.data) ? response.data : []
  } catch (err) {
    console.error('Error loading orders:', err)
  }
}

async function loadTaxes() {
  try {
    const response = await taxeService.getAll()
    availableTaxes.value = Array.isArray(response.data) ? response.data : (response.data?.content || [])
  } catch (err) {
    console.error('Error loading taxes:', err)
  }
}

async function handleCreateOrder() {
  if (!selectedTaxeId.value) return
  try {
    const order = await paymentStore.createCollectionOrder(selectedTaxeId.value, selectedChannel.value)
    orders.value.unshift(order)
    selectedTaxeId.value = ''
  } catch (err) {
    console.error('Error creating order:', err)
  }
}

function openPayment(order) {
  selectedOrder.value = order
  showPaymentGateway.value = true
  showQRCode.value = false
  showReceipt.value = false
}

function closePaymentGateway() {
  showPaymentGateway.value = false
  selectedOrder.value = null
}

async function handlePaymentSuccess(result) {
  showPaymentGateway.value = false
  if (result.receiptNumber) {
    try {
      const receipt = await receiptService.getReceipt(result.receiptNumber)
      currentReceipt.value = receipt.data
      showReceipt.value = true
    } catch (err) {
      console.error('Error loading receipt:', err)
    }
  }
  await loadOrders()
}

async function openQRCode(order) {
  selectedOrder.value = order
  try {
    const response = await qrCodeService.generateQRCode(order.id)
    currentQRCode.value = response.data
    showQRCode.value = true
    showPaymentGateway.value = false
    showReceipt.value = false
  } catch (err) {
    console.error('Error generating QR code:', err)
  }
}

async function handleCancel(order) {
  if (!confirm('Annuler ce paiement?')) return
  try {
    await paymentService.cancelPayment(order.reference)
    order.status = 'CANCELLED'
  } catch (err) {
    console.error('Error cancelling payment:', err)
  }
}

async function handleDownloadReceipt(receiptNumber) {
  try {
    await paymentStore.downloadReceiptPdf(receiptNumber)
  } catch (err) {
    console.error('Error downloading receipt:', err)
  }
}

function formatCurrency(amount) {
  if (!amount) return 'N/A'
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XOF' }).format(amount)
}

function formatDate(dateStr) {
  if (!dateStr) return 'N/A'
  return new Date(dateStr).toLocaleString('fr-FR')
}
</script>
