package com.nectuxingenieries.collect.tax.utils;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import static org.junit.jupiter.api.Assertions.*;

class ReceiptNumberGeneratorTest {

    @BeforeEach
    void setUp() {
        ReceiptNumberGenerator.resetSequence();
    }

    @Test
    void generateReceiptNumber_shouldStartWithTaxPrefix() {
        String receipt = ReceiptNumberGenerator.generateReceiptNumber();
        assertTrue(receipt.startsWith("TAX-"));
    }

    @Test
    void generateReceiptNumber_shouldFollowFormat() {
        String receipt = ReceiptNumberGenerator.generateReceiptNumber();
        String[] parts = receipt.split("-");
        assertEquals(3, parts.length, "Receipt should have 3 parts separated by '-'");
        assertEquals("TAX", parts[0]);
        assertEquals(8, parts[1].length(), "Date part should be 8 characters (yyyyMMdd)");
        assertEquals(4, parts[2].length(), "Sequence part should be 4 characters");
    }

    @Test
    void generateReceiptNumber_shouldIncrementSequence() {
        String receipt1 = ReceiptNumberGenerator.generateReceiptNumber();
        String receipt2 = ReceiptNumberGenerator.generateReceiptNumber();

        String seq1 = receipt1.split("-")[2];
        String seq2 = receipt2.split("-")[2];

        int s1 = Integer.parseInt(seq1);
        int s2 = Integer.parseInt(seq2);

        assertEquals(1, s2 - s1, "Sequence should increment by 1");
    }

    @Test
    void generateReceiptNumberWithDate_shouldUseProvidedDate() {
        LocalDate date = LocalDate.of(2026, 1, 15);
        String receipt = ReceiptNumberGenerator.generateReceiptNumber(date);
        assertTrue(receipt.contains("20260115"));
    }

    @Test
    void isValidReceiptNumber_shouldReturnTrue_forValidReceipt() {
        assertTrue(ReceiptNumberGenerator.isValidReceiptNumber("TAX-20260727-0001"));
    }

    @Test
    void isValidReceiptNumber_shouldReturnFalse_forInvalidReceipt() {
        assertFalse(ReceiptNumberGenerator.isValidReceiptNumber("INVALID"));
        assertFalse(ReceiptNumberGenerator.isValidReceiptNumber(null));
        assertFalse(ReceiptNumberGenerator.isValidReceiptNumber("TAX-invalid-0001"));
        assertFalse(ReceiptNumberGenerator.isValidReceiptNumber("TAX-20260727"));
    }

    @Test
    void extractDateFromReceiptNumber_shouldReturnCorrectDate() {
        LocalDate date = ReceiptNumberGenerator.extractDateFromReceiptNumber("TAX-20260727-0001");
        assertEquals(LocalDate.of(2026, 7, 27), date);
    }

    @Test
    void extractDateFromReceiptNumber_shouldThrowForInvalidReceipt() {
        assertThrows(IllegalArgumentException.class, () ->
                ReceiptNumberGenerator.extractDateFromReceiptNumber("INVALID"));
    }
}
