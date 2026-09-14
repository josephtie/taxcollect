package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Portefeuille;
import com.nectuxingenieries.collect.tax.dto.PortefeuilleDto;
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
public interface PortefeuilleMapper {

    @Mapping(source = "agent.id", target = "agentId")
    @Mapping(source = "agent.nom", target = "agentNom")
    @Mapping(source = "contribuable.id", target = "contribuableId")
    @Mapping(source = "contribuable.nom", target = "contribuableNom")
    PortefeuilleDto toDto(Portefeuille portefeuille);

    @Mapping(target = "agent", ignore = true)
    @Mapping(target = "contribuable", ignore = true)
    Portefeuille toEntity(PortefeuilleDto portefeuilleDto);

    @Mapping(target = "agent", ignore = true)
    @Mapping(target = "contribuable", ignore = true)
    void updateFromDto(PortefeuilleDto portefeuilleDto, @MappingTarget Portefeuille portefeuille);
}
