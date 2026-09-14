package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.MotifVisite;
import com.nectuxingenieries.collect.tax.models.enums.StatutVisite;
import java.time.LocalDateTime;

public class VisiteDto {
    private Long id;
    private Long tourneeId;
    private Long contribuableId;
    private String contribuableNom;
    private LocalDateTime dateVisite;
    private Double latitude;
    private Double longitude;
    private StatutVisite statut;
    private MotifVisite motif;
    private String observation;
    private Integer ordrePassage;
    private Integer dureeMinutes;
    private String syncStatus;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getTourneeId() { return tourneeId; }
    public void setTourneeId(Long tourneeId) { this.tourneeId = tourneeId; }
    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }
    public String getContribuableNom() { return contribuableNom; }
    public void setContribuableNom(String contribuableNom) { this.contribuableNom = contribuableNom; }
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
