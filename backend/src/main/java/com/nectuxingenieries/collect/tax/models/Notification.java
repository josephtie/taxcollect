package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.TypeNotification;
import jakarta.persistence.*;

@Entity
@Table(name = "notification")
public class Notification extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "agent_id")
    private Long agentId;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private TypeNotification type;

    @Column(nullable = false, length = 500)
    private String message;

    @Column(name = "lu", nullable = false)
    private Boolean lu = false;

    @Column(name = "date_lecture")
    private java.time.LocalDateTime dateLecture;

    @Column(name = "reference_id")
    private Long referenceId;

    @Column(name = "reference_type", length = 50)
    private String referenceType;

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
    public java.time.LocalDateTime getDateLecture() { return dateLecture; }
    public void setDateLecture(java.time.LocalDateTime dateLecture) { this.dateLecture = dateLecture; }
    public Long getReferenceId() { return referenceId; }
    public void setReferenceId(Long referenceId) { this.referenceId = referenceId; }
    public String getReferenceType() { return referenceType; }
    public void setReferenceType(String referenceType) { this.referenceType = referenceType; }
}
