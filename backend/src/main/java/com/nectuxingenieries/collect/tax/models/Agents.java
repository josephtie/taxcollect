package com.nectuxingenieries.collect.tax.models;


import jakarta.persistence.*;
import jakarta.persistence.PrePersist;

import java.time.LocalDate;
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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutAgent statut = StatutAgent.ACTIF;

    @Column(unique = true)
    private String matricule;

    @Column(length = 500)
    private String photo;

    @Column(name = "date_naissance")
    private LocalDate dateNaissance;

    @Column
    private String fonction;

    // Un agent peut être assigné à plusieurs zones de collecte
    @ManyToMany
    @JoinTable(
            name = "agent_zone",
            joinColumns = @JoinColumn(name = "agent_id"),
            inverseJoinColumns = @JoinColumn(name = "zone_id")
    )
    private List<Zone> zones;

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

    public StatutAgent getStatut() { return statut; }
    public void setStatut(StatutAgent statut) { this.statut = statut; }

    public String getMatricule() { return matricule; }
    public void setMatricule(String matricule) { this.matricule = matricule; }

    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }

    public LocalDate getDateNaissance() { return dateNaissance; }
    public void setDateNaissance(LocalDate dateNaissance) { this.dateNaissance = dateNaissance; }

    public String getFonction() { return fonction; }
    public void setFonction(String fonction) { this.fonction = fonction; }

    public List<Zone> getZones() { return zones; }
    public void setZones(List<Zone> zones) { this.zones = zones; }

    @PrePersist
    protected void onCreate() {
        if (statut == null) {
            statut = StatutAgent.ACTIF;
        }
    }
}

