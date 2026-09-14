package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.TypeSignalement;
import jakarta.persistence.*;

@Entity
@Table(name = "signalement")
public class Signalement extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "agent_id", nullable = false)
    private Long agentId;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false)
    private TypeSignalement type;

    @Column(nullable = false, length = 1000)
    private String message;

    @Column(name = "contribuable_id")
    private Long contribuableId;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "statut", nullable = false, length = 20)
    private String statut = "OUVERT";

    @Column(name = "reponse", length = 1000)
    private String reponse;

    @Column(name = "traite_par")
    private Long traitePar;

    @Column(name = "date_traitement")
    private java.time.LocalDateTime dateTraitement;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getAgentId() { return agentId; }
    public void setAgentId(Long agentId) { this.agentId = agentId; }
    public TypeSignalement getType() { return type; }
    public void setType(TypeSignalement type) { this.type = type; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Long getContribuableId() { return contribuableId; }
    public void setContribuableId(Long contribuableId) { this.contribuableId = contribuableId; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }
    public String getReponse() { return reponse; }
    public void setReponse(String reponse) { this.reponse = reponse; }
    public Long getTraitePar() { return traitePar; }
    public void setTraitePar(Long traitePar) { this.traitePar = traitePar; }
    public java.time.LocalDateTime getDateTraitement() { return dateTraitement; }
    public void setDateTraitement(java.time.LocalDateTime dateTraitement) { this.dateTraitement = dateTraitement; }
}
