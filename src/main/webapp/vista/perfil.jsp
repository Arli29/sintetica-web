<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("login");
        return;
    }

    Integer totalReservas = (Integer) request.getAttribute("totalReservas");
    Integer totalFavoritos = (Integer) request.getAttribute("totalFavoritos");
    if (totalReservas == null) totalReservas = 0;
    if (totalFavoritos == null) totalFavoritos = 0;

    // Context path para rutas absolutas
    String ctx = request.getContextPath();

    // Determinar la ruta de la imagen del avatar - CORREGIDO
    String avatarPath = "assets/img/user.png";
    if (usuario.getFotoUrl() != null && !usuario.getFotoUrl().trim().isEmpty()) {
        avatarPath = usuario.getFotoUrl();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mi Perfil | Sintética</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Varela+Round&display=swap" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
  <link rel="stylesheet" href="<%= ctx %>/assets/css/sintetica-home.css" />
  <link rel="stylesheet" href="<%= ctx %>/assets/css/perfil.css" />
</head>
<body>
  <header class="site-header" role="banner">
    <div class="wrap">
      <a class="logo" href="<%= ctx %>/inicio"><span>Sin</span>tética</a>
      <nav class="main-nav" aria-label="Principal">
        <a href="<%= ctx %>/#escenarios">Escenarios</a>
        <a href="<%= ctx %>/#reservas">Reservas</a>
        <a href="<%= ctx %>/#mapa">Mapa</a>
        <a href="<%= ctx %>/rompecabezas.html">Jugar y ganar</a>
      </nav>
      <div class="actions">
        <span class="welcome" style="color: #333; margin-right: 15px;">Hola, <%= usuario.getNombre() %></span>
        <a class="btn" href="<%= ctx %>/logout">Cerrar Sesión</a>
      </div>
    </div>
  </header>

  <main class="profile-page">
    <h1 class="page-title">Mi Perfil</h1>

    <!-- Mostrar mensajes del servidor -->
    <% if (request.getAttribute("exito") != null) { %>
        <div class="notification success">
            <%= request.getAttribute("exito") %>
        </div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
        <div class="notification error">
            <%= request.getAttribute("error") %>
        </div>
    <% } %>
    <% if (request.getAttribute("exitoPassword") != null) { %>
        <div class="notification success">
            <%= request.getAttribute("exitoPassword") %>
        </div>
    <% } %>
    <% if (request.getAttribute("errorPassword") != null) { %>
        <div class="notification error">
            <%= request.getAttribute("errorPassword") %>
        </div>
    <% } %>
    <% if (request.getAttribute("errorEliminar") != null) { %>
        <div class="notification error">
            <%= request.getAttribute("errorEliminar") %>
        </div>
    <% } %>

    <div class="profile-layout">
      <!-- Columna izquierda -->
      <div class="profile-sidebar">
        <!-- Avatar -->
        <div class="avatar-section">
          <div class="avatar-container">
            <form id="avatarForm" action="<%= ctx %>/actualizar-avatar" method="POST" enctype="multipart/form-data">
              <img src="<%= ctx + "/" + avatarPath %>" 
                   alt="Avatar" class="avatar" id="userAvatar">
              <button type="button" class="change-avatar-btn" id="changeAvatarBtn">
                <i class="fa-solid fa-camera"></i>
              </button>
              <input type="file" id="avatarInput" name="avatar" accept="image/*" hidden>
            </form>
          </div>
          <h2 class="user-name" id="userName"><%= usuario.getNombre() %> <%= usuario.getApellido() %></h2>
          <p class="user-email" id="userEmail"><%= usuario.getEmail() %></p>
        </div>

        <!-- Estadísticas -->
        <div class="stats-section">
          <div class="user-stats">
            <div class="stat-item">
              <span class="stat-number"><%= totalReservas %></span>
              <span class="stat-label">Reservas</span>
            </div>
            <div class="stat-item">
              <span class="stat-number"><%= totalFavoritos %></span>
              <span class="stat-label">Favoritos</span>
            </div>
          </div>
        </div>

        <!-- Reservas recientes -->
        <div class="reservas-section">
          <h3 class="reservas-title">Mis Reservas</h3>
          <div class="reservas-list">
            <% if (totalReservas > 0) { %>
                <div class="no-reservas">
                    <i class="fas fa-calendar-check"></i>
                    <p>Tienes <%= totalReservas %> reserva(s)</p>
                    <small>Ve al historial para ver los detalles</small>
                </div>
            <% } else { %>
                <div class="no-reservas">
                    <i class="fas fa-calendar-times"></i>
                    <p>No tienes reservas activas</p>
                </div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- Columna derecha -->
      <div class="profile-main">
        <!-- Información Personal -->
        <div class="profile-card">
          <h2 class="card-title">Información Personal</h2>
          <form class="profile-form" id="profileForm" action="<%= ctx %>/actualizar-perfil" method="POST">
            <div class="form-row">
              <div class="field">
                <label for="firstName">Nombre</label>
                <input type="text" id="firstName" name="firstName" value="<%= usuario.getNombre() %>" required>
              </div>
              <div class="field">
                <label for="lastName">Apellido</label>
                <input type="text" id="lastName" name="lastName" value="<%= usuario.getApellido() %>" required>
              </div>
            </div>
            <div class="field">
              <label for="email">Correo electrónico</label>
              <input type="email" id="email" name="email" value="<%= usuario.getEmail() %>" required>
            </div>
            <div class="field">
              <label for="phone">Teléfono</label>
              <input type="tel" id="phone" name="phone" value="<%= usuario.getTelefono() != null ? usuario.getTelefono() : "" %>">
            </div>
            <div class="form-actions">
              <button type="button" class="btn-secondary" id="cancelBtn">Cancelar</button>
              <button type="submit" class="btn-cta">Guardar cambios</button>
            </div>
          </form>
        </div>

        <!-- Seguridad -->
        <div class="profile-card">
          <h2 class="card-title">Seguridad</h2>
          <div class="security-options">
            <div class="security-item">
              <div class="security-info">
                <h3>Cambiar contraseña</h3>
                <p>Actualiza tu contraseña regularmente para mantener tu cuenta segura</p>
              </div>
              <button class="btn-secondary" id="changePasswordBtn">Cambiar</button>
            </div>
          </div>
        </div>

        <!-- Zona de peligro -->
        <div class="profile-card danger-zone">
          <h2 class="card-title">Zona de peligro</h2>
          <div class="danger-content">
            <div class="danger-info">
              <h3>Eliminar cuenta</h3>
              <p>Una vez que elimines tu cuenta, no hay vuelta atrás. Por favor, ten certeza.</p>
            </div>
            <button class="btn-danger" id="deleteAccountBtn">Eliminar cuenta</button>
          </div>
        </div>
      </div>
    </div>
  </main>

  <!-- Modal Cambiar Contraseña -->
  <div class="modal" id="passwordModal">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Cambiar contraseña</h2>
        <button class="close-modal" id="closePasswordModal">&times;</button>
      </div>
      <form class="password-form" id="passwordForm" action="<%= ctx %>/cambiar-contrasena" method="POST">
        <div class="field">
          <label for="currentPassword">Contraseña actual</label>
          <input type="password" id="currentPassword" name="currentPassword" placeholder="Contraseña actual" required>
        </div>
        <div class="field">
          <label for="newPassword">Nueva contraseña</label>
          <input type="password" id="newPassword" name="newPassword" placeholder="Nueva contraseña" required>
          <small>Debe tener al menos 8 caracteres</small>
        </div>
        <div class="field">
          <label for="confirmPassword">Confirmar nueva contraseña</label>
          <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirmar nueva contraseña" required>
        </div>
        <div class="form-actions">
          <button type="button" class="btn-secondary" id="cancelPasswordBtn">Cancelar</button>
          <button type="submit" class="btn-cta">Actualizar contraseña</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Modal Eliminar Cuenta -->
  <div class="modal" id="deleteModal">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Eliminar cuenta</h2>
        <button class="close-modal" id="closeDeleteModal">&times;</button>
      </div>
      <div class="modal-body">
        <p>¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.</p>
        <p>Todas tus reservas y datos personales se perderán permanentemente.</p>
        <div class="confirmation-check">
          <label>
            <input type="checkbox" id="confirmDelete">
            Entiendo que esta acción es irreversible
          </label>
        </div>
        <div class="form-actions">
          <button type="button" class="btn-secondary" id="cancelDeleteBtn">Cancelar</button>
          <button type="button" class="btn-danger" id="confirmDeleteBtn" disabled>Eliminar cuenta</button>
        </div>
      </div>
    </div>
  </div>

  <script src="<%= ctx %>/assets/js/sintetica-home.js"></script>
  <script src="<%= ctx %>/assets/js/perfil.js"></script>
</body>
</html>

