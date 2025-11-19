document.addEventListener('DOMContentLoaded', function() {
    // Variables globales
    let mapa;
    let marcador;
    let imagenesSeleccionadas = [];
    
    // Inicializar
    initMapa();
    initEventListeners();
    initUploadImagenes();

    function initMapa() {
        // Inicializar mapa centrado en Santa Marta
        mapa = L.map('mapa-ubicacion').setView([11.2408, -74.1990], 13);
        
        L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
            attribution: '&copy; OpenStreetMap &copy; CARTO',
            maxZoom: 20
        }).addTo(mapa);
        
        // Agregar marcador inicial
        marcador = L.marker([11.2408, -74.1990], {
            draggable: true
        }).addTo(mapa);
        
        marcador.bindPopup('Ubicación del escenario').openPopup();
        
        // Actualizar coordenadas al mover marcador
        marcador.on('dragend', function(e) {
            const pos = e.target.getLatLng();
            console.log('Nueva ubicación:', pos.lat, pos.lng);
        });
    }

    function initEventListeners() {
        // Botón de ubicación actual
        document.getElementById('btnUbicacion').addEventListener('click', obtenerUbicacionActual);
        
        // Botones de formulario
        document.getElementById('btnGuardarBorrador').addEventListener('click', guardarBorrador);
        document.getElementById('escenarioForm').addEventListener('submit', publicarEscenario);
        
        // Modal actions
        document.getElementById('btnVerEscenario').addEventListener('click', verEscenario);
        document.getElementById('btnAgregarOtro').addEventListener('click', agregarOtroEscenario);
        
        // Validación en tiempo real
        initValidaciones();
    }

    function initUploadImagenes() {
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('imagenes');
        const previewContainer = document.getElementById('imagenesPreview');
        
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
        const previewContainer = document.getElementById('imagenesPreview');
        
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
                
                // Mover mapa y marcador
                mapa.setView([lat, lng], 15);
                marcador.setLatLng([lat, lng]);
                
                // Obtener dirección (reverse geocoding)
                obtenerDireccion(lat, lng);
                
                btn.innerHTML = textoOriginal;
                btn.disabled = false;
            },
            function(error) {
                console.error('Error obteniendo ubicación:', error);
                alert('No se pudo obtener tu ubicación. Asegúrate de permitir el acceso a la ubicación.');
                btn.innerHTML = textoOriginal;
                btn.disabled = false;
            }
        );
    }

    function obtenerDireccion(lat, lng) {
        // En una implementación real, usarías un servicio de geocoding
        // Por ahora solo actualizamos los campos de ciudad y barrio
        document.getElementById('ciudad').value = 'Santa Marta';
        document.getElementById('barrio').value = 'Tu ubicación actual';
    }

    function initValidaciones() {
        // Validación de precio
        const precioInput = document.getElementById('precio_hora');
        precioInput.addEventListener('blur', function() {
            const valor = parseInt(this.value);
            if (valor < 10000) {
                this.value = 10000;
            }
        });
        
        // Validación de teléfono
        const telefonoInput = document.getElementById('telefono');
        telefonoInput.addEventListener('input', function() {
            this.value = this.value.replace(/\D/g, '').substring(0, 10);
        });
    }

    function validarFormulario() {
        const requiredFields = document.querySelectorAll('[required]');
        let valido = true;
        
        for (let field of requiredFields) {
            if (!field.value.trim()) {
                field.style.borderColor = 'var(--error)';
                valido = false;
                
                // Scroll to first error
                if (valido === false) {
                    field.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    field.focus();
                    break;
                }
            } else {
                field.style.borderColor = '#e9ecef';
            }
        }
        
        if (imagenesSeleccionadas.length === 0) {
            alert('Por favor agrega al menos una imagen del escenario');
            valido = false;
        }
        
        return valido;
    }

    function guardarBorrador() {
        if (!validarFormulario()) return;
        
        const formData = prepararDatosFormulario();
        formData.append('estado', 'borrador');
        
        // Simular guardado
        console.log('Guardando borrador:', Object.fromEntries(formData));
        
        // Mostrar feedback
        alert('Borrador guardado exitosamente');
    }

    function publicarEscenario(e) {
        e.preventDefault();
        
        if (!validarFormulario()) return;
        
        const btn = document.getElementById('btnPublicar');
        const textoOriginal = btn.innerHTML;
        
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Publicando...';
        btn.disabled = true;
        
        const formData = prepararDatosFormulario();
        formData.append('estado', 'publicado');
        
        // Simular envío al servidor
        setTimeout(() => {
            console.log('Publicando escenario:', Object.fromEntries(formData));
            mostrarConfirmacion();
            btn.innerHTML = textoOriginal;
            btn.disabled = false;
        }, 2000);
    }

    function prepararDatosFormulario() {
        const formData = new FormData();
        const form = document.getElementById('escenarioForm');
        
        // Agregar campos del formulario
        const fields = ['nombre', 'tipo_deporte', 'capacidad', 'direccion', 'ciudad', 'barrio', 
                       'precio_hora', 'telefono', 'whatsapp', 'descripcion'];
        
        fields.forEach(field => {
            const element = document.getElementById(field) || document.querySelector(`[name="${field}"]`);
            if (element) formData.append(field, element.value);
        });
        
        // Agregar características
        const caracteristicas = ['techada', 'iluminacion', 'vestieres', 'parqueadero', 'banios', 'gradas'];
        caracteristicas.forEach(caracteristica => {
            const checkbox = document.querySelector(`[name="${caracteristica}"]`);
            formData.append(caracteristica, checkbox.checked ? '1' : '0');
        });
        
        // Agregar horarios
        const horarios = ['horario_lv_inicio', 'horario_lv_fin', 'horario_sab_inicio', 
                         'horario_sab_fin', 'horario_dom_inicio', 'horario_dom_fin'];
        horarios.forEach(horario => {
            const input = document.querySelector(`[name="${horario}"]`);
            if (input) formData.append(horario, input.value);
        });
        
        // Agregar coordenadas
        const pos = marcador.getLatLng();
        formData.append('latitud', pos.lat);
        formData.append('longitud', pos.lng);
        
        // Agregar imágenes
        imagenesSeleccionadas.forEach((imagen, index) => {
            formData.append(`imagen_${index}`, imagen);
        });
        
        return formData;
    }

    function mostrarConfirmacion() {
        document.getElementById('modalConfirmacion').classList.add('active');
    }

    function verEscenario() {
        // Redirigir a la página del escenario
        window.location.href = 'mis-escenarios.html';
    }

    function agregarOtroEscenario() {
        // Limpiar formulario y recargar
        document.getElementById('escenarioForm').reset();
        document.getElementById('imagenesPreview').innerHTML = '';
        imagenesSeleccionadas = [];
        actualizarContadorImagenes();
        document.getElementById('modalConfirmacion').classList.remove('active');
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
});