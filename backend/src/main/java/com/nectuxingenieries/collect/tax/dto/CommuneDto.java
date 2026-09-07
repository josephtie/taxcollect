package com.nectuxingenieries.collect.tax.dto;


import lombok.Data;

@Data
public class CommuneDto {
    private Long id;
    private String nom;
    private String geometryGeoJson;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getGeometryGeoJson() { return geometryGeoJson; }
    public void setGeometryGeoJson(String geometryGeoJson) { this.geometryGeoJson = geometryGeoJson; }
}

