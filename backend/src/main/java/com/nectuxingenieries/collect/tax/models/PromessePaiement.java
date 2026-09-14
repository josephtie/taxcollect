package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "promesse_paiement")
public class PromessePaiement extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contribuable_id", nullable = false)
    private Contribuable contribuable;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private Agents agent;

    @Column(name = "montant_promis", nullable = false, precision = 19, scale = 2)
    private BigDecimal montantPromis;

    @Column(name = "date_promesse", nullable = false)
    private LocalDate datePromesse;

    @Column(name = "date_echeance", nullable = false)
    private LocalDate dateEcheance;

    @Column(name = "statut", nullable = false)
    private String statut = "EN_ATTENTE";

    @Column(name = "observation", length = 1000)
    private String observation;

    @Column(name = "relance_effectuee")
    private Boolean relanceEffectuee = false;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Contribuable getContribuable() { return contribuable; }
    public void setContribuable(Contribuable contribuable) { this.contribuable = contribuable; }
    public Agents getAgent() { return agent; }
    public void setAgent(Agents agent) { this.agent = agent; }
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
