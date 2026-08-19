package com.nectuxingenieries.collect.tax.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class RecensementDTO {

    private Long id;

    @NotBlank(message = "Le nom est obligatoire")
    private String nom;

    private String prenoms;

    @NotBlank(message = "Le téléphone est obligatoire")
    private String telephone;

    @NotBlank(message = "Le type est obligatoire")
    private String type;

    @NotBlank(message = "L'activité est obligatoire")
    private String activite;

    @NotNull(message = "La zone est obligatoire")
    private Long zoneId;

    private String marche;
    private String quartier;
    private Double latitude;
    private Double longitude;

    @NotBlank(message = "Le type de pièce d'identité est obligatoire")
    private String typePiece;

    @NotBlank(message = "Le numéro de pièce est obligatoire")
    private String numeroPiece;

    private String photoPiece;
    private String photoContribuable;

    private String numeroContribuable;
    private String qrCode;
    private String agentId;
    private String statut;
    private Boolean necessiteValidation;
    private Integer version;

    public RecensementDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenoms() { return prenoms; }
    public void setPrenoms(String prenoms) { this.prenoms = prenoms; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getActivite() { return activite; }
    public void setActivite(String activite) { this.activite = activite; }

    public Long getZoneId() { return zoneId; }
    public void setZoneId(Long zoneId) { this.zoneId = zoneId; }

    public String getMarche() { return marche; }
    public void setMarche(String marche) { this.marche = marche; }

    public String getQuartier() { return quartier; }
    public void setQuartier(String quartier) { this.quartier = quartier; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getTypePiece() { return typePiece; }
    public void setTypePiece(String typePiece) { this.typePiece = typePiece; }

    public String getNumeroPiece() { return numeroPiece; }
    public void setNumeroPiece(String numeroPiece) { this.numeroPiece = numeroPiece; }

    public String getPhotoPiece() { return photoPiece; }
    public void setPhotoPiece(String photoPiece) { this.photoPiece = photoPiece; }

    public String getPhotoContribuable() { return photoContribuable; }
    public void setPhotoContribuable(String photoContribuable) { this.photoContribuable = photoContribuable; }

    public String getNumeroContribuable() { return numeroContribuable; }
    public void setNumeroContribuable(String numeroContribuable) { this.numeroContribuable = numeroContribuable; }

    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    public String getAgentId() { return agentId; }
    public void setAgentId(String agentId) { this.agentId = agentId; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public Boolean getNecessiteValidation() { return necessiteValidation; }
    public void setNecessiteValidation(Boolean necessiteValidation) { this.necessiteValidation = necessiteValidation; }

    public Integer getVersion() { return version; }
    public void setVersion(Integer version) { this.version = version; }
}
