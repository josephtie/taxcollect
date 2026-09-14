package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.SyncItem;
import com.nectuxingenieries.collect.tax.dto.SyncItemDto;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface SyncItemMapper {
    SyncItemDto toDto(SyncItem syncItem);
    SyncItem toEntity(SyncItemDto syncItemDto);
}
