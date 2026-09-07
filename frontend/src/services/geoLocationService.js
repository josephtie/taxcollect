import { BaseService } from './baseService'

class GeoLocationService extends BaseService {
  constructor() {
    super('/api/taxcollect/geo')
  }

  async locate(lat, lng) {
    return this.get(`/locate?lat=${lat}&lng=${lng}`)
  }
}

export const geoLocationService = new GeoLocationService()
