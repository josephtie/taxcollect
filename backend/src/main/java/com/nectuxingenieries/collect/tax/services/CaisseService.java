package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.CaisseDto;
import java.util.List;
import java.util.Optional;

public interface CaisseService {
    CaisseDto create(CaisseDto caisseDto);
    Optional<CaisseDto> findById(Long id);
    List<CaisseDto> findAll();
    List<CaisseDto> findByAgentId(Long agentId);
    Optional<CaisseDto> findByAgentAndDate(Long agentId, java.time.LocalDate date);
    CaisseDto ouvrirCaisse(Long id);
    CaisseDto cloturerCaisse(Long id);
    void delete(Long id);
}
