package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutTransaction;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "transaction")
public class Transaction extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero_recu", unique = true, nullable = false)
    private String numeroRecu;

    @NotNull
    @Positive
    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal montant;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "contribuable_id", nullable = false)
    private Contribuable contribuable;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "agent_id", nullable = false)
    private Agents agent;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "zone_id", nullable = false)
    private Zone zone;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ModePaiement modePaiement;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutTransaction statut;

    @Column(name = "reference_paiement")
    private String referencePaiement;

    @Column(name = "hash_transaction", unique = true, nullable = false)
    private String hashTransaction;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "adresse_collecte")
    private String adresseCollecte;

    @Column(name = "offline", nullable = false)
    private Boolean offline = false;

    @Column(name = "date_synchronisation")
    private LocalDateTime dateSynchronisation;

    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation;

    @ManyToOne
    @JoinColumn(name = "cloture_caisse_id")
    private ClotureCaisse clotureCaisse;

    @ManyToOne
    @JoinColumn(name = "taxe_collect_id")
    private TaxeCollect taxeCollect;

    // --- Extensions module paiement ---
    @Column(name = "transaction_reference", unique = true)
    private String transactionReference;

    @Column(length = 32)
    private String provider;

    @Column(name = "provider_transaction_id", length = 128)
    private String providerTransactionId;

    @Column(name = "provider_request_id", length = 128)
    private String providerRequestId;

    @Column(length = 8)
    private String currency;

    @Column(name = "payment_method", length = 32)
    private String paymentMethod;

    @Column(name = "initiated_at")
    private LocalDateTime initiatedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "failure_reason", length = 255)
    private String failureReason;

    @Column(name = "idempotency_key", unique = true)
    private String idempotencyKey;

    @Column(name = "collection_order_id")
    private Long collectionOrderId;

    // Constructors
    public Transaction() {
        this.dateCreation = LocalDateTime.now();
        this.statut = StatutTransaction.EN_ATTENTE;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNumeroRecu() { return numeroRecu; }
    public void setNumeroRecu(String numeroRecu) { this.numeroRecu = numeroRecu; }

    public BigDecimal getMontant() { return montant; }
    public void setMontant(BigDecimal montant) { this.montant = montant; }

    public Contribuable getContribuable() { return contribuable; }
    public void setContribuable(Contribuable contribuable) { this.contribuable = contribuable; }

    public Agents getAgent() { return agent; }
    public void setAgent(Agents agent) { this.agent = agent; }

    public Zone getZone() { return zone; }
    public void setZone(Zone zone) { this.zone = zone; }

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

    public ClotureCaisse getClotureCaisse() { return clotureCaisse; }
    public void setClotureCaisse(ClotureCaisse clotureCaisse) { this.clotureCaisse = clotureCaisse; }

    public TaxeCollect getTaxeCollect() { return taxeCollect; }
    public void setTaxeCollect(TaxeCollect taxeCollect) { this.taxeCollect = taxeCollect; }

    public String getTransactionReference() { return transactionReference; }
    public void setTransactionReference(String transactionReference) { this.transactionReference = transactionReference; }

    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }

    public String getProviderTransactionId() { return providerTransactionId; }
    public void setProviderTransactionId(String providerTransactionId) { this.providerTransactionId = providerTransactionId; }

    public String getProviderRequestId() { return providerRequestId; }
    public void setProviderRequestId(String providerRequestId) { this.providerRequestId = providerRequestId; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public LocalDateTime getInitiatedAt() { return initiatedAt; }
    public void setInitiatedAt(LocalDateTime initiatedAt) { this.initiatedAt = initiatedAt; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }

    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }

    public String getIdempotencyKey() { return idempotencyKey; }
    public void setIdempotencyKey(String idempotencyKey) { this.idempotencyKey = idempotencyKey; }

    public Long getCollectionOrderId() { return collectionOrderId; }
    public void setCollectionOrderId(Long collectionOrderId) { this.collectionOrderId = collectionOrderId; }
}
