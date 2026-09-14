package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "portefeuille",
       uniqueConstraints = @UniqueConstraint(
           name = "uk_portefeuille_agent_contribuable",
           columnNames = {"agent_id", "contribuable_id"}
       ))
public class Portefeuille extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "agent_id", nullable = false)
    private Agents agent;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contribuable_id", nullable = false)
    private Contribuable contribuable;

    @Column(name = "date_affectation", nullable = false)
    private LocalDate dateAffectation;

    @Column(name = "date_fin")
    private LocalDate dateFin;

    @Column(name = "statut", nullable = false)
    private Boolean statut = true;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Agents getAgent() { return agent; }
    public void setAgent(Agents agent) { this.agent = agent; }
    public Contribuable getContribuable() { return contribuable; }
    public void setContribuable(Contribuable contribuable) { this.contribuable = contribuable; }
    public LocalDate getDateAffectation() { return dateAffectation; }
    public void setDateAffectation(LocalDate dateAffectation) { this.dateAffectation = dateAffectation; }
    public LocalDate getDateFin() { return dateFin; }
    public void setDateFin(LocalDate dateFin) { this.dateFin = dateFin; }
    public Boolean getStatut() { return statut; }
    public void setStatut(Boolean statut) { this.statut = statut; }
}
