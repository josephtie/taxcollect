package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

@Entity
@Table(name = "qr_code_contribuable")
public class QRCodeContribuable extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "code_qr", unique = true, nullable = false)
    private String codeQR;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "contribuable_id", nullable = false)
    private Contribuable contribuable;

    @NotNull
    @Column(name = "date_generation", nullable = false)
    private LocalDateTime dateGeneration;

    @NotNull
    @Column(name = "actif", nullable = false)
    private Boolean actif = true;

    @Column(name = "date_expiration")
    private LocalDateTime dateExpiration;

    @Column(name = "utilise_par")
    private String utilisePar;

    // Constructors
    public QRCodeContribuable() {
        this.dateGeneration = LocalDateTime.now();
        this.actif = true;
    }

    public QRCodeContribuable(String codeQR, Contribuable contribuable) {
        this();
        this.codeQR = codeQR;
        this.contribuable = contribuable;
    }

    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCodeQR() { return codeQR; }
    public void setCodeQR(String codeQR) { this.codeQR = codeQR; }

    public Contribuable getContribuable() { return contribuable; }
    public void setContribuable(Contribuable contribuable) { this.contribuable = contribuable; }

    public LocalDateTime getDateGeneration() { return dateGeneration; }
    public void setDateGeneration(LocalDateTime dateGeneration) { this.dateGeneration = dateGeneration; }

    public Boolean getActif() { return actif; }
    public void setActif(Boolean actif) { this.actif = actif; }

    public LocalDateTime getDateExpiration() { return dateExpiration; }
    public void setDateExpiration(LocalDateTime dateExpiration) { this.dateExpiration = dateExpiration; }

    public String getUtilisePar() { return utilisePar; }
    public void setUtilisePar(String utilisePar) { this.utilisePar = utilisePar; }
}
