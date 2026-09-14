package com.nectuxingenieries.collect.tax.dto;

import com.nectuxingenieries.collect.tax.models.enums.StatutTournee;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class TourneeDto {
    private Long id;
    private LocalDate dateTournee;
    private Long agentId;
    private String agentNom;
    private StatutTournee statut;
    private BigDecimal montantObjectif;
    private BigDecimal montantCollecte;
    private Integer nbVisitesPrevues;
    private Integer nbVisitesEffectuees;
    private List<VisiteDto> visites;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public LocalDate getDateTournee() { return dateTournee; }
    public void setDateTournee(LocalDate dateTournee) { this.dateTournee = dateTournee; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public String getAgentNom() { return agentNom; }
    public void setAgentNom(String agentNom) { this.agentNom = agentNom; }
    public StatutTournee getStatut() { return statut; }
    public void setStatut(StatutTournee statut) { this.statut = statut; }
    public BigDecimal getMontantObjectif() { return montantObjectif; }
    public void setMontantObjectif(BigDecimal montantObjectif) { this.montantObjectif = montantObjectif; }
    public BigDecimal getMontantCollecte() { return montantCollecte; }
    public void setMontantCollecte(BigDecimal montantCollecte) { this.montantCollecte = montantCollecte; }
    public Integer getNbVisitesPrevues() { return nbVisitesPrevues; }
    public void setNbVisitesPrevues(Integer nbVisitesPrevues) { this.nbVisitesPrevues = nbVisitesPrevues; }
    public Integer getNbVisitesEffectuees() { return nbVisitesEffectuees; }
    public void setNbVisitesEffectuees(Integer nbVisitesEffectuees) { this.nbVisitesEffectuees = nbVisitesEffectuees; }
    public List<VisiteDto> getVisites() { return visites; }
    public void setVisites(List<VisiteDto> visites) { this.visites = visites; }
}
