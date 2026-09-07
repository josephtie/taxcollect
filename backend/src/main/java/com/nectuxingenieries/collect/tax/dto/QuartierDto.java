package com.nectuxingenieries.collect.tax.dto;


import lombok.Data;

@Data
public class QuartierDto {
    private Long id;
    private String nom;
    private Long zoneId;
    private String zoneNom;
    private String communeNom;
    private Boolean statut;
    private String geometryGeoJson;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Long getZoneId() { return zoneId; }
    public void setZoneId(Long zoneId) { this.zoneId = zoneId; }
    public String getZoneNom() { return zoneNom; }
    public void setZoneNom(String zoneNom) { this.zoneNom = zoneNom; }
    public String getCommuneNom() { return communeNom; }
    public void setCommuneNom(String communeNom) { this.communeNom = communeNom; }
    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
    public String getGeometryGeoJson() { return geometryGeoJson; }
    public void setGeometryGeoJson(String geometryGeoJson) { this.geometryGeoJson = geometryGeoJson; }
}
