package com.nectuxingenieries.collect.tax.models.dto;


import lombok.Data;

@Data
public class QuartierDto {
    private Long id;
    private String nom;
    private Long communeId;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Long getCommuneId() { return communeId; }
    public void setCommuneId(Long communeId) { this.communeId = communeId; }
}
