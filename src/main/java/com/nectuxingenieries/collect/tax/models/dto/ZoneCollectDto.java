package com.nectuxingenieries.collect.tax.models.dto;



public class ZoneCollectDto {
    private Long id;
    private String nom;
    private Long quartierId;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Long getQuartierId() { return quartierId; }
    public void setQuartierId(Long quartierId) { this.quartierId = quartierId; }
}
