package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.AuditEntryDto;
import com.nectuxingenieries.collect.tax.models.enums.TypeAudit;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface AuditEntryService {
    AuditEntryDto create(AuditEntryDto auditEntryDto);
    Optional<AuditEntryDto> findById(Long id);
    List<AuditEntryDto> findByAgentId(Long agentId);
    List<AuditEntryDto> findByAgentIdSince(Long agentId, LocalDateTime since);
    List<AuditEntryDto> findPendingSync();
    List<AuditEntryDto> findByEntityType(String entityType);
    List<AuditEntryDto> findByUserId(String userId);
    List<AuditEntryDto> findByDateRange(LocalDateTime debut, LocalDateTime fin);
    List<AuditEntryDto> findByZoneId(Long zoneId);
    List<AuditEntryDto> findByQuartierId(Long quartierId);
    List<AuditEntryDto> findByType(TypeAudit type);
    List<AuditEntryDto> findByEntityTypeAndEntityId(String entityType, Long entityId);
    void trace(TypeAudit type, String action, String entityType, Long entityId, String description, String userId, String userRole, Long zoneId, Long quartierId);
    void delete(Long id);
}
