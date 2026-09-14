package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.TypeNotification;
import java.time.LocalDateTime;

public class NotificationDto {
    private Long id;
    private Long agentId;
    private TypeNotification type;
    private String message;
    private Boolean lu;
    private LocalDateTime dateLecture;
    private Long referenceId;
    private String referenceType;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public TypeNotification getType() { return type; }
    public void setType(TypeNotification type) { this.type = type; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Boolean getLu() { return lu; }
    public void setLu(Boolean lu) { this.lu = lu; }
    public LocalDateTime getDateLecture() { return dateLecture; }
    public void setDateLecture(LocalDateTime dateLecture) { this.dateLecture = dateLecture; }
    public Long getReferenceId() { return referenceId; }
    public void setReferenceId(Long referenceId) { this.referenceId = referenceId; }
    public String getReferenceType() { return referenceType; }
    public void setReferenceType(String referenceType) { this.referenceType = referenceType; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
