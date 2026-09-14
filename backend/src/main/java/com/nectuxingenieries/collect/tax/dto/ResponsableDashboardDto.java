package com.nectuxingenieries.collect.tax.dto;

import java.util.List;
import java.util.Map;

public class ResponsableDashboardDto {
    private QuartierInfo quartier;
    private SecteursInfo secteurs;
    private AgentsInfo agents;
    private ContribuablesInfo contribuables;
    private CollecteInfo collecte;
    private int anomalies;
    private double progression;

    public QuartierInfo getQuartier() { return quartier; }
    public void setQuartier(QuartierInfo quartier) { this.quartier = quartier; }
    public SecteursInfo getSecteurs() { return secteurs; }
    public void setSecteurs(SecteursInfo secteurs) { this.secteurs = secteurs; }
    public AgentsInfo getAgents() { return agents; }
    public void setAgents(AgentsInfo agents) { this.agents = agents; }
    public ContribuablesInfo getContribuables() { return contribuables; }
    public void setContribuables(ContribuablesInfo contribuables) { this.contribuables = contribuables; }
    public CollecteInfo getCollecte() { return collecte; }
    public void setCollecte(CollecteInfo collecte) { this.collecte = collecte; }
    public int getAnomalies() { return anomalies; }
    public void setAnomalies(int anomalies) { this.anomalies = anomalies; }
    public double getProgression() { return progression; }
    public void setProgression(double progression) { this.progression = progression; }

    public static class QuartierInfo {
        private Long id;
        private String nom;
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
    }

    public static class SecteursInfo {
        private int total;
        private List<String> liste;
        public int getTotal() { return total; }
        public void setTotal(int total) { this.total = total; }
        public List<String> getListe() { return liste; }
        public void setListe(List<String> liste) { this.liste = liste; }
    }

    public static class AgentsInfo {
        private int total;
        private int actifs;
        private int absents;
        public int getTotal() { return total; }
        public void setTotal(int total) { this.total = total; }
        public int getActifs() { return actifs; }
        public void setActifs(int actifs) { this.actifs = actifs; }
        public int getAbsents() { return absents; }
        public void setAbsents(int absents) { this.absents = absents; }
    }

    public static class ContribuablesInfo {
        private int total;
        private int visites;
        private int nonVisites;
        private int nouveaux;
        private int impayes;
        public int getTotal() { return total; }
        public void setTotal(int total) { this.total = total; }
        public int getVisites() { return visites; }
        public void setVisites(int visites) { this.visites = visites; }
        public int getNonVisites() { return nonVisites; }
        public void setNonVisites(int nonVisites) { this.nonVisites = nonVisites; }
        public int getNouveaux() { return nouveaux; }
        public void setNouveaux(int nouveaux) { this.nouveaux = nouveaux; }
        public int getImpayes() { return impayes; }
        public void setImpayes(int impayes) { this.impayes = impayes; }
    }

    public static class CollecteInfo {
        private java.math.BigDecimal montantCollecte;
        private java.math.BigDecimal impayes;
        private int paiementsJour;
        public java.math.BigDecimal getMontantCollecte() { return montantCollecte; }
        public void setMontantCollecte(java.math.BigDecimal montantCollecte) { this.montantCollecte = montantCollecte; }
        public java.math.BigDecimal getImpayes() { return impayes; }
        public void setImpayes(java.math.BigDecimal impayes) { this.impayes = impayes; }
        public int getPaiementsJour() { return paiementsJour; }
        public void setPaiementsJour(int paiementsJour) { this.paiementsJour = paiementsJour; }
    }
}
