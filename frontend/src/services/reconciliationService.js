import { BaseService } from './baseService'

class ReconciliationService extends BaseService {
  constructor() {
    super('/api/reconciliation')
  }

  async getAllReconciliations() {
    return this.get('')
  }

  async getReconciliation(reference) {
    return this.get(`/${reference}`)
  }
}

export const reconciliationService = new ReconciliationService()
