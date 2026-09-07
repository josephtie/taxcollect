package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.MultiPolygon;
import java.util.List;

@Entity
@Table(name = "zone")
public class Zone extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String nom;

    @ManyToOne
    @JoinColumn(name = "commune_id")
    private Commune commune;

    @OneToMany(mappedBy = "zone")
    private List<Quartier> quartiers;

    @OneToMany(mappedBy = "zone")
    private List<TaxeCollect> taxes;

    @ManyToMany(mappedBy = "zones")
    private List<Agents> agents;

    @Column(name = "superviseur_id")
    private String superviseurId;

    private Boolean statut;

    @Column(name = "geometry", columnDefinition = "geometry(MultiPolygon, 4326)")
    @JdbcTypeCode(SqlTypes.GEOMETRY)
    private MultiPolygon geometry;

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public Commune getCommune() { return commune; }
    public void setCommune(Commune commune) { this.commune = commune; }
    public List<Quartier> getQuartiers() { return quartiers; }
    public void setQuartiers(List<Quartier> quartiers) { this.quartiers = quartiers; }
    public List<TaxeCollect> getTaxes() { return taxes; }
    public void setTaxes(List<TaxeCollect> taxes) { this.taxes = taxes; }
    
    public List<Agents> getAgents() { return agents; }
    public void setAgents(List<Agents> agents) { this.agents = agents; }

    public String getSuperviseurId() { return superviseurId; }
    public void setSuperviseurId(String superviseurId) { this.superviseurId = superviseurId; }

    public Boolean getStatut() {
        return statut;
    }

    public void setStatut(Boolean statut) {
        this.statut = statut;
    }
    public MultiPolygon getGeometry() { return geometry; }
    public void setGeometry(MultiPolygon geometry) { this.geometry = geometry; }
}
