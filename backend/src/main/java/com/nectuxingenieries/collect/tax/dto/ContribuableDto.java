package com.nectuxingenieries.collect.tax.dto;



import java.util.List;

import java.math.BigDecimal;

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
    private Double precisionGps;
    private Long zoneId;
    private Long secteurId;
    private List<Long> taxeIds;

    private String numeroContribuable;
    private String typeContribuable;
    private String activite;
    private String marche;
    private String quartier;

    private String typePieceIdentite;
    private String numeroPiece;
    private String photoPiece;
    private String photoContribuable;

    private String statut;
    private Boolean necessiteValidation;
    private BigDecimal baseImposable;

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
    public Double getPrecisionGps() { return precisionGps; }
    public void setPrecisionGps(Double precisionGps) { this.precisionGps = precisionGps; }
    public Long getZoneId() { return zoneId; }
    public void setZoneId(Long zoneId) { this.zoneId = zoneId; }
    public Long getSecteurId() { return secteurId; }
    public void setSecteurId(Long secteurId) { this.secteurId = secteurId; }
    public List<Long> getTaxeIds() { return taxeIds; }
    public void setTaxeIds(List<Long> taxeIds) { this.taxeIds = taxeIds; }

    public String getActivites() { return activites; }
    public void setActivites(String activites) { this.activites = activites; }

    public String getNumeroContribuable() { return numeroContribuable; }
    public void setNumeroContribuable(String numeroContribuable) { this.numeroContribuable = numeroContribuable; }

    public String getTypeContribuable() { return typeContribuable; }
    public void setTypeContribuable(String typeContribuable) { this.typeContribuable = typeContribuable; }

    public String getActivite() { return activite; }
    public void setActivite(String activite) { this.activite = activite; }

    public String getMarche() { return marche; }
    public void setMarche(String marche) { this.marche = marche; }

    public String getQuartier() { return quartier; }
    public void setQuartier(String quartier) { this.quartier = quartier; }

    public String getTypePieceIdentite() { return typePieceIdentite; }
    public void setTypePieceIdentite(String typePieceIdentite) { this.typePieceIdentite = typePieceIdentite; }

    public String getNumeroPiece() { return numeroPiece; }
    public void setNumeroPiece(String numeroPiece) { this.numeroPiece = numeroPiece; }

    public String getPhotoPiece() { return photoPiece; }
    public void setPhotoPiece(String photoPiece) { this.photoPiece = photoPiece; }

    public String getPhotoContribuable() { return photoContribuable; }
    public void setPhotoContribuable(String photoContribuable) { this.photoContribuable = photoContribuable; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public Boolean getNecessiteValidation() { return necessiteValidation; }
    public void setNecessiteValidation(Boolean necessiteValidation) { this.necessiteValidation = necessiteValidation; }

    public BigDecimal getBaseImposable() { return baseImposable; }
    public void setBaseImposable(BigDecimal baseImposable) { this.baseImposable = baseImposable; }

    @Override
    public String toString() {
        return "ContribuableDto{" +
                "id=" + id +
                ", nom='" + nom + '\'' +
                ", prenom='" + prenom + '\'' +
                ", telephone='" + telephone + '\'' +
                ", numeroContribuable='" + numeroContribuable + '\'' +
                ", typeContribuable='" + typeContribuable + '\'' +
                ", typePieceIdentite='" + typePieceIdentite + '\'' +
                ", numeroPiece='" + numeroPiece + '\'' +
                ", zoneId=" + zoneId +
                '}';
    }
}
