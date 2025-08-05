package com.nectuxingenieries.collect.tax.models.dto;



import java.util.List;

public class ContribuableDto {
    private Long id;
    private String nom;
    private String prenom;
    private String telephone;
    private String activites;
    private String email;
    private String adresse;
    private Double latitude;
    private Double longitude;
    private Long zoneCollecteId;
    private List<Long> taxeIds;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public Long getZoneCollecteId() { return zoneCollecteId; }
    public void setZoneCollecteId(Long zoneCollecteId) { this.zoneCollecteId = zoneCollecteId; }
    public List<Long> getTaxeIds() { return taxeIds; }
    public void setTaxeIds(List<Long> taxeIds) { this.taxeIds = taxeIds; }

    public String getActivites() {
        return activites;
    }

    public void setActivites(String activites) {
        this.activites = activites;
    }

    @Override
    public String toString() {
        return "ContribuableDto{" +
                "id=" + id +
                ", nom='" + nom + '\'' +
                ", prenom='" + prenom + '\'' +
                ", telephone='" + telephone + '\'' +
                ", activites='" + activites + '\'' +
                ", email='" + email + '\'' +
                ", adresse='" + adresse + '\'' +
                ", latitude=" + latitude +
                ", longitude=" + longitude +
                ", zoneCollecteId=" + zoneCollecteId +
                ", taxeIds=" + taxeIds +
                '}';
    }
}
