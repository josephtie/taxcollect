package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.ContribuableDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface ContribuableService {
    ContribuableDto create(ContribuableDto contribuableDto);
    ContribuableDto update(Long id, ContribuableDto contribuableDto);
    Optional<ContribuableDto> findById(Long id);
    List<ContribuableDto> findAll();
    Page<ContribuableDto> findAll(Pageable pageable);
    Page<ContribuableDto> findAll(Map<String,String> filters, Pageable pageable);
    void delete(Long id);
    
    // Méthodes manquantes ajoutées
    Page<ContribuableDto> searchContribuables(String searchTerm, Map<String, String> filters, Pageable pageable);
    List<ContribuableDto> getContribuablesByZone(Long zoneId);
    Map<String, Object> getContribuableStats();
    byte[] exportContribuables(String format, Long zoneId);
}

