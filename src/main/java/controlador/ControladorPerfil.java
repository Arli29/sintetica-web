package controlador;

import modelo.Usuario;
import util.PasswordHasher;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.nio.file.*;

@WebServlet(name = "ControladorPerfil", urlPatterns = {
    "/perfil", "/actualizar-perfil", "/cambiar-contrasena", "/eliminar-cuenta", "/actualizar-avatar"
})
@MultipartConfig(
    maxFileSize = 2 * 1024 * 1024,      // 2MB
    maxRequestSize = 5 * 1024 * 1024    // 5MB
)
public class ControladorPerfil extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        System.out.println("🔍 GET Perfil: " + path);
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            System.out.println("🚫 Usuario no autenticado, redirigiendo a login");
            response.sendRedirect("login");
            return;
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        
        switch (path) {
            case "/perfil":
                mostrarPerfil(request, response, usuario);
                break;
            default:
                response.sendRedirect("perfil");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        System.out.println("🔍 POST Perfil: " + path);
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("login");
            return;
        }
        
        Usuario usuarioSesion = (Usuario) session.getAttribute("usuario");
        
        // Procesar subida de avatar (multipart)
        if ("/actualizar-avatar".equals(path)) {
            actualizarAvatar(request, response, usuarioSesion);
            return;
        }
        
        switch (path) {
            case "/actualizar-perfil":
                actualizarPerfil(request, response, usuarioSesion);
                break;
            case "/cambiar-contrasena":
                cambiarContrasena(request, response, usuarioSesion);
                break;
            case "/eliminar-cuenta":
                eliminarCuenta(request, response, usuarioSesion);
                break;
            default:
                response.sendRedirect("perfil");
                break;
        }
    }
    
    private void actualizarAvatar(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws ServletException, IOException {
        
        System.out.println("🖼️ Actualizando avatar...");
        
        try {
            // Verificar si hay archivo subido
            Part filePart = request.getPart("avatar");
            if (filePart == null || filePart.getSize() == 0) {
                // No se subió una nueva imagen: mantener la actual (o user.png por defecto)
                System.out.println("ℹ️ No se subió nueva imagen, se mantiene el avatar existente");
                mostrarPerfil(request, response, usuario);
                return;
            }

            
            // Validar tipo de archivo
            String contentType = filePart.getContentType();
            System.out.println("📄 Tipo de archivo: " + contentType);
            
            if (!contentType.startsWith("image/")) {
                request.setAttribute("error", "Solo se permiten archivos de imagen (JPEG, PNG, etc.)");
                mostrarPerfil(request, response, usuario);
                return;
            }
            
            // Validar tamaño (máximo 2MB)
            long fileSize = filePart.getSize();
            System.out.println("📏 Tamaño del archivo: " + fileSize + " bytes");
            
            if (fileSize > 2 * 1024 * 1024) {
                request.setAttribute("error", "La imagen no debe superar los 2MB");
                mostrarPerfil(request, response, usuario);
                return;
            }
            
            // Obtener la ruta real del directorio de despliegue
            String contextPath = request.getServletContext().getRealPath("/");
            System.out.println("📁 Context Path: " + contextPath);
            
            // Eliminar avatar anterior si existe
            eliminarAvatarAnterior(usuario, contextPath);
            
            // Crear directorio assets/img si no existe
            String uploadPath = contextPath + "assets/img";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("📁 Directorio creado: " + uploadPath + " - " + (created ? "Éxito" : "Falló"));
            } else {
                System.out.println("📁 Directorio ya existe: " + uploadPath);
            }
            
            // Generar nombre único para el archivo
            String fileExtension = getFileExtension(contentType);
            String fileName = "avatar_" + usuario.getIdUsuario() + "_" + System.currentTimeMillis() + "." + fileExtension;
            String filePath = uploadPath + File.separator + fileName;
            
            System.out.println("💾 Guardando archivo como: " + filePath);
            
            // Guardar archivo
            try (InputStream fileContent = filePart.getInputStream()) {
                Files.copy(fileContent, new File(filePath).toPath(), StandardCopyOption.REPLACE_EXISTING);
                System.out.println("✅ Archivo guardado exitosamente");
            } catch (Exception e) {
                System.out.println("❌ Error al guardar archivo: " + e.getMessage());
                throw e;
            }
            
            // Ruta relativa para la base de datos - CORREGIDO
            String relativePath = "assets/img/" + fileName;
            
            // Actualizar en base de datos
            boolean exito = Usuario.actualizarAvatar(usuario.getIdUsuario(), relativePath);
            
            if (exito) {
                // Actualizar objeto en sesión
                usuario.setFotoUrl(relativePath);
                request.getSession().setAttribute("usuario", usuario);
                request.setAttribute("exito", "Avatar actualizado correctamente");
                System.out.println("✅ Avatar guardado en BD: " + relativePath);
            } else {
                request.setAttribute("error", "Error al guardar el avatar en la base de datos");
                System.out.println("❌ Error al guardar en BD");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error al actualizar avatar: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la imagen: " + e.getMessage());
        }
        
        mostrarPerfil(request, response, usuario);
    }
    
    private void eliminarAvatarAnterior(Usuario usuario, String contextPath) {
        try {
            if (usuario.getFotoUrl() != null && 
                !usuario.getFotoUrl().trim().isEmpty() &&
                !usuario.getFotoUrl().equals("assets/img/user.png")) {
                
                String oldAvatarPath = contextPath + usuario.getFotoUrl();
                File oldAvatarFile = new File(oldAvatarPath);
                
                if (oldAvatarFile.exists() && oldAvatarFile.isFile()) {
                    boolean deleted = oldAvatarFile.delete();
                    System.out.println("🗑️ Avatar anterior eliminado: " + oldAvatarPath + " - " + (deleted ? "Éxito" : "Falló"));
                }
            }
        } catch (Exception e) {
            System.out.println("⚠️ Error al eliminar avatar anterior: " + e.getMessage());
        }
    }
    
    private String getFileExtension(String contentType) {
        switch (contentType) {
            case "image/jpeg":
            case "image/jpg":
                return "jpg";
            case "image/png":
                return "png";
            case "image/gif":
                return "gif";
            case "image/webp":
                return "webp";
            default:
                return "jpg";
        }
    }
    
    private void mostrarPerfil(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws ServletException, IOException {
        
        try {
            // Cargar datos actualizados del usuario desde la base de datos
            Usuario usuarioActualizado = Usuario.obtenerPorId(usuario.getIdUsuario());
            if (usuarioActualizado != null) {
                request.getSession().setAttribute("usuario", usuarioActualizado);
                request.setAttribute("usuario", usuarioActualizado);
            } else {
                request.setAttribute("usuario", usuario);
            }
            
            // Cargar estadísticas del usuario
            cargarEstadisticasUsuario(request, usuario.getIdUsuario());
            
            System.out.println("📄 Mostrando perfil para: " + usuario.getEmail());
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("vista/perfil.jsp");
            dispatcher.forward(request, response);
            
        } catch (Exception e) {
            System.out.println("❌ Error al mostrar perfil: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el perfil");
            RequestDispatcher dispatcher = request.getRequestDispatcher("vista/perfil.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    private void actualizarPerfil(HttpServletRequest request, HttpServletResponse response, Usuario usuarioSesion) 
            throws ServletException, IOException {
        
        System.out.println("🔄 Actualizando perfil...");
        
        // Obtener parámetros del formulario
        String nombre = request.getParameter("firstName");
        String apellido = request.getParameter("lastName");
        String email = request.getParameter("email");
        String telefono = request.getParameter("phone");
        
        System.out.println("📝 Datos a actualizar: " + nombre + " " + apellido + " - " + email);
        
        // Validaciones básicas
        if (nombre == null || apellido == null || email == null || 
            nombre.trim().isEmpty() || apellido.trim().isEmpty() || email.trim().isEmpty()) {
            
            System.out.println("❌ Validación fallida: campos obligatorios vacíos");
            request.setAttribute("error", "Nombre, apellido y email son obligatorios");
            mostrarPerfil(request, response, usuarioSesion);
            return;
        }
        
        // Verificar si el email ya existe (excluyendo el usuario actual)
        if (!email.equals(usuarioSesion.getEmail()) && Usuario.existeEmail(email)) {
            System.out.println("❌ Validación fallida: email ya registrado - " + email);
            request.setAttribute("error", "El email ya está registrado por otro usuario");
            mostrarPerfil(request, response, usuarioSesion);
            return;
        }
        
        try {
            // Actualizar en base de datos
            boolean exito = Usuario.actualizarPerfil(usuarioSesion.getIdUsuario(), nombre, apellido, email, telefono);
            
            if (exito) {
                // Actualizar objeto en sesión
                Usuario usuarioActualizado = new Usuario();
                usuarioActualizado.setIdUsuario(usuarioSesion.getIdUsuario());
                usuarioActualizado.setNombre(nombre);
                usuarioActualizado.setApellido(apellido);
                usuarioActualizado.setEmail(email);
                usuarioActualizado.setTelefono(telefono);
                usuarioActualizado.setContrasena(usuarioSesion.getContrasena());
                usuarioActualizado.setFotoUrl(usuarioSesion.getFotoUrl());
                usuarioActualizado.setFechaRegistro(usuarioSesion.getFechaRegistro());
                usuarioActualizado.setActivo(true);
                
                request.getSession().setAttribute("usuario", usuarioActualizado);
                request.setAttribute("exito", "Perfil actualizado correctamente");
                System.out.println("✅ Perfil actualizado exitosamente");
            } else {
                request.setAttribute("error", "Error al actualizar el perfil");
                System.out.println("❌ Error al actualizar perfil en BD");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Excepción al actualizar perfil: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error interno del sistema");
        }
        
        mostrarPerfil(request, response, (Usuario) request.getSession().getAttribute("usuario"));
    }
    
    private void cambiarContrasena(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws ServletException, IOException {
        
        System.out.println("🔄 Cambiando contraseña...");
        
        String contrasenaActual = request.getParameter("currentPassword");
        String nuevaContrasena = request.getParameter("newPassword");
        String confirmarContrasena = request.getParameter("confirmPassword");
        
        // Validaciones
        if (contrasenaActual == null || nuevaContrasena == null || confirmarContrasena == null ||
            contrasenaActual.trim().isEmpty() || nuevaContrasena.trim().isEmpty() || confirmarContrasena.trim().isEmpty()) {
            
            request.setAttribute("errorPassword", "Todos los campos son obligatorios");
            mostrarPerfil(request, response, usuario);
            return;
        }
        
        if (!nuevaContrasena.equals(confirmarContrasena)) {
            request.setAttribute("errorPassword", "Las contraseñas nuevas no coinciden");
            mostrarPerfil(request, response, usuario);
            return;
        }
        
        if (nuevaContrasena.length() < 8) {
            request.setAttribute("errorPassword", "La nueva contraseña debe tener al menos 8 caracteres");
            mostrarPerfil(request, response, usuario);
            return;
        }
        
        try {
            // Verificar contraseña actual
            if (!PasswordHasher.verifyPassword(contrasenaActual, usuario.getContrasena())) {
                request.setAttribute("errorPassword", "La contraseña actual es incorrecta");
                mostrarPerfil(request, response, usuario);
                return;
            }
            
            // Actualizar contraseña en BD
            boolean exito = Usuario.cambiarContrasena(usuario.getIdUsuario(), PasswordHasher.hashPassword(nuevaContrasena));
            
            if (exito) {
                // Actualizar objeto en sesión
                usuario.setContrasena(PasswordHasher.hashPassword(nuevaContrasena));
                request.getSession().setAttribute("usuario", usuario);
                request.setAttribute("exitoPassword", "Contraseña actualizada correctamente");
                System.out.println("✅ Contraseña actualizada exitosamente");
            } else {
                request.setAttribute("errorPassword", "Error al actualizar la contraseña");
                System.out.println("❌ Error al actualizar contraseña en BD");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Excepción al cambiar contraseña: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorPassword", "Error interno del sistema");
        }
        
        mostrarPerfil(request, response, usuario);
    }
    
    private void eliminarCuenta(HttpServletRequest request, HttpServletResponse response, Usuario usuario) 
            throws ServletException, IOException {
        
        System.out.println("🔄 Eliminando cuenta...");
        
        String confirmacion = request.getParameter("confirmacion");
        
        if (!"true".equals(confirmacion)) {
            request.setAttribute("errorEliminar", "Debes confirmar la eliminación");
            mostrarPerfil(request, response, usuario);
            return;
        }
        
        try {
            // Realizar soft delete en la base de datos
            boolean exito = Usuario.eliminarCuenta(usuario.getIdUsuario());
            
            if (exito) {
                System.out.println("✅ Cuenta eliminada exitosamente para: " + usuario.getEmail());
                
                // Invalidar sesión
                HttpSession session = request.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                
                // Redirigir a página de login
                response.sendRedirect("login?mensaje=Cuenta+eliminada+exitosamente");
                return;
            } else {
                request.setAttribute("errorEliminar", "Error al eliminar la cuenta");
                System.out.println("❌ Error al eliminar cuenta en BD");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Excepción al eliminar cuenta: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorEliminar", "Error interno del sistema");
        }
        
        mostrarPerfil(request, response, usuario);
    }
    
    private void cargarEstadisticasUsuario(HttpServletRequest request, int idUsuario) {
        try (Connection conn = modelo.Conexion.getConexion()) {
            
            // Contar reservas
            String sqlReservas = "SELECT COUNT(*) FROM reserva WHERE id_usuario = ?";
            PreparedStatement pstmtReservas = conn.prepareStatement(sqlReservas);
            pstmtReservas.setInt(1, idUsuario);
            ResultSet rsReservas = pstmtReservas.executeQuery();
            
            int totalReservas = 0;
            if (rsReservas.next()) {
                totalReservas = rsReservas.getInt(1);
            }
            
            // Contar favoritos
            String sqlFavoritos = "SELECT COUNT(*) FROM favorito WHERE id_usuario = ?";
            PreparedStatement pstmtFavoritos = conn.prepareStatement(sqlFavoritos);
            pstmtFavoritos.setInt(1, idUsuario);
            ResultSet rsFavoritos = pstmtFavoritos.executeQuery();
            
            int totalFavoritos = 0;
            if (rsFavoritos.next()) {
                totalFavoritos = rsFavoritos.getInt(1);
            }
            
            request.setAttribute("totalReservas", totalReservas);
            request.setAttribute("totalFavoritos", totalFavoritos);
            
            pstmtReservas.close();
            pstmtFavoritos.close();
            
        } catch (Exception e) {
            System.out.println("❌ Error al cargar estadísticas: " + e.getMessage());
            // En caso de error, establecer valores por defecto
            request.setAttribute("totalReservas", 0);
            request.setAttribute("totalFavoritos", 0);
        }
    }
}
