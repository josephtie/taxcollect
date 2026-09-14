package com.nectuxingenieries.collect.tax.models.enums;

/**
 * Statuts des cartes contribuables.
 */
public enum CarteStatus {
    DRAFT("draft", "Brouillon"),
    ACTIVE("active", "Active"),
    EXPIRED("expired", "Expirée"),
    SUSPENDED("suspended", "Suspendue"),
    REVOKED("revoked", "Révoquée"),
    LOST("lost", "Perdue"),
    DAMAGED("damaged", "Endommagée");

    private final String code;
    private final String label;

    CarteStatus(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public String getCode() {
        return code;
    }

    public String getLabel() {
        return label;
    }

    public static CarteStatus fromCode(String code) {
        for (CarteStatus status : values()) {
            if (status.code.equalsIgnoreCase(code)) {
                return status;
            }
        }
        return DRAFT;
    }
}
