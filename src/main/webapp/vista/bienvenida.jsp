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

    // mensaje de éxito por creación de escenario (mostrar una sola vez)
    String exitoCreacion = (String) session.getAttribute("exitoCreacion");
    if (exitoCreacion != null) {
        session.removeAttribute("exitoCreacion");
        request.setAttribute("exitoCreacion", exitoCreacion);
    }

    // context path para rutas absolutas
    String ctx = request.getContextPath();

    // avatar por defecto o el del usuario
    String avatarPath = "assets/img/user.png";
    if (usuario.getFotoUrl() != null && !usuario.getFotoUrl().trim().isEmpty()) {
        avatarPath = usuario.getFotoUrl().trim();
    }

    // Construir src real del avatar:
    // - Si empieza por http, dejamos tal cual (URL absoluta de Google)
    // - Si es relativo, le anteponemos el context path
    String avatarSrc = avatarPath;
    if (!avatarPath.startsWith("http://") && !avatarPath.startsWith("https://")) {
        if (avatarPath.startsWith("/")) {
            avatarSrc = ctx + avatarPath;
        } else {
            avatarSrc = ctx + "/" + avatarPath;
        }
    }

    // Obtener TODOS los escenarios (no solo destacados)
    List<Escenario> todosLosEscenarios = Escenario.obtenerTodosLosEscenarios();
