
package controlador;

import modelo.Usuario;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "ControladorUsuario", urlPatterns = {
    "/registro", "/login", "/logout", "/bienvenida", "/inicio"
})
public class ControladorUsuario extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        System.out.println("🔍 GET request: " + path);
        
        switch (path) {
            case "/registro":
                mostrarRegistro(request, response);
                break;
            case "/login":
                mostrarLogin(request, response);
                break;
            case "/logout":
                cerrarSesion(request, response);
                break;
            case "/bienvenida":
            case "/inicio":
                mostrarBienvenida(request, response);
                break;
            default:
                response.sendRedirect("login");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        System.out.println("🔍 POST request: " + path);
        
        switch (path) {
            case "/registro":
                procesarRegistro(request, response);
                break;
            case "/login":
                procesarLogin(request, response);
                break;
            default:
                response.sendRedirect("login");
                break;
        }
    }
    
    private void mostrarRegistro(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("📄 Mostrando formulario de registro");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/registro.jsp");
        dispatcher.forward(request, response);
    }
    
    private void mostrarLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("📄 Mostrando formulario de login");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/login.jsp");
        dispatcher.forward(request, response);
    }
    
    private void mostrarBienvenida(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            System.out.println("📄 Mostrando bienvenida para: " + usuario.getEmail());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/bienvenida.jsp");
            dispatcher.forward(request, response);
        } else {
            System.out.println("🚫 Usuario no autenticado, redirigiendo a login");
            response.sendRedirect("login");
        }
    }
    
    private void procesarRegistro(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("🔄 Procesando registro...");
        
        // Obtener parámetros del formulario
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String email = request.getParameter("email");
        String telefono = request.getParameter("telefono");
        String contrasena = request.getParameter("contrasena");
        String confirmarContrasena = request.getParameter("confirmar_contrasena");
        String aceptarTerminos = request.getParameter("aceptar_terminos");
        String comunicacionesProm = request.getParameter("comunicaciones_prom");
        
        System.out.println("📝 Datos recibidos: " + nombre + " " + apellido + " - " + email);
        
        // Validaciones básicas
        if (nombre == null || apellido == null || email == null || 
            contrasena == null || confirmarContrasena == null || aceptarTerminos == null ||
            nombre.trim().isEmpty() || apellido.trim().isEmpty() || 
            email.trim().isEmpty() || contrasena.trim().isEmpty()) {
            
            System.out.println("❌ Validación fallida: campos obligatorios vacíos");
            request.setAttribute("error", "Todos los campos obligatorios deben ser completados");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/registro.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        if (!contrasena.equals(confirmarContrasena)) {
            System.out.println("❌ Validación fallida: contraseñas no coinciden");
            request.setAttribute("error", "Las contraseñas no coinciden");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/registro.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        if (contrasena.length() < 8) {
            System.out.println("❌ Validación fallida: contraseña muy corta");
            request.setAttribute("error", "La contraseña debe tener al menos 8 caracteres");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/registro.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        // Verificar si el email ya existe
        if (Usuario.existeEmail(email)) {
            System.out.println("❌ Validación fallida: email ya registrado - " + email);
            request.setAttribute("error", "El email ya está registrado");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/registro.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        // Crear y registrar usuario
        try {
            Usuario usuario = new Usuario(nombre, apellido, email, telefono, contrasena);
            boolean aceptarTerminosBool = "on".equals(aceptarTerminos);
            boolean comunicacionesPromBool = "on".equals(comunicacionesProm);
            
            System.out.println("💾 Intentando registrar usuario en MySQL...");
            if (usuario.registrar(aceptarTerminosBool, comunicacionesPromBool)) {
                System.out.println("✅ Registro exitoso para: " + email);
                request.setAttribute("exito", "Registro exitoso. Ahora puedes iniciar sesión.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/login.jsp");
                dispatcher.forward(request, response);
            } else {
                System.out.println("❌ Error en el registro (retornó false)");
                request.setAttribute("error", "Error en el registro. Intenta nuevamente.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/registro.jsp");
                dispatcher.forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("❌ Excepción durante el registro: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error interno del sistema. Intenta más tarde.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/registro.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    private void procesarLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("🔄 Procesando login...");
        
        String email = request.getParameter("email");
        String contrasena = request.getParameter("contrasena");
        
        System.out.println("📝 Intentando login para: " + email);
        
        if (email == null || contrasena == null || 
            email.trim().isEmpty() || contrasena.trim().isEmpty()) {
            
            System.out.println("❌ Validación fallida: email o contraseña vacíos");
            request.setAttribute("error", "Email y contraseña son obligatorios");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/login.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        try {
            System.out.println("🔐 Validando credenciales en MySQL...");
            Usuario usuario = Usuario.validarLogin(email, contrasena);
            
            if (usuario != null) {
                System.out.println("✅ Login exitoso para: " + email);
                
                // Crear sesión
                HttpSession session = request.getSession();
                session.setAttribute("usuario", usuario);
                session.setMaxInactiveInterval(30 * 60); // 30 minutos
                
                System.out.println("🎯 Sesión creada, redirigiendo a inicio");
                response.sendRedirect("inicio");
            } else {
                System.out.println("❌ Login fallido: credenciales incorrectas para " + email);
                request.setAttribute("error", "Credenciales incorrectas");
                RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/login.jsp");
                dispatcher.forward(request, response);
            }
        } catch (Exception e) {
            System.out.println("❌ Excepción durante login: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error interno del sistema. Intenta más tarde.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vista/login.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    private void cerrarSesion(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            System.out.println("🚪 Cerrando sesión para: " + (usuario != null ? usuario.getEmail() : "unknown"));
            session.invalidate();
        } else {
            System.out.println("🚪 No hay sesión activa para cerrar");
        }
        response.sendRedirect("login");
    }
}
