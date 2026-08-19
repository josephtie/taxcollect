package com.nectuxingenieries.collect.tax.utils;

import java.math.BigDecimal;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class TransactionHashUtil {

    private static final DateTimeFormatter TIMESTAMP_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS");

    public static String generateTransactionHash(Long transactionId, BigDecimal montant, Long contribuableId, Long agentId, LocalDateTime timestamp) {
        try {
            String dataToHash = String.format("%d-%s-%d-%d-%s", 
                transactionId, montant.toPlainString(), contribuableId, agentId, timestamp.format(TIMESTAMP_FORMAT));
            
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(dataToHash.getBytes());
            
            return bytesToHex(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Erreur lors de la génération du hash de transaction", e);
        }
    }

    public static String generateTransactionHash(TransactionData data) {
        return generateTransactionHash(data.transactionId(), data.montant(), data.contribuableId(), data.agentId(), data.timestamp());
    }

    public static boolean verifyTransactionHash(String originalHash, TransactionData data) {
        String computedHash = generateTransactionHash(data);
        return originalHash.equals(computedHash);
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder hexString = new StringBuilder();
        for (byte b : bytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString().toUpperCase();
    }

    public record TransactionData(Long transactionId, BigDecimal montant, Long contribuableId, Long agentId, LocalDateTime timestamp) {}
}
