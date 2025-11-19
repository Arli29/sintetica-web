package controlador;

import modelo.Escenario;
import modelo.Conexion;
import modelo.Usuario;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.sql.*;

@WebServlet(name = "ControladorEscenarios", urlPatterns = {
    "/escenarios", "/escenario-detalle", "/crear-escenario", "/editar-escenario",
    "/eliminar-escenario", "/mis-escenarios"
})
@MultipartConfig(
    maxFileSize = 5 * 1024 * 1024,      // 5MB por archivo
    maxRequestSize = 25 * 1024 * 1024,  // 25MB por request
    fileSizeThreshold = 1024 * 1024     // 1MB en memoria antes de disco temp
)
public class ControladorEscenarios extends HttpServlet {

    // Prefijos web para mostrar
    private static final String PUBLIC_UPLOADS_PREFIX = "uploads/escenarios";
    private static final String PUBLIC_ASSETS_PREFIX  = "assets/img/escenarios";

    // Inputs válidos para imágenes
    private static final Set<String> IMG_FIELD_NAMES = new HashSet<>(Arrays.asList("imagenes", "nuevas_imagenes"));

    private static final int MAX_IMGS = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");

        switch (path) {
            case "/escenarios":
                listarEscenarios(request, response);
                break;
            case "/escenario-detalle":
                verDetalleEscenario(request, response);
                break;
            case "/mis-escenarios":
                misEscenarios(request, response, usuario);
                break;
            case "/crear-escenario":
                mostrarFormularioCrear(request, response);
                break;
            case "/editar-escenario":
                mostrarFormularioEditar(request, response, usuario);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/escenarios");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");

