package com.nectuxingenieries.collect.tax.exceptions;

public class NotFoundException extends BusinessException {

    public NotFoundException(String resource, Long id) {
        super("NOT_FOUND", resource + " non trouvé avec l'ID: " + id);
    }

    public NotFoundException(String resource, String identifier) {
        super("NOT_FOUND", resource + " non trouvé avec l'identifiant: " + identifier);
    }
}
