package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.AuditEntry;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuditEntryRepository extends BaseRepository<AuditEntry, Long>, JpaSpecificationExecutor<AuditEntry> {

    @Query("SELECT a FROM AuditEntry a WHERE a.agentId = :agentId AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByAgentId(@Param("agentId") Long agentId);

    @Query("SELECT a FROM AuditEntry a WHERE a.agentId = :agentId AND a.createdAt >= :since AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByAgentIdSince(@Param("agentId") Long agentId, @Param("since") LocalDateTime since);

    @Query("SELECT a FROM AuditEntry a WHERE a.syncStatus = :syncStatus AND a.deletedAt IS NULL")
    List<AuditEntry> findBySyncStatus(@Param("syncStatus") String syncStatus);

    @Query("SELECT a FROM AuditEntry a WHERE a.entityType = :entityType AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByEntityType(@Param("entityType") String entityType);

    @Query("SELECT a FROM AuditEntry a WHERE a.userId = :userId AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByUserId(@Param("userId") String userId);

    @Query("SELECT a FROM AuditEntry a WHERE a.createdAt >= :debut AND a.createdAt <= :fin AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByDateRange(@Param("debut") LocalDateTime debut, @Param("fin") LocalDateTime fin);

    @Query("SELECT a FROM AuditEntry a WHERE a.zoneId = :zoneId AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByZoneId(@Param("zoneId") Long zoneId);

    @Query("SELECT a FROM AuditEntry a WHERE a.quartierId = :quartierId AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByQuartierId(@Param("quartierId") Long quartierId);

    @Query("SELECT a FROM AuditEntry a WHERE a.type = :type AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByType(@Param("type") com.nectuxingenieries.collect.tax.models.enums.TypeAudit type);

    @Query("SELECT a FROM AuditEntry a WHERE a.entityType = :entityType AND a.entityId = :entityId AND a.deletedAt IS NULL ORDER BY a.createdAt DESC")
    List<AuditEntry> findByEntityTypeAndEntityId(@Param("entityType") String entityType, @Param("entityId") Long entityId);
}
