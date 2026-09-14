package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.PromessePaiementDto;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface PromessePaiementService {
    PromessePaiementDto create(PromessePaiementDto promesseDto);
    PromessePaiementDto update(Long id, PromessePaiementDto promesseDto);
    Optional<PromessePaiementDto> findById(Long id);
    List<PromessePaiementDto> findAll();
    List<PromessePaiementDto> findByContribuableId(Long contribuableId);
    List<PromessePaiementDto> findByAgentId(Long agentId);
    List<PromessePaiementDto> findEcheancesProches(LocalDate date);
    void delete(Long id);
    void restore(Long id);
    PromessePaiementDto marquerRelance(Long id);
    PromessePaiementDto marquerHonoree(Long id);
}
