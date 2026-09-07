import { BaseService } from './baseService'

class PaymentService extends BaseService {
  constructor() {
    super('/api/payments')
  }

  async initiatePayment(collectionOrderId, paymentMethod = 'MOBILE_MONEY', idempotencyKey = null) {
    const key = idempotencyKey || `PAY-${Date.now()}-${Math.random().toString(36).substring(2, 10).toUpperCase()}`
    return this.post('', {
      collectionOrderId,
      paymentMethod,
      idempotencyKey: key
    })
  }

  async getPaymentStatus(reference) {
    return this.get(`/${reference}`)
  }

  async cancelPayment(reference) {
    return this.post(`/${reference}/cancel`, {})
  }

  async refundPayment(reference, amount, reason) {
    return this.post(`/${reference}/refund`, { amount, reason })
  }
}

export const paymentService = new PaymentService()
