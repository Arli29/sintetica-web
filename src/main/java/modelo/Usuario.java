package modelo;

import util.PasswordHasher;
import java.sql.*;
import java.time.LocalDateTime;

public class Usuario {
    private int idUsuario;
    private String nombre;
    private String apellido;
    private String email;
    private String telefono;
    private String contrasena;
    private String fotoUrl;
    private LocalDateTime fechaRegistro;
    private boolean activo;
    
    public Usuario() {}
    
    public Usuario(String nombre, String apellido, String email, String telefono, String contrasena) {
        this.nombre = nombre;
        this.apellido = apellido;
        this.email = email;
        this.telefono = telefono;
        this.contrasena = PasswordHasher.hashPassword(contrasena);
        this.fechaRegistro = LocalDateTime.now();
        this.activo = true;
    }
    
    // Getters y Setters
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    
    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }
    
    public String getFotoUrl() { return fotoUrl; }
    public void setFotoUrl(String fotoUrl) { this.fotoUrl = fotoUrl; }
    
    public LocalDateTime getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(LocalDateTime fechaRegistro) { this.fechaRegistro = fechaRegistro; }
    
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
    
    public boolean registrar(boolean aceptarTerminos, boolean comunicacionesProm) {
        Connection conn = null;
        PreparedStatement pstmtUsuario = null;
        PreparedStatement pstmtPreferencias = null;
        
        try {
            System.out.println("🔍 INICIANDO REGISTRO EN MYSQL...");
            conn = Conexion.getConexion();
            System.out.println("✅ Conexión a MySQL establecida");
            
            String sqlUsuario = "INSERT INTO usuarios (nombre, apellido, email, telefono, contrasena, fecha_registro, activo) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmtUsuario = conn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS);
            
            pstmtUsuario.setString(1, this.nombre);
            pstmtUsuario.setString(2, this.apellido);
            pstmtUsuario.setString(3, this.email);
            pstmtUsuario.setString(4, this.telefono);
            pstmtUsuario.setString(5, this.contrasena);
            pstmtUsuario.setTimestamp(6, Timestamp.valueOf(this.fechaRegistro));
            pstmtUsuario.setBoolean(7, this.activo);
            
            System.out.println("📝 Ejecutando INSERT en usuarios...");
            int affectedRows = pstmtUsuario.executeUpdate();
            System.out.println("✅ Filas afectadas: " + affectedRows);
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmtUsuario.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        this.idUsuario = generatedKeys.getInt(1);
                        System.out.println("✅ ID generado: " + this.idUsuario);
                        
                        String sqlPreferencias = "INSERT INTO usuarios_preferencias (id_usuario, aceptar_terminos, comunicaciones_prom) VALUES (?, ?, ?)";
                        pstmtPreferencias = conn.prepareStatement(sqlPreferencias);
                        
                        pstmtPreferencias.setInt(1, this.idUsuario);
                        pstmtPreferencias.setBoolean(2, aceptarTerminos);
                        pstmtPreferencias.setBoolean(3, comunicacionesProm);
                        
                        System.out.println("📝 Ejecutando INSERT en preferencias...");
                        pstmtPreferencias.executeUpdate();
                        System.out.println("✅ Registro COMPLETADO exitosamente");
                        return true;
                    }
                }
            }
            
            System.out.println("❌ No se generó ID del usuario");
            return false;
            
        } catch (Exception e) {
            System.out.println("❌ ERROR en registro MySQL: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmtUsuario != null) pstmtUsuario.close();
                if (pstmtPreferencias != null) pstmtPreferencias.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                System.out.println("❌ Error cerrando conexiones: " + e.getMessage());
            }
        }
    }
    
    public static Usuario validarLogin(String email, String contrasena) {
        String sql = "SELECT * FROM usuarios WHERE email = ? AND activo = true";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String contrasenaHash = rs.getString("contrasena");
                
                if (PasswordHasher.verifyPassword(contrasena, contrasenaHash)) {
                    Usuario usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("id_usuario"));
                    usuario.setNombre(rs.getString("nombre"));
                    usuario.setApellido(rs.getString("apellido"));
                    usuario.setEmail(rs.getString("email"));
                    usuario.setTelefono(rs.getString("telefono"));
                    usuario.setContrasena(contrasenaHash);
                    usuario.setFotoUrl(rs.getString("foto_url"));
                    usuario.setFechaRegistro(rs.getTimestamp("fecha_registro").toLocalDateTime());
                    usuario.setActivo(rs.getBoolean("activo"));
                    return usuario;
                }
            }
            
        } catch (Exception e) {
            System.out.println(" ERROR en validarLogin: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    public static boolean existeEmail(String email) {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE email = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (Exception e) {
            System.out.println("ERROR en existeEmail: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // MÉTODOS NUEVOS PARA EL PERFIL
    
    public static boolean actualizarPerfil(int idUsuario, String nombre, String apellido, String email, String telefono) {
        String sql = "UPDATE usuarios SET nombre = ?, apellido = ?, email = ?, telefono = ? WHERE id_usuario = ? AND activo = true";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, nombre);
            pstmt.setString(2, apellido);
            pstmt.setString(3, email);
            pstmt.setString(4, telefono);
            pstmt.setInt(5, idUsuario);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (Exception e) {
            System.out.println("❌ ERROR en actualizarPerfil: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public static boolean cambiarContrasena(int idUsuario, String nuevaContrasenaHash) {
        String sql = "UPDATE usuarios SET contrasena = ? WHERE id_usuario = ? AND activo = true";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, nuevaContrasenaHash);
            pstmt.setInt(2, idUsuario);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (Exception e) {
            System.out.println("❌ ERROR en cambiarContrasena: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public static boolean eliminarCuenta(int idUsuario) {
        String sql = "UPDATE usuarios SET activo = false WHERE id_usuario = ?";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idUsuario);
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (Exception e) {
            System.out.println("❌ ERROR en eliminarCuenta: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public static boolean verificarContrasenaActual(int idUsuario, String contrasenaActual) {
        String sql = "SELECT contrasena FROM usuarios WHERE id_usuario = ? AND activo = true";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idUsuario);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String contrasenaHash = rs.getString("contrasena");
                return PasswordHasher.verifyPassword(contrasenaActual, contrasenaHash);
            }
            
        } catch (Exception e) {
            System.out.println("❌ ERROR en verificarContrasenaActual: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    public static boolean actualizarAvatar(int idUsuario, String avatarPath) {
        String sql = "UPDATE usuarios SET foto_url = ? WHERE id_usuario = ? AND activo = true";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, avatarPath);
            pstmt.setInt(2, idUsuario);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (Exception e) {
            System.out.println("❌ ERROR en actualizarAvatar: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    public static Usuario obtenerPorId(int idUsuario) {
        String sql = "SELECT * FROM usuarios WHERE id_usuario = ? AND activo = true";
        
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idUsuario);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNombre(rs.getString("nombre"));
                usuario.setApellido(rs.getString("apellido"));
                usuario.setEmail(rs.getString("email"));
                usuario.setTelefono(rs.getString("telefono"));
                usuario.setContrasena(rs.getString("contrasena"));
                usuario.setFotoUrl(rs.getString("foto_url"));
                usuario.setFechaRegistro(rs.getTimestamp("fecha_registro").toLocalDateTime());
                usuario.setActivo(rs.getBoolean("activo"));
                return usuario;
            }
            
        } catch (Exception e) {
            System.out.println("❌ ERROR en obtenerPorId: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public static Usuario obtenerPorEmail(String email) {
        String sql = "SELECT * FROM usuarios WHERE email = ? AND activo = true";
        try (Connection conn = Conexion.getConexion(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            System.out.println("❌ ERROR obtenerPorEmail: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

// Buscar por sub_google
    public static Usuario obtenerPorSubGoogle(String sub) {
        String sql = "SELECT * FROM usuarios WHERE sub_google = ? AND activo = true";
        try (Connection conn = Conexion.getConexion(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sub);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (Exception e) {
            System.out.println("❌ ERROR obtenerPorSubGoogle: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

// Registrar usuario desde Google
    public static Usuario registrarDesdeGoogle(String nombre, String apellido, String email,
            String fotoUrl, String subGoogle, String dummyPasswordPlain) {
        Connection conn = null;
        PreparedStatement pstmtUsuario = null;
        PreparedStatement pstmtPref = null;
        try {
            conn = Conexion.getConexion();

            String sql = "INSERT INTO usuarios "
                    + "(nombre, apellido, email, telefono, contrasena, foto_url, fecha_registro, activo, proveedor, sub_google) "
                    + "VALUES (?, ?, ?, ?, ?, ?, NOW(), 1, 'google', ?)";
            pstmtUsuario = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            String contrasenaHash = PasswordHasher.hashPassword(dummyPasswordPlain);

            pstmtUsuario.setString(1, nombre);
            pstmtUsuario.setString(2, apellido);
            pstmtUsuario.setString(3, email);
            pstmtUsuario.setString(4, null);
            pstmtUsuario.setString(5, contrasenaHash);
            pstmtUsuario.setString(6, fotoUrl);
            pstmtUsuario.setString(7, subGoogle);

            int affected = pstmtUsuario.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = pstmtUsuario.getGeneratedKeys()) {
                    if (keys.next()) {
                        int idUser = keys.getInt(1);

                        // Preferencias por defecto (como haces en registrar)
                        String sqlPref = "INSERT INTO usuarios_preferencias (id_usuario, aceptar_terminos, comunicaciones_prom) VALUES (?, 1, 1)";
                        pstmtPref = conn.prepareStatement(sqlPref);
                        pstmtPref.setInt(1, idUser);
                        pstmtPref.executeUpdate();

                        return obtenerPorId(idUser);
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("❌ ERROR registrarDesdeGoogle: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (pstmtPref != null) {
                    pstmtPref.close();
                }
            } catch (Exception ignore) {
            }
            try {
                if (pstmtUsuario != null) {
                    pstmtUsuario.close();
                }
            } catch (Exception ignore) {
            }
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ignore) {
            }
        }
        return null;
    }

// Enlazar cuenta local existente a Google o refrescar foto
    public static boolean sincronizarGoogle(int idUsuario, String subGoogle, String fotoUrl) {
        String sql = "UPDATE usuarios SET proveedor='google', sub_google=?, foto_url=COALESCE(?, foto_url) "
                + "WHERE id_usuario=? AND activo=true";
        try (Connection conn = Conexion.getConexion(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subGoogle);
            ps.setString(2, fotoUrl);
            ps.setInt(3, idUsuario);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("❌ ERROR sincronizarGoogle: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

// Mapeo común (coincide con tu patrón)
    private static Usuario mapRow(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setIdUsuario(rs.getInt("id_usuario"));
        u.setNombre(rs.getString("nombre"));
        u.setApellido(rs.getString("apellido"));
        u.setEmail(rs.getString("email"));
        u.setTelefono(rs.getString("telefono"));
        u.setContrasena(rs.getString("contrasena"));
        u.setFotoUrl(rs.getString("foto_url"));
        u.setFechaRegistro(rs.getTimestamp("fecha_registro").toLocalDateTime());
        u.setActivo(rs.getBoolean("activo"));
        return u;
    }
}
