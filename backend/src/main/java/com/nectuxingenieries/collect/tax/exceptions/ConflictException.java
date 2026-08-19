package com.nectuxingenieries.collect.tax.exceptions;

public class ConflictException extends BusinessException {

    public ConflictException(String message) {
        super("CONFLICT", message);
    }
}
