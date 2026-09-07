package com.nectuxingenieries.collect.tax.dto;


import java.math.BigDecimal;
import java.time.LocalDate;

public class TaxeCollectDto {
    private Long id;
    private Long contribuableId;
    private Long taxeId;
    private BigDecimal montant;
    private LocalDate datePaiement;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private LocalDate dueDate;
    private String periodeConcernee;
    private String statut; // Enum sous forme String
    private String taxType;
    private String reference;

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
    public BigDecimal getMontant() {
        return montant;
    }
    public void setMontant(BigDecimal montant) {
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
    public LocalDate getPeriodStart() {
        return periodStart;
    }
    public void setPeriodStart(LocalDate periodStart) {
        this.periodStart = periodStart;
    }
    public LocalDate getPeriodEnd() {
        return periodEnd;
    }
    public void setPeriodEnd(LocalDate periodEnd) {
        this.periodEnd = periodEnd;
    }
    public LocalDate getDueDate() {
        return dueDate;
    }
    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }
    public String getTaxType() {
        return taxType;
    }
    public void setTaxType(String taxType) {
        this.taxType = taxType;
    }
    public String getReference() {
        return reference;
    }
    public void setReference(String reference) {
        this.reference = reference;
    }
}

