package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.RemiseCaisseDto;
import java.util.List;
import java.util.Optional;

public interface RemiseCaisseService {
    RemiseCaisseDto create(RemiseCaisseDto remiseDto);
    Optional<RemiseCaisseDto> findById(Long id);
    List<RemiseCaisseDto> findAll();
    List<RemiseCaisseDto> findByCaisseId(Long caisseId);
    List<RemiseCaisseDto> findByStatut(String statut);
    List<RemiseCaisseDto> findByAgentId(Long agentId);
    RemiseCaisseDto confirmer(Long id, Long confirmePar, String commentaire);
    void delete(Long id);
}
