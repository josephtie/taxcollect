package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.TaxeCategorie;
import com.nectuxingenieries.collect.tax.models.enums.TaxePeriodicite;
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

    @Column(nullable = false)
    private Double taux; // ex: 0.1 = 10%

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaxePeriodicite periodicite;


    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaxeCategorie  categorie;
    // getters / setters


    public Taxe(TaxeCategorie categorie, TaxePeriodicite periodicite, Double taux, String description, String nom, Long id) {
        this.categorie = categorie;
        this.periodicite = periodicite;
        this.taux = taux;
        this.description = description;
        this.nom = nom;
        this.id = id;
    }

    public Taxe() {
    }


}

