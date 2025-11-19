<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login Sintética</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Varela+Round&display=swap" rel="stylesheet">

</head>

<body>
  <div class="container">
    <div class="login-box">
      <!-- Logo -->
      <div class="logo">
        <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Logo Sintética">
      </div>

      <!-- Formulario -->
      <form action="login" method="post">
        <% if (request.getAttribute("error") != null) { %>
          <div class="error-message" style="background: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
            <%= request.getAttribute("error") %>
          </div>
        <% } %>
        
        <% if (request.getAttribute("exito") != null) { %>
          <div class="success-message" style="background: #d4edda; color: #155724; padding: 10px; border-radius: 5px; margin-bottom: 1rem; border: 1px solid #c3e6cb;">
            <%= request.getAttribute("exito") %>
          </div>
        <% } %>

        <div class="input-group">
          <i class="bi bi-person"></i>
          <input type="email" name="email" placeholder="Correo electrónico" required>
        </div>

        <div class="input-group">
          <i class="bi bi-lock"></i>
          <input type="password" name="contrasena" placeholder="Contraseña" required>
        </div>

        <div class="options">
          <label><input type="checkbox"> Recordar mi contraseña</label>
          <a href="#">Olvidé contraseña</a>
        </div>

        <button type="submit" class="btn-login">Acceder</button>

        <div class="divider"></div>

        <button type="button" id="btnGoogle" class="btn-google" aria-label="Continuar con Google">
  <img src="${pageContext.request.contextPath}/assets/img/google.svg" alt="" aria-hidden="true">
  <span>Continuar con Google</span>
</button>

<script>
  (function () {
    var btn = document.getElementById('btnGoogle');
    if (btn) {
      btn.addEventListener('click', function () {
        window.location.href = '${pageContext.request.contextPath}/login-google';
      });
    }
  })();
</script>

        <button type="button" class="btn-apple">
          <i class="bi bi-apple"></i>
          Continuar con Apple
        </button>

        <p class="register">¿Aún no tienes una cuenta? <a href="registro">Regístrate gratis dando click aquí</a></p>
      </form>
    </div>
  </div>
</body>
</html>
