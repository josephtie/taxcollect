package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.StatutAnomalie;
import com.nectuxingenieries.collect.tax.models.enums.TypeAnomalie;
import jakarta.persistence.*;

@Entity
@Table(name = "anomalie")
public class Anomalie extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "quartier_id")
    private Long quartierId;

    @Column(name = "secteur_id")
    private Long secteurId;

    @Column(name = "secteur_nom", length = 100)
    private String secteurNom;

    @Column(name = "contribuable_id")
    private Long contribuableId;

    @Column(name = "contribuable_nom", length = 255)
    private String contribuableNom;

    @Column(name = "agent_id")
    private Long agentId;

    @Column(name = "agent_nom", length = 255)
    private String agentNom;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeAnomalie typeAnomalie;

    @Column(nullable = false, length = 500)
    private String probleme;

    @Column(length = 500)
    private String action;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutAnomalie statut = StatutAnomalie.OUVERTE;

    @Column(name = "cree_par_role", length = 30)
    private String creeParRole;

    @Column(name = "cree_par_id")
    private Long creeParId;

    @Column(name = "transmise_a", length = 30)
    private String transmiseA;

    @Column(name = "date_transmission")
    private java.time.LocalDateTime dateTransmission;

    @Column(name = "commentaire_superviseur", length = 1000)
    private String commentaireSuperviseur;

    @Column(name = "date_cloture")
    private java.time.LocalDateTime dateCloture;

    @Column(name = "cloturee_par")
    private Long clotureePar;

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
    public java.time.LocalDateTime getDateTransmission() { return dateTransmission; }
    public void setDateTransmission(java.time.LocalDateTime dateTransmission) { this.dateTransmission = dateTransmission; }
    public String getCommentaireSuperviseur() { return commentaireSuperviseur; }
    public void setCommentaireSuperviseur(String commentaireSuperviseur) { this.commentaireSuperviseur = commentaireSuperviseur; }
    public java.time.LocalDateTime getDateCloture() { return dateCloture; }
    public void setDateCloture(java.time.LocalDateTime dateCloture) { this.dateCloture = dateCloture; }
    public Long getClotureePar() { return clotureePar; }
    public void setClotureePar(Long clotureePar) { this.clotureePar = clotureePar; }
}
