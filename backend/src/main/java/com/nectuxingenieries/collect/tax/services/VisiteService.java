package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.VisiteDto;
import java.util.List;
import java.util.Optional;

public interface VisiteService {
    VisiteDto create(VisiteDto visiteDto);
    VisiteDto update(Long id, VisiteDto visiteDto);
    Optional<VisiteDto> findById(Long id);
    List<VisiteDto> findAll();
    List<VisiteDto> findByTourneeId(Long tourneeId);
    List<VisiteDto> findByContribuableId(Long contribuableId);
    void delete(Long id);
    void restore(Long id);
    VisiteDto updateStatut(Long id, String statut, String motif, String observation);
}
