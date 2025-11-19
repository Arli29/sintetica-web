
package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordHasher {
    
    public static String hashPassword(String password) {
        try {
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);
            
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] hashedPassword = md.digest(password.getBytes());
            
            byte[] combined = new byte[salt.length + hashedPassword.length];
            System.arraycopy(salt, 0, combined, 0, salt.length);
            System.arraycopy(hashedPassword, 0, combined, salt.length, hashedPassword.length);
            
            return Base64.getEncoder().encodeToString(combined);
            
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error al hashear la contraseña", e);
        }
    }
    
    public static boolean verifyPassword(String password, String hashedPassword) {
        try {
            byte[] combined = Base64.getDecoder().decode(hashedPassword);
            byte[] salt = new byte[16];
            byte[] storedHash = new byte[combined.length - 16];
            
            System.arraycopy(combined, 0, salt, 0, 16);
            System.arraycopy(combined, 16, storedHash, 0, storedHash.length);
            
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt);
            byte[] computedHash = md.digest(password.getBytes());
            
            return MessageDigest.isEqual(storedHash, computedHash);
            
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error al verificar la contraseña", e);
        }
    }
}
