package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.AnomalieDto;
import java.util.List;
import java.util.Optional;

public interface AnomalieService {
    AnomalieDto create(AnomalieDto anomalieDto);
    Optional<AnomalieDto> findById(Long id);
    List<AnomalieDto> findByQuartierId(Long quartierId);
    List<AnomalieDto> findByQuartierIdAndStatut(Long quartierId, String statut);
    List<AnomalieDto> findByStatut(String statut);
    List<AnomalieDto> findByAgentId(Long agentId);
    AnomalieDto documenter(Long id, String commentaire);
    AnomalieDto transmettre(Long id, String commentaire);
    AnomalieDto affecterAction(Long id, Long agentId, String action);
    AnomalieDto clôturer(Long id, Long clotureePar, String commentaire);
    AnomalieDto escaler(Long id, String commentaire);
    void delete(Long id);
}
