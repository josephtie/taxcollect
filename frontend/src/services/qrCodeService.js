import { BaseService } from './baseService'

class QRCodeService extends BaseService {
  constructor() {
    super('/api/qr')
  }

  async generateQRCode(collectionOrderId) {
    return this.post('/generate', { collectionOrderId })
  }

  async resolveQRCode(token) {
    return this.get(`/${token}`)
  }
}

export const qrCodeService = new QRCodeService()