%>
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sintética · Inicio</title>
    <meta
      name="description"
      content="Reserva canchas deportivas rápido, claro y sin llamadas."
    />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      href="https://fonts.googleapis.com/css2?family=Varela+Round:wght@400;700&display=swap"
      rel="stylesheet"
    />
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css"
    />
    <link rel="stylesheet" href="<%= ctx %>/assets/css/sintetica-home.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>

    <style>
      .notification-global {
        position: fixed;
        top: 80px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 1000;
        background: #10b981;
        color: white;
        padding: 16px 24px;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        display: flex;
        align-items: center;
        gap: 12px;
        max-width: 500px;
        animation: slideInDown 0.5s ease-out;
      }
      .notification-global.error { background: #ef4444; }
      .notification-global i { font-size: 20px; }
      @keyframes slideInDown {
        from { transform: translateX(-50%) translateY(-100%); opacity: 0; }
        to { transform: translateX(-50%) translateY(0); opacity: 1; }
      }
      .notification-close {
        background: none; border: none; color: white; cursor: pointer;
        padding: 4px; margin-left: auto;
      }
    </style>
  </head>

  <body>
    <!-- Notificación de éxito al crear escenario -->
    <% if (request.getAttribute("exitoCreacion") != null) { %>
      <div class="notification-global" id="notificationGlobal">
        <i class="fas fa-check-circle"></i>
        <span><%= request.getAttribute("exitoCreacion") %></span>
        <button class="notification-close" onclick="closeNotification()">
          <i class="fas fa-times"></i>
        </button>
      </div>
      <script>
        function closeNotification() {
          const n = document.getElementById('notificationGlobal');
          if (!n) return;
          n.style.transform = 'translateX(-50%) translateY(-100%)';
          n.style.opacity = '0';
          setTimeout(() => n.remove(), 300);
        }
        setTimeout(closeNotification, 5000);
      </script>
    <% } %>

    <header class="site-header" role="banner">
      <div class="wrap">
        <a class="logo" href="<%= ctx %>/inicio"><span>Sin</span>tética</a>

        <nav class="main-nav" aria-label="Principal">
          <a href="#escenarios">Escenarios</a>
          <a href="#reservas">Reservas</a>
          <a href="#mapa">Mapa</a>
          <a href="<%= ctx %>/vista/rompecabezas.jsp">Jugar y ganar</a>
        </nav>

        <div class="actions">
          <span class="welcome" style="color:#333;margin-right:15px;">
            Hola, <%= usuario.getNombre() %>
          </span>

          <!-- Botón Avatar -->
          <button
            id="btnUserMenu"
            class="avatar-btn"
            aria-haspopup="menu"
            aria-expanded="false"
            aria-label="Abrir menú de usuario"
          >
            <!-- Usamos avatarSrc ya normalizado -->
            <img src="<%= avatarSrc %>" alt="Avatar" />
          </button>

          <ul
            id="userMenu"
            class="user-menu"
            role="menu"
            aria-labelledby="btnUserMenu"
            hidden
          >
            <li role="none">
              <a role="menuitem" href="<%= ctx %>/perfil">
                <i class="fas fa-user"></i> Perfil
              </a>
            </li>
            <li role="none">
              <a role="menuitem" href="#">
                <i class="fas fa-calendar-alt"></i> Historial de reservas
              </a>
            </li>
            <li role="none">
              <a role="menuitem" href="<%= ctx %>/crear-escenario">
                <i class="fas fa-plus-circle"></i> Agregar escenario
              </a>
            </li>
            <li role="none">
              <a role="menuitem" href="<%= ctx %>/mis-escenarios">
                <i class="fas fa-list"></i> Mis escenarios
              </a>
            </li>
            <li class="sep" role="separator"></li>
            <li role="none">
              <a role="menuitem" href="<%= ctx %>/logout">
                <i class="fas fa-sign-out-alt"></i> Cerrar sesión
              </a>
            </li>
          </ul>
        </div>
      </div>
    </header>

    <main id="main">
      <!-- HERO -->
      <section class="hero">
        <div class="wrap hero-grid">
          <div class="hero-copy">
            <h1>Encuentra y reserva<br />canchas deportivas</h1>
            <p class="lead">Descuentos al completar el rompecabezas.</p>

            <form class="search" action="<%= ctx %>/escenarios" method="GET" role="search" aria-label="Buscar canchas">
              <input
                type="search"
                name="q"
                placeholder="Buscar barrio, escenario o deporte…"
                aria-label="Buscar"
              />
              <button class="search-btn" type="submit" aria-label="Buscar">
                <i class="fas fa-search"></i>
              </button>
            </form>

            <ul class="chips" aria-label="Filtros rápidos">
              <li><button type="button" data-filter="Fútbol">Fútbol</button></li>
              <li><button type="button" data-filter="Baloncesto">Baloncesto</button></li>
              <li><button type="button" data-filter="Voleibol">Voleibol</button></li>
              <li><button type="button" data-filter="Natación">Natación</button></li>
              <li><button type="button" data-filter="Patinaje">Patinaje</button></li>
            </ul>

            <div id="chip-cupon" class="coupon-chip" hidden></div>
          </div>

          <aside id="mapa" class="hero-card" aria-label="Mapa y promoción">
            <div id="map" class="map"></div>
            <a
              class="promo-badge"
              href="<%= ctx %>/vista/rompecabezas.jsp"
              aria-label="Ir a Jugar y ganar"
            >
              <span class="dot"></span> Jugar y ganar
            </a>
          </aside>
        </div>
      </section>

      <!-- ESCENARIOS -->
      <section id="escenarios" class="nearby">
        <div class="wrap">
          <header class="sec-head">
            <h2>Todos los Escenarios Disponibles</h2>
            <a class="viewall" href="<%= ctx %>/escenarios">Ver más</a>
          </header>

          <div class="cards">
            <% if (todosLosEscenarios != null && !todosLosEscenarios.isEmpty()) { %>
              <% for (Escenario escenario : todosLosEscenarios) { 
                   boolean tieneImagen = (escenario.getImagenes() != null && !escenario.getImagenes().isEmpty());
                   String primeraImg = tieneImagen ? escenario.getImagenes().get(0) : "assets/img/default-field.jpg";

                   // Normalizar ruta de imagen del escenario:
                   // - Si empieza por http, la dejamos igual
                   // - Si es relativa, la unimos con el context path
                   String imgSrc = primeraImg;
                   if (!primeraImg.startsWith("http://") && !primeraImg.startsWith("https://")) {
                       if (primeraImg.startsWith("/")) {
                           imgSrc = ctx + primeraImg;
                       } else {
                           imgSrc = ctx + "/" + primeraImg;
                       }
                   }
              %>
                <article class="card">
                  <img
                    loading="lazy"
                    src="<%= imgSrc %>"
                    alt="<%= escenario.getNombre() %>"
                  />
                  <div class="txt">
                    <h3><%= escenario.getNombre() %></h3>
                    <p>
                      <%= escenario.getNombreBarrio() != null ? escenario.getNombreBarrio() : "Santa Marta" %> · 
                      <%= escenario.getNombreDeporte() %>
                      <% if (escenario.getNombrePropietario() != null) { %>
                        · Propietario: <%= escenario.getNombrePropietario() %>
                      <% } %>
                    </p>
                    <div class="meta">
                      <span class="price">$<%= String.format("%,.0f", escenario.getPrecioPorHora()) %>/hora</span>
                      <span class="tag"><%= escenario.getNombreDeporte() %></span>
                    </div>
                    <a class="book" href="<%= ctx %>/escenario-detalle?id=<%= escenario.getIdEscenario() %>">Ver detalles</a>
                  </div>
                </article>
              <% } %>
            <% } else { %>
              <!-- Mensaje cuando no hay escenarios -->
              <div class="no-escenarios" style="grid-column: 1 / -1; text-align: center; padding: 40px;">
                <i class="fas fa-map-marker-alt" style="font-size: 48px; color: #ccc; margin-bottom: 20px;"></i>
                <h3 style="color: #666; margin-bottom: 10px;">No hay escenarios disponibles</h3>
                <p style="color: #999; margin-bottom: 20px;">Sé el primero en agregar un escenario deportivo</p>
                <a href="<%= ctx %>/crear-escenario" class="btn-principal" style="display: inline-flex; align-items: center; gap: 8px;">
                  <i class="fas fa-plus"></i>
                  Agregar Primer Escenario
                </a>
              </div>
            <% } %>
          </div>

          <% if (todosLosEscenarios != null && !todosLosEscenarios.isEmpty()) { %>
            <div style="text-align: center; margin-top: 20px; color: #666;">
              <p><strong><%= todosLosEscenarios.size() %></strong> escenario(s) disponible(s)</p>
            </div>
          <% } %>
        </div>
      </section>

      <!-- TESTIMONIOS -->
      <section class="testimonials">
        <div class="wrap">
          <header class="sec-head">
            <h2>Lo que dicen nuestros usuarios</h2>
          </header>
          <div class="testimonial-cards">
            <article class="testimonial-card">
              <div class="testimonial-header">
                <div class="user-info">
                  <img src="https://i.pravatar.cc/60?img=1" alt="Carlos M." />
                  <div>
                    <h4>Carlos M.</h4>
                    <div class="stars">★★★★★</div>
                  </div>
                </div>
              </div>
              <p>"Reservé en 2 minutos sin llamadas. ¡Increíble experiencia!"</p>
            </article>

            <article class="testimonial-card">
              <div class="testimonial-header">
                <div class="user-info">
                  <img src="https://i.pravatar.cc/60?img=2" alt="Ana L." />
                  <div>
                    <h4>Ana L.</h4>
                    <div class="stars">★★★★★</div>
                  </div>
                </div>
              </div>
              <p>"El rompecabezas me dio 20% de descuento. ¡Totalmente recomendado!"</p>
            </article>

            <article class="testimonial-card">
              <div class="testimonial-header">
                <div class="user-info">
                  <img src="https://i.pravatar.cc/60?img=3" alt="Miguel R." />
                  <div>
                    <h4>Miguel R.</h4>
                    <div class="stars">★★★★☆</div>
                  </div>
                </div>
              </div>
              <p>"Canchas siempre en buen estado y el proceso de reserva es súper fácil."</p>
            </article>
          </div>
        </div>
      </section>

      <!-- PREGUNTAS FRECUENTES -->
      <section class="faq">
        <div class="wrap">
          <header class="sec-head">
            <h2>Preguntas frecuentes</h2>
          </header>
          <div class="faq-grid">
            <details class="faq-item">
              <summary>¿Cómo funciona el rompecabezas para descuentos?</summary>
              <div class="faq-content">
                <p>
                  Completa el juego interactivo para obtener cupones de descuento
                  que puedes aplicar directamente en tu reserva. Los descuentos
                  varían entre 10% y 25%.
                </p>
              </div>
            </details>

            <details class="faq-item">
              <summary>¿Puedo cancelar o modificar mi reserva?</summary>
              <div class="faq-content">
                <p>
                  Sí, puedes cancelar sin costo hasta 24 horas antes de tu
                  reserva. Las modificaciones dependen de la disponibilidad.
                </p>
              </div>
            </details>

            <details class="faq-item">
              <summary>¿Qué métodos de pago aceptan?</summary>
              <div class="faq-content">
                <p>
                  Aceptamos tarjetas débito/crédito, transferencias bancarias y
                  pago en efectivo en la cancha.
                </p>
              </div>
            </details>

            <details class="faq-item">
              <summary>¿Necesito crear una cuenta para reservar?</summary>
              <div class="faq-content">
                <p>
                  Sí, necesitas una cuenta gratuita para gestionar tus reservas,
                  aplicar descuentos y acceder a tu historial.
                </p>
              </div>
            </details>

            <details class="faq-item">
              <summary>¿Qué pasa si llueve el día de mi reserva?</summary>
              <div class="faq-content">
                <p>
                  En caso de lluvia, puedes reprogramar tu reserva sin costo o
                  recibir un reembolso completo si la cancha no está techada.
                </p>
              </div>
            </details>

            <details class="faq-item">
              <summary>¿Ofrecen descuentos para grupos grandes?</summary>
              <div class="faq-content">
                <p>
                  Sí, para grupos de más de 20 personas ofrecemos descuentos
                  especiales. Contáctanos para más información.
                </p>
              </div>
            </details>
          </div>
        </div>
      </section>
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

    <script src="<%= ctx %>/assets/js/mapa.js"></script>
    <script src="<%= ctx %>/assets/js/sintetica-home.js"></script>

    <script>
      // Filtros rápidos para escenarios
      document.addEventListener('DOMContentLoaded', function() {
        // Filtros rápidos (chips)
        document.querySelectorAll('.chips button').forEach(btn => {
          btn.addEventListener('click', function() {
            const deporte = this.getAttribute('data-filter');
            window.location.href = '<%= ctx %>/escenarios?deporte=' + encodeURIComponent(deporte);
          });
        });

        // Buscar al presionar Enter
        const searchInput = document.querySelector('input[type="search"]');
        if (searchInput) {
          searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
              this.closest('form').submit();
            }
          });
        }

        // Si el campo está vacío, ver todos
        const searchForm = document.querySelector('.search');
        if (searchForm) {
          searchForm.addEventListener('submit', function(e) {
            const v = this.querySelector('input[type="search"]').value.trim();
            if (v === '') {
              e.preventDefault();
              window.location.href = '<%= ctx %>/escenarios';
            }
          });
        }
      });
    </script>
  </body>
</html>
