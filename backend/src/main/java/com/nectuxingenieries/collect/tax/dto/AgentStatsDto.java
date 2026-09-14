package com.nectuxingenieries.collect.tax.dto;

import java.math.BigDecimal;

public class AgentStatsDto {
    private String period;
    private int nbVisites;
    private int nbVisitesPayees;
    private int nbVisitesImpayees;
    private int nbVisitesAbsentes;
    private int nbNouveauxContribuables;
    private BigDecimal montantCollecte;
    private BigDecimal montantEspece;
    private BigDecimal montantMobileMoney;
    private int nbTransactions;
    private int nbPaiementsPartiels;
    private BigDecimal montantAttendu;
    private BigDecimal montantImpayes;
    private double tauxRecouvrement;
    private double tauxReussite;
    private int nbPromesses;
    private int nbRelances;

    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }
    public int getNbVisites() { return nbVisites; }
    public void setNbVisites(int nbVisites) { this.nbVisites = nbVisites; }
    public int getNbVisitesPayees() { return nbVisitesPayees; }
    public void setNbVisitesPayees(int nbVisitesPayees) { this.nbVisitesPayees = nbVisitesPayees; }
    public int getNbVisitesImpayees() { return nbVisitesImpayees; }
    public void setNbVisitesImpayees(int nbVisitesImpayees) { this.nbVisitesImpayees = nbVisitesImpayees; }
    public int getNbVisitesAbsentes() { return nbVisitesAbsentes; }
    public void setNbVisitesAbsentes(int nbVisitesAbsentes) { this.nbVisitesAbsentes = nbVisitesAbsentes; }
    public int getNbNouveauxContribuables() { return nbNouveauxContribuables; }
    public void setNbNouveauxContribuables(int nbNouveauxContribuables) { this.nbNouveauxContribuables = nbNouveauxContribuables; }
    public BigDecimal getMontantCollecte() { return montantCollecte; }
    public void setMontantCollecte(BigDecimal montantCollecte) { this.montantCollecte = montantCollecte; }
    public BigDecimal getMontantEspece() { return montantEspece; }
    public void setMontantEspece(BigDecimal montantEspece) { this.montantEspece = montantEspece; }
    public BigDecimal getMontantMobileMoney() { return montantMobileMoney; }
    public void setMontantMobileMoney(BigDecimal montantMobileMoney) { this.montantMobileMoney = montantMobileMoney; }
    public int getNbTransactions() { return nbTransactions; }
    public void setNbTransactions(int nbTransactions) { this.nbTransactions = nbTransactions; }
    public int getNbPaiementsPartiels() { return nbPaiementsPartiels; }
    public void setNbPaiementsPartiels(int nbPaiementsPartiels) { this.nbPaiementsPartiels = nbPaiementsPartiels; }
    public BigDecimal getMontantAttendu() { return montantAttendu; }
    public void setMontantAttendu(BigDecimal montantAttendu) { this.montantAttendu = montantAttendu; }
    public BigDecimal getMontantImpayes() { return montantImpayes; }
    public void setMontantImpayes(BigDecimal montantImpayes) { this.montantImpayes = montantImpayes; }
    public double getTauxRecouvrement() { return tauxRecouvrement; }
    public void setTauxRecouvrement(double tauxRecouvrement) { this.tauxRecouvrement = tauxRecouvrement; }
    public double getTauxReussite() { return tauxReussite; }
    public void setTauxReussite(double tauxReussite) { this.tauxReussite = tauxReussite; }
    public int getNbPromesses() { return nbPromesses; }
    public void setNbPromesses(int nbPromesses) { this.nbPromesses = nbPromesses; }
    public int getNbRelances() { return nbRelances; }
    public void setNbRelances(int nbRelances) { this.nbRelances = nbRelances; }
}
