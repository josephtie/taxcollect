package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.PortefeuilleDto;
import java.util.List;
import java.util.Optional;

public interface PortefeuilleService {
    PortefeuilleDto create(PortefeuilleDto portefeuilleDto);
    PortefeuilleDto update(Long id, PortefeuilleDto portefeuilleDto);
    Optional<PortefeuilleDto> findById(Long id);
    List<PortefeuilleDto> findAll();
    List<PortefeuilleDto> findByAgentId(Long agentId);
    List<PortefeuilleDto> findByContribuableId(Long contribuableId);
    void delete(Long id);
    void restore(Long id);
    void desaffecter(Long id);
}
