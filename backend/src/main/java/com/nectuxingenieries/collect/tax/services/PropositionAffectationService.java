package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.PropositionAffectationDto;
import java.util.List;
import java.util.Optional;

public interface PropositionAffectationService {
    PropositionAffectationDto create(PropositionAffectationDto dto);
    Optional<PropositionAffectationDto> findById(Long id);
    List<PropositionAffectationDto> findByQuartierId(Long quartierId);
    List<PropositionAffectationDto> findByQuartierIdAndStatut(Long quartierId, String statut);
    List<PropositionAffectationDto> findByStatut(String statut);
    PropositionAffectationDto valider(Long id, Long valideePar, String commentaire);
    PropositionAffectationDto rejeter(Long id, Long valideePar, String commentaire);
    void delete(Long id);
}
