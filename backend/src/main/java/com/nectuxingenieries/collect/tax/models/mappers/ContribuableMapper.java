package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.dto.ContribuableDto;
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
public interface ContribuableMapper {

    @Mapping(target = "zoneId", source = "zone.id")
    @Mapping(target = "zoneNom", source = "zone.nom")
    @Mapping(target = "quartierId", source = "quartierEntite.id")
    @Mapping(target = "quartierNom", source = "quartierEntite.nom")
    @Mapping(target = "secteurId", source = "secteur.id")
    @Mapping(target = "secteurNom", source = "secteur.nom")
    ContribuableDto toDto(Contribuable contribuable);

    @Mapping(target = "zone", ignore = true)
    @Mapping(target = "quartierEntite", ignore = true)
    @Mapping(target = "secteur", ignore = true)
    Contribuable toEntity(ContribuableDto contribuableDto);

    @Mapping(target = "zone", ignore = true)
    @Mapping(target = "quartierEntite", ignore = true)
    @Mapping(target = "secteur", ignore = true)
    void updateFromDto(ContribuableDto contribuableDto, @MappingTarget Contribuable contribuable);
}

