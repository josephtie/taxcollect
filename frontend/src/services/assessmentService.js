import { BaseService } from './baseService'

class AssessmentService extends BaseService {
  constructor() {
    super('/api/assessments')
  }

  async generateForTaxe(taxeId, targetDate = null) {
    const params = targetDate ? `?targetDate=${targetDate}` : ''
    return this.post(`/generate/${taxeId}${params}`, {})
  }

  async generateForAll(targetDate = null) {
    const params = targetDate ? `?targetDate=${targetDate}` : ''
    return this.post(`/generate-all${params}`, {})
  }

  async markOverdue() {
    return this.post('/mark-overdue', {})
  }

  async findByPeriod(periodStart, periodEnd) {
    return this.get(`/period?periodStart=${periodStart}&periodEnd=${periodEnd}`)
  }

  async exportAssessments(format, periodStart, periodEnd) {
    return this.download('/export', { format, periodStart, periodEnd })
  }
}

export const assessmentService = new AssessmentService()
