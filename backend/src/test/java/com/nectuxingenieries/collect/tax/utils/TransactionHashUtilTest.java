package com.nectuxingenieries.collect.tax.utils;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import static org.junit.jupiter.api.Assertions.*;

class TransactionHashUtilTest {

    private static final DateTimeFormatter TIMESTAMP_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");

    @Test
    void generateTransactionHash_shouldReturnConsistentHash() {
        Long transactionId = 1L;
        BigDecimal montant = new BigDecimal("5000.00");
        Long contribuableId = 10L;
        Long agentId = 5L;
        LocalDateTime timestamp = LocalDateTime.of(2026, 7, 27, 10, 30, 0);

        String hash1 = TransactionHashUtil.generateTransactionHash(transactionId, montant, contribuableId, agentId, timestamp);
        String hash2 = TransactionHashUtil.generateTransactionHash(transactionId, montant, contribuableId, agentId, timestamp);

        assertNotNull(hash1);
        assertEquals(hash1, hash2, "Hash should be deterministic for same inputs");
        assertEquals(64, hash1.length(), "SHA-256 hash should be 64 hex characters");
    }

    @Test
    void generateTransactionHash_shouldReturnDifferentHash_forDifferentInputs() {
        LocalDateTime timestamp = LocalDateTime.now();

        String hash1 = TransactionHashUtil.generateTransactionHash(1L, new BigDecimal("5000.00"), 10L, 5L, timestamp);
        String hash2 = TransactionHashUtil.generateTransactionHash(2L, new BigDecimal("5000.00"), 10L, 5L, timestamp);

        assertNotEquals(hash1, hash2, "Different transaction IDs should produce different hashes");
    }

    @Test
    void generateTransactionHash_shouldHandleNullTransactionId() {
        String hash = TransactionHashUtil.generateTransactionHash(null, new BigDecimal("1000.00"), 1L, 1L, LocalDateTime.now());
        assertNotNull(hash);
    }

    @Test
    void verifyTransactionHash_shouldReturnTrue_forCorrectHash() {
        Long transactionId = 1L;
        BigDecimal montant = new BigDecimal("5000.00");
        Long contribuableId = 10L;
        Long agentId = 5L;
        LocalDateTime timestamp = LocalDateTime.of(2026, 7, 27, 10, 30, 0);

        String hash = TransactionHashUtil.generateTransactionHash(transactionId, montant, contribuableId, agentId, timestamp);
        TransactionHashUtil.TransactionData data = new TransactionHashUtil.TransactionData(transactionId, montant, contribuableId, agentId, timestamp);

        assertTrue(TransactionHashUtil.verifyTransactionHash(hash, data));
    }

    @Test
    void verifyTransactionHash_shouldReturnFalse_forIncorrectHash() {
        TransactionHashUtil.TransactionData data = new TransactionHashUtil.TransactionData(1L, new BigDecimal("5000.00"), 10L, 5L, LocalDateTime.now());
        assertFalse(TransactionHashUtil.verifyTransactionHash("WRONG_HASH", data));
    }

    @Test
    void generateTransactionHash_shouldHandleBigDecimalPrecision() {
        BigDecimal montant1 = new BigDecimal("5000.00");
        BigDecimal montant2 = new BigDecimal("5000.0");

        LocalDateTime timestamp = LocalDateTime.now();
        String hash1 = TransactionHashUtil.generateTransactionHash(1L, montant1, 10L, 5L, timestamp);
        String hash2 = TransactionHashUtil.generateTransactionHash(1L, montant2, 10L, 5L, timestamp);

        assertNotEquals(hash1, hash2, "Different BigDecimal scales should produce different hashes (toPlainString preserves scale)");
    }
}
