import { BaseService } from './baseService'

class ReceiptService extends BaseService {
  constructor() {
    super('/api/receipts')
  }

  async getReceipt(receiptNumber) {
    return this.get(`/${receiptNumber}`)
  }

  async downloadReceiptPdf(receiptNumber) {
    return this.download(`/${receiptNumber}/pdf`)
  }
}

export const receiptService = new ReceiptService()
