package com.nectuxingenieries.collect.tax.models;

import com.nectuxingenieries.collect.tax.models.enums.CarteStatus;
import com.nectuxingenieries.collect.tax.models.enums.CarteType;
import com.nectuxingenieries.collect.tax.models.enums.QRSecurityLevel;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Carte contribuable — carte physique ou numérique associée à un contribuable.
 * Un contribuable peut avoir plusieurs cartes dans le temps mais une seule active.
 */
@Entity
@Table(name = "carte_contribuable",
        uniqueConstraints = {
            @UniqueConstraint(columnNames = "numero_carte"),
            @UniqueConstraint(columnNames = "matricule_unique")
        },
        indexes = {
            @Index(name = "idx_carte_contribuable_id", columnList = "contribuable_id"),
            @Index(name = "idx_carte_status", columnList = "status"),
            @Index(name = "idx_carte_matricule", columnList = "matricule_unique")
        })
public class CarteContribuable extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contribuable_id", nullable = false)
    private Contribuable contribuable;

    @Column(name = "numero_carte", nullable = false, unique = true, length = 50)
    private String numeroCarte;

    @Column(name = "matricule_unique", nullable = false, unique = true, length = 50)
    private String matriculeUnique;

    @Column(name = "qr_code_data", columnDefinition = "TEXT")
    private String qrCodeData;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 20)
    private CarteType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private CarteStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "security_level", nullable = false, length = 20)
    private QRSecurityLevel securityLevel;

    @Column(name = "date_emission", nullable = false)
    private LocalDateTime dateEmission;

    @Column(name = "date_expiration", nullable = false)
    private LocalDateTime dateExpiration;

    @Column(name = "photo_url", length = 500)
    private String photoUrl;

    @Column(name = "agent_id", length = 100)
    private String agentId;

    @Column(name = "zone_id", length = 100)
    private String zoneId;

    @Column(name = "synced", nullable = false)
    private Boolean synced = true;

    // Constructeur par défaut requis par JPA
    public CarteContribuable() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Contribuable getContribuable() { return contribuable; }
    public void setContribuable(Contribuable contribuable) { this.contribuable = contribuable; }

    public String getNumeroCarte() { return numeroCarte; }
    public void setNumeroCarte(String numeroCarte) { this.numeroCarte = numeroCarte; }

    public String getMatriculeUnique() { return matriculeUnique; }
    public void setMatriculeUnique(String matriculeUnique) { this.matriculeUnique = matriculeUnique; }

    public String getQrCodeData() { return qrCodeData; }
    public void setQrCodeData(String qrCodeData) { this.qrCodeData = qrCodeData; }

    public CarteType getType() { return type; }
    public void setType(CarteType type) { this.type = type; }

    public CarteStatus getStatus() { return status; }
    public void setStatus(CarteStatus status) { this.status = status; }

    public QRSecurityLevel getSecurityLevel() { return securityLevel; }
    public void setSecurityLevel(QRSecurityLevel securityLevel) { this.securityLevel = securityLevel; }

    public LocalDateTime getDateEmission() { return dateEmission; }
    public void setDateEmission(LocalDateTime dateEmission) { this.dateEmission = dateEmission; }

    public LocalDateTime getDateExpiration() { return dateExpiration; }
    public void setDateExpiration(LocalDateTime dateExpiration) { this.dateExpiration = dateExpiration; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public String getAgentId() { return agentId; }
    public void setAgentId(String agentId) { this.agentId = agentId; }

    public String getZoneId() { return zoneId; }
    public void setZoneId(String zoneId) { this.zoneId = zoneId; }

    public Boolean getSynced() { return synced; }
    public void setSynced(Boolean synced) { this.synced = synced; }
}