        switch (path) {
            case "/crear-escenario":
                crearEscenario(request, response, usuario);
                break;
            case "/editar-escenario":
                editarEscenario(request, response, usuario);
                break;
            case "/eliminar-escenario":
                eliminarEscenario(request, response, usuario);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/escenarios");
                break;
        }
    }

    private void listarEscenarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("q");
        String deporte = request.getParameter("deporte");
        String barrio = request.getParameter("barrio");

        List<Escenario> escenarios;
        if ((query != null && !query.trim().isEmpty()) ||
            (deporte != null && !deporte.trim().isEmpty()) ||
            (barrio != null && !barrio.trim().isEmpty())) {
            escenarios = Escenario.buscarEscenarios(query, deporte, barrio);
        } else {
            escenarios = Escenario.obtenerTodosLosEscenarios(); // ideal: solo activos
        }

        request.setAttribute("escenarios", escenarios);
        request.setAttribute("query", query);
        request.setAttribute("deporteFiltro", deporte);
        request.setAttribute("barrioFiltro", barrio);

        RequestDispatcher dispatcher = request.getRequestDispatcher("vista/escenarios.jsp");
        dispatcher.forward(request, response);
    }

    private void verDetalleEscenario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/escenarios");
            return;
        }

        try {
            int idEscenario = Integer.parseInt(idParam);
            Escenario escenario = Escenario.obtenerPorId(idEscenario);
            if (escenario == null) {
                response.sendRedirect(request.getContextPath() + "/escenarios");
                return;
            }
            request.setAttribute("escenario", escenario);
            RequestDispatcher dispatcher = request.getRequestDispatcher("vista/detalle-escenario.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/escenarios");
        }
    }

    private void misEscenarios(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        List<Escenario> escenarios = Escenario.obtenerEscenariosPorPropietario(usuario.getIdUsuario());
        request.setAttribute("escenarios", escenarios);

        RequestDispatcher dispatcher = request.getRequestDispatcher("vista/mis-escenarios.jsp");
        dispatcher.forward(request, response);
    }

    private void mostrarFormularioCrear(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("vista/crear-escenario.jsp");
        if (dispatcher != null) {
            dispatcher.forward(request, response);
        } else {
            response.sendError(404, "Página no encontrada");
        }
    }

    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/mis-escenarios");
            return;
        }

        try {
            int idEscenario = Integer.parseInt(idParam);
            Escenario escenario = Escenario.obtenerPorId(idEscenario);
            if (escenario == null) {
                response.sendRedirect(request.getContextPath() + "/mis-escenarios?error=escenario_no_encontrado");
                return;
            }
            if (escenario.getIdPropietario() != usuario.getIdUsuario()) {
                request.setAttribute("error", "No tienes permisos para editar este escenario");
                RequestDispatcher dispatcher = request.getRequestDispatcher("vista/mis-escenarios.jsp");
                dispatcher.forward(request, response);
                return;
            }

            cargarDatosFormulario(request);
            request.setAttribute("escenario", escenario);
            RequestDispatcher dispatcher = request.getRequestDispatcher("vista/editar-escenario.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/mis-escenarios?error=id_invalido");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/mis-escenarios?error=error_interno");
        }
    }

    private void cargarDatosFormulario(HttpServletRequest request) {
        // Si necesitas combos/auxiliares, cárgalos aquí
    }

    private void crearEscenario(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        try {
            String nombre = request.getParameter("nombre");
            String direccion = request.getParameter("direccion");
            String idBarrioParam = request.getParameter("id_barrio");
            String idSuperficieParam = request.getParameter("id_superficie");
            String idDeporteParam = request.getParameter("id_deporte");
            String precioParam = request.getParameter("precio_por_hora");
            String latitudParam = request.getParameter("latitud");
            String longitudParam = request.getParameter("longitud");

            if (nombre == null || direccion == null || idBarrioParam == null ||
                idSuperficieParam == null || idDeporteParam == null || precioParam == null) {
                request.setAttribute("error", "Faltan campos obligatorios");
                mostrarFormularioCrear(request, response);
                return;
            }

            String descripcion = request.getParameter("descripcion");
            int idBarrio = Integer.parseInt(idBarrioParam);
            int idSuperficie = Integer.parseInt(idSuperficieParam);
            int idDeporte = Integer.parseInt(idDeporteParam);
            double precioPorHora = Double.parseDouble(precioParam);
            double latitud = (latitudParam != null && !latitudParam.isEmpty()) ? Double.parseDouble(latitudParam) : 0.0;
            double longitud = (longitudParam != null && !longitudParam.isEmpty()) ? Double.parseDouble(longitudParam) : 0.0;

            Escenario escenario = new Escenario();
            escenario.setIdPropietario(usuario.getIdUsuario());
            escenario.setNombre(nombre);
            escenario.setDescripcion(descripcion);
            escenario.setDireccion(direccion);
            escenario.setIdBarrio(idBarrio);
            escenario.setIdSuperficie(idSuperficie);
            escenario.setIdDeporte(idDeporte);
            escenario.setPrecioPorHora(precioPorHora);
            escenario.setLatitud(latitud);
            escenario.setLongitud(longitud);

            String[] serviciosArray = request.getParameterValues("servicios");
            List<Integer> servicios = new ArrayList<>();
            if (serviciosArray != null) {
                for (String servicio : serviciosArray) {
                    try { servicios.add(Integer.parseInt(servicio)); } catch (NumberFormatException ignore) {}
                }
            }

            boolean exito = Escenario.crearEscenario(escenario, servicios);
            if (exito) {
                int idEscenario = obtenerUltimoIdEscenario(usuario.getIdUsuario());
                if (idEscenario > 0) {
                    List<String> nuevas = procesarImagenesEscenario(request, idEscenario);
                    // Si subieron imágenes, pon la primera como portada (orden 0)
                    if (!nuevas.isEmpty()) {
                        try (Connection c = Conexion.getConexion()) {
                            setPortada(c, idEscenario, nuevas.get(0));
                        }
                    }
                    HttpSession session = request.getSession();
                    session.setAttribute("exitoCreacion", "¡Escenario creado exitosamente! Ya está disponible para reservas.");
                    response.sendRedirect(request.getContextPath() + "/inicio");
                    return;
                } else {
                    request.setAttribute("error", "Error al obtener el ID del escenario creado");
                }
            } else {
                request.setAttribute("error", "Error al crear el escenario en la base de datos");
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Error en el formato de los números");
        } catch (Exception e) {
            request.setAttribute("error", "Error en los datos del formulario");
        }

        mostrarFormularioCrear(request, response);
    }

    private int obtenerUltimoIdEscenario(int idPropietario) {
        String sql = "SELECT id_escenario FROM escenario WHERE id_propietario = ? ORDER BY fecha_registro DESC LIMIT 1";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idPropietario);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt("id_escenario");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /** Procesa imágenes subidas y retorna la lista de rutas web insertadas en BD. */
    private List<String> procesarImagenesEscenario(HttpServletRequest request, int idEscenario) {
        List<String> insertadas = new ArrayList<>();
        try {
            UploadTarget target = resolveUploadTarget(request, idEscenario);
            Collection<Part> parts = request.getParts();
            int imagenCount = 0;

            for (Part part : parts) {
                String fieldName = part.getName();
                if (!IMG_FIELD_NAMES.contains(fieldName)) continue;
                if (part.getSize() <= 0) continue;

                String contentType = part.getContentType();
                if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) continue;
                if (part.getSize() > 5L * 1024L * 1024L) continue; // 5MB

                String submitted = getSubmittedFileName(part);
                if (submitted == null || submitted.trim().isEmpty()) continue;

                String ext = contentTypeToExt(contentType, submitted);
                String fileName = "esc_" + idEscenario + "_" + System.currentTimeMillis() + "_" + imagenCount + "." + ext;

                Files.createDirectories(target.dir);
                try (InputStream in = part.getInputStream()) {
                    Files.copy(in, target.dir.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
                } catch (Exception copyEx) {
                    copyEx.printStackTrace();
                    continue;
                }

                String publicPath = (target.publicPrefix + "/" + fileName).replace("\\", "/");
                guardarImagenEnBD(idEscenario, publicPath, imagenCount);
                insertadas.add(publicPath);
                imagenCount++;

                if (imagenCount >= MAX_IMGS) break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return insertadas;
    }

    /** Dónde guardar físicamente + prefijo web a almacenar en BD. */
    private UploadTarget resolveUploadTarget(HttpServletRequest request, int idEscenario) {
        // Externo configurable: -DSINTETICA_UPLOADS_DIR=/ruta/absoluta
        String configuredBase = System.getProperty("SINTETICA_UPLOADS_DIR");
        if (configuredBase == null || configuredBase.trim().isEmpty()) {
            configuredBase = System.getProperty("user.home") + File.separator + "sintetica_uploads";
        }
        Path externalDir = Paths.get(configuredBase, "escenarios", String.valueOf(idEscenario));
        try {
            Files.createDirectories(externalDir);
            return new UploadTarget(externalDir, PUBLIC_UPLOADS_PREFIX + "/" + idEscenario);
        } catch (Exception ignored) {}

        // Fallback: assets internos del WAR
        String realRoot = request.getServletContext().getRealPath("/");
        Path internalDir = Paths.get(realRoot, "assets", "img", "escenarios", String.valueOf(idEscenario));
        return new UploadTarget(internalDir, PUBLIC_ASSETS_PREFIX + "/" + idEscenario);
    }

    private static class UploadTarget {
        Path dir;
        String publicPrefix;
        UploadTarget(Path dir, String publicPrefix) {
            this.dir = dir;
            this.publicPrefix = publicPrefix;
        }
    }

    private String getSubmittedFileName(Part part) {
        try {
            String cd = part.getHeader("content-disposition");
            if (cd == null) return null;
            for (String token : cd.split(";")) {
                token = token.trim();
                if (token.startsWith("filename")) {
                    String fileName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                    return Paths.get(fileName).getFileName().toString();
                }
            }
        } catch (Exception ignore) {}
        return null;
    }

    private String contentTypeToExt(String contentType, String fallbackName) {
        if (contentType == null) contentType = "";
        contentType = contentType.toLowerCase(Locale.ROOT);
        if (contentType.contains("jpeg") || contentType.contains("jpg")) return "jpg";
        if (contentType.contains("png"))  return "png";
        if (contentType.contains("gif"))  return "gif";
        if (contentType.contains("webp")) return "webp";
        String name = fallbackName.toLowerCase(Locale.ROOT);
        int i = name.lastIndexOf('.');
        if (i > -1 && i < name.length() - 1) return name.substring(i + 1);
        return "jpg";
    }

    private void guardarImagenEnBD(int idEscenario, String imagePath, int orden) {
        String sql = "INSERT INTO escenario_imagen (id_escenario, url, orden) VALUES (?, ?, ?)";
        try (Connection conn = Conexion.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idEscenario);
            pstmt.setString(2, imagePath);
            pstmt.setInt(3, orden);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void editarEscenario(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        try {
            Escenario escenario = new Escenario();
            escenario.setIdEscenario(Integer.parseInt(request.getParameter("id_escenario")));
            escenario.setIdPropietario(usuario.getIdUsuario());
            escenario.setNombre(request.getParameter("nombre"));
            escenario.setDescripcion(request.getParameter("descripcion"));
            escenario.setDireccion(request.getParameter("direccion"));
            escenario.setIdBarrio(Integer.parseInt(request.getParameter("id_barrio")));
            escenario.setIdSuperficie(Integer.parseInt(request.getParameter("id_superficie")));
            escenario.setIdDeporte(Integer.parseInt(request.getParameter("id_deporte")));
            escenario.setPrecioPorHora(Double.parseDouble(request.getParameter("precio_por_hora")));
            escenario.setLatitud(Double.parseDouble(request.getParameter("latitud")));
            escenario.setLongitud(Double.parseDouble(request.getParameter("longitud")));

            String[] serviciosArray = request.getParameterValues("servicios");
            List<Integer> servicios = new ArrayList<>();
            if (serviciosArray != null) {
                for (String servicio : serviciosArray) {
                    try { servicios.add(Integer.parseInt(servicio)); } catch (NumberFormatException ignore) {}
                }
            }

            boolean exito = Escenario.actualizarEscenario(escenario, servicios);

            // 1) ELIMINAR imágenes marcadas
            String eliminarCsv = request.getParameter("imagenes_eliminar"); // rutas web relativas, separadas por coma
            if (eliminarCsv != null && !eliminarCsv.trim().isEmpty()) {
                String[] rutas = eliminarCsv.split(",");
                for (String ruta : rutas) {
                    ruta = ruta.trim();
                    if (!ruta.isEmpty()) {
                        eliminarImagenFisicaYBD(request, escenario.getIdEscenario(), ruta);
                    }
                }
            }

            // 2) PROCESAR nuevas imágenes
            List<String> nuevas = Collections.emptyList();
            try {
                nuevas = procesarImagenesEscenario(request, escenario.getIdEscenario());
            } catch (Exception imgEx) {
                imgEx.printStackTrace();
            }

            // 3) PORTADA: usar nueva o mantener/poner existente
            String portadaExistente = request.getParameter("portada_existente");
            boolean usarNuevaComoPortada = "1".equals(request.getParameter("usar_como_portada"));

            try (Connection conn = Conexion.getConexion()) {
                if (usarNuevaComoPortada && !nuevas.isEmpty()) {
                    setPortada(conn, escenario.getIdEscenario(), normalizePublicPath(nuevas.get(0)));
                } else if (portadaExistente != null && !portadaExistente.trim().isEmpty()) {
                    setPortada(conn, escenario.getIdEscenario(), normalizePublicPath(portadaExistente));
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (exito) {
                request.getSession().setAttribute("mensajeExito", "Escenario actualizado exitosamente");
            } else {
                request.getSession().setAttribute("mensajeError", "Error al actualizar el escenario");
            }

        } catch (Exception e) {
            request.getSession().setAttribute("mensajeError", "Error en los datos del formulario");
        }

        response.sendRedirect(request.getContextPath() + "/mis-escenarios");
    }

    private void eliminarEscenario(HttpServletRequest request, HttpServletResponse response, Usuario usuario)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/mis-escenarios");
            return;
        }

        try {
            int idEscenario = Integer.parseInt(idParam);
            boolean exito = Escenario.eliminarEscenario(idEscenario, usuario.getIdUsuario());
            if (exito) {
                request.getSession().setAttribute("mensajeExito", "Escenario eliminado exitosamente.");
            } else {
                request.getSession().setAttribute("mensajeError", "No se pudo eliminar el escenario.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("mensajeError", "ID de escenario inválido.");
        }

        response.sendRedirect(request.getContextPath() + "/mis-escenarios");
    }

    /** Coloca la imagen indicada como portada (orden = 0). */
    private void setPortada(Connection conn, int idEscenario, String publicPathNorm) throws SQLException {
        // Lleva todas a orden alto
        try (PreparedStatement p1 = conn.prepareStatement(
                "UPDATE escenario_imagen SET orden = 999 WHERE id_escenario = ?")) {
            p1.setInt(1, idEscenario);
            p1.executeUpdate();
        }
        // Pone la elegida en 0. Tolera que en BD esté con o sin slash inicial
        try (PreparedStatement p2 = conn.prepareStatement(
                "UPDATE escenario_imagen SET orden = 0 WHERE id_escenario = ? AND (url = ? OR url = ?)")) {
            p2.setInt(1, idEscenario);
            p2.setString(2, publicPathNorm);
            p2.setString(3, publicPathNorm.startsWith("/") ? publicPathNorm.substring(1) : ("/" + publicPathNorm));
            p2.executeUpdate();
        }
    }

    /** Elimina físicamente y en BD una imagen del escenario. */
    private void eliminarImagenFisicaYBD(HttpServletRequest request, int idEscenario, String publicPath) {
        String norm = normalizePublicPath(publicPath);

        // 1) Eliminar BD
        try (Connection conn = Conexion.getConexion();
             PreparedStatement ps = conn.prepareStatement(
                     "DELETE FROM escenario_imagen WHERE id_escenario = ? AND (url = ? OR url = ?)")) {
            ps.setInt(1, idEscenario);
            ps.setString(2, norm);
            ps.setString(3, norm.startsWith("/") ? norm.substring(1) : ("/" + norm));
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2) Eliminar archivo físico
        try {
            Path filePath = resolveFilePathFromPublic(request, norm);
            if (filePath != null && Files.exists(filePath)) {
                Files.delete(filePath);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Normaliza una ruta pública (sin doble slash, sin backslashes). */
    private String normalizePublicPath(String p) {
        if (p == null) return "";
        p = p.replace("\\", "/").trim();
        if (p.startsWith("/")) p = p.substring(1);
        return p;
    }

    /** Resuelve ruta física (disco) a partir de la ruta pública guardada en BD. */
    private Path resolveFilePathFromPublic(HttpServletRequest request, String publicPath) {
        try {
            publicPath = normalizePublicPath(publicPath);
            // uploads externos
            if (publicPath.startsWith(PUBLIC_UPLOADS_PREFIX)) {
                // PUBLIC_UPLOADS_PREFIX/idEscenario/archivo
                String configuredBase = System.getProperty("SINTETICA_UPLOADS_DIR");
                if (configuredBase == null || configuredBase.trim().isEmpty()) {
                    configuredBase = System.getProperty("user.home") + File.separator + "sintetica_uploads";
                }
                // Reemplazar prefijo por base física
                String rest = publicPath.substring(PUBLIC_UPLOADS_PREFIX.length()); // e.g. /15/xxx.jpg
                return Paths.get(configuredBase, rest.replaceFirst("^/", ""));     // base/15/xxx.jpg
            }
            // assets internos
            if (publicPath.startsWith(PUBLIC_ASSETS_PREFIX)) {
                String realRoot = request.getServletContext().getRealPath("/");
                return Paths.get(realRoot, publicPath);
            }
        } catch (Exception ignore) {}
        return null;
    }
}

