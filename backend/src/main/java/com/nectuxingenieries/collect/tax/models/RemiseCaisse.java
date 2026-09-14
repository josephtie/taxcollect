package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "remise_caisse")
public class RemiseCaisse extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "caisse_id", nullable = false)
    private Caisse caisse;

    @Column(name = "montant", nullable = false, precision = 19, scale = 2)
    private BigDecimal montant;

    @Column(name = "beneficiaire", nullable = false, length = 255)
    private String beneficiaire;

    @Column(name = "date_remise", nullable = false)
    private LocalDateTime dateRemise;

    @Column(name = "reference", length = 100)
    private String reference;

    @Column(name = "observation", length = 1000)
    private String observation;

    @Column(name = "statut", nullable = false, length = 20)
    private String statut = "EN_ATTENTE";

    @Column(name = "confirme_par")
    private Long confirmePar;

    @Column(name = "date_confirmation")
    private LocalDateTime dateConfirmation;

    @Column(name = "commentaire_confirmation", length = 1000)
    private String commentaireConfirmation;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Caisse getCaisse() { return caisse; }
    public void setCaisse(Caisse caisse) { this.caisse = caisse; }
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
