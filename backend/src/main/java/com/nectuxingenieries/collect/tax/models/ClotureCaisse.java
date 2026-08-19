package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.StatutCloture;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "cloture_caisse")
public class ClotureCaisse extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "agent_id", nullable = false)
    private Agents agent;

    @NotNull
    @Column(name = "date_cloture", nullable = false)
    private LocalDate dateCloture;

    @NotNull
    @Column(name = "montant_total_espece", nullable = false, precision = 19, scale = 2)
    private BigDecimal montantTotalEspece;

    @NotNull
    @Column(name = "montant_total_mobile_money", nullable = false, precision = 19, scale = 2)
    private BigDecimal montantTotalMobileMoney;

    @NotNull
    @Column(name = "montant_total", nullable = false, precision = 19, scale = 2)
    private BigDecimal montantTotal;

    @Column(name = "montant_declare", precision = 19, scale = 2)
    private BigDecimal montantDeclare;

    @Column(name = "montant_depose", precision = 19, scale = 2)
    private BigDecimal montantDepose;

    @Column(name = "reference_depot_banque")
    private String referenceDepotBanque;

    @Column(name = "date_depot_banque")
    private LocalDateTime dateDepotBanque;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutCloture statut;

    @Column(name = "commentaire_agent")
    private String commentaireAgent;

    @Column(name = "commentaire_tresor")
    private String commentaireTresor;

    @Column(name = "date_validation_tresor")
    private LocalDateTime dateValidationTresor;

    @ManyToOne
    @JoinColumn(name = "valide_par_id")
    private Agents validePar;

    @OneToMany(mappedBy = "clotureCaisse")
    private List<Transaction> transactions;

    @Column(name = "nombre_transactions", nullable = false)
    private Integer nombreTransactions = 0;

    // Constructors
    public ClotureCaisse() {
        this.statut = StatutCloture.EN_COURS;
        this.dateCloture = LocalDate.now();
        this.montantTotalEspece = BigDecimal.ZERO;
        this.montantTotalMobileMoney = BigDecimal.ZERO;
        this.montantTotal = BigDecimal.ZERO;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Agents getAgent() { return agent; }
    public void setAgent(Agents agent) { this.agent = agent; }

    public LocalDate getDateCloture() { return dateCloture; }
    public void setDateCloture(LocalDate dateCloture) { this.dateCloture = dateCloture; }

    public BigDecimal getMontantTotalEspece() { return montantTotalEspece; }
    public void setMontantTotalEspece(BigDecimal montantTotalEspece) { this.montantTotalEspece = montantTotalEspece; }

    public BigDecimal getMontantTotalMobileMoney() { return montantTotalMobileMoney; }
    public void setMontantTotalMobileMoney(BigDecimal montantTotalMobileMoney) { this.montantTotalMobileMoney = montantTotalMobileMoney; }

    public BigDecimal getMontantTotal() { return montantTotal; }
    public void setMontantTotal(BigDecimal montantTotal) { this.montantTotal = montantTotal; }

    public BigDecimal getMontantDeclare() { return montantDeclare; }
    public void setMontantDeclare(BigDecimal montantDeclare) { this.montantDeclare = montantDeclare; }

    public BigDecimal getMontantDepose() { return montantDepose; }
    public void setMontantDepose(BigDecimal montantDepose) { this.montantDepose = montantDepose; }

    public String getReferenceDepotBanque() { return referenceDepotBanque; }
    public void setReferenceDepotBanque(String referenceDepotBanque) { this.referenceDepotBanque = referenceDepotBanque; }

    public LocalDateTime getDateDepotBanque() { return dateDepotBanque; }
    public void setDateDepotBanque(LocalDateTime dateDepotBanque) { this.dateDepotBanque = dateDepotBanque; }

    public StatutCloture getStatut() { return statut; }
    public void setStatut(StatutCloture statut) { this.statut = statut; }

    public String getCommentaireAgent() { return commentaireAgent; }
    public void setCommentaireAgent(String commentaireAgent) { this.commentaireAgent = commentaireAgent; }

    public String getCommentaireTresor() { return commentaireTresor; }
    public void setCommentaireTresor(String commentaireTresor) { this.commentaireTresor = commentaireTresor; }

    public LocalDateTime getDateValidationTresor() { return dateValidationTresor; }
    public void setDateValidationTresor(LocalDateTime dateValidationTresor) { this.dateValidationTresor = dateValidationTresor; }

    public Agents getValidePar() { return validePar; }
    public void setValidePar(Agents validePar) { this.validePar = validePar; }

    public List<Transaction> getTransactions() { return transactions; }
    public void setTransactions(List<Transaction> transactions) { this.transactions = transactions; }

    public Integer getNombreTransactions() { return nombreTransactions; }
    public void setNombreTransactions(Integer nombreTransactions) { this.nombreTransactions = nombreTransactions; }
}
