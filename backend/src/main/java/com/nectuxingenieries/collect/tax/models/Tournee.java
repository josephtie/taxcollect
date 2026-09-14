package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.StatutTournee;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "tournee")
public class Tournee extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "date_tournee", nullable = false)
    private LocalDate dateTournee;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private Agents agent;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatutTournee statut = StatutTournee.PLANIFIEE;

    @Column(name = "montant_objectif", precision = 19, scale = 2)
    private java.math.BigDecimal montantObjectif;

    @Column(name = "montant_collecte", precision = 19, scale = 2)
    private java.math.BigDecimal montantCollecte;

    @Column(name = "nb_visites_prevues")
    private Integer nbVisitesPrevues;

    @Column(name = "nb_visites_effectuees")
    private Integer nbVisitesEffectuees;

    @OneToMany(mappedBy = "tournee", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Visite> visites;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public LocalDate getDateTournee() { return dateTournee; }
    public void setDateTournee(LocalDate dateTournee) { this.dateTournee = dateTournee; }
    public Agents getAgent() { return agent; }
    public void setAgent(Agents agent) { this.agent = agent; }
    public StatutTournee getStatut() { return statut; }
    public void setStatut(StatutTournee statut) { this.statut = statut; }
    public java.math.BigDecimal getMontantObjectif() { return montantObjectif; }
    public void setMontantObjectif(java.math.BigDecimal montantObjectif) { this.montantObjectif = montantObjectif; }
    public java.math.BigDecimal getMontantCollecte() { return montantCollecte; }
    public void setMontantCollecte(java.math.BigDecimal montantCollecte) { this.montantCollecte = montantCollecte; }
    public Integer getNbVisitesPrevues() { return nbVisitesPrevues; }
    public void setNbVisitesPrevues(Integer nbVisitesPrevues) { this.nbVisitesPrevues = nbVisitesPrevues; }
    public Integer getNbVisitesEffectuees() { return nbVisitesEffectuees; }
    public void setNbVisitesEffectuees(Integer nbVisitesEffectuees) { this.nbVisitesEffectuees = nbVisitesEffectuees; }
    public List<Visite> getVisites() { return visites; }
    public void setVisites(List<Visite> visites) { this.visites = visites; }
}
