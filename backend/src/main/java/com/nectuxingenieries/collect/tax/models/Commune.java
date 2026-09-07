package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.MultiPolygon;
import java.util.List;

@Entity
@Table(name = "commune")
public class Commune extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String nom;

    @OneToMany(mappedBy = "commune")
    private List<Zone> zones;

    @Column(name = "geometry", columnDefinition = "geometry(MultiPolygon, 4326)")
    @JdbcTypeCode(SqlTypes.GEOMETRY)
    private MultiPolygon geometry;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public List<Zone> getZones() { return zones; }
    public void setZones(List<Zone> zones) { this.zones = zones; }
    public MultiPolygon getGeometry() { return geometry; }
    public void setGeometry(MultiPolygon geometry) { this.geometry = geometry; }
}

