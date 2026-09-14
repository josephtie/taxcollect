package com.nectuxingenieries.collect.tax.models.enums;

/**
 * Niveaux de sécurité QR pour les cartes contribuables.
 */
public enum QRSecurityLevel {
    BASIC("basic", "Basique"),
    STANDARD("standard", "Standard"),
    HIGH("high", "Élevé"),
    MAXIMUM("maximum", "Maximum");

    private final String code;
    private final String label;

    QRSecurityLevel(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public String getCode() {
        return code;
    }

    public String getLabel() {
        return label;
    }

    public static QRSecurityLevel fromCode(String code) {
        for (QRSecurityLevel level : values()) {
            if (level.code.equalsIgnoreCase(code)) {
                return level;
            }
        }
        return STANDARD;
    }
}
