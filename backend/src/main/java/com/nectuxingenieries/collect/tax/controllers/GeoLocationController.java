package com.nectuxingenieries.collect.tax.controllers;

import com.nectuxingenieries.collect.tax.dto.GeoLocationResultDto;
import com.nectuxingenieries.collect.tax.services.GeoLocationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("api/taxcollect/geo")
@RequiredArgsConstructor
@Tag(name = "Géolocalisation", description = "API de géolocalisation territoriale")
public class GeoLocationController {

    private final GeoLocationService geoLocationService;

    @GetMapping("/locate")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPERVISEUR', 'AGENT')")
    public ResponseEntity<GeoLocationResultDto> locate(
            @RequestParam double lat,
            @RequestParam double lng) {
        GeoLocationResultDto result = geoLocationService.locate(lat, lng);
        if (result.getCommune() == null && result.getZone() == null
                && result.getQuartier() == null && result.getSecteur() == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(result);
    }
}
