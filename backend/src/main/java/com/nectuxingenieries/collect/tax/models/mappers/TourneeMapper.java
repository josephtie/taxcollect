package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Tournee;
import com.nectuxingenieries.collect.tax.dto.TourneeDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface TourneeMapper {

    @Mapping(source = "agent.id", target = "agentId")
    @Mapping(source = "agent.nom", target = "agentNom")
    TourneeDto toDto(Tournee tournee);

    @Mapping(target = "agent", ignore = true)
    Tournee toEntity(TourneeDto tourneeDto);

    @Mapping(target = "agent", ignore = true)
    void updateFromDto(TourneeDto tourneeDto, @MappingTarget Tournee tournee);
}
