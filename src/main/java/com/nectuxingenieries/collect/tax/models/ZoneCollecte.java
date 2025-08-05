package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "zone_collecte")
public class ZoneCollecte extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String nom;

    @ManyToOne
    @JoinColumn(name = "quartier_id")
    private Quartier quartier;

    @OneToMany(mappedBy = "zone")
    private List<TaxeCollect> taxes;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Quartier getQuartier() { return quartier; }
    public void setQuartier(Quartier quartier) { this.quartier = quartier; }
    public List<TaxeCollect> getTaxes() { return taxes; }
    public void setTaxes(List<TaxeCollect> taxes) { this.taxes = taxes; }
}

