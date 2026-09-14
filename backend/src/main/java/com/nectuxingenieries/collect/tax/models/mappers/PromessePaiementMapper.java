package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.PromessePaiement;
import com.nectuxingenieries.collect.tax.dto.PromessePaiementDto;
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
public interface PromessePaiementMapper {

    @Mapping(source = "contribuable.id", target = "contribuableId")
    @Mapping(source = "contribuable.nom", target = "contribuableNom")
    @Mapping(source = "agent.id", target = "agentId")
    @Mapping(source = "agent.nom", target = "agentNom")
    PromessePaiementDto toDto(PromessePaiement promesse);

    @Mapping(target = "contribuable", ignore = true)
    @Mapping(target = "agent", ignore = true)
    PromessePaiement toEntity(PromessePaiementDto promesseDto);

    @Mapping(target = "contribuable", ignore = true)
    @Mapping(target = "agent", ignore = true)
    void updateFromDto(PromessePaiementDto promesseDto, @MappingTarget PromessePaiement promesse);
}
