package com.nectuxingenieries.collect.tax.dto;

import java.math.BigDecimal;
import java.util.List;

public class ZoneDashboardDto {
    private Long zoneId;
    private String zoneNom;
    private int nbQuartiers;
    private int nbSecteurs;
    private int nbAgents;
    private int nbContribuables;
    private int nbContribuablesVisites;
    private int nbContribuablesNonVisites;
    private int nbNouveauxContribuables;
    private BigDecimal montantEncaisse;
    private BigDecimal montantRestant;
    private double tauxRecouvrement;
    private double tauxCouverture;
    private List<QuartierPerformance> performanceQuartiers;
    private int anomalies;

    public Long getZoneId() { return zoneId; }
    public void setZoneId(Long zoneId) { this.zoneId = zoneId; }
    public String getZoneNom() { return zoneNom; }
    public void setZoneNom(String zoneNom) { this.zoneNom = zoneNom; }
    public int getNbQuartiers() { return nbQuartiers; }
    public void setNbQuartiers(int nbQuartiers) { this.nbQuartiers = nbQuartiers; }
    public int getNbSecteurs() { return nbSecteurs; }
    public void setNbSecteurs(int nbSecteurs) { this.nbSecteurs = nbSecteurs; }
    public int getNbAgents() { return nbAgents; }
    public void setNbAgents(int nbAgents) { this.nbAgents = nbAgents; }
    public int getNbContribuables() { return nbContribuables; }
    public void setNbContribuables(int nbContribuables) { this.nbContribuables = nbContribuables; }
    public int getNbContribuablesVisites() { return nbContribuablesVisites; }
    public void setNbContribuablesVisites(int nbContribuablesVisites) { this.nbContribuablesVisites = nbContribuablesVisites; }
    public int getNbContribuablesNonVisites() { return nbContribuablesNonVisites; }
    public void setNbContribuablesNonVisites(int nbContribuablesNonVisites) { this.nbContribuablesNonVisites = nbContribuablesNonVisites; }
    public int getNbNouveauxContribuables() { return nbNouveauxContribuables; }
    public void setNbNouveauxContribuables(int nbNouveauxContribuables) { this.nbNouveauxContribuables = nbNouveauxContribuables; }
    public BigDecimal getMontantEncaisse() { return montantEncaisse; }
    public void setMontantEncaisse(BigDecimal montantEncaisse) { this.montantEncaisse = montantEncaisse; }
    public BigDecimal getMontantRestant() { return montantRestant; }
    public void setMontantRestant(BigDecimal montantRestant) { this.montantRestant = montantRestant; }
    public double getTauxRecouvrement() { return tauxRecouvrement; }
    public void setTauxRecouvrement(double tauxRecouvrement) { this.tauxRecouvrement = tauxRecouvrement; }
    public double getTauxCouverture() { return tauxCouverture; }
    public void setTauxCouverture(double tauxCouverture) { this.tauxCouverture = tauxCouverture; }
    public List<QuartierPerformance> getPerformanceQuartiers() { return performanceQuartiers; }
    public void setPerformanceQuartiers(List<QuartierPerformance> performanceQuartiers) { this.performanceQuartiers = performanceQuartiers; }
    public int getAnomalies() { return anomalies; }
    public void setAnomalies(int anomalies) { this.anomalies = anomalies; }

    public static class QuartierPerformance {
        private Long quartierId;
        private String quartierNom;
        private int nbAgents;
        private int nbContribuables;
        private int nbVisites;
        private double tauxCouverture;
        private BigDecimal montantCollecte;
        private int anomalies;
        public Long getQuartierId() { return quartierId; }
        public void setQuartierId(Long quartierId) { this.quartierId = quartierId; }
        public String getQuartierNom() { return quartierNom; }
        public void setQuartierNom(String quartierNom) { this.quartierNom = quartierNom; }
        public int getNbAgents() { return nbAgents; }
        public void setNbAgents(int nbAgents) { this.nbAgents = nbAgents; }
        public int getNbContribuables() { return nbContribuables; }
        public void setNbContribuables(int nbContribuables) { this.nbContribuables = nbContribuables; }
        public int getNbVisites() { return nbVisites; }
        public void setNbVisites(int nbVisites) { this.nbVisites = nbVisites; }
        public double getTauxCouverture() { return tauxCouverture; }
        public void setTauxCouverture(double tauxCouverture) { this.tauxCouverture = tauxCouverture; }
        public BigDecimal getMontantCollecte() { return montantCollecte; }
        public void setMontantCollecte(BigDecimal montantCollecte) { this.montantCollecte = montantCollecte; }
        public int getAnomalies() { return anomalies; }
        public void setAnomalies(int anomalies) { this.anomalies = anomalies; }
    }
}
