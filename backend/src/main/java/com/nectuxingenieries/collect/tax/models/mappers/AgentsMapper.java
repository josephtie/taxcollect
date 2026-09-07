package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.StatutAgent;
import com.nectuxingenieries.collect.tax.dto.AgentsDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.Named;

@Mapper(componentModel = "spring")
public interface AgentsMapper {

    @Mapping(target = "statut", defaultValue = "ACTIF")
    AgentsDto toDto(Agents agent);
    
    @Mapping(target = "statut", defaultValue = "ACTIF")
    Agents toEntity(AgentsDto agentDto);
    
    @Mapping(target = "statut", defaultValue = "ACTIF")
    void updateFromDto(AgentsDto agentDto, @MappingTarget Agents agent);
    
    // Méthode de debug pour vérifier le mapping
    default Agents debugToEntity(AgentsDto dto) {
        System.out.println("DEBUG Mapper: Input DTO statut: " + dto.getStatut());
        Agents entity = toEntity(dto);
        System.out.println("DEBUG Mapper: Output Entity statut: " + entity.getStatut());
        return entity;
    }
}

