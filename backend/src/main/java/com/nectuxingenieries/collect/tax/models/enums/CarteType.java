package com.nectuxingenieries.collect.tax.models.enums;

/**
 * Types de cartes contribuables.
 */
public enum CarteType {
    PAPER("paper", "Papier"),
    PVC("pvc", "PVC"),
    DIGITAL("digital", "Numérique");

    private final String code;
    private final String label;

    CarteType(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public String getCode() {
        return code;
    }

    public String getLabel() {
        return label;
    }

    public static CarteType fromCode(String code) {
        for (CarteType type : values()) {
            if (type.code.equalsIgnoreCase(code)) {
                return type;
            }
        }
        return PVC;
    }
}
