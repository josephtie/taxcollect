package com.nectuxingenieries.collect.tax.dto;

public class AgentSummaryDto {
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private String telephone;
    private String initials;

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
    public String getInitials() { return initials; }
    public void setInitials(String initials) { this.initials = initials; }
}
