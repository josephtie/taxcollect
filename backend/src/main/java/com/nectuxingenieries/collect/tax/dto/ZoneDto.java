package com.nectuxingenieries.collect.tax.dto;

import java.util.List;

public class ZoneDto {
    private Long id;
    private String nom;
    private Long communeId;
    private String communeNom;
    private String superviseurId;
    private Boolean statut;
    private String geometryGeoJson;
    private List<AgentSummaryDto> agents;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Long getCommuneId() { return communeId; }
    public void setCommuneId(Long communeId) { this.communeId = communeId; }
    public String getCommuneNom() { return communeNom; }
    public void setCommuneNom(String communeNom) { this.communeNom = communeNom; }
    public String getSuperviseurId() { return superviseurId; }
    public void setSuperviseurId(String superviseurId) { this.superviseurId = superviseurId; }
    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
    public String getGeometryGeoJson() { return geometryGeoJson; }
    public void setGeometryGeoJson(String geometryGeoJson) { this.geometryGeoJson = geometryGeoJson; }
    public List<AgentSummaryDto> getAgents() { return agents; }
    public void setAgents(List<AgentSummaryDto> agents) { this.agents = agents; }
}
