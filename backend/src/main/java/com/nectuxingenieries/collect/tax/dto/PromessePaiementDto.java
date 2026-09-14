package com.nectuxingenieries.collect.tax.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public class PromessePaiementDto {
    private Long id;
    private Long contribuableId;
    private String contribuableNom;
    private Long agentId;
    private String agentNom;
    private BigDecimal montantPromis;
    private LocalDate datePromesse;
    private LocalDate dateEcheance;
    private String statut;
    private String observation;
    private Boolean relanceEffectuee;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }
    public String getContribuableNom() { return contribuableNom; }
    public void setContribuableNom(String contribuableNom) { this.contribuableNom = contribuableNom; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public BigDecimal getMontantPromis() { return montantPromis; }
    public void setMontantPromis(BigDecimal montantPromis) { this.montantPromis = montantPromis; }
    public LocalDate getDatePromesse() { return datePromesse; }
    public void setDatePromesse(LocalDate datePromesse) { this.datePromesse = datePromesse; }
    public LocalDate getDateEcheance() { return dateEcheance; }
    public void setDateEcheance(LocalDate dateEcheance) { this.dateEcheance = dateEcheance; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public String getObservation() { return observation; }
    public void setObservation(String observation) { this.observation = observation; }
    public Boolean getRelanceEffectuee() { return relanceEffectuee; }
    public void setRelanceEffectuee(Boolean relanceEffectuee) { this.relanceEffectuee = relanceEffectuee; }
}
