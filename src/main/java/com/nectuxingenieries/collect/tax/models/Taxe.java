package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.TaxeCategorie;
import com.nectuxingenieries.collect.tax.models.enums.TaxePeriodicite;
import com.nectuxingenieries.collect.tax.models.enums.TypeCalcul;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.extern.log4j.Log4j2;

@Entity
@Table(name = "taxe")
@Getter
@Setter
@Log4j2
public class Taxe extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nom;

    @Column(length = 500)
    private String description;

    @Column(name = "taux")
    private Double taux; // ex: 0.1 = 10% (null si montant fixe)

    @Column(name = "montant_fixe")
    private Double montantFixe; // Montant fixe en FCFA (null si taux)

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TypeCalcul typeCalcul; // TAUX ou MONTANT

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaxePeriodicite periodicite;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaxeCategorie categorie;

    // getters / setters

    public Taxe(TaxeCategorie categorie, TaxePeriodicite periodicite, Double taux, Double montantFixe, TypeCalcul typeCalcul, String description, String nom, Long id) {
        this.categorie = categorie;
        this.periodicite = periodicite;
        this.taux = taux;
        this.montantFixe = montantFixe;
        this.typeCalcul = typeCalcul;
        this.description = description;
        this.nom = nom;
        this.id = id;
    }

    public Taxe() {
    }

    public Double getTaux() {
        return taux;
    }

    public void setTaux(Double taux) {
        this.taux = taux;
    }

    public Double getMontantFixe() {
        return montantFixe;
    }

    public void setMontantFixe(Double montantFixe) {
        this.montantFixe = montantFixe;
    }

    public TypeCalcul getTypeCalcul() {
        return typeCalcul;
    }

    public void setTypeCalcul(TypeCalcul typeCalcul) {
        this.typeCalcul = typeCalcul;
    }

    public TaxePeriodicite getPeriodicite() {
        return periodicite;
    }

    public void setPeriodicite(TaxePeriodicite periodicite) {
        this.periodicite = periodicite;
    }

    public TaxeCategorie getCategorie() {
        return categorie;
    }

    public void setCategorie(TaxeCategorie categorie) {
        this.categorie = categorie;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
