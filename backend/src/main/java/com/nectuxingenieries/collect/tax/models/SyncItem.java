package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.StatutSyncItem;
import jakarta.persistence.*;

@Entity
@Table(name = "sync_item")
public class SyncItem extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "agent_id")
    private Long agentId;

    @Column(name = "entity_type", nullable = false, length = 50)
    private String entityType;

    @Column(name = "entity_id")
    private Long entityId;

    @Column(name = "local_id", length = 100)
    private String localId;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false)
    private StatutSyncItem statut = StatutSyncItem.PENDING;

    @Column(name = "action", nullable = false, length = 20)
    private String action;

    @Column(name = "payload", columnDefinition = "TEXT")
    private String payload;

    @Column(name = "error_message", length = 1000)
    private String errorMessage;

    @Column(name = "retry_count", nullable = false)
    private Integer retryCount = 0;

    @Column(name = "last_sync_attempt")
    private java.time.LocalDateTime lastSyncAttempt;

    @Column(name = "synced_at")
    private java.time.LocalDateTime syncedAt;

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
    public java.time.LocalDateTime getLastSyncAttempt() { return lastSyncAttempt; }
    public void setLastSyncAttempt(java.time.LocalDateTime lastSyncAttempt) { this.lastSyncAttempt = lastSyncAttempt; }
    public java.time.LocalDateTime getSyncedAt() { return syncedAt; }
    public void setSyncedAt(java.time.LocalDateTime syncedAt) { this.syncedAt = syncedAt; }
}
