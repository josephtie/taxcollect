package com.nectuxingenieries.collect.tax.dto;

import java.time.LocalDate;

public class PortefeuilleDto {
    private Long id;
    private Long agentId;
    private String agentNom;
    private Long contribuableId;
    private String contribuableNom;
    private LocalDate dateAffectation;
    private LocalDate dateFin;
    private Boolean statut;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }
    public String getContribuableNom() { return contribuableNom; }
    public void setContribuableNom(String contribuableNom) { this.contribuableNom = contribuableNom; }
    public LocalDate getDateAffectation() { return dateAffectation; }
    public void setDateAffectation(LocalDate dateAffectation) { this.dateAffectation = dateAffectation; }
    public LocalDate getDateFin() { return dateFin; }
    public void setDateFin(LocalDate dateFin) { this.dateFin = dateFin; }
    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
}
