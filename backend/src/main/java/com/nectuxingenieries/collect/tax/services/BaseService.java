package com.nectuxingenieries.collect.tax.services;

import java.util.List;
import java.util.Optional;

/**
 * Service de base avec suppression logique pour toutes les entités
 */
public interface BaseService<T, ID, DTO> {
    
    // Opérations CRUD de base
    DTO create(DTO dto);
    DTO update(ID id, DTO dto);
    Optional<DTO> findById(ID id);
    List<DTO> findAll();
    void delete(ID id);
    
    // Opérations de suppression logique
    void restore(ID id);
    List<DTO> findAllIncludingDeleted();
    
    // Utilitaires
    long countActive();
    long countAll();
}
