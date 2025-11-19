<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Usuario" %>
<%@ page import="modelo.Escenario" %>
<%@ page import="java.util.List" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("login");
        return;
    }

    Escenario escenario = (Escenario) request.getAttribute("escenario");
    if (escenario == null) {
        response.sendRedirect("escenarios");
        return;
    }

    String ctx = request.getContextPath();

    // Determinar la ruta de la imagen del avatar (por si luego quieres usarlo)
    String avatarPath = "assets/img/user.png";
    if (usuario.getFotoUrl() != null && !usuario.getFotoUrl().trim().isEmpty()) {
        avatarPath = usuario.getFotoUrl().trim();
    }
    String avatarSrc = avatarPath;
    if (!avatarPath.startsWith("http://") && !avatarPath.startsWith("https://")) {
        if (avatarPath.startsWith("/")) {
            avatarSrc = ctx + avatarPath;
        } else {
            avatarSrc = ctx + "/" + avatarPath;
        }
    }

    List<String> imagenes = escenario.getImagenes();

    // Normalizar ruta de la imagen principal
    String imagenPrincipalSrc = null;
    if (imagenes != null && !imagenes.isEmpty()) {
        String p = imagenes.get(0);
        imagenPrincipalSrc = p;
        if (!p.startsWith("http://") && !p.startsWith("https://")) {
            if (p.startsWith("/")) {
                imagenPrincipalSrc = ctx + p;
            } else {
                imagenPrincipalSrc = ctx + "/" + p;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= escenario.getNombre() %> - Sintética</title>
    <link rel="stylesheet" href="<%= ctx %>/assets/css/sintetica-home.css">
    <link href="https://fonts.googleapis.com/css2?family=Varela+Round:wght@400;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
    <style>
        .detalle-escenario {
            padding: 20px 0 40px;
        }
        
        .detalle-header {
            margin-bottom: 30px;
        }
        
        .detalle-titulo {
            font-size: 32px;
            margin: 0 0 8px;
            color: var(--ink);
        }
        
        .detalle-subtitulo {
            color: var(--muted);
            margin: 0 0 16px;
            font-size: 18px;
        }
        
        .detalle-grid {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 30px;
            align-items: start;
        }
        
        .galeria {
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow);
        }
        
        .imagen-principal {
            width: 100%;
            height: 400px;
            object-fit: cover;
            display: block;
        }
        
        .galeria-miniaturas {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 8px;
            padding: 12px;
            background: var(--card);
        }
        
        .miniatura {
            width: 100%;
            height: 80px;
            object-fit: cover;
            border-radius: 8px;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .miniatura:hover {
            transform: scale(1.05);
        }
        
        .miniatura.activa {
            border: 3px solid var(--brand);
        }
        
        .info-sidebar {
            background: var(--card);
            border-radius: var(--radius);
            padding: 24px;
            box-shadow: var(--shadow);
            position: sticky;
            top: 100px;
        }
        
        .precio-destacado {
            font-size: 32px;
            font-weight: bold;
            color: var(--brand);
            margin-bottom: 8px;
        }
        
        .precio-periodo {
            color: var(--muted);
            margin-bottom: 20px;
        }
        
        .btn-reservar {
            display: block;
            width: 100%;
            background: var(--brand);
            color: white;
            text-decoration: none;
            text-align: center;
            padding: 16px;
            border-radius: 12px;
            font-weight: bold;
            font-size: 18px;
            margin-bottom: 16px;
            transition: all 0.3s ease;
        }
        
        .btn-reservar:hover {
            background: #e67a00;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }
        
        .info-contacto {
            border-top: 1px solid #eee;
            padding-top: 16px;
            margin-top: 16px;
        }
        
        .detalle-seccion {
            margin-bottom: 30px;
        }
        
        .detalle-seccion h3 {
            font-size: 20px;
            margin-bottom: 16px;
            color: var(--ink);
        }
        
        .caracteristicas-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px;
        }
        
        .caracteristica {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        
        .caracteristica i {
            color: var(--brand);
            font-size: 18px;
        }
        
        .mapa-detalle {
            height: 300px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-top: 16px;
        }
        
        .info-basica {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 20px;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        
        .info-label {
            font-size: 14px;
            color: var(--muted);
        }
        
        .info-valor {
            font-weight: bold;
            color: var(--ink);
        }
        
        .descripcion {
            line-height: 1.6;
            color: var(--muted);
            font-size: 16px;
        }
        
        .sin-imagen {
            height: 400px;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 18px;
        }
        
        .sin-imagen i {
            font-size: 48px;
            margin-bottom: 16px;
        }
        
        /* Responsive */
        @media (max-width: 980px) {
            .detalle-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .info-sidebar {
                position: static;
            }
            
            .imagen-principal {
                height: 300px;
            }
        }
        
        @media (max-width: 768px) {
            .detalle-titulo {
                font-size: 24px;
            }
            
            .galeria-miniaturas {
                grid-template-columns: repeat(3, 1fr);
            }
            
            .caracteristicas-grid {
                grid-template-columns: 1fr;
            }
            
            .info-basica {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 480px) {
            .imagen-principal {
                height: 250px;
            }
            
            .miniatura {
                height: 60px;
            }
            
            .precio-destacado {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>
    <header class="site-header" role="banner">
        <div class="wrap">
            <a class="logo" href="<%= ctx %>/inicio"><span>Sin</span>tética</a>
            <nav class="main-nav" aria-label="Principal">
                <a href="<%= ctx %>/inicio#escenarios">Escenarios</a>
                <a href="<%= ctx %>/inicio#reservas">Reservas</a>
                <a href="<%= ctx %>/inicio#mapa">Mapa</a>
                <a href="<%= ctx %>/rompecabezas.html">Jugar y ganar</a>
            </nav>
            <div class="actions">
                <span class="welcome" style="color: #333; margin-right: 15px;">Hola, <%= usuario.getNombre() %></span>
                <a class="btn" href="<%= ctx %>/mis-escenarios">Mis Escenarios</a>
            </div>
        </div>
    </header>

    <main class="detalle-escenario">
        <div class="wrap">
            <div class="detalle-header">
                <h1 class="detalle-titulo"><%= escenario.getNombre() %></h1>
                <p class="detalle-subtitulo">
                    <%= escenario.getDireccion() %> · 
                    <%= escenario.getNombreBarrio() != null ? escenario.getNombreBarrio() : "Santa Marta" %> · 
                    <%= escenario.getNombreDeporte() %>
                </p>
                
                <div class="info-basica">
                    <div class="info-item">
                        <span class="info-label">Deporte</span>
                        <span class="info-valor"><%= escenario.getNombreDeporte() %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Superficie</span>
                        <span class="info-valor"><%= escenario.getNombreSuperficie() != null ? escenario.getNombreSuperficie() : "No especificada" %></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">Barrio</span>
                        <span class="info-valor"><%= escenario.getNombreBarrio() != null ? escenario.getNombreBarrio() : "Santa Marta" %></span>
                    </div>
                    <% if (escenario.getNombrePropietario() != null) { %>
                    <div class="info-item">
                        <span class="info-label">Propietario</span>
                        <span class="info-valor"><%= escenario.getNombrePropietario() %></span>
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="detalle-grid">
                <!-- Columna principal -->
                <div class="columna-principal">
                    <!-- Galería de imágenes -->
                    <div class="galeria">
                        <% if (imagenes != null && !imagenes.isEmpty()) { %>
                            <img
                                id="imagenPrincipal"
                                src="<%= imagenPrincipalSrc %>"
                                alt="<%= escenario.getNombre() %>"
                                class="imagen-principal"
                            />
                            <div class="galeria-miniaturas">
                                <%
                                    for (int i = 0; i < imagenes.size(); i++) {
                                        String p = imagenes.get(i);
                                        String thumbSrc = p;
                                        if (!p.startsWith("http://") && !p.startsWith("https://")) {
                                            if (p.startsWith("/")) {
                                                thumbSrc = ctx + p;
                                            } else {
                                                thumbSrc = ctx + "/" + p;
                                            }
                                        }
                                %>
                                    <img
                                        src="<%= thumbSrc %>"
                                        alt="Imagen <%= i + 1 %>"
                                        class="miniatura <%= i == 0 ? "activa" : "" %>"
                                        data-index="<%= i %>"
                                        onclick="cambiarImagen(<%= i %>)"
                                    />
                                <% } %>
                            </div>
                        <% } else { %>
                            <div class="sin-imagen">
                                <div style="text-align: center;">
                                    <i class="fas fa-camera"></i>
                                    <p>No hay imágenes disponibles</p>
                                </div>
                            </div>
                        <% } %>
                    </div>

                    <!-- Descripción -->
                    <section class="detalle-seccion">
                        <h3>Descripción</h3>
                        <p class="descripcion">
                            <%= escenario.getDescripcion() != null && !escenario.getDescripcion().isEmpty() 
                                ? escenario.getDescripcion() 
                                : "Este escenario deportivo ofrece instalaciones de calidad para la práctica de " + escenario.getNombreDeporte() + ". Ideal para partidos amistosos, entrenamientos y competencias." %>
                        </p>
                    </section>

                    <!-- Características y servicios -->
                    <section class="detalle-seccion">
                        <h3>Características</h3>
                        <div class="caracteristicas-grid">
                            <div class="caracteristica">
                                <i class="fas fa-futbol"></i>
                                <span>Cancha de <%= escenario.getNombreDeporte() %></span>
                            </div>
                            <div class="caracteristica">
                                <i class="fas fa-layer-group"></i>
                                <span>Superficie: <%= escenario.getNombreSuperficie() != null ? escenario.getNombreSuperficie() : "Estándar" %></span>
                            </div>
                            <div class="caracteristica">
                                <i class="fas fa-ruler-combined"></i>
                                <span>Medidas reglamentarias</span>
                            </div>
                            <div class="caracteristica">
                                <i class="fas fa-users"></i>
                                <span>Capacidad para equipos</span>
                            </div>
                            <!-- Puedes agregar más características específicas según los servicios del escenario -->
                        </div>
                    </section>

                    <!-- Ubicación -->
                    <section class="detalle-seccion">
                        <h3>Ubicación</h3>
                        <p><%= escenario.getDireccion() %></p>
                        <div id="mapaDetalle" class="mapa-detalle"></div>
                    </section>
                </div>

                <!-- Sidebar de reserva -->
                <div class="info-sidebar">
                    <div class="precio-destacado">$<%= String.format("%,.0f", escenario.getPrecioPorHora()) %></div>
                    <div class="precio-periodo">por hora</div>
                    
                    <a href="#" class="btn-reservar">
                        <i class="fas fa-calendar-check"></i>
                        Reservar Ahora
                    </a>
                    
                    <div class="info-contacto">
                        <h4>Información de Contacto</h4>
                        <div style="margin-bottom: 12px;">
                            <strong>Dirección:</strong><br>
                            <%= escenario.getDireccion() %>
                        </div>
                        <div style="margin-bottom: 12px;">
                            <strong>Barrio:</strong><br>
                            <%= escenario.getNombreBarrio() != null ? escenario.getNombreBarrio() : "Santa Marta" %>
                        </div>
                        <% if (escenario.getNombrePropietario() != null) { %>
                        <div>
                            <strong>Propietario:</strong><br>
                            <%= escenario.getNombrePropietario() %>
                        </div>
                        <% } %>
                    </div>
                    
                    <div style="margin-top: 20px; padding: 16px; background: #f8f9fa; border-radius: 8px;">
                        <h4 style="margin: 0 0 8px 0; font-size: 16px;">¿Necesitas ayuda?</h4>
                        <p style="margin: 0; color: var(--muted); font-size: 14px;">
                            Contáctanos para resolver tus dudas sobre reservas y disponibilidad.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer class="site-footer">
        <div class="wrap">
            <small>© 2025 Sintética</small>
            <nav aria-label="Legal">
                <a href="<%= ctx %>/legal/terminos.html">Términos</a>
                <a href="<%= ctx %>/legal/privacidad.html">Privacidad</a>
                <a href="<%= ctx %>/soporte.html">Soporte</a>
            </nav>
        </div>
    </footer>

    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
    <script>
        // Galería de imágenes
        function cambiarImagen(index) {
            const imagenes = document.querySelectorAll('.miniatura');
            const imagenPrincipal = document.getElementById('imagenPrincipal');
            
            if (!imagenes.length) return;

            // Remover clase activa de todas las miniaturas
            imagenes.forEach(img => img.classList.remove('activa'));
            
            // Agregar clase activa a la miniatura clickeada
            imagenes[index].classList.add('activa');
            
            // Cambiar imagen principal
            imagenPrincipal.src = imagenes[index].src;
        }
        
        // Mapa
        document.addEventListener('DOMContentLoaded', function() {
            // Coordenadas del escenario
            const latitud = <%= escenario.getLatitud() != 0.0 ? escenario.getLatitud() : 11.2408 %>;
            const longitud = <%= escenario.getLongitud() != 0.0 ? escenario.getLongitud() : -74.1990 %>;
            
            // Crear mapa
            const mapa = L.map('mapaDetalle').setView([latitud, longitud], 15);
            
            // Agregar capa de tiles
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(mapa);
            
            // Agregar marcador
            L.marker([latitud, longitud])
                .addTo(mapa)
                .bindPopup('<strong><%= escenario.getNombre() %></strong><br><%= escenario.getDireccion() %>')
                .openPopup();
        });
        
        // Efectos de hover para cards
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.caracteristica');
            cards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 4px 12px rgba(0,0,0,0.1)';
                });
                
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = 'none';
                });
            });
        });
    </script>
</body>
</html>
