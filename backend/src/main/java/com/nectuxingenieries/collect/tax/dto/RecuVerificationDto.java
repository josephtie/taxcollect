package com.nectuxingenieries.collect.tax.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class RecuVerificationDto {
    private boolean valide;
    private String numeroRecu;
    private String hashTransaction;
    private Long transactionId;
    private String contribuableNom;
    private String contribuablePrenom;
    private java.math.BigDecimal montant;
    private String modePaiement;
    private String statut;
    private LocalDateTime dateCreation;
    private String agentNom;
    private String zoneNom;
    private List<String> anomalies;

    public boolean getValide() { return valide; }
    public void setValide(boolean valide) { this.valide = valide; }
    public String getNumeroRecu() { return numeroRecu; }
    public void setNumeroRecu(String numeroRecu) { this.numeroRecu = numeroRecu; }
    public String getHashTransaction() { return hashTransaction; }
    public void setHashTransaction(String hashTransaction) { this.hashTransaction = hashTransaction; }
    public Long getTransactionId() { return transactionId; }
    public void setTransactionId(Long transactionId) { this.transactionId = transactionId; }
    public String getContribuableNom() { return contribuableNom; }
    public void setContribuableNom(String contribuableNom) { this.contribuableNom = contribuableNom; }
    public String getContribuablePrenom() { return contribuablePrenom; }
    public void setContribuablePrenom(String contribuablePrenom) { this.contribuablePrenom = contribuablePrenom; }
    public java.math.BigDecimal getMontant() { return montant; }
    public void setMontant(java.math.BigDecimal montant) { this.montant = montant; }
    public String getModePaiement() { return modePaiement; }
    public void setModePaiement(String modePaiement) { this.modePaiement = modePaiement; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public String getZoneNom() { return zoneNom; }
    public void setZoneNom(String zoneNom) { this.zoneNom = zoneNom; }
    public List<String> getAnomalies() { return anomalies; }
    public void setAnomalies(List<String> anomalies) { this.anomalies = anomalies; }
}
