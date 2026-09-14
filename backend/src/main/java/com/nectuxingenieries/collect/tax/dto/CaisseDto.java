package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.StatutCaisse;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class CaisseDto {
    private Long id;
    private Long agentId;
    private String agentNom;
    private LocalDate dateCaisse;
    private BigDecimal soldeInitial;
    private BigDecimal montantEspece;
    private BigDecimal montantMobileMoney;
    private BigDecimal montantTotal;
    private StatutCaisse statut;
    private LocalDateTime dateOuverture;
    private LocalDateTime dateCloture;
    private Integer nombreTransactions;
    private String observation;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public LocalDate getDateCaisse() { return dateCaisse; }
    public void setDateCaisse(LocalDate dateCaisse) { this.dateCaisse = dateCaisse; }
    public BigDecimal getSoldeInitial() { return soldeInitial; }
    public void setSoldeInitial(BigDecimal soldeInitial) { this.soldeInitial = soldeInitial; }
    public BigDecimal getMontantEspece() { return montantEspece; }
    public void setMontantEspece(BigDecimal montantEspece) { this.montantEspece = montantEspece; }
    public BigDecimal getMontantMobileMoney() { return montantMobileMoney; }
    public void setMontantMobileMoney(BigDecimal montantMobileMoney) { this.montantMobileMoney = montantMobileMoney; }
    public BigDecimal getMontantTotal() { return montantTotal; }
    public void setMontantTotal(BigDecimal montantTotal) { this.montantTotal = montantTotal; }
    public StatutCaisse getStatut() { return statut; }
    public void setStatut(StatutCaisse statut) { this.statut = statut; }
    public LocalDateTime getDateOuverture() { return dateOuverture; }
    public void setDateOuverture(LocalDateTime dateOuverture) { this.dateOuverture = dateOuverture; }
    public LocalDateTime getDateCloture() { return dateCloture; }
    public void setDateCloture(LocalDateTime dateCloture) { this.dateCloture = dateCloture; }
    public Integer getNombreTransactions() { return nombreTransactions; }
    public void setNombreTransactions(Integer nombreTransactions) { this.nombreTransactions = nombreTransactions; }
    public String getObservation() { return observation; }
    public void setObservation(String observation) { this.observation = observation; }
}
