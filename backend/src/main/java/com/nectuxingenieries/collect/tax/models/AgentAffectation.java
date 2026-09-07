package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "agent_affectation",
       uniqueConstraints = @UniqueConstraint(
           name = "uk_agent_affectation",
           columnNames = {"agent_id", "territory_type", "territory_id"}
       ))
public class AgentAffectation extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private Agents agent;

    @Enumerated(EnumType.STRING)
    @Column(name = "territory_type", nullable = false, length = 20)
    private TerritoryType territoryType;

    @Column(name = "territory_id", nullable = false)
    private Long territoryId;

    @Column(name = "date_debut")
    private LocalDate dateDebut;

    @Column(name = "date_fin")
    private LocalDate dateFin;

    @Column(name = "statut", nullable = false)
    private Boolean statut = true;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Agents getAgent() { return agent; }
    public void setAgent(Agents agent) { this.agent = agent; }

    public TerritoryType getTerritoryType() { return territoryType; }
    public void setTerritoryType(TerritoryType territoryType) { this.territoryType = territoryType; }

    public Long getTerritoryId() { return territoryId; }
    public void setTerritoryId(Long territoryId) { this.territoryId = territoryId; }

    public LocalDate getDateDebut() { return dateDebut; }
    public void setDateDebut(LocalDate dateDebut) { this.dateDebut = dateDebut; }

    public LocalDate getDateFin() { return dateFin; }
    public void setDateFin(LocalDate dateFin) { this.dateFin = dateFin; }

    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
}
