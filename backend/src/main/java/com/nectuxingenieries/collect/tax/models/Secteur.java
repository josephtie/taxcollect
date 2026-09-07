package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.MultiPolygon;

@Entity
@Table(name = "secteur")
public class Secteur extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String nom;

    @ManyToOne
    @JoinColumn(name = "quartier_id")
    private Quartier quartier;

    @Column(name = "latitude", nullable = true)
    private Double latitude;

    @Column(name = "longitude", nullable = true)
    private Double longitude;

    @Column(name = "rue", nullable = true)
    private String rue;

    @Column(name = "numero_lot", nullable = true)
    private String numeroLot;

    @Column(name = "geometry", columnDefinition = "geometry(MultiPolygon, 4326)")
    @JdbcTypeCode(SqlTypes.GEOMETRY)
    private MultiPolygon geometry;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Quartier getQuartier() { return quartier; }
    public void setQuartier(Quartier quartier) { this.quartier = quartier; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public String getRue() { return rue; }
    public void setRue(String rue) { this.rue = rue; }
    public String getNumeroLot() { return numeroLot; }
    public void setNumeroLot(String numeroLot) { this.numeroLot = numeroLot; }
    public MultiPolygon getGeometry() { return geometry; }
    public void setGeometry(MultiPolygon geometry) { this.geometry = geometry; }
}
