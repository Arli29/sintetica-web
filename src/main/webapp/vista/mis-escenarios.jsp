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

    List<Escenario> escenarios = (List<Escenario>) request.getAttribute("escenarios");
    String exito = (String) request.getAttribute("exito");
    String error = (String) request.getAttribute("error");

    // context path para rutas absolutas
    String ctx = request.getContextPath();

    // Determinar la ruta de la imagen del avatar (por si luego quieres mostrarlo)
    String avatarPath = "assets/img/user.png";
    if (usuario.getFotoUrl() != null && !usuario.getFotoUrl().trim().isEmpty()) {
        avatarPath = usuario.getFotoUrl().trim();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Escenarios - Sintética</title>
    <link rel="stylesheet" href="<%= ctx %>/assets/css/sintetica-home.css">
    <link href="https://fonts.googleapis.com/css2?family=Varela+Round:wght@400;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        .mis-escenarios {
            padding: 20px 0 40px;
            min-height: 70vh;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 20px;
        }

        .page-title {
            font-size: 32px;
            margin: 0;
            color: var(--ink);
        }

        .btn-agregar {
            background: var(--brand);
            color: white;
            text-decoration: none;
            padding: 12px 24px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: bold;
            transition: all 0.3s ease;
        }

        .btn-agregar:hover {
            background: #e67a00;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 138, 0, 0.3);
        }

        .escenarios-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }

        .escenario-card {
            background: var(--card);
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: var(--shadow);
            transition: all 0.3s ease;
            position: relative;
        }

        .escenario-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .card-imagen {
            width: 100%;
            height: 200px;
            object-fit: cover;
            display: block;
        }

        .sin-imagen {
            height: 200px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }

        .card-contenido {
            padding: 20px;
        }

        .card-titulo {
            font-size: 20px;
            margin: 0 0 8px;
            color: var(--ink);
        }

        .card-info {
            color: var(--muted);
            margin: 0 0 12px;
            font-size: 14px;
            line-height: 1.4;
        }

        .card-precio {
            font-size: 18px;
            font-weight: bold;
            color: var(--brand);
            margin-bottom: 16px;
        }

        .card-acciones {
            display: flex;
            gap: 10px;
        }

        .btn-editar {
            flex: 1;
            background: #3b82f6;
            color: white;
            text-decoration: none;
            padding: 10px 16px;
            border-radius: 8px;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            transition: all 0.3s ease;
        }

        .btn-editar:hover {
            background: #2563eb;
            transform: translateY(-1px);
        }

        .btn-eliminar {
            background: #ef4444;
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: 8px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            transition: all 0.3s ease;
        }

        .btn-eliminar:hover {
            background: #dc2626;
            transform: translateY(-1px);
        }

        .estado-badge {
            position: absolute;
            top: 12px;
            right: 12px;
            background: #10b981;
            color: white;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: bold;
        }

        .sin-escenarios {
            grid-column: 1 / -1;
            text-align: center;
            padding: 60px 20px;
            background: var(--card);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }

        .sin-escenarios i {
            font-size: 64px;
            color: #d1d5db;
            margin-bottom: 20px;
        }

        .sin-escenarios h3 {
            color: var(--ink);
            margin: 0 0 12px;
            font-size: 24px;
        }

        .sin-escenarios p {
            color: var(--muted);
            margin: 0 0 24px;
            font-size: 16px;
        }

        .notification {
            padding: 16px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.5s ease-out;
        }

        .notification.success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .notification.error {
            background: #fee2e2;
            color: #7f1d1d;
            border: 1px solid #fecaca;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 10000;
        }

        .modal {
            background: white;
            border-radius: var(--radius);
            padding: 30px;
            max-width: 400px;
            width: 90%;
            box-shadow: var(--shadow);
            text-align: center;
        }

        .modal h3 {
            margin: 0 0 16px;
            color: var(--ink);
        }

        .modal p {
            color: var(--muted);
            margin: 0 0 24px;
            line-height: 1.5;
        }

        .modal-acciones {
            display: flex;
            gap: 12px;
            justify-content: center;
        }

        .btn-cancelar {
            background: #6b7280;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .btn-cancelar:hover {
            background: #4b5563;
        }

        .btn-confirmar {
            background: #ef4444;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.3s ease;
        }

        .btn-confirmar:hover {
            background: #dc2626;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .escenarios-grid {
                grid-template-columns: 1fr;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .page-title {
                font-size: 24px;
            }

            .card-acciones {
                flex-direction: column;
            }
        }

        @media (max-width: 480px) {
            .mis-escenarios {
                padding: 16px 0 32px;
            }

            .escenario-card {
                margin-bottom: 16px;
            }

            .modal {
                padding: 20px;
            }

            .modal-acciones {
                flex-direction: column;
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
                <a class="btn" href="<%= ctx %>/crear-escenario">Agregar Escenario</a>
            </div>
        </div>
    </header>

    <main class="mis-escenarios">
        <div class="wrap">
            <!-- Header de la página -->
            <div class="page-header">
                <h1 class="page-title">Mis Escenarios</h1>
                <a href="<%= ctx %>/crear-escenario" class="btn-agregar">
                    <i class="fas fa-plus"></i>
                    Agregar Nuevo Escenario
                </a>
            </div>

            <!-- Notificaciones -->
            <% if (exito != null) { %>
                <div class="notification success">
                    <i class="fas fa-check-circle"></i>
                    <%= exito %>
                </div>
            <% } %>

            <% if (error != null) { %>
                <div class="notification error">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= error %>
                </div>
            <% } %>

            <!-- Lista de escenarios -->
            <div class="escenarios-grid">
                <% if (escenarios != null && !escenarios.isEmpty()) { %>
                    <% for (Escenario escenario : escenarios) {

                        // Obtener primera imagen o una por defecto
                        String primeraImg = null;
                        if (escenario.getImagenes() != null && !escenario.getImagenes().isEmpty()) {
                            primeraImg = escenario.getImagenes().get(0);
                        } else {
                            primeraImg = "assets/img/default-field.jpg";
                        }

                        // Normalizar ruta -> si es relativa, agregar context path
                        String imgSrc = primeraImg;
                        if (!primeraImg.startsWith("http://") && !primeraImg.startsWith("https://")) {
                            if (primeraImg.startsWith("/")) {
                                imgSrc = ctx + primeraImg;
                            } else {
                                imgSrc = ctx + "/" + primeraImg;
                            }
                        }
                    %>
                        <div class="escenario-card">
                            <span class="estado-badge">Activo</span>

                            <img src="<%= imgSrc %>"
                                 alt="<%= escenario.getNombre() %>" class="card-imagen">

                            <div class="card-contenido">
                                <h3 class="card-titulo"><%= escenario.getNombre() %></h3>
                                <p class="card-info">
                                    <%= escenario.getDireccion() %><br>
                                    <%= escenario.getNombreBarrio() != null ? escenario.getNombreBarrio() : "Santa Marta" %> ·
                                    <%= escenario.getNombreDeporte() %>
                                </p>
                                <div class="card-precio">$<%= String.format("%,.0f", escenario.getPrecioPorHora()) %>/hora</div>

                                <div class="card-acciones">
                                    <a href="<%= ctx %>/editar-escenario?id=<%= escenario.getIdEscenario() %>" class="btn-editar">
                                        <i class="fas fa-edit"></i>
                                        Editar
                                    </a>
                                    <button class="btn-eliminar"
                                            onclick="mostrarModalEliminar(<%= escenario.getIdEscenario() %>, '<%= escenario.getNombre().replace("'", "\\'") %>')">
                                        <i class="fas fa-trash"></i>
                                        Eliminar
                                    </button>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } else { %>
                    <div class="sin-escenarios">
                        <i class="fas fa-map-marker-alt"></i>
                        <h3>No tienes escenarios registrados</h3>
                        <p>Comienza agregando tu primer escenario deportivo para recibir reservas</p>
                        <a href="<%= ctx %>/crear-escenario" class="btn-agregar">
                            <i class="fas fa-plus"></i>
                            Agregar Primer Escenario
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
    </main>

    <!-- Modal de confirmación para eliminar -->
    <div class="modal-overlay" id="modalEliminar">
        <div class="modal">
            <h3>¿Eliminar escenario?</h3>
            <p id="modalMensaje">¿Estás seguro de que quieres eliminar este escenario? Esta acción no se puede deshacer.</p>
            <form id="formEliminar" action="<%= ctx %>/eliminar-escenario" method="POST" style="display: none;">
                <input type="hidden" name="id" id="escenarioId">
            </form>
            <div class="modal-acciones">
                <button class="btn-cancelar" onclick="cerrarModal()">Cancelar</button>
                <button class="btn-confirmar" onclick="confirmarEliminacion()">Sí, Eliminar</button>
            </div>
        </div>
    </div>

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

    <script>
        // Modal de eliminación
        function mostrarModalEliminar(id, nombre) {
            const modal = document.getElementById('modalEliminar');
            const mensaje = document.getElementById('modalMensaje');
            const inputId = document.getElementById('escenarioId');

            mensaje.textContent = `¿Estás seguro de que quieres eliminar el escenario "${nombre}"? Esta acción no se puede deshacer.`;
            inputId.value = id;

            modal.style.display = 'flex';
        }

        function cerrarModal() {
            const modal = document.getElementById('modalEliminar');
            modal.style.display = 'none';
        }

        function confirmarEliminacion() {
            document.getElementById('formEliminar').submit();
        }

        // Cerrar modal al hacer clic fuera
        document.getElementById('modalEliminar').addEventListener('click', function(e) {
            if (e.target === this) {
                cerrarModal();
            }
        });

        // Cerrar modal con ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                cerrarModal();
            }
        });

        // Efectos de hover para las cards
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.escenario-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-5px)';
                });

                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                });
            });
        });
    </script>
</body>
</html>
