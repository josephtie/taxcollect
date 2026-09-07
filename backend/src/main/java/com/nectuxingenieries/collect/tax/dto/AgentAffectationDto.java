package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.TerritoryType;
import java.time.LocalDate;

public class AgentAffectationDto {
    private Long id;
    private Long agentId;
    private String agentNom;
    private String agentPrenom;
    private String agentEmail;
    private String agentTelephone;
    private String agentInitials;
    private TerritoryType territoryType;
    private Long territoryId;
    private String territoryNom;
    private LocalDate dateDebut;
    private LocalDate dateFin;
    private Boolean statut;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public String getAgentPrenom() { return agentPrenom; }
    public void setAgentPrenom(String agentPrenom) { this.agentPrenom = agentPrenom; }
    public String getAgentEmail() { return agentEmail; }
    public void setAgentEmail(String agentEmail) { this.agentEmail = agentEmail; }
    public String getAgentTelephone() { return agentTelephone; }
    public void setAgentTelephone(String agentTelephone) { this.agentTelephone = agentTelephone; }
    public String getAgentInitials() { return agentInitials; }
    public void setAgentInitials(String agentInitials) { this.agentInitials = agentInitials; }
    public TerritoryType getTerritoryType() { return territoryType; }
    public void setTerritoryType(TerritoryType territoryType) { this.territoryType = territoryType; }
    public Long getTerritoryId() { return territoryId; }
    public void setTerritoryId(Long territoryId) { this.territoryId = territoryId; }
    public String getTerritoryNom() { return territoryNom; }
    public void setTerritoryNom(String territoryNom) { this.territoryNom = territoryNom; }
    public LocalDate getDateDebut() { return dateDebut; }
    public void setDateDebut(LocalDate dateDebut) { this.dateDebut = dateDebut; }
    public LocalDate getDateFin() { return dateFin; }
    public void setDateFin(LocalDate dateFin) { this.dateFin = dateFin; }
    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
}
