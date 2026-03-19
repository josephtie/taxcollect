package com.nectuxingenieries.collect.tax.models;


import com.nectuxingenieries.collect.tax.models.enums.ModePaiement;
import com.nectuxingenieries.collect.tax.models.enums.StatutPayment;
import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.Year;
import java.time.YearMonth;

@Entity
@Table(name = "taxecollect")
public class TaxeCollect extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Double montant;

    @Column(name = "date_emission", nullable = false)
    private LocalDate dateEmission;

    @Column(name = "date_limite", nullable = false)
    private LocalDate dateLimite;

    @Column(nullable = false)
    private boolean paye;

    @ManyToOne
    @JoinColumn(name = "contribuable_id", nullable = false)
    private Contribuable contribuable;

    @ManyToOne
    @JoinColumn(name = "zone_id", nullable = false)
    private ZoneCollecte zone;


    @Column(name = "date_paiement", nullable = false)
    private LocalDate datePaiement;

    private YearMonth periodeMensuelle;
    private Year periodeAnnuelle;


    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutPayment statut;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ModePaiement modePaiement;

    private boolean offline; // true if processed offline and synced later
    private String numeroRecu; // généré automatiquement, unique

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Double getMontant() { return montant; }
    public void setMontant(Double montant) { this.montant = montant; }
    public LocalDate getDateEmission() { return dateEmission; }
    public void setDateEmission(LocalDate dateEmission) { this.dateEmission = dateEmission; }
    public LocalDate getDateLimite() { return dateLimite; }
    public void setDateLimite(LocalDate dateLimite) { this.dateLimite = dateLimite; }
    public boolean isPaye() { return paye; }
    public void setPaye(boolean paye) { this.paye = paye; }
    public Contribuable getContribuable() { return contribuable; }
    public void setContribuable(Contribuable contribuable) { this.contribuable = contribuable; }
    public ZoneCollecte getZone() { return zone; }
    public void setZone(ZoneCollecte zone) { this.zone = zone; }

    public LocalDate getDatePaiement() {
        return datePaiement;
    }

    public void setDatePaiement(LocalDate datePaiement) {
        this.datePaiement = datePaiement;
    }



    public StatutPayment getStatut() {
        return statut;
    }

    public void setStatut(StatutPayment statut) {
        this.statut = statut;
    }

    public TaxeCollect(Double montant, LocalDate dateEmission, LocalDate dateLimite, boolean paye, Contribuable contribuable, ZoneCollecte zone, LocalDate datePaiement, StatutPayment statut, Long id) {
        this.montant = montant;
        this.dateEmission = dateEmission;
        this.dateLimite = dateLimite;
        this.paye = paye;
        this.contribuable = contribuable;
        this.zone = zone;
        this.datePaiement = datePaiement;
        this.statut = statut;
        this.id = id;
    }

    public YearMonth getPeriodeMensuelle() {
        return periodeMensuelle;
    }

    public void setPeriodeMensuelle(YearMonth periodeMensuelle) {
        this.periodeMensuelle = periodeMensuelle;
    }

    public Year getPeriodeAnnuelle() {
        return periodeAnnuelle;
    }

    public void setPeriodeAnnuelle(Year periodeAnnuelle) {
        this.periodeAnnuelle = periodeAnnuelle;
    }

    public ModePaiement getModePaiement() {
        return modePaiement;
    }

    public void setModePaiement(ModePaiement modePaiement) {
        this.modePaiement = modePaiement;
    }

    public boolean isOffline() {
        return offline;
    }

    public void setOffline(boolean offline) {
        this.offline = offline;
    }

    public String getNumeroRecu() {
        return numeroRecu;
    }

    public void setNumeroRecu(String numeroRecu) {
        this.numeroRecu = numeroRecu;
    }
}
