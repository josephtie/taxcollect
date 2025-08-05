package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.ZoneCollecte;
import com.nectuxingenieries.collect.tax.models.dto.ZoneCollectDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface ZoneCollecteMapper {

    ZoneCollectDto toDto(ZoneCollecte zone);
    ZoneCollecte toEntity(ZoneCollectDto zoneDto);
    void updateFromDto(ZoneCollectDto zoneDto, @MappingTarget ZoneCollecte zone);
}

