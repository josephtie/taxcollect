package com.nectuxingenieries.collect.tax.models.dto;


import java.time.LocalDate;

public class TaxeCollectDto {
    private Long id;
    private Long contribuableId;
    private Long taxeId;
    private Double montant;
    private LocalDate datePaiement;
    private String periodeConcernee;
    private String statut; // Enum sous forme String

    // Getters & setters
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public Long getContribuableId() {
        return contribuableId;
    }
    public void setContribuableId(Long contribuableId) {
        this.contribuableId = contribuableId;
    }
    public Long getTaxeId() {
        return taxeId;
    }
    public void setTaxeId(Long taxeId) {
        this.taxeId = taxeId;
    }
    public Double getMontant() {
        return montant;
    }
    public void setMontant(Double montant) {
        this.montant = montant;
    }
    public LocalDate getDatePaiement() {
        return datePaiement;
    }
    public void setDatePaiement(LocalDate datePaiement) {
        this.datePaiement = datePaiement;
    }
    public String getPeriodeConcernee() {
        return periodeConcernee;
    }
    public void setPeriodeConcernee(String periodeConcernee) {
        this.periodeConcernee = periodeConcernee;
    }
    public String getStatut() {
        return statut;
    }
    public void setStatut(String statut) {
        this.statut = statut;
    }
}

