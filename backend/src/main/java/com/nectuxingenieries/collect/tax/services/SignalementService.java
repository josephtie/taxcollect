package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.SignalementDto;
import java.util.List;
import java.util.Optional;

public interface SignalementService {
    SignalementDto create(SignalementDto signalementDto);
    Optional<SignalementDto> findById(Long id);
    List<SignalementDto> findAll();
    List<SignalementDto> findByAgentId(Long agentId);
    List<SignalementDto> findByStatut(String statut);
    SignalementDto traiter(Long id, String reponse, Long traitePar);
    void delete(Long id);
}
