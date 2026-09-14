package com.nectuxingenieries.collect.tax.dto;

import java.time.LocalDateTime;

public class MessageDto {
    private Long id;
    private Long expediteurId;
    private String expediteurRole;
    private Long destinataireId;
    private String destinataireRole;
    private Long signalementId;
    private String contenu;
    private Boolean lu;
    private LocalDateTime dateLecture;
    private Boolean offline;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getExpediteurId() { return expediteurId; }
    public void setExpediteurId(Long expediteurId) { this.expediteurId = expediteurId; }
    public String getExpediteurRole() { return expediteurRole; }
    public void setExpediteurRole(String expediteurRole) { this.expediteurRole = expediteurRole; }
    public Long getDestinataireId() { return destinataireId; }
    public void setDestinataireId(Long destinataireId) { this.destinataireId = destinataireId; }
    public String getDestinataireRole() { return destinataireRole; }
    public void setDestinataireRole(String destinataireRole) { this.destinataireRole = destinataireRole; }
    public Long getSignalementId() { return signalementId; }
    public void setSignalementId(Long signalementId) { this.signalementId = signalementId; }
    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }
    public Boolean getLu() { return lu; }
    public void setLu(Boolean lu) { this.lu = lu; }
    public LocalDateTime getDateLecture() { return dateLecture; }
    public void setDateLecture(LocalDateTime dateLecture) { this.dateLecture = dateLecture; }
    public Boolean getOffline() { return offline; }
    public void setOffline(Boolean offline) { this.offline = offline; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
