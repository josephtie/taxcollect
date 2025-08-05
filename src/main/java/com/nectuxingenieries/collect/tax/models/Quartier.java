package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;

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
    @JoinColumn(name = "commune_id")
    private Commune commune;

    @OneToMany(mappedBy = "quartier")
    private List<ZoneCollecte> zones;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Commune getCommune() { return commune; }
    public void setCommune(Commune commune) { this.commune = commune; }
    public List<ZoneCollecte> getZones() { return zones; }
    public void setZones(List<ZoneCollecte> zones) { this.zones = zones; }
}

