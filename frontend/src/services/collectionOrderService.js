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
}

export const collectionOrderService = new CollectionOrderService()
