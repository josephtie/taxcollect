package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "message")
public class Message extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "expediteur_id", nullable = false)
    private Long expediteurId;

    @Column(name = "expediteur_role", nullable = false, length = 30)
    private String expediteurRole;

    @Column(name = "destinataire_id")
    private Long destinataireId;

    @Column(name = "destinataire_role", length = 30)
    private String destinataireRole;

    @Column(name = "signalement_id")
    private Long signalementId;

    @Column(nullable = false, length = 2000)
    private String contenu;

    @Column(name = "lu", nullable = false)
    private Boolean lu = false;

    @Column(name = "date_lecture")
    private LocalDateTime dateLecture;

    @Column(name = "offline", nullable = false)
    private Boolean offline = false;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getExpediteurId() { return expediteurId; }
    public void setExpediteurId(Long expediteurId) { this.expediteurId = expediteurId; }
    public String getExpediteurRole() { return expediteurRole; }
    public void setExpediteurRole(String expediteurRole) { this.expediteurRole = expediteurRole; }
    public Long getDestinataireId() { return destinataireId; }
    public void setDestinataireId(Long destinataireId) { this.destinataireId = destinataireId; }
    public String getDestinataireRole() { return destinataireRole; }
    public void setDestinataireRole(String destinataireRole) { this.destinataireRole = destinataireRole; }
    public Long getSignalementId() { return signalementId; }
    public void setSignalementId(Long signalementId) { this.signalementId = signalementId; }
    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }
    public Boolean getLu() { return lu; }
    public void setLu(Boolean lu) { this.lu = lu; }
    public LocalDateTime getDateLecture() { return dateLecture; }
    public void setDateLecture(LocalDateTime dateLecture) { this.dateLecture = dateLecture; }
    public Boolean getOffline() { return offline; }
    public void setOffline(Boolean offline) { this.offline = offline; }
}
