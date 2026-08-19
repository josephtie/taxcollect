package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.TaxeCategorie;
import com.nectuxingenieries.collect.tax.models.enums.TaxePeriodicite;
import com.nectuxingenieries.collect.tax.models.enums.TypeCalcul;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.extern.log4j.Log4j2;

import java.math.BigDecimal;

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

    @Column(name = "taux", precision = 5, scale = 4)
    private BigDecimal taux; // ex: 0.1 = 10% (null si montant fixe)

    @Column(name = "montant_fixe", precision = 19, scale = 2)
    private BigDecimal montantFixe; // Montant fixe en FCFA (null si taux)

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

    public Taxe(TaxeCategorie categorie, TaxePeriodicite periodicite, BigDecimal taux, BigDecimal montantFixe, TypeCalcul typeCalcul, String description, String nom, Long id) {
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

    public BigDecimal getTaux() {
        return taux;
    }

    public void setTaux(BigDecimal taux) {
        this.taux = taux;
    }

    public BigDecimal getMontantFixe() {
        return montantFixe;
    }

    public void setMontantFixe(BigDecimal montantFixe) {
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
