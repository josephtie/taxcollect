package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Contribuable;
import com.nectuxingenieries.collect.tax.models.dto.ContribuableDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface ContribuableMapper {

    ContribuableDto toDto(Contribuable contribuable);
    Contribuable toEntity(ContribuableDto contribuableDto);
    void updateFromDto(ContribuableDto contribuableDto, @MappingTarget Contribuable contribuable);
}

