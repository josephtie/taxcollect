package com.nectuxingenieries.collect.tax.services;

import com.nectuxingenieries.collect.tax.dto.SyncItemDto;
import com.nectuxingenieries.collect.tax.models.enums.StatutSyncItem;
import java.util.List;
import java.util.Optional;

public interface SyncItemService {
    SyncItemDto create(SyncItemDto syncItemDto);
    Optional<SyncItemDto> findById(Long id);
    List<SyncItemDto> findByAgentId(Long agentId);
    List<SyncItemDto> findByAgentIdAndStatut(Long agentId, StatutSyncItem statut);
    List<SyncItemDto> findByStatut(StatutSyncItem statut);
    void markSynced(Long id);
    void markFailed(Long id, String errorMessage);
    long countPendingByAgentId(Long agentId);
    void delete(Long id);
}
