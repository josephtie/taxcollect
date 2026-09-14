package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.MotifVisite;
import com.nectuxingenieries.collect.tax.models.enums.StatutVisite;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "visite")
public class Visite extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tournee_id", nullable = false)
    private Tournee tournee;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contribuable_id", nullable = false)
    private Contribuable contribuable;

    @Column(name = "date_visite", nullable = false)
    private LocalDateTime dateVisite;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutVisite statut = StatutVisite.A_VISITER;

    @Enumerated(EnumType.STRING)
    @Column(name = "motif")
    private MotifVisite motif;

    @Column(name = "observation", length = 1000)
    private String observation;

    @Column(name = "ordre_passage")
    private Integer ordrePassage;

    @Column(name = "duree_minutes")
    private Integer dureeMinutes;

    @Column(name = "sync_status", length = 20)
    private String syncStatus = "SYNCED";

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Tournee getTournee() { return tournee; }
    public void setTournee(Tournee tournee) { this.tournee = tournee; }
    public Contribuable getContribuable() { return contribuable; }
    public void setContribuable(Contribuable contribuable) { this.contribuable = contribuable; }
    public LocalDateTime getDateVisite() { return dateVisite; }
    public void setDateVisite(LocalDateTime dateVisite) { this.dateVisite = dateVisite; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public StatutVisite getStatut() { return statut; }
    public void setStatut(StatutVisite statut) { this.statut = statut; }
    public MotifVisite getMotif() { return motif; }
    public void setMotif(MotifVisite motif) { this.motif = motif; }
    public String getObservation() { return observation; }
    public void setObservation(String observation) { this.observation = observation; }
    public Integer getOrdrePassage() { return ordrePassage; }
    public void setOrdrePassage(Integer ordrePassage) { this.ordrePassage = ordrePassage; }
    public Integer getDureeMinutes() { return dureeMinutes; }
    public void setDureeMinutes(Integer dureeMinutes) { this.dureeMinutes = dureeMinutes; }
    public String getSyncStatus() { return syncStatus; }
    public void setSyncStatus(String syncStatus) { this.syncStatus = syncStatus; }
}
