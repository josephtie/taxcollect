package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.Anomalie;
import com.nectuxingenieries.collect.tax.dto.AnomalieDto;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface AnomalieMapper {
    AnomalieDto toDto(Anomalie anomalie);
    Anomalie toEntity(AnomalieDto anomalieDto);
}
