package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Visite;
import com.nectuxingenieries.collect.tax.dto.VisiteDto;
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
public interface VisiteMapper {

    @Mapping(source = "tournee.id", target = "tourneeId")
    @Mapping(source = "contribuable.id", target = "contribuableId")
    @Mapping(source = "contribuable.nom", target = "contribuableNom")
    VisiteDto toDto(Visite visite);

    @Mapping(target = "tournee", ignore = true)
    @Mapping(target = "contribuable", ignore = true)
    Visite toEntity(VisiteDto visiteDto);

    @Mapping(target = "tournee", ignore = true)
    @Mapping(target = "contribuable", ignore = true)
    void updateFromDto(VisiteDto visiteDto, @MappingTarget Visite visite);
}
