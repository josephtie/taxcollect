package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.TaxeCategorie;
import com.nectuxingenieries.collect.tax.models.enums.TaxePeriodicite;
import com.nectuxingenieries.collect.tax.models.enums.TypeCalcul;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

public class TaxeDto {
    private Long id;
    
    @NotNull(message = "Le nom est obligatoire")
    private String nom;
    
    private String description;
    
    private Double taux;
    
    private Double montantFixe;
    
    @NotNull(message = "Le type de calcul est obligatoire")
    private TypeCalcul typeCalcul;
    
    @NotNull(message = "La catégorie est obligatoire")
    private TaxeCategorie categorie;
    
    @NotNull(message = "La périodicité est obligatoire")
    private TaxePeriodicite periodicite;
    
    // Champs d'audit et suppression logique
    private LocalDateTime createdAt;
    private String createdBy;
    private LocalDateTime updatedAt;
    private String updatedBy;
    private LocalDateTime deletedAt;
    private String deletedBy;
    private Boolean isActive;
    
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
    public TaxeCategorie getCategorie() {
        return categorie;
    }
    public void setCategorie(TaxeCategorie categorie) {
        this.categorie = categorie;
    }
    public TaxePeriodicite getPeriodicite() {
        return periodicite;
    }
    public void setPeriodicite(TaxePeriodicite periodicite) {
        this.periodicite = periodicite;
    }
    
    // Getters & setters pour les champs d'audit et suppression logique
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    public String getCreatedBy() {
        return createdBy;
    }
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    public String getUpdatedBy() {
        return updatedBy;
    }
    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }
    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }
    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }
    public String getDeletedBy() {
        return deletedBy;
    }
    public void setDeletedBy(String deletedBy) {
        this.deletedBy = deletedBy;
    }
    public Boolean getIsActive() {
        return isActive;
    }
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    
    // Méthodes utilitaires
    public boolean isDeleted() {
        return deletedAt != null;
    }
}

