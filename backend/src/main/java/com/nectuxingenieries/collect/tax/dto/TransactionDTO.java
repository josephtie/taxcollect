package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TransactionDTO {

    private Long id;
    private String numeroRecu;
    @NotNull(message = "Le montant est obligatoire")
    @Positive(message = "Le montant doit être positif")
    private BigDecimal montant;
    @NotNull(message = "L'ID du contribuable est obligatoire")
    private Long contribuableId;
    @NotNull(message = "L'ID de l'agent est obligatoire")
    private Long agentId;
    @NotNull(message = "L'ID de la zone est obligatoire")
    private Long zoneId;
    @NotNull(message = "Le mode de paiement est obligatoire")
    private ModePaiement modePaiement;
    private StatutTransaction statut;
    private String referencePaiement;
    private String hashTransaction;
    private Double latitude;
    private Double longitude;
    private String adresseCollecte;
    private Boolean offline;
    private LocalDateTime dateSynchronisation;
    private LocalDateTime dateCreation;
    
    // Informations additionnelles pour les réponses
    private String contribuableNom;
    private String contribuablePrenom;
    private String agentNom;
    private String agentPrenom;
    private String zoneNom;

    // Constructors
    public TransactionDTO() {}

    public TransactionDTO(BigDecimal montant, Long contribuableId, Long agentId, Long zoneId, ModePaiement modePaiement) {
        this.montant = montant;
        this.contribuableId = contribuableId;
        this.agentId = agentId;
        this.zoneId = zoneId;
        this.modePaiement = modePaiement;
        this.offline = false;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNumeroRecu() { return numeroRecu; }
    public void setNumeroRecu(String numeroRecu) { this.numeroRecu = numeroRecu; }

    public BigDecimal getMontant() { return montant; }
    public void setMontant(BigDecimal montant) { this.montant = montant; }

    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }

    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }

    public Long getZoneId() { return zoneId; }
    public void setZoneId(Long zoneId) { this.zoneId = zoneId; }

    public ModePaiement getModePaiement() { return modePaiement; }
    public void setModePaiement(ModePaiement modePaiement) { this.modePaiement = modePaiement; }

    public StatutTransaction getStatut() { return statut; }
    public void setStatut(StatutTransaction statut) { this.statut = statut; }

    public String getReferencePaiement() { return referencePaiement; }
    public void setReferencePaiement(String referencePaiement) { this.referencePaiement = referencePaiement; }

    public String getHashTransaction() { return hashTransaction; }
    public void setHashTransaction(String hashTransaction) { this.hashTransaction = hashTransaction; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getAdresseCollecte() { return adresseCollecte; }
    public void setAdresseCollecte(String adresseCollecte) { this.adresseCollecte = adresseCollecte; }

    public Boolean getOffline() { return offline; }
    public void setOffline(Boolean offline) { this.offline = offline; }

    public LocalDateTime getDateSynchronisation() { return dateSynchronisation; }
    public void setDateSynchronisation(LocalDateTime dateSynchronisation) { this.dateSynchronisation = dateSynchronisation; }

    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }

    public String getContribuableNom() { return contribuableNom; }
    public void setContribuableNom(String contribuableNom) { this.contribuableNom = contribuableNom; }

    public String getContribuablePrenom() { return contribuablePrenom; }
    public void setContribuablePrenom(String contribuablePrenom) { this.contribuablePrenom = contribuablePrenom; }

    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }

    public String getAgentPrenom() { return agentPrenom; }
    public void setAgentPrenom(String agentPrenom) { this.agentPrenom = agentPrenom; }

    public String getZoneNom() { return zoneNom; }
    public void setZoneNom(String zoneNom) { this.zoneNom = zoneNom; }
}
