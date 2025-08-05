package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Commune;
import com.nectuxingenieries.collect.tax.models.dto.CommuneDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface CommuneMapper {

    CommuneDto toDto(Commune commune);
    Commune toEntity(CommuneDto communeDto);
    void updateFromDto(CommuneDto communeDto, @MappingTarget Commune commune);
}

