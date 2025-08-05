package com.nectuxingenieries.collect.tax.security;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordEncoder {

    public static String encodeSSHA(String password) {
        try {
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[4]; // généralement 4 à 8 octets
            random.nextBytes(salt);

            MessageDigest sha1 = MessageDigest.getInstance("SHA-1");
            sha1.update(password.getBytes());
            sha1.update(salt);

            byte[] digest = sha1.digest();
            byte[] digestAndSalt = new byte[digest.length + salt.length];
            System.arraycopy(digest, 0, digestAndSalt, 0, digest.length);
            System.arraycopy(salt, 0, digestAndSalt, digest.length, salt.length);

            return "{SSHA}" + Base64.getEncoder().encodeToString(digestAndSalt);
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors du hachage SSHA du mot de passe", e);
        }
    }
}
