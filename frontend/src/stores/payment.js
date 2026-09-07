import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { paymentService, collectionOrderService, qrCodeService, receiptService } from '@/services'

export const usePaymentStore = defineStore('payment', () => {
  const collectionOrders = ref([])
  const currentOrder = ref(null)
  const currentPayment = ref(null)
  const currentReceipt = ref(null)
  const qrCode = ref(null)
  const loading = ref(false)
  const error = ref(null)

  const activeOrders = computed(() =>
    (collectionOrders.value || []).filter(o =>
      o.status === 'OPEN' || o.status === 'PENDING_PAYMENT'
    )
  )

  const paidOrders = computed(() =>
    (collectionOrders.value || []).filter(o => o.status === 'PAID')
  )

  async function createCollectionOrder(taxeCollectId, channel = 'DIRECT_PAYMENT') {
    loading.value = true
    error.value = null
    try {
      const response = await collectionOrderService.createCollectionOrder(taxeCollectId, channel)
      currentOrder.value = response.data
      collectionOrders.value.unshift(response.data)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la création de l\'ordre de collecte'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function getCollectionOrder(reference) {
    loading.value = true
    error.value = null
    try {
      const response = await collectionOrderService.getCollectionOrder(reference)
      currentOrder.value = response.data
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la récupération de l\'ordre'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function initiatePayment(collectionOrderId, paymentMethod = 'MOBILE_MONEY') {
    loading.value = true
    error.value = null
    try {
      const response = await paymentService.initiatePayment(collectionOrderId, paymentMethod)
      currentPayment.value = response.data
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de l\'initiation du paiement'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function getPaymentStatus(reference) {
    try {
      const response = await paymentService.getPaymentStatus(reference)
      currentPayment.value = response.data
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la vérification du statut'
      throw err
    }
  }

  async function cancelPayment(reference) {
    loading.value = true
    error.value = null
    try {
      await paymentService.cancelPayment(reference)
      if (currentPayment.value) {
        currentPayment.value.status = 'CANCELLED'
      }
    } catch (err) {
      error.value = err.message || 'Erreur lors de l\'annulation'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function refundPayment(reference, amount, reason) {
    loading.value = true
    error.value = null
    try {
      const response = await paymentService.refundPayment(reference, amount, reason)
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors du remboursement'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function generateQRCode(collectionOrderId) {
    loading.value = true
    error.value = null
    try {
      const response = await qrCodeService.generateQRCode(collectionOrderId)
      qrCode.value = response.data
      return response.data
    } catch (err) {
      error.value = err.message || 'Erreur lors de la génération du QR code'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function resolveQRCode(token) {
    loading.value = true
    error.value = null
    try {
      const response = await qrCodeService.resolveQRCode(token)
      return response.data
    } catch (err) {
      error.value = err.message || 'QR code invalide ou expiré'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function getReceipt(receiptNumber) {
    loading.value = true
    error.value = null
    try {
      const response = await receiptService.getReceipt(receiptNumber)
      currentReceipt.value = response.data
      return response.data
    } catch (err) {
      error.value = err.message || 'Reçu introuvable'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function downloadReceiptPdf(receiptNumber) {
    try {
      const response = await receiptService.downloadReceiptPdf(receiptNumber)
      const url = window.URL.createObjectURL(new Blob([response.data]))
      const link = document.createElement('a')
      link.href = url
      link.setAttribute('download', `recu-${receiptNumber}.pdf`)
      document.body.appendChild(link)
      link.click()
      link.remove()
      window.URL.revokeObjectURL(url)
    } catch (err) {
      error.value = err.message || 'Erreur lors du téléchargement du reçu'
      throw err
    }
  }

  function reset() {
    currentOrder.value = null
    currentPayment.value = null
    currentReceipt.value = null
    qrCode.value = null
    error.value = null
  }

  return {
    collectionOrders,
    currentOrder,
    currentPayment,
    currentReceipt,
    qrCode,
    loading,
    error,
    activeOrders,
    paidOrders,
    createCollectionOrder,
    getCollectionOrder,
    initiatePayment,
    getPaymentStatus,
    cancelPayment,
    refundPayment,
    generateQRCode,
    resolveQRCode,
    getReceipt,
    downloadReceiptPdf,
    reset
  }
})
