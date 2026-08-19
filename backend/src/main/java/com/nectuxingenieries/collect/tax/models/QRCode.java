package com.nectuxingenieries.collect.tax.models;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
@Entity
public class QRCode extends Auditable{

    @Id
    @GeneratedValue
    private Long id;

    @OneToOne
    private Contribuable contribuable;

    private String code; // généré de manière unique (UUID)

    // ce QR code est généré une fois et affiché sur l’étal


}

