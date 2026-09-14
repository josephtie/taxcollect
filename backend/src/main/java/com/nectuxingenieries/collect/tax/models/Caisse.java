package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.StatutCaisse;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "caisse",
       uniqueConstraints = @UniqueConstraint(
           name = "uk_caisse_agent_date",
           columnNames = {"agent_id", "date_caisse"}
       ))
public class Caisse extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private Agents agent;

    @Column(name = "date_caisse", nullable = false)
    private LocalDate dateCaisse;

    @Column(name = "solde_initial", nullable = false, precision = 19, scale = 2)
    private BigDecimal soldeInitial = BigDecimal.ZERO;

    @Column(name = "montant_espece", nullable = false, precision = 19, scale = 2)
    private BigDecimal montantEspece = BigDecimal.ZERO;

    @Column(name = "montant_mobile_money", nullable = false, precision = 19, scale = 2)
    private BigDecimal montantMobileMoney = BigDecimal.ZERO;

    @Column(name = "montant_total", nullable = false, precision = 19, scale = 2)
    private BigDecimal montantTotal = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutCaisse statut = StatutCaisse.FERMEE;

    @Column(name = "date_ouverture")
    private LocalDateTime dateOuverture;

    @Column(name = "date_cloture")
    private LocalDateTime dateCloture;

    @Column(name = "nombre_transactions", nullable = false)
    private Integer nombreTransactions = 0;

    @Column(name = "observation", length = 1000)
    private String observation;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Agents getAgent() { return agent; }
    public void setAgent(Agents agent) { this.agent = agent; }
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
