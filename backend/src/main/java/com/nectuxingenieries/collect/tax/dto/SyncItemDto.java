package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.StatutSyncItem;
import java.time.LocalDateTime;

public class SyncItemDto {
    private Long id;
    private Long agentId;
    private String entityType;
    private Long entityId;
    private String localId;
    private StatutSyncItem statut;
    private String action;
    private String payload;
    private String errorMessage;
    private Integer retryCount;
    private LocalDateTime lastSyncAttempt;
    private LocalDateTime syncedAt;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public Long getEntityId() { return entityId; }
    public void setEntityId(Long entityId) { this.entityId = entityId; }
    public String getLocalId() { return localId; }
    public void setLocalId(String localId) { this.localId = localId; }
    public StatutSyncItem getStatut() { return statut; }
    public void setStatut(StatutSyncItem statut) { this.statut = statut; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getPayload() { return payload; }
    public void setPayload(String payload) { this.payload = payload; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    public Integer getRetryCount() { return retryCount; }
    public void setRetryCount(Integer retryCount) { this.retryCount = retryCount; }
    public LocalDateTime getLastSyncAttempt() { return lastSyncAttempt; }
    public void setLastSyncAttempt(LocalDateTime lastSyncAttempt) { this.lastSyncAttempt = lastSyncAttempt; }
    public LocalDateTime getSyncedAt() { return syncedAt; }
    public void setSyncedAt(LocalDateTime syncedAt) { this.syncedAt = syncedAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
