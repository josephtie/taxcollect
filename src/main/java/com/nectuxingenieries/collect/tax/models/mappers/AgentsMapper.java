package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Agents;
import com.nectuxingenieries.collect.tax.models.dto.AgentsDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface AgentsMapper {

    AgentsDto toDto(Agents agent);
    Agents toEntity(AgentsDto agentDto);
    void updateFromDto(AgentsDto agentDto, @MappingTarget Agents agent);
}

