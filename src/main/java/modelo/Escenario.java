package modelo;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class Escenario {
    private int idEscenario;
    private int idPropietario;
    private String nombre;
    private String descripcion;
    private String direccion;
    private int idBarrio;
    private int idSuperficie;
    private int idDeporte;
    private double precioPorHora;
    private int idEstado;
    private Double latitud;
    private Double longitud;
    private Timestamp fechaRegistro;
    
    // Campos para joins
    private String nombreBarrio;
    private String nombreDeporte;
    private String nombrePropietario;
    private String nombreSuperficie;
    private List<String> servicios;
    private List<String> imagenes;

    public Escenario() {
        this.servicios = new ArrayList<>();
        this.imagenes = new ArrayList<>();
    }

    // Getters y Setters
    public int getIdEscenario() { return idEscenario; }
    public void setIdEscenario(int idEscenario) { this.idEscenario = idEscenario; }

    public int getIdPropietario() { return idPropietario; }
    public void setIdPropietario(int idPropietario) { this.idPropietario = idPropietario; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public int getIdBarrio() { return idBarrio; }
    public void setIdBarrio(int idBarrio) { this.idBarrio = idBarrio; }

    public int getIdSuperficie() { return idSuperficie; }
    public void setIdSuperficie(int idSuperficie) { this.idSuperficie = idSuperficie; }

    public int getIdDeporte() { return idDeporte; }
    public void setIdDeporte(int idDeporte) { this.idDeporte = idDeporte; }

    public double getPrecioPorHora() { return precioPorHora; }
    public void setPrecioPorHora(double precioPorHora) { this.precioPorHora = precioPorHora; }

    public int getIdEstado() { return idEstado; }
    public void setIdEstado(int idEstado) { this.idEstado = idEstado; }

    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }

    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }

    public Timestamp getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Timestamp fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public String getNombreBarrio() { return nombreBarrio; }
    public void setNombreBarrio(String nombreBarrio) { this.nombreBarrio = nombreBarrio; }

    public String getNombreDeporte() { return nombreDeporte; }
    public void setNombreDeporte(String nombreDeporte) { this.nombreDeporte = nombreDeporte; }

    public String getNombrePropietario() { return nombrePropietario; }
    public void setNombrePropietario(String nombrePropietario) { this.nombrePropietario = nombrePropietario; }

    public String getNombreSuperficie() { return nombreSuperficie; }
    public void setNombreSuperficie(String nombreSuperficie) { this.nombreSuperficie = nombreSuperficie; }

    public List<String> getServicios() { return servicios; }
    public void setServicios(List<String> servicios) { this.servicios = servicios; }
    public void addServicio(String servicio) { this.servicios.add(servicio); }

    public List<String> getImagenes() { return imagenes; }
    public void setImagenes(List<String> imagenes) { this.imagenes = imagenes; }
    public void addImagen(String imagen) { this.imagenes.add(imagen); }

    // Métodos CRUD
    public static boolean crearEscenario(Escenario escenario, List<Integer> servicios) {
        String sql = "INSERT INTO escenario (id_propietario, nombre, descripcion, direccion, id_barrio, " +
                    "id_superficie, id_deporte, precio_por_hora, id_estado, latitud, longitud) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet generatedKeys = null;
        
        try {
            conn = Conexion.getConexion();
            // CORREGIDO: Usar Statement.RETURN_GENERATED_KEYS correctamente
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            pstmt.setInt(1, escenario.getIdPropietario());
            pstmt.setString(2, escenario.getNombre());
            pstmt.setString(3, escenario.getDescripcion() != null ? escenario.getDescripcion() : "");
            pstmt.setString(4, escenario.getDireccion());
            pstmt.setInt(5, escenario.getIdBarrio());
            pstmt.setInt(6, escenario.getIdSuperficie());
            pstmt.setInt(7, escenario.getIdDeporte());
            pstmt.setDouble(8, escenario.getPrecioPorHora());
            pstmt.setDouble(9, escenario.getLatitud() != null ? escenario.getLatitud() : 0.0);
            pstmt.setDouble(10, escenario.getLongitud() != null ? escenario.getLongitud() : 0.0);
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int idEscenario = generatedKeys.getInt(1);
                    
                    // Insertar servicios
                    if (servicios != null && !servicios.isEmpty()) {
                        boolean serviciosInsertados = insertarServicios(conn, idEscenario, servicios);
                        if (!serviciosInsertados) {
                            System.out.println("⚠️ Advertencia: No se pudieron insertar algunos servicios");
                        }
                    }
                    
                    return true;
                }
            }
        } catch (Exception e) {
            System.out.println("❌ Error al crear escenario: " + e.getMessage());
            e.printStackTrace();
        } finally {
            // Cerrar todos los recursos incluyendo el ResultSet
            try {
                if (generatedKeys != null) generatedKeys.close();
            } catch (SQLException e) {
                System.out.println("Error al cerrar generatedKeys: " + e.getMessage());
            }
            cerrarRecursos(conn, pstmt, null);
        }
        return false;
    }

    private static boolean insertarServicios(Connection conn, int idEscenario, List<Integer> servicios) {
        String sqlServicios = "INSERT INTO escenario_servicio (id_escenario, id_servicio) VALUES (?, ?)";
        PreparedStatement pstmtServicios = null;
        try {
            pstmtServicios = conn.prepareStatement(sqlServicios);
            for (int idServicio : servicios) {
                pstmtServicios.setInt(1, idEscenario);
                pstmtServicios.setInt(2, idServicio);
                pstmtServicios.addBatch();
            }
            pstmtServicios.executeBatch();
            return true;
        } catch (Exception e) {
            System.out.println("❌ Error al insertar servicios: " + e.getMessage());
            return false;
        } finally {
            if (pstmtServicios != null) {
                try {
                    pstmtServicios.close();
                } catch (SQLException e) {
                    System.out.println("Error al cerrar pstmtServicios: " + e.getMessage());
                }
            }
        }
    }

    // NUEVO MÉTODO: Obtener TODOS los escenarios activos (no solo destacados)
    public static List<Escenario> obtenerTodosLosEscenarios() {
        List<Escenario> escenarios = new ArrayList<>();
        String sql = "SELECT e.*, b.nombre as nombre_barrio, d.nombre as nombre_deporte, " +
                    "s.nombre as nombre_superficie, u.nombre as nombre_propietario " +
                    "FROM escenario e " +
                    "LEFT JOIN barrio b ON e.id_barrio = b.id_barrio " +
                    "LEFT JOIN tipo_deporte d ON e.id_deporte = d.id_deporte " +
                    "LEFT JOIN tipo_superficie s ON e.id_superficie = s.id_superficie " +
                    "LEFT JOIN usuarios u ON e.id_propietario = u.id_usuario " +
                    "WHERE e.id_estado = 1 " + // Solo escenarios activos
                    "ORDER BY e.fecha_registro DESC"; // Ordenados por los más recientes primero
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConexion();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Escenario escenario = mapearEscenario(rs);
                escenario.setServicios(obtenerServiciosEscenario(conn, escenario.getIdEscenario()));
                escenario.setImagenes(obtenerImagenesEscenario(conn, escenario.getIdEscenario()));
                escenarios.add(escenario);
            }
        } catch (Exception e) {
            System.out.println("Error al obtener todos los escenarios: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(conn, pstmt, rs);
        }
        return escenarios;
    }

    // Método original modificado para obtener solo algunos destacados (opcional)
    public static List<Escenario> obtenerEscenariosDestacados() {
        List<Escenario> escenarios = new ArrayList<>();
        String sql = "SELECT e.*, b.nombre as nombre_barrio, d.nombre as nombre_deporte, " +
                    "s.nombre as nombre_superficie, u.nombre as nombre_propietario " +
                    "FROM escenario e " +
                    "LEFT JOIN barrio b ON e.id_barrio = b.id_barrio " +
                    "LEFT JOIN tipo_deporte d ON e.id_deporte = d.id_deporte " +
                    "LEFT JOIN tipo_superficie s ON e.id_superficie = s.id_superficie " +
                    "LEFT JOIN usuarios u ON e.id_propietario = u.id_usuario " +
                    "WHERE e.id_estado = 1 " + // Solo escenarios activos
                    "ORDER BY e.fecha_registro DESC LIMIT 12"; // Los 12 más recientes
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConexion();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Escenario escenario = mapearEscenario(rs);
                escenario.setServicios(obtenerServiciosEscenario(conn, escenario.getIdEscenario()));
                escenario.setImagenes(obtenerImagenesEscenario(conn, escenario.getIdEscenario()));
                escenarios.add(escenario);
            }
        } catch (Exception e) {
            System.out.println("Error al obtener escenarios destacados: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(conn, pstmt, rs);
        }
        return escenarios;
    }

    public static List<Escenario> buscarEscenarios(String query, String deporte, String barrio) {
        List<Escenario> escenarios = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT e.*, b.nombre as nombre_barrio, d.nombre as nombre_deporte, " +
            "s.nombre as nombre_superficie, u.nombre as nombre_propietario " +
            "FROM escenario e " +
            "LEFT JOIN barrio b ON e.id_barrio = b.id_barrio " +
            "LEFT JOIN tipo_deporte d ON e.id_deporte = d.id_deporte " +
            "LEFT JOIN tipo_superficie s ON e.id_superficie = s.id_superficie " +
            "LEFT JOIN usuarios u ON e.id_propietario = u.id_usuario " +
            "WHERE e.id_estado = 1 "
        );
        
        List<Object> parametros = new ArrayList<>();
        
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (e.nombre LIKE ? OR e.descripcion LIKE ? OR b.nombre LIKE ?) ");
            parametros.add("%" + query + "%");
            parametros.add("%" + query + "%");
            parametros.add("%" + query + "%");
        }
        
        if (deporte != null && !deporte.trim().isEmpty()) {
            sql.append("AND d.nombre = ? ");
            parametros.add(deporte);
        }
        
        if (barrio != null && !barrio.trim().isEmpty()) {
            sql.append("AND b.nombre = ? ");
            parametros.add(barrio);
        }
        
        sql.append("ORDER BY e.fecha_registro DESC");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConexion();
            pstmt = conn.prepareStatement(sql.toString());
            
            for (int i = 0; i < parametros.size(); i++) {
                pstmt.setObject(i + 1, parametros.get(i));
            }
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Escenario escenario = mapearEscenario(rs);
                escenario.setServicios(obtenerServiciosEscenario(conn, escenario.getIdEscenario()));
                escenario.setImagenes(obtenerImagenesEscenario(conn, escenario.getIdEscenario()));
                escenarios.add(escenario);
            }
        } catch (Exception e) {
            System.out.println("Error al buscar escenarios: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(conn, pstmt, rs);
        }
        return escenarios;
    }

    public static Escenario obtenerPorId(int idEscenario) {
        String sql = "SELECT e.*, b.nombre as nombre_barrio, d.nombre as nombre_deporte, " +
                    "s.nombre as nombre_superficie, u.nombre as nombre_propietario " +
                    "FROM escenario e " +
                    "LEFT JOIN barrio b ON e.id_barrio = b.id_barrio " +
                    "LEFT JOIN tipo_deporte d ON e.id_deporte = d.id_deporte " +
                    "LEFT JOIN tipo_superficie s ON e.id_superficie = s.id_superficie " +
                    "LEFT JOIN usuarios u ON e.id_propietario = u.id_usuario " +
                    "WHERE e.id_escenario = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConexion();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idEscenario);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Escenario escenario = mapearEscenario(rs);
                escenario.setServicios(obtenerServiciosEscenario(conn, idEscenario));
                escenario.setImagenes(obtenerImagenesEscenario(conn, idEscenario));
                return escenario;
            }
        } catch (Exception e) {
            System.out.println("Error al obtener escenario por ID: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(conn, pstmt, rs);
        }
        return null;
    }

    public static boolean actualizarEscenario(Escenario escenario, List<Integer> servicios) {
        String sql = "UPDATE escenario SET nombre = ?, descripcion = ?, direccion = ?, " +
                    "id_barrio = ?, id_superficie = ?, id_deporte = ?, precio_por_hora = ?, " +
                    "latitud = ?, longitud = ? WHERE id_escenario = ? AND id_propietario = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = Conexion.getConexion();
            conn.setAutoCommit(false);
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, escenario.getNombre());
            pstmt.setString(2, escenario.getDescripcion());
            pstmt.setString(3, escenario.getDireccion());
            pstmt.setInt(4, escenario.getIdBarrio());
            pstmt.setInt(5, escenario.getIdSuperficie());
            pstmt.setInt(6, escenario.getIdDeporte());
            pstmt.setDouble(7, escenario.getPrecioPorHora());
            pstmt.setDouble(8, escenario.getLatitud());
            pstmt.setDouble(9, escenario.getLongitud());
            pstmt.setInt(10, escenario.getIdEscenario());
            pstmt.setInt(11, escenario.getIdPropietario());
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                // Actualizar servicios
                actualizarServicios(conn, escenario.getIdEscenario(), servicios);
                conn.commit();
                return true;
            } else {
                conn.rollback();
            }
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                System.out.println("Error al hacer rollback: " + ex.getMessage());
            }
            System.out.println("Error al actualizar escenario: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.out.println("Error al restaurar auto-commit: " + e.getMessage());
            }
            cerrarRecursos(conn, pstmt, null);
        }
        return false;
    }

    private static void actualizarServicios(Connection conn, int idEscenario, List<Integer> servicios) throws SQLException {
        // Eliminar servicios existentes
        String sqlDelete = "DELETE FROM escenario_servicio WHERE id_escenario = ?";
        PreparedStatement pstmtDelete = null;
        try {
            pstmtDelete = conn.prepareStatement(sqlDelete);
            pstmtDelete.setInt(1, idEscenario);
            pstmtDelete.executeUpdate();
        } finally {
            if (pstmtDelete != null) pstmtDelete.close();
        }
        
        // Insertar nuevos servicios
        if (servicios != null && !servicios.isEmpty()) {
            insertarServicios(conn, idEscenario, servicios);
        }
    }

    public static boolean eliminarEscenario(int idEscenario, int idPropietario) {
    String sql = "UPDATE escenario SET id_estado = 2 WHERE id_escenario = ? AND id_propietario = ?";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = Conexion.getConexion();
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, idEscenario);
        pstmt.setInt(2, idPropietario);

        int affectedRows = pstmt.executeUpdate();
        return affectedRows > 0;

    } catch (Exception e) {
        System.out.println("Error al eliminar escenario: " + e.getMessage());
        e.printStackTrace();
    } finally {
        cerrarRecursos(conn, pstmt, null);
    }
    return false;
}


   public static List<Escenario> obtenerEscenariosPorPropietario(int idPropietario) {
    List<Escenario> escenarios = new ArrayList<>();

    String sql =
        "SELECT e.*, " +
        "       b.nombre AS nombre_barrio, " +
        "       d.nombre AS nombre_deporte, " +
        "       s.nombre AS nombre_superficie, " +
        "       CONCAT(u.nombre, ' ', u.apellido) AS nombre_propietario " +
        "FROM escenario e " +
        "LEFT JOIN barrio b          ON e.id_barrio      = b.id_barrio " +
        "LEFT JOIN tipo_deporte d    ON e.id_deporte     = d.id_deporte " +
        "LEFT JOIN tipo_superficie s ON e.id_superficie  = s.id_superficie " +
        "LEFT JOIN usuarios u        ON e.id_propietario = u.id_usuario " +
        "WHERE e.id_propietario = ? AND e.id_estado = 1 " +   // ← SOLO ACTIVOS
        "ORDER BY e.fecha_registro DESC";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = Conexion.getConexion();
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, idPropietario);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Escenario escenario = mapearEscenario(rs);
            escenario.setServicios(obtenerServiciosEscenario(conn, escenario.getIdEscenario()));
            escenario.setImagenes(obtenerImagenesEscenario(conn, escenario.getIdEscenario()));
            escenarios.add(escenario);
        }
    } catch (Exception e) {
        System.out.println("Error al obtener escenarios del propietario: " + e.getMessage());
        e.printStackTrace();
    } finally {
        cerrarRecursos(conn, pstmt, rs);
    }
    return escenarios;
}

    private static Escenario mapearEscenario(ResultSet rs) throws SQLException {
        Escenario escenario = new Escenario();
        escenario.setIdEscenario(rs.getInt("id_escenario"));
        escenario.setIdPropietario(rs.getInt("id_propietario"));
        escenario.setNombre(rs.getString("nombre"));
        escenario.setDescripcion(rs.getString("descripcion"));
        escenario.setDireccion(rs.getString("direccion"));
        escenario.setIdBarrio(rs.getInt("id_barrio"));
        escenario.setIdSuperficie(rs.getInt("id_superficie"));
        escenario.setIdDeporte(rs.getInt("id_deporte"));
        escenario.setPrecioPorHora(rs.getDouble("precio_por_hora"));
        escenario.setIdEstado(rs.getInt("id_estado"));
        
        // Manejar valores nulos para latitud y longitud
        double lat = rs.getDouble("latitud");
        double lng = rs.getDouble("longitud");
        if (!rs.wasNull()) {
            escenario.setLatitud(lat);
            escenario.setLongitud(lng);
        }
        
        escenario.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        escenario.setNombreBarrio(rs.getString("nombre_barrio"));
        escenario.setNombreDeporte(rs.getString("nombre_deporte"));
        escenario.setNombreSuperficie(rs.getString("nombre_superficie"));
        escenario.setNombrePropietario(rs.getString("nombre_propietario"));
        return escenario;
    }

    private static List<String> obtenerServiciosEscenario(Connection conn, int idEscenario) throws SQLException {
        List<String> servicios = new ArrayList<>();
        String sql = "SELECT s.nombre FROM escenario_servicio es " +
                    "JOIN servicio s ON es.id_servicio = s.id_servicio " +
                    "WHERE es.id_escenario = ?";
        
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idEscenario);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                servicios.add(rs.getString("nombre"));
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }
        return servicios;
    }

    private static List<String> obtenerImagenesEscenario(Connection conn, int idEscenario) throws SQLException {
        List<String> imagenes = new ArrayList<>();
        String sql = "SELECT url FROM escenario_imagen WHERE id_escenario = ? ORDER BY orden";
        
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idEscenario);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                imagenes.add(rs.getString("url"));
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }
        return imagenes;
    }

    private static void cerrarRecursos(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar recursos: " + e.getMessage());
        }
    }
    
   
}
