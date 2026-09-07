package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.GeoLocationResultDto;

public interface GeoLocationService {
    GeoLocationResultDto locate(double latitude, double longitude);
}
