// sintetica-home.js - Funcionalidades generales del sitio

document.addEventListener('DOMContentLoaded', function() {
    initUserMenu();
    initMobileMenu();
    initSmoothScroll();
    initSearchEnhancements();
    initFilterChips();
});

// Menú de usuario
function initUserMenu() {
    const btnUserMenu = document.getElementById('btnUserMenu');
    const userMenu = document.getElementById('userMenu');
    
    if (!btnUserMenu || !userMenu) return;
    
    btnUserMenu.addEventListener('click', function(e) {
        e.stopPropagation();
        const isExpanded = this.getAttribute('aria-expanded') === 'true';
        this.setAttribute('aria-expanded', !isExpanded);
        userMenu.hidden = isExpanded;
        
        if (!isExpanded) {
            userMenu.style.animation = 'slideDown 0.2s ease-out';
        }
    });
    
    // Cerrar menú al hacer clic fuera
    document.addEventListener('click', function() {
        if (btnUserMenu && userMenu) {
            btnUserMenu.setAttribute('aria-expanded', 'false');
            userMenu.hidden = true;
        }
    });
    
    // Prevenir que el clic en el menú lo cierre
    if (userMenu) {
        userMenu.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
}

// Menú móvil (si existe)
function initMobileMenu() {
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const mainNav = document.querySelector('.main-nav');
    
    if (mobileMenuBtn && mainNav) {
        mobileMenuBtn.addEventListener('click', function() {
            mainNav.classList.toggle('active');
            this.classList.toggle('active');
        });
    }
}

// Scroll suave para anclas
function initSmoothScroll() {
    const links = document.querySelectorAll('a[href^="#"]');
    
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            
            // Solo aplicar scroll suave para anclas internas
            if (href !== '#' && href.startsWith('#')) {
                e.preventDefault();
                const target = document.querySelector(href);
                
                if (target) {
                    const headerHeight = document.querySelector('.site-header')?.offsetHeight || 0;
                    const targetPosition = target.offsetTop - headerHeight - 20;
                    
                    window.scrollTo({
                        top: targetPosition,
                        behavior: 'smooth'
                    });
                    
                    // Actualizar URL sin recargar
                    history.pushState(null, null, href);
                }
            }
        });
    });
}

// Mejoras para búsqueda
function initSearchEnhancements() {
    const searchInput = document.querySelector('input[type="search"]');
    const searchForm = document.querySelector('.search');
    
    if (searchInput && searchForm) {
        // Limpiar búsqueda con Escape
        searchInput.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                this.value = '';
                this.blur();
            }
        });
        
        // Búsqueda automática con debounce (opcional para futuras implementaciones)
        let searchTimeout;
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            // Aquí se podría implementar búsqueda en tiempo real
        });
    }
}

// Chips de filtros
function initFilterChips() {
    const filterChips = document.querySelectorAll('.chips button');
    
    filterChips.forEach(chip => {
        chip.addEventListener('click', function() {
            // Remover clase activa de todos los chips
            filterChips.forEach(c => c.classList.remove('active'));
            
            // Agregar clase activa al chip clickeado
            this.classList.add('active');
            
            // Aquí se podría agregar lógica para filtrado en tiempo real
            // si se implementa AJAX en el futuro
        });
    });
}

// Funciones utilitarias
const Sintetica = {
    // Formatear precio
    formatPrice: function(price) {
        return new Intl.NumberFormat('es-CO', {
            style: 'currency',
            currency: 'COP',
            minimumFractionDigits: 0
        }).format(price);
    },
    
    // Mostrar notificación
    showNotification: function(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <span>${message}</span>
            <button class="notification-close">&times;</button>
        `;
        
        document.body.appendChild(notification);
        
        // Animación de entrada
        setTimeout(() => notification.classList.add('show'), 100);
        
        // Cerrar notificación
        notification.querySelector('.notification-close').addEventListener('click', () => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        });
        
        // Auto-remover después de 5 segundos
        setTimeout(() => {
            if (notification.parentNode) {
                notification.classList.remove('show');
                setTimeout(() => notification.remove(), 300);
            }
        }, 5000);
    },
    
    // Cargar más elementos (para paginación futura)
    loadMore: function(container, url, page) {
        // Implementación básica para cargar más elementos vía AJAX
        fetch(`${url}?page=${page}`)
            .then(response => response.text())
            .then(html => {
                const tempDiv = document.createElement('div');
                tempDiv.innerHTML = html;
                const newElements = tempDiv.querySelector(container).innerHTML;
                document.querySelector(container).innerHTML += newElements;
            })
            .catch(error => {
                console.error('Error loading more content:', error);
                this.showNotification('Error al cargar más contenido', 'error');
            });
    },
    
    // Validar formulario
    validateForm: function(form) {
        const inputs = form.querySelectorAll('input[required], select[required], textarea[required]');
        let isValid = true;
        
        inputs.forEach(input => {
            if (!input.value.trim()) {
                input.classList.add('error');
                isValid = false;
                
                // Scroll al primer error
                if (isValid === false) {
                    input.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    input.focus();
                }
            } else {
                input.classList.remove('error');
            }
        });
        
        return isValid;
    },
    
    // Limpiar validación
    clearValidation: function(form) {
        const inputs = form.querySelectorAll('.error');
        inputs.forEach(input => input.classList.remove('error'));
    }
};

// Estilos para notificaciones (se pueden agregar al CSS principal)
const notificationStyles = `
    .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 8px;
        color: white;
        z-index: 10000;
        transform: translateX(400px);
        transition: transform 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: space-between;
        min-width: 300px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    
    .notification.show {
        transform: translateX(0);
    }
    
    .notification-info {
        background: #3498db;
    }
    
    .notification-success {
        background: #27ae60;
    }
    
    .notification-warning {
        background: #f39c12;
    }
    
    .notification-error {
        background: #e74c3c;
    }
    
    .notification-close {
        background: none;
        border: none;
        color: white;
        font-size: 18px;
        cursor: pointer;
        margin-left: 15px;
        padding: 0;
        width: 20px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
`;

// Inyectar estilos de notificación
const styleSheet = document.createElement('style');
styleSheet.textContent = notificationStyles;
document.head.appendChild(styleSheet);

// Hacer funciones disponibles globalmente
window.Sintetica = Sintetica;

// Inicialización específica para la página de inicio
if (document.querySelector('.hero')) {
    // Configuraciones específicas para la página de inicio
    console.log('Página de inicio inicializada');
}
