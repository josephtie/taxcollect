package com.nectuxingenieries.collect.tax.services.impl;

import com.nectuxingenieries.collect.tax.models.AuditEntry;
import com.nectuxingenieries.collect.tax.dto.AuditEntryDto;
import com.nectuxingenieries.collect.tax.models.enums.TypeAudit;
import com.nectuxingenieries.collect.tax.models.mappers.AuditEntryMapper;
import com.nectuxingenieries.collect.tax.services.AuditEntryService;
import com.nectuxingenieries.collect.tax.repositories.AuditEntryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class AuditEntryServiceImpl implements AuditEntryService {

    @Autowired
    private AuditEntryRepository auditEntryRepository;
    @Autowired
    private AuditEntryMapper auditEntryMapper;

    @Override
    public AuditEntryDto create(AuditEntryDto auditEntryDto) {
        AuditEntry entity = auditEntryMapper.toEntity(auditEntryDto);
        return auditEntryMapper.toDto(auditEntryRepository.save(entity));
    }

    @Override
    public Optional<AuditEntryDto> findById(Long id) {
        return auditEntryRepository.findById(id).map(auditEntryMapper::toDto);
    }

    @Override
    public List<AuditEntryDto> findByAgentId(Long agentId) {
        return auditEntryRepository.findByAgentId(agentId).stream()
                .map(auditEntryMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findByAgentIdSince(Long agentId, LocalDateTime since) {
        return auditEntryRepository.findByAgentIdSince(agentId, since).stream()
                .map(auditEntryMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findPendingSync() {
        return auditEntryRepository.findBySyncStatus("PENDING").stream()
                .map(auditEntryMapper::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void delete(Long id) {
        auditEntryRepository.deleteLogical(id, "system");
    }

    @Override
    public List<AuditEntryDto> findByEntityType(String entityType) {
        return auditEntryRepository.findByEntityType(entityType).stream()
                .map(auditEntryMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findByUserId(String userId) {
        return auditEntryRepository.findByUserId(userId).stream()
                .map(auditEntryMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findByDateRange(LocalDateTime debut, LocalDateTime fin) {
        return auditEntryRepository.findByDateRange(debut, fin).stream()
                .map(auditEntryMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findByZoneId(Long zoneId) {
        return auditEntryRepository.findByZoneId(zoneId).stream()
                .map(auditEntryMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findByQuartierId(Long quartierId) {
        return auditEntryRepository.findByQuartierId(quartierId).stream()
                .map(auditEntryMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findByType(TypeAudit type) {
        return auditEntryRepository.findByType(type).stream()
                .map(auditEntryMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public List<AuditEntryDto> findByEntityTypeAndEntityId(String entityType, Long entityId) {
        return auditEntryRepository.findByEntityTypeAndEntityId(entityType, entityId).stream()
                .map(auditEntryMapper::toDto).collect(Collectors.toList());
    }

    @Override
    public void trace(TypeAudit type, String action, String entityType, Long entityId,
                       String description, String userId, String userRole, Long zoneId, Long quartierId) {
        AuditEntry entry = new AuditEntry();
        entry.setType(type);
        entry.setAction(action);
        entry.setEntityType(entityType);
        entry.setEntityId(entityId);
        entry.setDescription(description);
        entry.setUserId(userId);
        entry.setUserRole(userRole);
        entry.setZoneId(zoneId);
        entry.setQuartierId(quartierId);
        entry.setOffline(false);
        entry.setSyncStatus("SYNCED");
        auditEntryRepository.save(entry);
    }
}
