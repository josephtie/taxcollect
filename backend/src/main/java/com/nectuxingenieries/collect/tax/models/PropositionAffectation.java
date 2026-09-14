package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.StatutProposition;
import jakarta.persistence.*;

@Entity
@Table(name = "proposition_affectation")
public class PropositionAffectation extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "agent_id", nullable = false)
    private Long agentId;

    @Column(name = "agent_nom", length = 255)
    private String agentNom;

    @Column(name = "secteur_id")
    private Long secteurId;

    @Column(name = "secteur_nom", length = 100)
    private String secteurNom;

    @Column(name = "quartier_id")
    private Long quartierId;

    @Column(name = "propose_par_id", nullable = false)
    private Long proposeParId;

    @Column(name = "propose_par_role", length = 30)
    private String proposeParRole;

    @Column(length = 500)
    private String motif;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutProposition statut = StatutProposition.EN_ATTENTE;

    @Column(name = "validee_par")
    private Long valideePar;

    @Column(name = "date_validation")
    private java.time.LocalDateTime dateValidation;

    @Column(name = "commentaire_validation", length = 1000)
    private String commentaireValidation;

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
    public java.time.LocalDateTime getDateValidation() { return dateValidation; }
    public void setDateValidation(java.time.LocalDateTime dateValidation) { this.dateValidation = dateValidation; }
    public String getCommentaireValidation() { return commentaireValidation; }
    public void setCommentaireValidation(String commentaireValidation) { this.commentaireValidation = commentaireValidation; }
}
