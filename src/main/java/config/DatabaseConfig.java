
package config;

public class DatabaseConfig {
    // CONFIGURACIÓN MYSQL
    public static final String HOST = "localhost";
    public static final String PUERTO = "3306";
    public static final String BASE_DE_DATOS = "sintetica";
    public static final String USUARIO = "root";
    public static final String CONTRASENA = "";  // Por defecto en XAMPP está vacía
    public static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    public static String getConnectionUrl() {
        return String.format(
            "jdbc:mysql://%s:%s/%s?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC", 
            HOST, PUERTO, BASE_DE_DATOS
        );
    }
}
