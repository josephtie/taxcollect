package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Caisse;
import com.nectuxingenieries.collect.tax.dto.CaisseDto;
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
public interface CaisseMapper {
    @Mapping(target = "agentId", source = "agent.id")
    @Mapping(target = "agentNom", source = "agent.nom")
    CaisseDto toDto(Caisse caisse);
    @Mapping(target = "agent", ignore = true)
    Caisse toEntity(CaisseDto caisseDto);
    @Mapping(target = "agent", ignore = true)
    void updateFromDto(CaisseDto caisseDto, @MappingTarget Caisse caisse);
}
