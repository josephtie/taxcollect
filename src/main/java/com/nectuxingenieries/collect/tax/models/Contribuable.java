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

    @ManyToOne
    @JoinColumn(name = "zone_id", nullable = false)
    private ZoneCollecte zoneCollecte;

    @OneToMany(mappedBy = "contribuable")
    private List<TaxeCollect> taxes;

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
}

