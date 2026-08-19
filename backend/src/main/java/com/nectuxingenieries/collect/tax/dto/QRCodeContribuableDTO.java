package com.nectuxingenieries.collect.tax.dto;

import java.time.LocalDateTime;

public class QRCodeContribuableDTO {

    private Long id;
    private String codeQR;
    private Long contribuableId;
    private String contribuableNom;
    private String contribuablePrenom;
    private String numeroContribuable;
    private LocalDateTime dateGeneration;
    private Boolean actif;
    private LocalDateTime dateExpiration;
    private String utilisePar;

    public QRCodeContribuableDTO() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCodeQR() { return codeQR; }
    public void setCodeQR(String codeQR) { this.codeQR = codeQR; }

    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }

    public String getContribuableNom() { return contribuableNom; }
    public void setContribuableNom(String contribuableNom) { this.contribuableNom = contribuableNom; }

    public String getContribuablePrenom() { return contribuablePrenom; }
    public void setContribuablePrenom(String contribuablePrenom) { this.contribuablePrenom = contribuablePrenom; }

    public String getNumeroContribuable() { return numeroContribuable; }
    public void setNumeroContribuable(String numeroContribuable) { this.numeroContribuable = numeroContribuable; }

    public LocalDateTime getDateGeneration() { return dateGeneration; }
    public void setDateGeneration(LocalDateTime dateGeneration) { this.dateGeneration = dateGeneration; }

    public Boolean getActif() { return actif; }
    public void setActif(Boolean actif) { this.actif = actif; }

    public LocalDateTime getDateExpiration() { return dateExpiration; }
    public void setDateExpiration(LocalDateTime dateExpiration) { this.dateExpiration = dateExpiration; }

    public String getUtilisePar() { return utilisePar; }
    public void setUtilisePar(String utilisePar) { this.utilisePar = utilisePar; }
}
