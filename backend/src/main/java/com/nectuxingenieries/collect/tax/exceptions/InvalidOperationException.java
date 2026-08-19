package com.nectuxingenieries.collect.tax.exceptions;

public class InvalidOperationException extends BusinessException {

    public InvalidOperationException(String message) {
        super("INVALID_OPERATION", message);
    }
}
