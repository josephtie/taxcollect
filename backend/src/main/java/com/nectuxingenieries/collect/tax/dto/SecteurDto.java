package com.nectuxingenieries.collect.tax.dto;

public class SecteurDto {
    private Long id;
    private String nom;
    private Long quartierId;
    private String quartierNom;
    private Double latitude;
    private Double longitude;
    private String rue;
    private String numeroLot;
    private String geometryGeoJson;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Long getQuartierId() { return quartierId; }
    public void setQuartierId(Long quartierId) { this.quartierId = quartierId; }
    public String getQuartierNom() { return quartierNom; }
    public void setQuartierNom(String quartierNom) { this.quartierNom = quartierNom; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public String getRue() { return rue; }
    public void setRue(String rue) { this.rue = rue; }
    public String getNumeroLot() { return numeroLot; }
    public void setNumeroLot(String numeroLot) { this.numeroLot = numeroLot; }
    public String getGeometryGeoJson() { return geometryGeoJson; }
    public void setGeometryGeoJson(String geometryGeoJson) { this.geometryGeoJson = geometryGeoJson; }
}
