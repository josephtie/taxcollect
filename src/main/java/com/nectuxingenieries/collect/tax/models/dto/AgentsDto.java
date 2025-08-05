package com.nectuxingenieries.collect.tax.models.dto;


import java.util.List;

public class AgentsDto {
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;
    private List<Long> zoneIds;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public List<Long> getZoneIds() { return zoneIds; }
    public void setZoneIds(List<Long> zoneIds) { this.zoneIds = zoneIds; }
}

