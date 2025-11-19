package controlador;

import com.google.api.client.googleapis.auth.oauth2.*;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;

import modelo.Usuario;
import util.PasswordHasher;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet("/login-google")
public class LoginGoogleServlet extends HttpServlet {

    // ⚠️ Para pruebas: usa las credenciales que compartiste.
    // Recomendado: mover a variables de entorno o web.xml y ROTAR el secreto al finalizar.
    private static final String CLIENT_ID = System.getenv("GOOGLE_CLIENT_ID");
    private static final String CLIENT_SECRET = System.getenv("GOOGLE_CLIENT_SECRET");


    // Ajusta al dominio/puerto/contexto reales de tu app:
    private static final String REDIRECT_URI = "http://localhost:8080/sintetica-login/login-google";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            // 1) Ir a consentimiento de Google
            String authUrl =
                "https://accounts.google.com/o/oauth2/auth"
                + "?client_id=" + CLIENT_ID
                + "&redirect_uri=" + REDIRECT_URI
                + "&response_type=code"
                + "&scope=email%20profile";
            response.sendRedirect(authUrl);
            return;
        }

        GoogleTokenResponse tokenResponse = new GoogleAuthorizationCodeTokenRequest(
                new NetHttpTransport(),
                JacksonFactory.getDefaultInstance(),
                "https://oauth2.googleapis.com/token",
                CLIENT_ID, CLIENT_SECRET, code, REDIRECT_URI
        ).execute();


        GoogleIdToken idToken = tokenResponse.parseIdToken();
        Payload payload = idToken.getPayload();

        String sub = payload.getSubject(); // ID estable de Google
        String email = payload.getEmail();
        String nombre = (String) payload.get("name");
        String foto = (String) payload.get("picture");

        // 3) Buscar usuario por sub_google o por email
        Usuario usuario = Usuario.obtenerPorSubGoogle(sub);
        if (usuario == null) {
            usuario = Usuario.obtenerPorEmail(email);
        }

        if (usuario == null) {
            // 4) Registrar usuario de Google (tu tabla exige contrasena NOT NULL)
            String dummyPass = generarTokenAleatorio(); // no utilizable para login local
            usuario = Usuario.registrarDesdeGoogle(
                    nombre, "", email, foto, sub, dummyPass
            );
        } else {
            // Asegurar campos Google si era cuenta local existente
            Usuario.sincronizarGoogle(usuario.getIdUsuario(), sub, foto);
        }

        // 5) Crear sesión igual que tu login local y redirigir a /inicio
        HttpSession session = request.getSession();
        session.setAttribute("usuario", usuario);
        session.setMaxInactiveInterval(30 * 60);
        response.sendRedirect(request.getContextPath() + "/inicio");
    }

    private String generarTokenAleatorio() {
        byte[] b = new byte[32];
        new SecureRandom().nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }
}

