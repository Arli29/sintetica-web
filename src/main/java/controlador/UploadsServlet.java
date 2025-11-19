package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;

@WebServlet(name = "UploadsServlet", urlPatterns = {"/uploads/*"})
public class UploadsServlet extends HttpServlet {

    private Path resolveBaseDir() {
        String configuredBase = System.getProperty("SINTETICA_UPLOADS_DIR");
        if (configuredBase == null || configuredBase.trim().isEmpty()) {
            configuredBase = System.getProperty("user.home") + File.separator + "sintetica_uploads";
        }
        return Paths.get(configuredBase).toAbsolutePath().normalize();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Path baseDir = resolveBaseDir();                     // ~/sintetica_uploads
        String pathInfo = req.getPathInfo();                 // /escenarios/15/archivo.jpg
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Normaliza y evita path traversal
        Path requested = baseDir.resolve(pathInfo.replaceFirst("^/", "")).normalize();
        if (!requested.startsWith(baseDir)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (!Files.exists(requested) || !Files.isRegularFile(requested)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = Files.probeContentType(requested);
        if (mime == null) mime = "application/octet-stream";
        resp.setContentType(mime);
        resp.setHeader("Cache-Control", "public, max-age=31536000, immutable");

        try (OutputStream out = resp.getOutputStream();
             InputStream in = Files.newInputStream(requested)) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) out.write(buf, 0, len);
        }
    }
}

