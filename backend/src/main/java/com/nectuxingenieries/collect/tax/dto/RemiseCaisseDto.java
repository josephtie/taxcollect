package com.nectuxingenieries.collect.tax.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class RemiseCaisseDto {
    private Long id;
    private Long caisseId;
    private BigDecimal montant;
    private String beneficiaire;
    private LocalDateTime dateRemise;
    private String reference;
    private String observation;
    private String statut;
    private Long confirmePar;
    private LocalDateTime dateConfirmation;
    private String commentaireConfirmation;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getCaisseId() { return caisseId; }
    public void setCaisseId(Long caisseId) { this.caisseId = caisseId; }
    public BigDecimal getMontant() { return montant; }
    public void setMontant(BigDecimal montant) { this.montant = montant; }
    public String getBeneficiaire() { return beneficiaire; }
    public void setBeneficiaire(String beneficiaire) { this.beneficiaire = beneficiaire; }
    public LocalDateTime getDateRemise() { return dateRemise; }
    public void setDateRemise(LocalDateTime dateRemise) { this.dateRemise = dateRemise; }
    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
    public String getObservation() { return observation; }
    public void setObservation(String observation) { this.observation = observation; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public Long getConfirmePar() { return confirmePar; }
    public void setConfirmePar(Long confirmePar) { this.confirmePar = confirmePar; }
    public LocalDateTime getDateConfirmation() { return dateConfirmation; }
    public void setDateConfirmation(LocalDateTime dateConfirmation) { this.dateConfirmation = dateConfirmation; }
    public String getCommentaireConfirmation() { return commentaireConfirmation; }
    public void setCommentaireConfirmation(String commentaireConfirmation) { this.commentaireConfirmation = commentaireConfirmation; }
}
