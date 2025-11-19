<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Registro Sintética</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/registro.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Varela+Round&display=swap" rel="stylesheet">
</head>

<body>
  <div class="register-container">
    <div class="register-box">
      <!-- Columna izquierda: formulario -->
      <div class="form-section">
        <h2>Regístrate</h2>

        <form action="registro" method="post">
          <% if (request.getAttribute("error") != null) { %>
            <div class="error-message" style="background: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 1rem; border: 1px solid #f5c6cb;">
              <%= request.getAttribute("error") %>
            </div>
          <% } %>

          <div class="input-row">
            <input type="text" name="nombre" placeholder="Nombre" required>
            <input type="text" name="apellido" placeholder="Apellido" required>
          </div>

          <input type="email" name="email" placeholder="Correo electrónico" required>
          <input type="tel" name="telefono" placeholder="Teléfono" required>
          <small>Te enviaremos un código de verificación a este número.</small>

          <input type="password" name="contrasena" placeholder="Contraseña" required>
          <small>Debe tener al menos 8 caracteres, incluir mayúscula, minúscula, número y caracter especial.</small>

          <input type="password" name="confirmar_contrasena" placeholder="Confirmar contraseña" required>

          <label><input type="checkbox" name="aceptar_terminos" required> Acepto los Términos y Condiciones y la Política de Privacidad</label>
          <label><input type="checkbox" name="comunicaciones_prom"> Deseo recibir comunicaciones promocionales</label>

          <button type="submit" class="btn-register">Crear cuenta</button>
        </form>
      </div>

      <!-- Columna derecha: logo y sociales -->
      <div class="logo-section">
        <img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="Logo Sintética">

        <button type="button" id="btnGoogleReg" class="btn-google">
  <img src="${pageContext.request.contextPath}/assets/img/google.svg" alt="Google">
  Continuar con Google
</button>
  <script>
  document.getElementById("btnGoogleReg").addEventListener("click", function () {
    window.location.href = "${pageContext.request.contextPath}/login-google";
  });
</script>



        <button type="button" class="btn-apple">
          <i class="bi bi-apple"></i>
          Continuar con Apple
        </button>
      </div>
    </div>
  </div>
</body>

</html>
