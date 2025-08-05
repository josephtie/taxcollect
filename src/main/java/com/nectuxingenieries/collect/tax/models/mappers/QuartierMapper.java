package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Quartier;
import com.nectuxingenieries.collect.tax.models.dto.QuartierDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface QuartierMapper {

    QuartierDto toDto(Quartier quartier);
    Quartier toEntity(QuartierDto quartierDto);
    void updateFromDto(QuartierDto quartierDto, @MappingTarget Quartier quartier);
}

