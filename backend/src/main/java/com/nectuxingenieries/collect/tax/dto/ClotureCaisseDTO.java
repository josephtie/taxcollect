package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.StatutCloture;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class ClotureCaisseDTO {

    private Long id;
    @NotNull(message = "L'ID de l'agent est obligatoire")
    private Long agentId;
    @NotNull(message = "La date de clôture est obligatoire")
    private LocalDate dateCloture;
    @NotNull(message = "Le montant total espèce est obligatoire")
    private BigDecimal montantTotalEspece;
    @NotNull(message = "Le montant total mobile money est obligatoire")
    private BigDecimal montantTotalMobileMoney;
    @NotNull(message = "Le montant total est obligatoire")
    private BigDecimal montantTotal;
    private BigDecimal montantDeclare;
    private BigDecimal montantDepose;
    private String referenceDepotBanque;
    private LocalDateTime dateDepotBanque;
    @NotNull(message = "Le statut est obligatoire")
    private StatutCloture statut;
    private String commentaireAgent;
    private String commentaireTresor;
    private LocalDateTime dateValidationTresor;
    private Long valideParId;
    private Integer nombreTransactions;

    // Informations additionnelles pour les réponses
    private String agentNom;
    private String agentPrenom;
    private String valideParNom;
    private String valideParPrenom;

    // Constructors
    public ClotureCaisseDTO() {}

    public ClotureCaisseDTO(Long agentId, LocalDate dateCloture, BigDecimal montantTotalEspece, 
                           BigDecimal montantTotalMobileMoney, BigDecimal montantTotal) {
        this.agentId = agentId;
        this.dateCloture = dateCloture;
        this.montantTotalEspece = montantTotalEspece;
        this.montantTotalMobileMoney = montantTotalMobileMoney;
        this.montantTotal = montantTotal;
        this.statut = StatutCloture.EN_COURS;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }

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

    public Long getValideParId() { return valideParId; }
    public void setValideParId(Long valideParId) { this.valideParId = valideParId; }

    public Integer getNombreTransactions() { return nombreTransactions; }
    public void setNombreTransactions(Integer nombreTransactions) { this.nombreTransactions = nombreTransactions; }

    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }

    public String getAgentPrenom() { return agentPrenom; }
    public void setAgentPrenom(String agentPrenom) { this.agentPrenom = agentPrenom; }

    public String getValideParNom() { return valideParNom; }
    public void setValideParNom(String valideParNom) { this.valideParNom = valideParNom; }

    public String getValideParPrenom() { return valideParPrenom; }
    public void setValideParPrenom(String valideParPrenom) { this.valideParPrenom = valideParPrenom; }
}
