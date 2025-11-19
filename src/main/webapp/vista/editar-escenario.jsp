<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Escenario" %>
<%@ page import="java.util.List" %>
<%
    Escenario escenario = (Escenario) request.getAttribute("escenario");
    if (escenario == null) {
        response.sendRedirect(request.getContextPath() + "/mis-escenarios");
        return;
    }
    String ctx = request.getContextPath();
    List<String> imagenes = escenario.getImagenes();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Editar Escenario - Sintética</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Varela+Round:wght@400;700&display=swap" rel="stylesheet" />
    <style>
        :root{
            --brand:#ff8a00; --brand2:#ff8a00;
            --bg:#f5f6f8; --ink:#222; --muted:#6b7280;
            --card:#fff; --radius:18px; --shadow:0 14px 30px rgba(0,0,0,.08);
        }
        *{box-sizing:border-box; margin:0; padding:0;}
        body{font-family:'Varela Round',system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; color:var(--ink); background:var(--bg); line-height:1.5;}
        .wrap{width:min(1200px,92%); margin-inline:auto}

        /* Header */
        .site-header{position:sticky; top:0; z-index:1000; background:#fff; border-bottom:1px solid #eee}
        .site-header .wrap{display:flex; align-items:center; gap:20px; padding:14px 0}
        .logo{font-weight:900; font-size:26px; color:#111; text-decoration:none}
        .logo span{color:var(--brand)}
        .main-nav{display:flex; gap:10px}
        .main-nav a{color:#23262d; text-decoration:none; padding:10px 12px; border-radius:12px}
        .main-nav a:hover{background:#f3f4f6}
        .actions{margin-left:auto; display:flex; gap:12px; align-items:center}
        .actions .ghost{color:#374151; text-decoration:none}
        .actions .btn{background:var(--brand2); color:#fff; padding:10px 14px; border-radius:12px; text-decoration:none; border:none; cursor:pointer; font-family:inherit; font-size:14px; transition:all 0.3s ease;}
        .btn:hover{transform:translateY(-2px); box-shadow:0 4px 12px rgba(0,0,0,0.15)}

        /* Avatar & menu (por si luego lo usas) */
        .avatar-btn{border:0;background:#fff;border-radius:999px;padding:2px;cursor:pointer; position:relative; z-index:1002;}
        .avatar-btn img{width:36px;height:36px;border-radius:50%;display:block}
        .user-menu{position:fixed; top:70px; right:24px; min-width:250px; background:#fff; border:1px solid #eee; border-radius:14px; box-shadow:var(--shadow); padding:8px; list-style:none; margin:0; z-index:9999;}
        .user-menu[hidden]{display:none}
        .user-menu a{display:block; padding:10px 12px; border-radius:10px; color:#111; text-decoration:none}
        .user-menu a:hover{background:#f6f7f9}
        .user-menu .sep{height:1px; background:#eee; margin:6px 4px}
        .user-menu a i {margin-right:8px; font-size:18px;}

        /* Cards */
        .card{background:var(--card); border-radius:16px; overflow:hidden; box-shadow:var(--shadow); margin-bottom:20px;}
        .card .txt{padding:20px;}

        /* Form Styles */
        .form-section{margin-bottom:30px; padding-bottom:20px; border-bottom:1px solid #eee;}
        .form-section:last-child{border-bottom:none;}
        .form-title{color:var(--brand); margin-bottom:20px; font-size:20px; display:flex; align-items:center; gap:10px;}
        .form-grid{display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-bottom:20px;}
        .form-group{margin-bottom:20px;}
        .form-label{display:block; margin-bottom:8px; font-weight:bold; color:var(--ink); font-size:14px;}
        .form-control{width:100%; padding:12px 16px; border:1px solid #e7e7e7; border-radius:12px; font-family:inherit; font-size:16px; background:#fff; transition:all 0.3s ease;}
        .form-control:focus{outline:none; border-color:var(--brand); box-shadow:0 0 0 3px rgba(255,138,0,0.1);}
        textarea.form-control{min-height:100px; resize:vertical;}

        /* Service Options */
        .services-grid{display:grid; grid-template-columns:1fr 1fr; gap:10px;}
        .service-option{display:flex; align-items:center; gap:10px; padding:12px; border:1px solid #e7e7e7; border-radius:12px; cursor:pointer; transition:all 0.3s ease; background:#fff;}
        .service-option:hover{border-color:var(--brand); background:#fffaf0;}
        .service-option input[type="checkbox"]{margin:0;}

        /* Image Styles */
        .image-upload-container{margin-bottom:20px;}
        .current-images{display:grid; grid-template-columns:repeat(auto-fill, minmax(170px, 1fr)); gap:15px; margin-top:10px;}
        .image-item{position:relative; border-radius:12px; overflow:hidden; background:#fff;}
        .image-item img{width:100%; height:120px; object-fit:cover; border-radius:12px; border:2px solid #e7e7e7;}
        .image-remove{position:absolute; top:5px; right:5px; background:rgba(239,68,68,0.95); color:white; border:none; border-radius:50%; width:25px; height:25px; cursor:pointer; display:flex; align-items:center; justify-content:center;}
        .image-upload-box{border:2px dashed #e7e7e7; border-radius:12px; padding:30px; text-align:center; cursor:pointer; transition:all 0.3s ease; background:#fafafa;}
        .image-upload-box:hover{border-color:var(--brand); background:#fffaf0;}
        .image-preview{display:grid; grid-template-columns:repeat(auto-fill, minmax(150px, 1fr)); gap:15px; margin-top:15px;}
        .preview-item{position:relative;}
        .preview-item img{width:100%; height:120px; object-fit:cover; border-radius:12px; border:2px solid var(--brand);}
        .preview-remove{position:absolute; top:5px; right:5px; background:rgba(239,68,68,0.95); color:white; border:none; border-radius:50%; width:25px; height:25px; cursor:pointer; display:flex; align-items:center; justify-content:center;}

        .portada-radio{display:flex; align-items:center; gap:8px; margin-top:6px; color:#555;}
        .file-box{border:1px dashed #cbd5e1; border-radius:14px; padding:16px; background:#fafafa;}

        /* Buttons */
        .btn{background:var(--brand); color:#fff; padding:12px 20px; border-radius:12px; text-decoration:none; border:none; cursor:pointer; font-family:inherit; font-size:14px; display:inline-flex; align-items:center; gap:8px; transition:all 0.3s ease;}
        .btn:hover{transform:translateY(-2px); box-shadow:0 4px 12px rgba(0,0,0,0.15)}
        .btn-secondary{background:var(--muted); color:#fff;}
        .btn-danger{background:#ef4444;}
        .btn-outline{background:transparent; border:1px solid #e7e7e7; color:var(--ink);}
        .action-buttons{display:flex; justify-content:space-between; align-items:center; padding-top:20px; border-top:1px solid #eee;}

        /* Footer */
        .site-footer{background:#fff; border-top:1px solid #eee; margin-top:40px;}
        .site-footer .wrap{display:flex; align-items:center; justify-content:space-between; padding:16px 0}
        .site-footer a{color:#4b5563; text-decoration:none}

        .alert{background:#fee2e2; color:#991b1b; padding:15px; border-radius:12px; margin-bottom:20px; border:1px solid #fecaca;}
        .page-hero{padding:28px 0 10px;}

        @media (max-width: 768px){
            .form-grid{grid-template-columns:1fr;}
            .services-grid{grid-template-columns:1fr;}
            .action-buttons{flex-direction:column; gap:15px; align-items:stretch;}
            .action-buttons > div{display:flex; flex-direction:column; gap:10px;}
            .site-header .wrap{flex-wrap:wrap;}
            .main-nav{order:3; width:100%; justify-content:center; margin-top:10px;}
            .current-images, .image-preview{grid-template-columns:repeat(auto-fill, minmax(120px, 1fr));}
        }
        @media (max-width: 720px){
            .main-nav{display:none}
            .actions .ghost,.actions .btn{display:none}
        }
    </style>
</head>
<body>
    <header class="site-header" role="banner">
        <div class="wrap">
            <a class="logo" href="<%= ctx %>/inicio"><span>Sin</span>tética</a>
            <nav class="main-nav" aria-label="Principal">
                <a href="<%= ctx %>/escenarios">Escenarios</a>
                <a href="<%= ctx %>/mis-reservas">Mis Reservas</a>
                <a href="<%= ctx %>/mis-escenarios">Mis Escenarios</a>
                <a href="<%= ctx %>/rompecabezas.html">Jugar y ganar</a>
            </nav>
            <div class="actions">
                <a class="btn" href="<%= ctx %>/mis-escenarios">Mis Escenarios</a>
            </div>
        </div>
    </header>

    <main id="main">
        <section class="page-hero">
            <div class="wrap">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
                    <h1 style="margin: 0; font-size: 32px; color: var(--ink); display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-edit" style="color: var(--brand);"></i>
                        Editar Escenario
                    </h1>
                    <a href="<%= ctx %>/mis-escenarios" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Volver
                    </a>
                </div>

                <% String error = request.getParameter("error"); %>
                <% if (error != null) { %>
                    <div class="alert">
                        <i class="fas fa-exclamation-triangle"></i> <%= error %>
                    </div>
                <% } %>

                <div class="card">
                    <div class="txt">
                        <form action="<%= ctx %>/editar-escenario" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="id_escenario" value="<%= escenario.getIdEscenario() %>">

                            <!-- Información Básica -->
                            <div class="form-section">
                                <h3 class="form-title">
                                    <i class="fas fa-info-circle"></i> Información Básica
                                </h3>
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label">Nombre del Escenario *</label>
                                        <input type="text" class="form-control" name="nombre"
                                               value="<%= escenario.getNombre() != null ? escenario.getNombre() : "" %>"
                                               placeholder="Ej: Cancha Fútbol 5 Los Pinos" required>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Deporte *</label>
                                        <select class="form-control" name="id_deporte" required>
                                            <option value="1" <%= escenario.getIdDeporte() == 1 ? "selected" : "" %>>Fútbol</option>
                                            <option value="2" <%= escenario.getIdDeporte() == 2 ? "selected" : "" %>>Baloncesto</option>
                                            <option value="3" <%= escenario.getIdDeporte() == 3 ? "selected" : "" %>>Tenis</option>
                                            <option value="4" <%= escenario.getIdDeporte() == 4 ? "selected" : "" %>>Voleibol</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Descripción</label>
                                    <textarea class="form-control" name="descripcion" rows="4"
                                        placeholder="Describe las características de tu escenario..."><%= escenario.getDescripcion() != null ? escenario.getDescripcion() : "" %></textarea>
                                </div>
                            </div>

                            <!-- Ubicación -->
                            <div class="form-section">
                                <h3 class="form-title"><i class="fas fa-map-marker-alt"></i> Ubicación</h3>
                                <div class="form-group">
                                    <label class="form-label">Dirección Completa *</label>
                                    <input type="text" class="form-control" name="direccion"
                                           value="<%= escenario.getDireccion() != null ? escenario.getDireccion() : "" %>"
                                           placeholder="Ej: Calle 123 #45-67" required>
                                </div>
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label">Barrio *</label>
                                        <select class="form-control" name="id_barrio" required>
                                            <option value="1" <%= escenario.getIdBarrio() == 1 ? "selected" : "" %>>Centro</option>
                                            <option value="2" <%= escenario.getIdBarrio() == 2 ? "selected" : "" %>>Rodadero</option>
                                            <option value="3" <%= escenario.getIdBarrio() == 3 ? "selected" : "" %>>Gaira</option>
                                            <option value="4" <%= escenario.getIdBarrio() == 4 ? "selected" : "" %>>Bonda</option>
                                            <option value="5" <%= escenario.getIdBarrio() == 5 ? "selected" : "" %>>Mamatoco</option>
                                            <option value="6" <%= escenario.getIdBarrio() == 6 ? "selected" : "" %>>Taganga</option>
                                            <option value="7" <%= escenario.getIdBarrio() == 7 ? "selected" : "" %>>Pozos Colorados</option>
                                            <option value="8" <%= escenario.getIdBarrio() == 8 ? "selected" : "" %>>La Castellana</option>
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Superficie *</label>
                                        <select class="form-control" name="id_superficie" required>
                                            <option value="1" <%= escenario.getIdSuperficie() == 1 ? "selected" : "" %>>Sintética</option>
                                            <option value="2" <%= escenario.getIdSuperficie() == 2 ? "selected" : "" %>>Césped Natural</option>
                                            <option value="3" <%= escenario.getIdSuperficie() == 3 ? "selected" : "" %>>Dura</option>
                                            <option value="4" <%= escenario.getIdSuperficie() == 4 ? "selected" : "" %>>Arcilla</option>
                                            <option value="5" <%= escenario.getIdSuperficie() == 5 ? "selected" : "" %>>Arena</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-grid">
                                    <div class="form-group">
                                        <label class="form-label">Latitud</label>
                                        <input type="number" step="any" class="form-control" name="latitud"
                                               value="<%= escenario.getLatitud() != 0.0 ? escenario.getLatitud() : 11.240354 %>"
                                               placeholder="Ej: 11.240354">
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Longitud</label>
                                        <input type="number" step="any" class="form-control" name="longitud"
                                               value="<%= escenario.getLongitud() != 0.0 ? escenario.getLongitud() : -74.211023 %>"
                                               placeholder="Ej: -74.211023">
                                    </div>
                                </div>
                            </div>

                            <!-- Imágenes del Escenario -->
                            <div class="form-section">
                                <h3 class="form-title"><i class="fas fa-images"></i> Imágenes del Escenario</h3>

                                <!-- Imágenes actuales + selector de portada -->
                                <div class="form-group">
                                    <label class="form-label">Imágenes actuales</label>
                                    <div class="current-images">
                                        <% if (imagenes != null && !imagenes.isEmpty()) {
                                               for (int i=0;i<imagenes.size();i++) {
                                                   String img = imagenes.get(i);
                                                   if (img.startsWith("/")) img = img.substring(1);
                                                   img = img.replace("\\","/");
                                        %>
                                            <div class="image-item">
                                                <img src="<%= ctx + "/" + img %>" alt="Imagen del escenario">
                                                <div class="portada-radio">
                                                    <input type="radio" name="portada_existente" value="<%= img %>" <%= (i==0?"checked":"") %> />
                                                    <small>Usar como portada</small>
                                                </div>
                                                <button type="button" class="image-remove" title="Eliminar" onclick="eliminarImagen(this, '<%= img %>')">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            </div>
                                        <%   }
                                           } else { %>
                                            <p style="color: var(--muted); grid-column: 1 / -1; text-align: center; padding: 20px;">
                                                No hay imágenes cargadas para este escenario
                                            </p>
                                        <% } %>
                                    </div>
                                    <p class="form-help" style="margin-top:10px;color:#6b7280;">Marca cuál imagen quieres como <b>portada</b>. Si subes nuevas, puedes seleccionar “usar primera nueva como portada”.</p>
                                </div>

                                <!-- Subir nuevas imágenes -->
                                <div class="form-group">
                                    <label class="form-label">Agregar nuevas imágenes</label>
                                    <div class="image-upload-box" onclick="document.getElementById('nuevasImagenes').click()">
                                        <i class="fas fa-cloud-upload-alt" style="font-size: 40px; color: var(--muted); margin-bottom: 10px;"></i>
                                        <p style="color: var(--muted); margin: 0;">Haz clic para seleccionar imágenes</p>
                                        <small style="color: var(--muted);">Formatos: JPG, PNG, GIF, WEBP. Máx. 5MB por imagen</small>
                                    </div>
                                    <input type="file" id="nuevasImagenes" name="nuevas_imagenes" multiple accept="image/*" style="display: none;" onchange="previewNuevasImagenes(this)">
                                    <div class="file-box" style="margin-top:10px;">
                                        <label class="portada-radio">
                                            <input type="checkbox" name="usar_como_portada" value="1">
                                            <small>Usar la <b>primera nueva</b> como portada</small>
                                        </label>
                                    </div>
                                    <div id="previewContainer" class="image-preview" style="display: none;"></div>
                                </div>
                            </div>

                            <!-- Precio y Servicios -->
                            <div class="form-section">
                                <h3 class="form-title"><i class="fas fa-cog"></i> Precio y Características</h3>
                                <div class="form-group">
                                    <label class="form-label">Precio por Hora ($) *</label>
                                    <input type="number" step="0.01" min="0" class="form-control"
                                           name="precio_por_hora" value="<%= escenario.getPrecioPorHora() %>"
                                           placeholder="Ej: 50000.00" required>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Servicios Disponibles</label>
                                    <div class="services-grid">
                                        <label class="service-option"><input type="checkbox" name="servicios" value="1"><span>Vestieres</span></label>
                                        <label class="service-option"><input type="checkbox" name="servicios" value="2"><span>Iluminación</span></label>
                                        <label class="service-option"><input type="checkbox" name="servicios" value="3"><span>Parqueadero</span></label>
                                        <label class="service-option"><input type="checkbox" name="servicios" value="4"><span>Baños</span></label>
                                        <label class="service-option"><input type="checkbox" name="servicios" value="5"><span>Duchas</span></label>
                                        <label class="service-option"><input type="checkbox" name="servicios" value="6"><span>Bar/Cafetería</span></label>
                                    </div>
                                </div>
                            </div>

                            <!-- Botones -->
                            <div class="action-buttons">
                                <button type="button" class="btn btn-danger" onclick="confirmarEliminacion()">
                                    <i class="fas fa-trash"></i> Eliminar Escenario
                                </button>
                                <div style="display: flex; gap: 15px;">
                                    <a href="<%= ctx %>/mis-escenarios" class="btn btn-secondary">
                                        <i class="fas fa-times"></i> Cancelar
                                    </a>
                                    <button type="submit" class="btn">
                                        <i class="fas fa-save"></i> Guardar Cambios
                                    </button>
                                </div>
                            </div>

                            <!-- Hidden para eliminar -->
                            <input type="hidden" id="imagenesEliminar" name="imagenes_eliminar" value="">
                        </form>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <footer class="site-footer">
        <div class="wrap">
            <small>© 2025 Sintética</small>
            <nav aria-label="Legal">
                <a href="<%= ctx %>/terminos">Términos</a>
                <a href="<%= ctx %>/privacidad">Privacidad</a>
                <a href="<%= ctx %>/soporte">Soporte</a>
            </nav>
        </div>
    </footer>

    <script>
        // Lista CSV para imágenes a eliminar
        const imagenesAEliminar = [];

        function eliminarImagen(boton, imagenRelativa) {
            if (confirm('¿Eliminar esta imagen?')) {
                const item = boton.parentElement;
                item.style.opacity = '0.5';

                if (!imagenesAEliminar.includes(imagenRelativa)) {
                    imagenesAEliminar.push(imagenRelativa);
                }
                document.getElementById('imagenesEliminar').value = imagenesAEliminar.join(',');

                // Si estaba marcada como portada, limpia el radio
                const radio = item.querySelector('input[type="radio"][name="portada_existente"]');
                if (radio && radio.checked) {
                    radio.checked = false;
                }

                setTimeout(() => item.remove(), 300);
            }
        }

        function previewNuevasImagenes(input) {
            const previewContainer = document.getElementById('previewContainer');
            previewContainer.innerHTML = '';

            if (input.files && input.files.length > 0) {
                previewContainer.style.display = 'grid';

                for (let i = 0; i < input.files.length; i++) {
                    const file = input.files[i];
                    if (!file.type.startsWith('image/')) continue;

                    const reader = new FileReader();
                    reader.onload = function(e) {
                        const previewItem = document.createElement('div');
                        previewItem.className = 'preview-item';
                        previewItem.innerHTML = `
                            <img src="${e.target.result}" alt="Vista previa">
                            <button type="button" class="preview-remove" onclick="removerPreview(this)">
                                <i class="fas fa-times"></i>
                            </button>
                        `;
                        previewContainer.appendChild(previewItem);
                    };
                    reader.readAsDataURL(file);
                }
            } else {
                previewContainer.style.display = 'none';
            }
        }

        function removerPreview(boton) {
            const item = boton.parentElement;
            item.remove();
            const previewContainer = document.getElementById('previewContainer');
            if (previewContainer.children.length === 0) {
                previewContainer.style.display = 'none';
            }
            // Nota: remover del FileList requiere recrear input (lo dejamos simple)
        }

        function confirmarEliminacion() {
            if (confirm('¿Eliminar el escenario "<%= escenario.getNombre() %>"? Esta acción no se puede deshacer.')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '<%= ctx %>/eliminar-escenario';
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'id';
                input.value = '<%= escenario.getIdEscenario() %>';
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>

