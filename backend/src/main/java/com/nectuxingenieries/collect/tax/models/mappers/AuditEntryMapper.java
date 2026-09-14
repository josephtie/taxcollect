package com.nectuxingenieries.collect.tax.models.mappers;

import com.nectuxingenieries.collect.tax.models.AuditEntry;
import com.nectuxingenieries.collect.tax.dto.AuditEntryDto;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(
    componentModel = "spring",
    nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
    unmappedTargetPolicy = ReportingPolicy.IGNORE
)
public interface AuditEntryMapper {
    AuditEntryDto toDto(AuditEntry auditEntry);
    AuditEntry toEntity(AuditEntryDto auditEntryDto);
}
