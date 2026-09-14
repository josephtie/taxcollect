package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.StatutAnomalie;
import com.nectuxingenieries.collect.tax.models.enums.TypeAnomalie;
import java.time.LocalDateTime;

public class AnomalieDto {
    private Long id;
    private Long quartierId;
    private Long secteurId;
    private String secteurNom;
    private Long contribuableId;
    private String contribuableNom;
    private Long agentId;
    private String agentNom;
    private TypeAnomalie typeAnomalie;
    private String probleme;
    private String action;
    private StatutAnomalie statut;
    private String creeParRole;
    private Long creeParId;
    private String transmiseA;
    private LocalDateTime dateTransmission;
    private String commentaireSuperviseur;
    private LocalDateTime dateCloture;
    private Long clotureePar;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getQuartierId() { return quartierId; }
    public void setQuartierId(Long quartierId) { this.quartierId = quartierId; }
    public Long getSecteurId() { return secteurId; }
    public void setSecteurId(Long secteurId) { this.secteurId = secteurId; }
    public String getSecteurNom() { return secteurNom; }
    public void setSecteurNom(String secteurNom) { this.secteurNom = secteurNom; }
    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }
    public String getContribuableNom() { return contribuableNom; }
    public void setContribuableNom(String contribuableNom) { this.contribuableNom = contribuableNom; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public TypeAnomalie getTypeAnomalie() { return typeAnomalie; }
    public void setTypeAnomalie(TypeAnomalie typeAnomalie) { this.typeAnomalie = typeAnomalie; }
    public String getProbleme() { return probleme; }
    public void setProbleme(String probleme) { this.probleme = probleme; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public StatutAnomalie getStatut() { return statut; }
    public void setStatut(StatutAnomalie statut) { this.statut = statut; }
    public String getCreeParRole() { return creeParRole; }
    public void setCreeParRole(String creeParRole) { this.creeParRole = creeParRole; }
    public Long getCreeParId() { return creeParId; }
    public void setCreeParId(Long creeParId) { this.creeParId = creeParId; }
    public String getTransmiseA() { return transmiseA; }
    public void setTransmiseA(String transmiseA) { this.transmiseA = transmiseA; }
    public LocalDateTime getDateTransmission() { return dateTransmission; }
    public void setDateTransmission(LocalDateTime dateTransmission) { this.dateTransmission = dateTransmission; }
    public String getCommentaireSuperviseur() { return commentaireSuperviseur; }
    public void setCommentaireSuperviseur(String commentaireSuperviseur) { this.commentaireSuperviseur = commentaireSuperviseur; }
    public LocalDateTime getDateCloture() { return dateCloture; }
    public void setDateCloture(LocalDateTime dateCloture) { this.dateCloture = dateCloture; }
    public Long getClotureePar() { return clotureePar; }
    public void setClotureePar(Long clotureePar) { this.clotureePar = clotureePar; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
