
package modelo;

import config.DatabaseConfig;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {
    private static Connection conexion = null;
    
    public static Connection getConexion() throws SQLException, ClassNotFoundException {
        if (conexion == null || conexion.isClosed()) {
            Class.forName(DatabaseConfig.DRIVER);
            conexion = DriverManager.getConnection(
                DatabaseConfig.getConnectionUrl(),
                DatabaseConfig.USUARIO,
                DatabaseConfig.CONTRASENA
            );
        }
        return conexion;
    }
    
    public static void cerrarConexion() throws SQLException {
        if (conexion != null && !conexion.isClosed()) {
            conexion.close();
        }
    }
}
