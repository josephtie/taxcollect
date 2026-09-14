package com.nectuxingenieries.collect.tax.repositories;

import com.nectuxingenieries.collect.tax.models.SyncItem;
import com.nectuxingenieries.collect.tax.models.enums.StatutSyncItem;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SyncItemRepository extends BaseRepository<SyncItem, Long>, JpaSpecificationExecutor<SyncItem> {

    @Query("SELECT s FROM SyncItem s WHERE s.agentId = :agentId AND s.statut = :statut AND s.deletedAt IS NULL ORDER BY s.createdAt ASC")
    List<SyncItem> findByAgentIdAndStatut(@Param("agentId") Long agentId, @Param("statut") StatutSyncItem statut);

    @Query("SELECT s FROM SyncItem s WHERE s.statut = :statut AND s.deletedAt IS NULL ORDER BY s.createdAt ASC")
    List<SyncItem> findByStatut(@Param("statut") StatutSyncItem statut);

    @Query("SELECT s FROM SyncItem s WHERE s.agentId = :agentId AND s.deletedAt IS NULL ORDER BY s.createdAt DESC")
    List<SyncItem> findByAgentId(@Param("agentId") Long agentId);

    @Modifying
    @Transactional
    @Query("UPDATE SyncItem s SET s.statut = :statut, s.syncedAt = :syncedAt WHERE s.id = :id")
    void updateStatut(@Param("id") Long id, @Param("statut") StatutSyncItem statut, @Param("syncedAt") LocalDateTime syncedAt);

    @Modifying
    @Transactional
    @Query("UPDATE SyncItem s SET s.statut = :statut, s.errorMessage = :error, s.retryCount = s.retryCount + 1, s.lastSyncAttempt = :attempt WHERE s.id = :id")
    void markFailed(@Param("id") Long id, @Param("statut") StatutSyncItem statut, @Param("error") String error, @Param("attempt") LocalDateTime attempt);

    @Query("SELECT COUNT(s) FROM SyncItem s WHERE s.agentId = :agentId AND s.statut = :statut AND s.deletedAt IS NULL")
    long countByAgentIdAndStatut(@Param("agentId") Long agentId, @Param("statut") StatutSyncItem statut);
}
