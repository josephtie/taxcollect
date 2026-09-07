package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.dto.GeoLocationResultDto;
import com.nectuxingenieries.collect.tax.models.Commune;
import com.nectuxingenieries.collect.tax.models.Quartier;
import com.nectuxingenieries.collect.tax.models.Secteur;
import com.nectuxingenieries.collect.tax.models.Zone;
import com.nectuxingenieries.collect.tax.models.mappers.CommuneMapper;
import com.nectuxingenieries.collect.tax.models.mappers.QuartierMapper;
import com.nectuxingenieries.collect.tax.models.mappers.SecteurMapper;
import com.nectuxingenieries.collect.tax.models.mappers.ZoneMapper;
import com.nectuxingenieries.collect.tax.repositories.CommuneRepository;
import com.nectuxingenieries.collect.tax.repositories.QuartierRepository;
import com.nectuxingenieries.collect.tax.repositories.SecteurRepository;
import com.nectuxingenieries.collect.tax.repositories.ZoneRepository;
import com.nectuxingenieries.collect.tax.services.GeoLocationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class GeoLocationServiceImpl implements GeoLocationService {

    @Autowired
    private SecteurRepository secteurRepository;
    @Autowired
    private QuartierRepository quartierRepository;
    @Autowired
    private ZoneRepository zoneRepository;
    @Autowired
    private CommuneRepository communeRepository;
    @Autowired
    private SecteurMapper secteurMapper;
    @Autowired
    private QuartierMapper quartierMapper;
    @Autowired
    private ZoneMapper zoneMapper;
    @Autowired
    private CommuneMapper communeMapper;

    @Override
    public GeoLocationResultDto locate(double latitude, double longitude) {
        GeoLocationResultDto result = new GeoLocationResultDto();
        result.setLatitude(latitude);
        result.setLongitude(longitude);

        // 1. Try to find the most precise level first: Secteur
        Secteur secteur = secteurRepository.findByGeometryContaining(latitude, longitude);
        if (secteur != null) {
            result.setSecteur(secteurMapper.toDto(secteur));
            // Derive quartier from secteur if not already set
            if (secteur.getQuartier() != null) {
                Quartier quartier = secteur.getQuartier();
                result.setQuartier(quartierMapper.toDto(quartier));
                if (quartier.getZone() != null) {
                    Zone zone = quartier.getZone();
                    result.setZone(zoneMapper.toDto(zone));
                    if (zone.getCommune() != null) {
                        result.setCommune(communeMapper.toDto(zone.getCommune()));
                    }
                }
            }
            return result;
        }

        // 2. If no secteur found, try Quartier
        Quartier quartier = quartierRepository.findByGeometryContaining(latitude, longitude);
        if (quartier != null) {
            result.setQuartier(quartierMapper.toDto(quartier));
            if (quartier.getZone() != null) {
                Zone zone = quartier.getZone();
                result.setZone(zoneMapper.toDto(zone));
                if (zone.getCommune() != null) {
                    result.setCommune(communeMapper.toDto(zone.getCommune()));
                }
            }
            return result;
        }

        // 3. If no quartier found, try Zone
        Zone zone = zoneRepository.findByGeometryContaining(latitude, longitude);
        if (zone != null) {
            result.setZone(zoneMapper.toDto(zone));
            if (zone.getCommune() != null) {
                result.setCommune(communeMapper.toDto(zone.getCommune()));
            }
            return result;
        }

        // 4. Last resort: try Commune
        Commune commune = communeRepository.findByGeometryContaining(latitude, longitude);
        if (commune != null) {
            result.setCommune(communeMapper.toDto(commune));
        }

        return result;
    }
}
