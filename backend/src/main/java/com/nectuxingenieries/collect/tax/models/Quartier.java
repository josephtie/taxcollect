package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.MultiPolygon;
import java.util.List;

@Entity
@Table(name = "quartier")
public class Quartier extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String nom;

    @ManyToOne
    @JoinColumn(name = "zone_id")
    private Zone zone;

    @OneToMany(mappedBy = "quartier")
    private List<Secteur> secteurs;

    private Boolean statut;

    @Column(name = "geometry", columnDefinition = "geometry(MultiPolygon, 4326)")
    @JdbcTypeCode(SqlTypes.GEOMETRY)
    private MultiPolygon geometry;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Zone getZone() { return zone; }
    public void setZone(Zone zone) { this.zone = zone; }
    public List<Secteur> getSecteurs() { return secteurs; }
    public void setSecteurs(List<Secteur> secteurs) { this.secteurs = secteurs; }
    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
    public MultiPolygon getGeometry() { return geometry; }
    public void setGeometry(MultiPolygon geometry) { this.geometry = geometry; }
}

