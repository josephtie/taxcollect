package com.nectuxingenieries.collect.tax.models.dto;


import com.nectuxingenieries.collect.tax.models.enums.TaxeCategorie;
import com.nectuxingenieries.collect.tax.models.enums.TaxePeriodicite;

public class TaxeDto {
    private Long id;
    private String nom;
    private String description;
    private Double taux;
    private TaxeCategorie categorie;
    private TaxePeriodicite periodicite;
    // Getters & setters
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getNom() {
        return nom;
    }
    public void setNom(String nom) {
        this.nom = nom;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public Double getTaux() {
        return taux;
    }
    public void setTaux(Double taux) {
        this.taux = taux;
    }
}

