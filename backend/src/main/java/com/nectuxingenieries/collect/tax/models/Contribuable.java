package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "contribuable")
public class Contribuable extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String prenom;

    @Column(nullable = true)
    private String telephone;

    @Column(nullable = true)
    private String email;

    @Column(nullable = true)
    private String adresse;

    @Column(name = "latitude", nullable = true)
    private Double latitude;

    @Column(name = "longitude", nullable = true)
    private Double longitude;

    @Column(name = "numero_contribuable", unique = true)
    private String numeroContribuable;

    @Column(name = "type_contribuable")
    private String typeContribuable;

    @Column(name = "activite")
    private String activite;

    @Column(name = "marche")
    private String marche;

    @Column(name = "quartier")
    private String quartier;

    @Column(name = "type_piece_identite")
    private String typePieceIdentite;

    @Column(name = "numero_piece")
    private String numeroPiece;

    @Column(name = "photo_piece", columnDefinition = "TEXT")
    private String photoPiece;

    @Column(name = "photo_contribuable", columnDefinition = "TEXT")
    private String photoContribuable;

    @Column(name = "statut_contribuable")
    private String statut = "actif";

    @Column(name = "necessite_validation")
    private Boolean necessiteValidation = false;

    @ManyToOne
    @JoinColumn(name = "zone_id", nullable = false)
    private ZoneCollecte zoneCollecte;

    @OneToMany(mappedBy = "contribuable")
    private List<TaxeCollect> taxes;

    @OneToMany(mappedBy = "contribuable")
    private List<QRCodeContribuable> qrCodes;

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
    public ZoneCollecte getZoneCollecte() { return zoneCollecte; }
    public void setZoneCollecte(ZoneCollecte zoneCollecte) { this.zoneCollecte = zoneCollecte; }
    public List<TaxeCollect> getTaxes() { return taxes; }
    public void setTaxes(List<TaxeCollect> taxes) { this.taxes = taxes; }
    public List<QRCodeContribuable> getQrCodes() { return qrCodes; }
    public void setQrCodes(List<QRCodeContribuable> qrCodes) { this.qrCodes = qrCodes; }

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
}

