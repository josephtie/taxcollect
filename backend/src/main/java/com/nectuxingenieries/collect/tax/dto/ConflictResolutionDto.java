package com.nectuxingenieries.collect.tax.dto;

public class ConflictResolutionDto {
    private Long syncItemId;
    private String entityType;
    private Long entityId;
    private String localData;
    private String serverData;
    private String resolution;
    private String resolvedBy;
    private String commentaire;

    public Long getSyncItemId() { return syncItemId; }
    public void setSyncItemId(Long syncItemId) { this.syncItemId = syncItemId; }
    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }
    public Long getEntityId() { return entityId; }
    public void setEntityId(Long entityId) { this.entityId = entityId; }
    public String getLocalData() { return localData; }
    public void setLocalData(String localData) { this.localData = localData; }
    public String getServerData() { return serverData; }
    public void setServerData(String serverData) { this.serverData = serverData; }
    public String getResolution() { return resolution; }
    public void setResolution(String resolution) { this.resolution = resolution; }
    public String getResolvedBy() { return resolvedBy; }
    public void setResolvedBy(String resolvedBy) { this.resolvedBy = resolvedBy; }
    public String getCommentaire() { return commentaire; }
    public void setCommentaire(String commentaire) { this.commentaire = commentaire; }
}
