<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect("login");
        return;
    }

    String ctx = request.getContextPath();

    // Determinar la ruta de la imagen del avatar
    String avatarPath = "assets/img/user.png";
    if (usuario.getFotoUrl() != null && !usuario.getFotoUrl().trim().isEmpty()) {
        avatarPath = usuario.getFotoUrl().trim();
    }

    // Normalizar src del avatar: absoluta (Google) vs relativa
    String avatarSrc = avatarPath;
    if (!avatarPath.startsWith("http://") && !avatarPath.startsWith("https://")) {
        if (avatarPath.startsWith("/")) {
            avatarSrc = ctx + avatarPath;
        } else {
            avatarSrc = ctx + "/" + avatarPath;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agregar Escenario - Sintética</title>
    <link rel="stylesheet" href="<%= ctx %>/assets/css/escenarios.css">
    <link href="https://fonts.googleapis.com/css2?family=Varela+Round:wght@400;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />
    <style>
        .mapa {
            height: 300px;
            border-radius: 12px;
            margin-bottom: 15px;
            border: 2px solid #e9ecef;
            width: 100%;
            overflow: hidden;
        }

        .leaflet-container {
            font-family: 'Varela Round', system-ui, -apple-system, sans-serif;
        }

        .notification {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: 500;
        }

        .notification.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .notification.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .imagen-preview-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .imagen-preview {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .imagen-preview img {
            width: 100%;
            height: 120px;
            object-fit: cover;
            display: block;
        }

        .eliminar-imagen {
            position: absolute;
            top: 5px;
            right: 5px;
            background: rgba(239, 68, 68, 0.9);
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
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
                <span class="welcome" style="color: #333; margin-right: 15px;">
                    Hola, <%= usuario.getNombre() %>
                </span>
                <!-- Si quieres mostrar avatar, descomenta:
                <img src="<%= avatarSrc %>" alt="Avatar" style="width:32px;height:32px;border-radius:50%;object-fit:cover;margin-right:10px;">
                -->
                <a class="btn" href="<%= ctx %>/mis-escenarios">Mis Escenarios</a>
            </div>
        </div>
    </header>

    <main class="agregar-escenario-main">
        <div class="wrap">
            <div class="form-header">
                <h1>Agregar Nuevo Escenario</h1>
                <p>Completa la información de tu cancha para empezar a recibir reservas</p>
            </div>

            <!-- Mostrar mensajes -->
            <% if (request.getAttribute("error") != null) { %>
                <div class="notification error">
                    <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
                </div>
            <% } %>
            <% if (request.getAttribute("exito") != null) { %>
                <div class="notification success">
                    <i class="fas fa-check-circle"></i> <%= request.getAttribute("exito") %>
                </div>
            <% } %>

            <form class="escenario-form" action="<%= ctx %>/crear-escenario" method="POST" enctype="multipart/form-data">
                <!-- Información Básica -->
                <section class="form-section">
                    <h2>Información Básica</h2>
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="nombre">Nombre del Escenario *</label>
                            <input type="text" id="nombre" name="nombre" required 
                                   placeholder="Ej: Cancha La Castellana">
                        </div>

                        <div class="form-group">
                            <label for="id_deporte">Deporte Principal *</label>
                            <select id="id_deporte" name="id_deporte" required>
                                <option value="">Selecciona un deporte</option>
                                <option value="1">Fútbol</option>
                                <option value="2">Fútbol 5</option>
                                <option value="3">Fútbol 7</option>
                                <option value="4">Baloncesto</option>
                                <option value="5">Voleibol</option>
                                <option value="6">Tenis</option>
                                <option value="7">Pádel</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="id_barrio">Barrio *</label>
                            <select id="id_barrio" name="id_barrio" required>
                                <option value="">Selecciona un barrio</option>
                                <option value="1">Centro</option>
                                <option value="2">Rodadero</option>
                                <option value="3">Gaira</option>
                                <option value="4">Bonda</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="id_superficie">Superficie *</label>
                            <select id="id_superficie" name="id_superficie" required>
                                <option value="">Selecciona superficie</option>
                                <option value="1">Césped Natural</option>
                                <option value="2">Césped Sintético</option>
                                <option value="3">Cemento</option>
                                <option value="4">Parquet</option>
                            </select>
                        </div>
                    </div>
                </section>

                <!-- Ubicación -->
                <section class="form-section">
                    <h2>Ubicación</h2>
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label for="direccion">Dirección Completa *</label>
                            <input type="text" id="direccion" name="direccion" required
                                   placeholder="Ej: Calle 123 #45-67, Barrio El Centro">
                        </div>

                        <div class="form-group">
                            <label for="latitud">Latitud *</label>
                            <input type="number" id="latitud" name="latitud" step="any" required
                                   placeholder="11.2408" value="11.2408">
                        </div>

                        <div class="form-group">
                            <label for="longitud">Longitud *</label>
                            <input type="number" id="longitud" name="longitud" step="any" required
                                   placeholder="-74.1990" value="-74.1990">
                        </div>
                    </div>

                    <div class="mapa-container">
                        <div id="mapa-ubicacion" class="mapa"></div>
                        <button type="button" class="btn-ubicacion" id="btnUbicacion">
                            <i class="fas fa-map-marker-alt"></i>
                            Usar mi ubicación actual
                        </button>
                    </div>
                </section>

                <!-- Características -->
                <section class="form-section">
                    <h2>Características</h2>
                    <div class="caracteristicas-grid">
                        <label class="checkbox-custom">
                            <input type="checkbox" name="servicios" value="1">
                            <span class="checkmark"></span>
                            <i class="fas fa-home"></i>
                            Techada
                        </label>

                        <label class="checkbox-custom">
                            <input type="checkbox" name="servicios" value="2">
                            <span class="checkmark"></span>
                            <i class="fas fa-lightbulb"></i>
                            Iluminación
                        </label>

                        <label class="checkbox-custom">
                            <input type="checkbox" name="servicios" value="3">
                            <span class="checkmark"></span>
                            <i class="fas fa-shower"></i>
                            Vestieres
                        </label>

                        <label class="checkbox-custom">
                            <input type="checkbox" name="servicios" value="4">
                            <span class="checkmark"></span>
                            <i class="fas fa-parking"></i>
                            Parqueadero
                        </label>

                        <label class="checkbox-custom">
                            <input type="checkbox" name="servicios" value="5">
                            <span class="checkmark"></span>
                            <i class="fas fa-restroom"></i>
                            Baños
                        </label>

                        <label class="checkbox-custom">
                            <input type="checkbox" name="servicios" value="6">
                            <span class="checkmark"></span>
                            <i class="fas fa-users"></i>
                            Gradas
                        </label>
                    </div>
                </section>

                <!-- Precios y Horarios -->
                <section class="form-section">
                    <h2>Precios y Horarios</h2>
                    
                    <div class="precios-section">
                        <h3>Precio por Hora *</h3>
                        <div class="precio-input">
                            <span class="currency">$</span>
                            <input type="number" id="precio_por_hora" name="precio_por_hora" 
                                   required min="10000" step="5000"
                                   placeholder="50000">
                            <span class="suffix">COP/hora</span>
                        </div>
                    </div>
                </section>

                <!-- Información de Contacto -->
                <section class="form-section">
                    <h2>Información de Contacto</h2>
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label for="descripcion">Descripción del Escenario</label>
                            <textarea id="descripcion" name="descripcion" rows="4"
                                      placeholder="Describe tu cancha, superficie, medidas, servicios adicionales..."></textarea>
                        </div>
                    </div>
                </section>

                <!-- Imágenes del Escenario -->
                <section class="form-section">
                    <h2>Imágenes del Escenario</h2>
                    <div class="imagenes-container">
                        <div class="upload-area" id="uploadArea">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <h3>Arrastra las imágenes aquí</h3>
                            <p>o haz clic para seleccionar</p>
                            <input type="file" id="imagenes" name="imagenes" 
                                   multiple accept="image/*" style="display: none;">
                            <small>Máximo 5 imágenes • JPG, PNG • Hasta 5MB cada una</small>
                        </div>

                        <div class="imagen-preview-container" id="imagenPreviewContainer">
                            <!-- Las previsualizaciones de imágenes se agregarán aquí -->
                        </div>
                    </div>
                </section>

                <!-- Términos y Envío -->
                <section class="form-section">
                    <div class="terminos-section">
                        <label class="checkbox-terminos">
                            <input type="checkbox" id="aceptar_terminos" required>
                            <span class="checkmark"></span>
                            Acepto los <a href="<%= ctx %>/terminos-proveedores.html" target="_blank">términos y condiciones</a> 
                            para propietarios de escenarios
                        </label>
                    </div>

                    <div class="form-actions">
                        <button type="button" class="btn-secundario" onclick="window.history.back()">
                            Cancelar
                        </button>
                        <button type="submit" class="btn-principal" id="btnPublicar">
                            <i class="fas fa-rocket"></i>
                            Publicar Escenario
                        </button>
                    </div>
                </section>
            </form>
        </div>
    </main>

    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
    <script>
        // Mapa interactivo
        let mapa;
        let marcador;
        let imagenesSeleccionadas = [];

        document.addEventListener('DOMContentLoaded', function() {
            // Inicializar mapa
            initMapa();
            
            // Ubicación actual
            document.getElementById('btnUbicacion').addEventListener('click', obtenerUbicacionActual);
            
            // Actualizar coordenadas cuando se cambien manualmente
            document.getElementById('latitud').addEventListener('change', actualizarMarcadorDesdeInputs);
            document.getElementById('longitud').addEventListener('change', actualizarMarcadorDesdeInputs);
            
            // Configurar subida de imágenes
            initUploadImagenes();
            
            // Validación del formulario
            const form = document.querySelector('.escenario-form');
            form.addEventListener('submit', function(e) {
                const precio = document.getElementById('precio_por_hora').value;
                if (precio < 10000) {
                    e.preventDefault();
                    alert('El precio por hora debe ser al menos $10,000');
                    return false;
                }
                
                if (!document.getElementById('aceptar_terminos').checked) {
                    e.preventDefault();
                    alert('Debes aceptar los términos y condiciones');
                    return false;
                }
                
                return true;
            });
        });

        function initMapa() {
            // Coordenadas iniciales (Santa Marta)
            const latitud = parseFloat(document.getElementById('latitud').value) || 11.2408;
            const longitud = parseFloat(document.getElementById('longitud').value) || -74.1990;
            
            // Crear mapa
            mapa = L.map('mapa-ubicacion').setView([latitud, longitud], 15);
            
            // Agregar capa de tiles
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(mapa);
            
            // Crear marcador inicial
            marcador = L.marker([latitud, longitud], {
                draggable: true
            }).addTo(mapa);
            
            // Actualizar coordenadas al arrastrar marcador
            marcador.on('dragend', function(e) {
                const pos = e.target.getLatLng();
                document.getElementById('latitud').value = pos.lat.toFixed(6);
                document.getElementById('longitud').value = pos.lng.toFixed(6);
            });
            
            // Permitir hacer clic en el mapa para mover el marcador
            mapa.on('click', function(e) {
                marcador.setLatLng(e.latlng);
                document.getElementById('latitud').value = e.latlng.lat.toFixed(6);
                document.getElementById('longitud').value = e.latlng.lng.toFixed(6);
            });
        }

        function obtenerUbicacionActual() {
            const btn = document.getElementById('btnUbicacion');
            const textoOriginal = btn.innerHTML;
            
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Obteniendo ubicación...';
            btn.disabled = true;
            
            if (!navigator.geolocation) {
                alert('La geolocalización no es soportada por tu navegador');
                btn.innerHTML = textoOriginal;
                btn.disabled = false;
                return;
            }
            
            navigator.geolocation.getCurrentPosition(
                function(posicion) {
                    const lat = posicion.coords.latitude;
                    const lng = posicion.coords.longitude;
                    
                    // Actualizar inputs
                    document.getElementById('latitud').value = lat.toFixed(6);
                    document.getElementById('longitud').value = lng.toFixed(6);
                    
                    // Mover mapa y marcador
                    mapa.setView([lat, lng], 16);
                    marcador.setLatLng([lat, lng]);
                    
                    btn.innerHTML = textoOriginal;
                    btn.disabled = false;
                    
                    // Obtener dirección aproximada (reverse geocoding básico)
                    obtenerDireccionAproximada(lat, lng);
                },
                function(error) {
                    console.error('Error obteniendo ubicación:', error);
                    let mensaje = 'No se pudo obtener tu ubicación. ';
                    
                    switch(error.code) {
                        case error.PERMISSION_DENIED:
                            mensaje += 'Permiso denegado por el usuario.';
                            break;
                        case error.POSITION_UNAVAILABLE:
                            mensaje += 'La información de ubicación no está disponible.';
                            break;
                        case error.TIMEOUT:
                            mensaje += 'Tiempo de espera agotado.';
                            break;
                        default:
                            mensaje += 'Error desconocido.';
                    }
                    
                    alert(mensaje);
                    btn.innerHTML = textoOriginal;
                    btn.disabled = false;
                },
                {
                    enableHighAccuracy: true,
                    timeout: 10000,
                    maximumAge: 60000
                }
            );
        }

        function actualizarMarcadorDesdeInputs() {
            const lat = parseFloat(document.getElementById('latitud').value);
            const lng = parseFloat(document.getElementById('longitud').value);
            
            if (!isNaN(lat) && !isNaN(lng)) {
                marcador.setLatLng([lat, lng]);
                mapa.setView([lat, lng], mapa.getZoom());
            }
        }

        function obtenerDireccionAproximada(lat, lng) {
            // Usar Nominatim para reverse geocoding
            fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1`)
                .then(response => response.json())
                .then(data => {
                    if (data && data.address) {
                        const direccion = [];
                        if (data.address.road) direccion.push(data.address.road);
                        if (data.address.suburb) direccion.push(data.address.suburb);
                        if (data.address.city_district) direccion.push(data.address.city_district);
                        
                        if (direccion.length > 0) {
                            document.getElementById('direccion').value = direccion.join(', ');
                        }
                    }
                })
                .catch(error => {
                    console.log('No se pudo obtener la dirección:', error);
                });
        }

        function initUploadImagenes() {
            const uploadArea = document.getElementById('uploadArea');
            const fileInput = document.getElementById('imagenes');
            const previewContainer = document.getElementById('imagenPreviewContainer');
            
            // Click en área de upload
            uploadArea.addEventListener('click', () => fileInput.click());
            
            // Cambio en input de archivos
            fileInput.addEventListener('change', manejarSeleccionArchivos);
            
            // Drag and drop
            uploadArea.addEventListener('dragover', (e) => {
                e.preventDefault();
                uploadArea.classList.add('dragover');
            });
            
            uploadArea.addEventListener('dragleave', () => {
                uploadArea.classList.remove('dragover');
            });
            
            uploadArea.addEventListener('drop', (e) => {
                e.preventDefault();
                uploadArea.classList.remove('dragover');
                const files = e.dataTransfer.files;
                manejarArchivos(files);
            });
        }

        function manejarSeleccionArchivos(e) {
            const files = e.target.files;
            manejarArchivos(files);
        }

        function manejarArchivos(files) {
            const maxImagenes = 5;
            const maxTamaño = 5 * 1024 * 1024; // 5MB
            
            if (imagenesSeleccionadas.length + files.length > maxImagenes) {
                alert(`Solo puedes subir máximo ${maxImagenes} imágenes`);
                return;
            }
            
            for (let file of files) {
                if (file.size > maxTamaño) {
                    alert(`La imagen ${file.name} es demasiado grande (máximo 5MB)`);
                    continue;
                }
                
                if (!file.type.startsWith('image/')) {
                    alert(`El archivo ${file.name} no es una imagen válida`);
                    continue;
                }
                
                // Agregar a array
                imagenesSeleccionadas.push(file);
                
                // Crear preview
                crearPreviewImagen(file);
            }
            
            // Actualizar contador
            actualizarContadorImagenes();
        }

        function crearPreviewImagen(file) {
            const reader = new FileReader();
            const previewContainer = document.getElementById('imagenPreviewContainer');
            
            reader.onload = function(e) {
                const preview = document.createElement('div');
                preview.className = 'imagen-preview';
                preview.innerHTML = `
                    <img src="${e.target.result}" alt="Preview">
                    <button type="button" class="eliminar-imagen" data-filename="${file.name}">
                        <i class="fas fa-times"></i>
                    </button>
                `;
                
                previewContainer.appendChild(preview);
                
                // Event listener para eliminar
                preview.querySelector('.eliminar-imagen').addEventListener('click', function() {
                    eliminarImagen(file.name, preview);
                });
            };
            
            reader.readAsDataURL(file);
        }

        function eliminarImagen(nombreArchivo, elementoPreview) {
            // Remover del array
            imagenesSeleccionadas = imagenesSeleccionadas.filter(file => file.name !== nombreArchivo);
            
            // Remover preview
            elementoPreview.remove();
            
            // Actualizar contador
            actualizarContadorImagenes();
        }

        function actualizarContadorImagenes() {
            const uploadArea = document.getElementById('uploadArea');
            const counter = uploadArea.querySelector('small');
            counter.textContent = `${imagenesSeleccionadas.length}/5 imágenes seleccionadas • JPG, PNG • Hasta 5MB cada una`;
        }
    </script>
</body>
</html>
