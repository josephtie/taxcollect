package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "agent")
public class Agents extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nom;

    @Column(nullable = false)
    private String prenom;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String telephone;

    // Un agent peut être assigné à plusieurs zones de collecte
    @ManyToMany
    @JoinTable(
            name = "agent_zone",
            joinColumns = @JoinColumn(name = "agent_id"),
            inverseJoinColumns = @JoinColumn(name = "zone_id")
    )
    private List<ZoneCollecte> zones;

    // Getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public List<ZoneCollecte> getZones() { return zones; }
    public void setZones(List<ZoneCollecte> zones) { this.zones = zones; }
}

