package com.nectuxingenieries.collect.tax.dto;

import java.math.BigDecimal;

public class AgentDashboardDto {
    private Long agentId;
    private int nbVisitesJour;
    private int nbVisitesMois;
    private BigDecimal montantCollecteJour;
    private BigDecimal montantCollecteMois;
    private int nbImpayes;
    private BigDecimal montantImpayes;
    private int nbPromessesEnAttente;
    private int nbNotificationsNonLues;
    private int nbPortefeuille;
    private int nbContribuablesAvecGps;
    private int nbTransactionsOffline;

    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public int getNbVisitesJour() { return nbVisitesJour; }
    public void setNbVisitesJour(int nbVisitesJour) { this.nbVisitesJour = nbVisitesJour; }
    public int getNbVisitesMois() { return nbVisitesMois; }
    public void setNbVisitesMois(int nbVisitesMois) { this.nbVisitesMois = nbVisitesMois; }
    public BigDecimal getMontantCollecteJour() { return montantCollecteJour; }
    public void setMontantCollecteJour(BigDecimal montantCollecteJour) { this.montantCollecteJour = montantCollecteJour; }
    public BigDecimal getMontantCollecteMois() { return montantCollecteMois; }
    public void setMontantCollecteMois(BigDecimal montantCollecteMois) { this.montantCollecteMois = montantCollecteMois; }
    public int getNbImpayes() { return nbImpayes; }
    public void setNbImpayes(int nbImpayes) { this.nbImpayes = nbImpayes; }
    public BigDecimal getMontantImpayes() { return montantImpayes; }
    public void setMontantImpayes(BigDecimal montantImpayes) { this.montantImpayes = montantImpayes; }
    public int getNbPromessesEnAttente() { return nbPromessesEnAttente; }
    public void setNbPromessesEnAttente(int nbPromessesEnAttente) { this.nbPromessesEnAttente = nbPromessesEnAttente; }
    public int getNbNotificationsNonLues() { return nbNotificationsNonLues; }
    public void setNbNotificationsNonLues(int nbNotificationsNonLues) { this.nbNotificationsNonLues = nbNotificationsNonLues; }
    public int getNbPortefeuille() { return nbPortefeuille; }
    public void setNbPortefeuille(int nbPortefeuille) { this.nbPortefeuille = nbPortefeuille; }
    public int getNbContribuablesAvecGps() { return nbContribuablesAvecGps; }
    public void setNbContribuablesAvecGps(int nbContribuablesAvecGps) { this.nbContribuablesAvecGps = nbContribuablesAvecGps; }
    public int getNbTransactionsOffline() { return nbTransactionsOffline; }
    public void setNbTransactionsOffline(int nbTransactionsOffline) { this.nbTransactionsOffline = nbTransactionsOffline; }
}
