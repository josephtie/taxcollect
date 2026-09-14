package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.RemiseCaisse;
import com.nectuxingenieries.collect.tax.dto.RemiseCaisseDto;
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
public interface RemiseCaisseMapper {
    @Mapping(target = "caisseId", source = "caisse.id")
    RemiseCaisseDto toDto(RemiseCaisse remiseCaisse);
    @Mapping(target = "caisse", ignore = true)
    RemiseCaisse toEntity(RemiseCaisseDto remiseCaisseDto);
    @Mapping(target = "caisse", ignore = true)
    void updateFromDto(RemiseCaisseDto remiseCaisseDto, @MappingTarget RemiseCaisse remiseCaisse);
}
