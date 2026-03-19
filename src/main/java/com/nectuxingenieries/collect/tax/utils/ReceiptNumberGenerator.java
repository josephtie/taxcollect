package com.nectuxingenieries.collect.tax.utils;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.atomic.AtomicLong;

public class ReceiptNumberGenerator {

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final AtomicLong sequence = new AtomicLong(0);

    public static String generateReceiptNumber() {
        LocalDate today = LocalDate.now();
        String datePart = today.format(DATE_FORMAT);
        long sequenceNumber = sequence.incrementAndGet();
        
        return String.format("TAX-%s-%04d", datePart, sequenceNumber);
    }

    public static String generateReceiptNumber(LocalDate date) {
        String datePart = date.format(DATE_FORMAT);
        long sequenceNumber = sequence.incrementAndGet();
        
        return String.format("TAX-%s-%04d", datePart, sequenceNumber);
    }

    public static String generateReceiptNumber(LocalDate date, long sequenceNumber) {
        String datePart = date.format(DATE_FORMAT);
        
        return String.format("TAX-%s-%04d", datePart, sequenceNumber);
    }

    public static boolean isValidReceiptNumber(String receiptNumber) {
        if (receiptNumber == null || !receiptNumber.startsWith("TAX-")) {
            return false;
        }
        
        String[] parts = receiptNumber.split("-");
        if (parts.length != 3) {
            return false;
        }
        
        try {
            LocalDate.parse(parts[1], DATE_FORMAT);
            Integer.parseInt(parts[2]);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static LocalDate extractDateFromReceiptNumber(String receiptNumber) {
        if (!isValidReceiptNumber(receiptNumber)) {
            throw new IllegalArgumentException("Numéro de reçu invalide");
        }
        
        String[] parts = receiptNumber.split("-");
        return LocalDate.parse(parts[1], DATE_FORMAT);
    }

    public static void resetSequence() {
        sequence.set(0);
    }

    public static void setSequence(long value) {
        sequence.set(value);
    }

    public static long getCurrentSequence() {
        return sequence.get();
    }
}
