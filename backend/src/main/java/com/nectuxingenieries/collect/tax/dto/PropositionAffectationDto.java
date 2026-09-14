package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.StatutProposition;
import java.time.LocalDateTime;

public class PropositionAffectationDto {
    private Long id;
    private Long agentId;
    private String agentNom;
    private Long secteurId;
    private String secteurNom;
    private Long quartierId;
    private Long proposeParId;
    private String proposeParRole;
    private String motif;
    private StatutProposition statut;
    private Long valideePar;
    private LocalDateTime dateValidation;
    private String commentaireValidation;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public Long getSecteurId() { return secteurId; }
    public void setSecteurId(Long secteurId) { this.secteurId = secteurId; }
    public String getSecteurNom() { return secteurNom; }
    public void setSecteurNom(String secteurNom) { this.secteurNom = secteurNom; }
    public Long getQuartierId() { return quartierId; }
    public void setQuartierId(Long quartierId) { this.quartierId = quartierId; }
    public Long getProposeParId() { return proposeParId; }
    public void setProposeParId(Long proposeParId) { this.proposeParId = proposeParId; }
    public String getProposeParRole() { return proposeParRole; }
    public void setProposeParRole(String proposeParRole) { this.proposeParRole = proposeParRole; }
    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }
    public StatutProposition getStatut() { return statut; }
    public void setStatut(StatutProposition statut) { this.statut = statut; }
    public Long getValideePar() { return valideePar; }
    public void setValideePar(Long valideePar) { this.valideePar = valideePar; }
    public LocalDateTime getDateValidation() { return dateValidation; }
    public void setDateValidation(LocalDateTime dateValidation) { this.dateValidation = dateValidation; }
    public String getCommentaireValidation() { return commentaireValidation; }
    public void setCommentaireValidation(String commentaireValidation) { this.commentaireValidation = commentaireValidation; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
