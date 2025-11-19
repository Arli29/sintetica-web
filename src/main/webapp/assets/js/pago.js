document.addEventListener('DOMContentLoaded', function() {
    // Variables globales
    let metodoPagoSeleccionado = 'tarjeta';
    
    // Inicializar
    initEventListeners();
    initFormValidation();

    function initEventListeners() {
        // Selección de método de pago
        document.querySelectorAll('.metodo-card').forEach(card => {
            card.addEventListener('click', function() {
                seleccionarMetodoPago(this.dataset.metodo);
            });
        });

        // Formatear número de tarjeta
        document.getElementById('numeroTarjeta').addEventListener('input', formatearNumeroTarjeta);
        
        // Formatear fecha de vencimiento
        document.getElementById('fechaVencimiento').addEventListener('input', formatearFechaVencimiento);
        
        // Validar CVV
        document.getElementById('cvv').addEventListener('input', validarCVV);
        
        // Botón de pago
        document.getElementById('btnPagar').addEventListener('click', procesarPago);
        
        // Modal actions
        document.getElementById('closeModal').addEventListener('click', cerrarModal);
        document.getElementById('btnVerReserva').addEventListener('click', verReserva);
        document.getElementById('btnNuevaReserva').addEventListener('click', nuevaReserva);
        
        // Enter en formulario
        document.getElementById('tarjetaForm').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                procesarPago();
            }
        });
    }

    function initFormValidation() {
        // Validación en tiempo real
        const inputs = document.querySelectorAll('#tarjetaForm input');
        inputs.forEach(input => {
            input.addEventListener('blur', validarCampo);
            input.addEventListener('input', limpiarError);
        });
    }

    function seleccionarMetodoPago(metodo) {
        metodoPagoSeleccionado = metodo;
        
        // Remover selección anterior
        document.querySelectorAll('.metodo-card').forEach(card => {
            card.classList.remove('selected');
        });
        
        // Agregar selección actual
        document.querySelector(`.metodo-card[data-metodo="${metodo}"]`).classList.add('selected');
        
        // Mostrar formulario correspondiente
        document.querySelectorAll('.formulario-tarjeta, .formulario-pse, .formulario-efectivo').forEach(form => {
            form.classList.remove('active');
        });
        
        document.getElementById(`form-${metodo}`).classList.add('active');
        
        // Actualizar texto del botón de pago
        actualizarBotonPago();
    }

    function formatearNumeroTarjeta(e) {
        let input = e.target;
        let value = input.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
        let formattedValue = '';
        
        for (let i = 0; i < value.length; i++) {
            if (i > 0 && i % 4 === 0) {
                formattedValue += ' ';
            }
            formattedValue += value[i];
        }
        
        input.value = formattedValue;
        
        // Detectar tipo de tarjeta
        detectarTipoTarjeta(value);
    }

    function detectarTipoTarjeta(numero) {
        const cardIcons = document.querySelectorAll('.card-icon');
        cardIcons.forEach(icon => icon.style.opacity = '0.3');
        
        if (/^4/.test(numero)) {
            document.querySelector('.card-icon.visa').style.opacity = '1';
        } else if (/^5[1-5]/.test(numero)) {
            document.querySelector('.card-icon.mastercard').style.opacity = '1';
        }
    }

    function formatearFechaVencimiento(e) {
        let input = e.target;
        let value = input.value.replace(/\D/g, '');
        
        if (value.length >= 2) {
            value = value.substring(0, 2) + '/' + value.substring(2, 4);
        }
        
        input.value = value;
    }

    function validarCVV(e) {
        let input = e.target;
        input.value = input.value.replace(/\D/g, '').substring(0, 3);
    }

    function validarCampo(e) {
        const input = e.target;
        const value = input.value.trim();
        
        switch(input.id) {
            case 'numeroTarjeta':
                if (!validarNumeroTarjeta(value)) {
                    mostrarError(input, 'Número de tarjeta inválido');
                }
                break;
                
            case 'fechaVencimiento':
                if (!validarFechaVencimiento(value)) {
                    mostrarError(input, 'Fecha de vencimiento inválida');
                }
                break;
                
            case 'cvv':
                if (!validarCVVNumero(value)) {
                    mostrarError(input, 'CVV debe tener 3 dígitos');
                }
                break;
                
            case 'nombreTitular':
                if (value.length < 3) {
                    mostrarError(input, 'Nombre demasiado corto');
                }
                break;
                
            case 'emailFactura':
                if (!validarEmail(value)) {
                    mostrarError(input, 'Email inválido');
                }
                break;
        }
    }

    function validarNumeroTarjeta(numero) {
        // Limpiar espacios
        const cleanNumero = numero.replace(/\s/g, '');
        return cleanNumero.length >= 13 && cleanNumero.length <= 19 && /^\d+$/.test(cleanNumero);
    }

    function validarFechaVencimiento(fecha) {
        if (!/^\d{2}\/\d{2}$/.test(fecha)) return false;
        
        const [mes, ano] = fecha.split('/').map(Number);
        const ahora = new Date();
        const añoActual = ahora.getFullYear() % 100;
        const mesActual = ahora.getMonth() + 1;
        
        if (mes < 1 || mes > 12) return false;
        if (ano < añoActual) return false;
        if (ano === añoActual && mes < mesActual) return false;
        
        return true;
    }

    function validarCVVNumero(cvv) {
        return cvv.length === 3 && /^\d+$/.test(cvv);
    }

    function validarEmail(email) {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    function mostrarError(input, mensaje) {
        // Remover error anterior
        limpiarError({ target: input });
        
        // Agregar estilo de error
        input.style.borderColor = 'var(--error)';
        
        // Crear elemento de error
        const errorElement = document.createElement('div');
        errorElement.className = 'error-message';
        errorElement.style.color = 'var(--error)';
        errorElement.style.fontSize = '12px';
        errorElement.style.marginTop = '5px';
        errorElement.textContent = mensaje;
        
        input.parentNode.appendChild(errorElement);
    }

    function limpiarError(e) {
        const input = e.target;
        input.style.borderColor = '#e9ecef';
        
        const errorElement = input.parentNode.querySelector('.error-message');
        if (errorElement) {
            errorElement.remove();
        }
    }

    function actualizarBotonPago() {
        const btnPagar = document.getElementById('btnPagar');
        const total = document.querySelector('.total-amount').textContent;
        
        switch(metodoPagoSeleccionado) {
            case 'tarjeta':
                btnPagar.innerHTML = `<i class="fas fa-lock"></i> Pagar ${total}`;
                break;
            case 'pse':
                btnPagar.innerHTML = `<i class="fas fa-university"></i> Pagar con PSE ${total}`;
                break;
            case 'efectivo':
                btnPagar.innerHTML = `<i class="fas fa-money-bill-wave"></i> Reservar (Pagar en cancha)`;
                break;
        }
    }

    function validarFormularioCompleto() {
        if (metodoPagoSeleccionado !== 'tarjeta') return true;
        
        const inputs = [
            'numeroTarjeta',
            'nombreTitular',
            'fechaVencimiento',
            'cvv',
            'emailFactura'
        ];
        
        for (let id of inputs) {
            const input = document.getElementById(id);
            if (!input.value.trim()) {
                mostrarError(input, 'Este campo es requerido');
                input.focus();
                return false;
            }
        }
        
        if (!document.getElementById('aceptarTerminos').checked) {
            alert('Debes aceptar los términos y condiciones para continuar');
            return false;
        }
        
        return true;
    }

    function procesarPago() {
        if (!validarFormularioCompleto()) return;
        
        // Simular procesamiento de pago
        const btnPagar = document.getElementById('btnPagar');
        const textoOriginal = btnPagar.innerHTML;
        
        btnPagar.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
        btnPagar.disabled = true;
        
        // Simular delay de red
        setTimeout(() => {
            mostrarConfirmacion();
            btnPagar.innerHTML = textoOriginal;
            btnPagar.disabled = false;
        }, 2000);
    }

    function mostrarConfirmacion() {
        document.getElementById('modalConfirmacion').classList.add('active');
        
        // Actualizar detalles en el modal según el método de pago
        const metodoTexto = {
            'tarjeta': 'Tarjeta crédito/débito',
            'pse': 'PSE',
            'efectivo': 'Efectivo (en cancha)'
        };
        
        document.querySelector('.confirmacion-detalles p:last-child').innerHTML = 
            `<strong>Método de pago:</strong> ${metodoTexto[metodoPagoSeleccionado]}`;
    }

    function cerrarModal() {
        document.getElementById('modalConfirmacion').classList.remove('active');
    }

    function verReserva() {
        // Redirigir a página de mis reservas
        window.location.href = 'mis-reservas.html';
    }

    function nuevaReserva() {
        // Redirigir a búsqueda de escenarios
        window.location.href = 'index.html#escenarios';
    }

    // Inicializar con tarjeta seleccionada
    seleccionarMetodoPago('tarjeta');
});