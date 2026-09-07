package com.nectuxingenieries.collect.tax.dto;


import com.nectuxingenieries.collect.tax.models.StatutAgent;

import java.time.LocalDate;
import java.util.List;

public class AgentsDto {
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;
    private StatutAgent statut;
    private Boolean enLigne; // Pour le statut de connexion
    private String matricule;
    private String photo;
    private LocalDate dateNaissance;
    private String fonction;
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
    public StatutAgent getStatut() { return statut; }
    public void setStatut(StatutAgent statut) { this.statut = statut; }
    public Boolean getEnLigne() { return enLigne; }
    public void setEnLigne(Boolean enLigne) { this.enLigne = enLigne; }
    public String getMatricule() { return matricule; }
    public void setMatricule(String matricule) { this.matricule = matricule; }
    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }
    public LocalDate getDateNaissance() { return dateNaissance; }
    public void setDateNaissance(LocalDate dateNaissance) { this.dateNaissance = dateNaissance; }
    public String getFonction() { return fonction; }
    public void setFonction(String fonction) { this.fonction = fonction; }
    public List<Long> getZoneIds() { return zoneIds; }
    public void setZoneIds(List<Long> zoneIds) { this.zoneIds = zoneIds; }
}

