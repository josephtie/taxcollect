package com.nectuxingenieries.collect.tax.dto;

import java.util.Map;

public class RecensementStatsDTO {

    private Long totalContribuables;
    private Long nonSynchronises;
    private Long enValidation;
    private Long creesAujourdhui;
    private Long misAJourAujourdhui;
    private Map<String, Long> repartitionParType;
    private Map<String, Long> repartitionParZone;
    private Double tauxSynchronisation;

    public RecensementStatsDTO() {}

    public Long getTotalContribuables() { return totalContribuables; }
    public void setTotalContribuables(Long totalContribuables) { this.totalContribuables = totalContribuables; }

    public Long getNonSynchronises() { return nonSynchronises; }
    public void setNonSynchronises(Long nonSynchronises) { this.nonSynchronises = nonSynchronises; }

    public Long getEnValidation() { return enValidation; }
    public void setEnValidation(Long enValidation) { this.enValidation = enValidation; }

    public Long getCreesAujourdhui() { return creesAujourdhui; }
    public void setCreesAujourdhui(Long creesAujourdhui) { this.creesAujourdhui = creesAujourdhui; }

    public Long getMisAJourAujourdhui() { return misAJourAujourdhui; }
    public void setMisAJourAujourdhui(Long misAJourAujourdhui) { this.misAJourAujourdhui = misAJourAujourdhui; }

    public Map<String, Long> getRepartitionParType() { return repartitionParType; }
    public void setRepartitionParType(Map<String, Long> repartitionParType) { this.repartitionParType = repartitionParType; }

    public Map<String, Long> getRepartitionParZone() { return repartitionParZone; }
    public void setRepartitionParZone(Map<String, Long> repartitionParZone) { this.repartitionParZone = repartitionParZone; }

    public Double getTauxSynchronisation() { return tauxSynchronisation; }
    public void setTauxSynchronisation(Double tauxSynchronisation) { this.tauxSynchronisation = tauxSynchronisation; }
}
