package com.nectuxingenieries.collect.tax.dto;

import java.util.List;

public class SupervisedZoneDto {
    private Long id;
    private String nom;
    private String communeNom;
    private Boolean statut;
    private String superviseurId;
    private List<AgentSummaryDto> agents;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getCommuneNom() { return communeNom; }
    public void setCommuneNom(String communeNom) { this.communeNom = communeNom; }
    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
    public String getSuperviseurId() { return superviseurId; }
    public void setSuperviseurId(String superviseurId) { this.superviseurId = superviseurId; }
    public List<AgentSummaryDto> getAgents() { return agents; }
    public void setAgents(List<AgentSummaryDto> agents) { this.agents = agents; }
}
