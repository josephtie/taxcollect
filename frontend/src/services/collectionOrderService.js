import { BaseService } from './baseService'

class CollectionOrderService extends BaseService {
  constructor() {
    super('/api/collection-orders')
  }

  async createCollectionOrder(taxeCollectId, channel = 'DIRECT_PAYMENT') {
    return this.post('', { taxeCollectId, channel })
  }

  async getCollectionOrder(reference) {
    return this.get(`/${reference}`)
  }

  async getAllCollectionOrders(page = 0, size = 20) {
    return this.get('', { page, size })
  }
}

export const collectionOrderService = new CollectionOrderService()
