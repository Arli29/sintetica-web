// perfil.js - Funcionalidades completas del perfil
document.addEventListener('DOMContentLoaded', function() {
    console.log('✅ perfil.js cargado correctamente');
    initializeProfilePage();
});

function initializeProfilePage() {
    setupEventListeners();
    setupModals();
    console.log('🎯 Perfil inicializado');
}

function setupEventListeners() {
    // Botón para cambiar avatar
    const changeAvatarBtn = document.getElementById('changeAvatarBtn');
    const avatarInput = document.getElementById('avatarInput');
    
    if (changeAvatarBtn && avatarInput) {
        changeAvatarBtn.addEventListener('click', function() {
            console.log('📸 Abriendo selector de imagen');
            avatarInput.click();
        });
        
        avatarInput.addEventListener('change', handleAvatarChange);
    }
    
    // Botón para cambiar contraseña
    const changePasswordBtn = document.getElementById('changePasswordBtn');
    if (changePasswordBtn) {
        changePasswordBtn.addEventListener('click', function() {
            console.log('🔓 Abriendo modal de contraseña');
            document.getElementById('passwordModal').classList.add('active');
            // Limpiar formulario
            const form = document.getElementById('passwordForm');
            if (form) form.reset();
        });
    }
    
    // Botón para eliminar cuenta
    const deleteAccountBtn = document.getElementById('deleteAccountBtn');
    if (deleteAccountBtn) {
        deleteAccountBtn.addEventListener('click', function() {
            console.log('🗑️ Abriendo modal de eliminación');
            document.getElementById('deleteModal').classList.add('active');
            // Resetear checkbox
            const checkbox = document.getElementById('confirmDelete');
            const button = document.getElementById('confirmDeleteBtn');
            if (checkbox) checkbox.checked = false;
            if (button) button.disabled = true;
        });
    }
    
    // Botón cancelar en formulario de perfil
    const cancelBtn = document.getElementById('cancelBtn');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', resetForm);
    }
    
    // Configurar formularios
    setupFormHandlers();
}

function setupModals() {
    // Modal de contraseña
    setupModal('passwordModal', 'closePasswordModal', 'cancelPasswordBtn');
    
    // Modal de eliminación
    setupModal('deleteModal', 'closeDeleteModal', 'cancelDeleteBtn');
    
    // Configurar checkbox de confirmación
    const confirmDelete = document.getElementById('confirmDelete');
    const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
    
    if (confirmDelete && confirmDeleteBtn) {
        confirmDelete.addEventListener('change', function() {
            confirmDeleteBtn.disabled = !this.checked;
        });
        
        // Configurar acción de eliminación
        confirmDeleteBtn.addEventListener('click', handleAccountDeletion);
    }
}

function setupModal(modalId, closeBtnId, cancelBtnId) {
    const modal = document.getElementById(modalId);
    const closeBtn = document.getElementById(closeBtnId);
    const cancelBtn = document.getElementById(cancelBtnId);
    
    if (modal) {
        // Cerrar al hacer clic fuera
        modal.addEventListener('click', function(e) {
            if (e.target === this) {
                this.classList.remove('active');
            }
        });
    }
    
    if (closeBtn) {
        closeBtn.addEventListener('click', function() {
            document.getElementById(modalId).classList.remove('active');
        });
    }
    
    if (cancelBtn) {
        cancelBtn.addEventListener('click', function() {
            document.getElementById(modalId).classList.remove('active');
        });
    }
}

function setupFormHandlers() {
    // Formulario de perfil
    const profileForm = document.getElementById('profileForm');
    if (profileForm) {
        profileForm.addEventListener('submit', function(e) {
            if (!validateProfileForm()) {
                e.preventDefault();
                return false;
            }
            showLoading(this, 'Guardando...');
            showNotification('Actualizando perfil...', 'info');
        });
    }
    
    // Formulario de contraseña
    const passwordForm = document.getElementById('passwordForm');
    if (passwordForm) {
        passwordForm.addEventListener('submit', function(e) {
            if (!validatePasswordForm()) {
                e.preventDefault();
                return false;
            }
            showLoading(this, 'Actualizando...');
            showNotification('Cambiando contraseña...', 'info');
        });
    }
}

function handleAvatarChange(e) {
    const file = e.target.files[0];
    if (file) {
        console.log('🖼️ Imagen seleccionada:', file.name, '- Tipo:', file.type, '- Tamaño:', (file.size / 1024).toFixed(2) + 'KB');
        
        // Validar tipo de archivo
        if (!file.type.match('image.*')) {
            showNotification('Por favor selecciona una imagen válida (JPEG, PNG, etc.)', 'error');
            return;
        }
        
        // Validar tamaño (máximo 2MB)
        if (file.size > 2 * 1024 * 1024) {
            showNotification('La imagen no debe superar los 2MB', 'error');
            return;
        }
        
        // Crear preview inmediato
        const reader = new FileReader();
        reader.onload = function(e) {
            const userAvatar = document.getElementById('userAvatar');
            if (userAvatar) {
                userAvatar.src = e.target.result;
                console.log('🖼️ Preview actualizado');
            }
        };
        reader.onerror = function() {
            showNotification('Error al cargar la imagen', 'error');
        };
        reader.readAsDataURL(file);
        
        // Enviar al servidor usando FormData
        uploadAvatar(file);
    }
}

function uploadAvatar(file) {
    console.log('📤 Enviando imagen al servidor...');
    
    showNotification('Subiendo imagen...', 'info');
    
    // Usar FormData para enviar el archivo
    const formData = new FormData();
    formData.append('avatar', file);
    
    // Hacer la petición fetch a la URL correcta
    fetch('actualizar-avatar', {
        method: 'POST',
        body: formData,
        headers: {
            // No establecer Content-Type, FormData lo hace automáticamente con boundary
        }
    })
    .then(response => {
        console.log('📨 Respuesta del servidor:', response.status, response.statusText);
        
        if (!response.ok) {
            // Si hay un error HTTP, obtener más detalles
            if (response.status === 404) {
                throw new Error('La ruta /actualizar-avatar no fue encontrada. Verifica la configuración del servidor.');
            } else if (response.status === 500) {
                throw new Error('Error interno del servidor al procesar la imagen.');
            } else {
                throw new Error(`Error ${response.status}: ${response.statusText}`);
            }
        }
        return response.text();
    })
    .then(result => {
        console.log('✅ Imagen subida exitosamente. Respuesta:', result);
        showNotification('Avatar actualizado correctamente', 'success');
        
        // Recargar la página después de un breve delay para ver la notificación
        setTimeout(() => {
            console.log('🔄 Recargando página...');
            window.location.reload();
        }, 1500);
    })
    .catch(error => {
        console.error('❌ Error subiendo avatar:', error);
        showNotification('Error al subir la imagen: ' + error.message, 'error');
        
        // Revertir preview en caso de error
        const userAvatar = document.getElementById('userAvatar');
        const avatarInput = document.getElementById('avatarInput');
        if (userAvatar && avatarInput) {
            // Resetear el input file
            avatarInput.value = '';
            // Opcional: Volver a la imagen original si quieres revertir el preview
            // userAvatar.src = userAvatar.dataset.originalSrc || userAvatar.src;
        }
    });
}

function handleAccountDeletion() {
    const confirmDelete = document.getElementById('confirmDelete');
    if (!confirmDelete || !confirmDelete.checked) {
        showNotification('Debes confirmar la eliminación de la cuenta', 'error');
        return;
    }
    
    console.log('🗑️ Iniciando eliminación de cuenta');
    showNotification('Eliminando cuenta...', 'info');
    
    // Crear formulario dinámico para eliminación
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = 'eliminar-cuenta';
    
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'confirmacion';
    input.value = 'true';
    
    form.appendChild(input);
    document.body.appendChild(form);
    
    // Mostrar loading en el botón
    const deleteBtn = document.getElementById('confirmDeleteBtn');
    if (deleteBtn) {
        deleteBtn.disabled = true;
        deleteBtn.textContent = 'Eliminando...';
        deleteBtn.classList.add('loading');
    }
    
    form.submit();
}

function validateProfileForm() {
    const nombre = document.getElementById('firstName').value.trim();
    const apellido = document.getElementById('lastName').value.trim();
    const email = document.getElementById('email').value.trim();
    
    if (!nombre || !apellido || !email) {
        showNotification('Por favor completa todos los campos obligatorios', 'error');
        return false;
    }
    
    if (!isValidEmail(email)) {
        showNotification('Por favor ingresa un email válido', 'error');
        return false;
    }
    
    return true;
}

function validatePasswordForm() {
    const currentPassword = document.getElementById('currentPassword').value;
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    if (!currentPassword || !newPassword || !confirmPassword) {
        showNotification('Todos los campos de contraseña son obligatorios', 'error');
        return false;
    }
    
    if (newPassword.length < 8) {
        showNotification('La nueva contraseña debe tener al menos 8 caracteres', 'error');
        return false;
    }
    
    if (newPassword !== confirmPassword) {
        showNotification('Las contraseñas nuevas no coinciden', 'error');
        return false;
    }
    
    return true;
}

function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

function resetForm() {
    showNotification('Cambios descartados', 'info');
    // Recargar la página para resetear los valores
    setTimeout(() => {
        window.location.reload();
    }, 1000);
}

function showLoading(form, text) {
    const submitBtn = form.querySelector('.btn-cta, .btn-danger');
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.textContent = text;
        submitBtn.classList.add('loading');
    }
}

// Sistema de notificaciones
function showNotification(message, type = 'info') {
    // Remover notificaciones existentes
    const existingNotifications = document.querySelectorAll('.custom-notification');
    existingNotifications.forEach(notification => {
        if (notification.parentNode) {
            notification.parentNode.removeChild(notification);
        }
    });
    
    // Crear elemento de notificación
    const notification = document.createElement('div');
    notification.className = `custom-notification notification-${type}`;
    notification.textContent = message;
    
    // Estilos de la notificación
    notification.style.position = 'fixed';
    notification.style.top = '20px';
    notification.style.right = '20px';
    notification.style.padding = '16px 24px';
    notification.style.borderRadius = '8px';
    notification.style.color = 'white';
    notification.style.fontWeight = '600';
    notification.style.zIndex = '10000';
    notification.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
    notification.style.transition = 'all 0.3s ease';
    notification.style.transform = 'translateX(100%)';
    notification.style.opacity = '0';
    notification.style.maxWidth = '400px';
    notification.style.fontFamily = '"Varela Round", sans-serif';
    notification.style.fontSize = '14px';
    
    // Colores según tipo
    const colors = {
        'success': { bg: '#10b981', border: '#059669' },
        'error': { bg: '#ef4444', border: '#dc2626' },
        'info': { bg: '#3b82f6', border: '#2563eb' }
    };
    
    const colorConfig = colors[type] || colors.info;
    notification.style.background = colorConfig.bg;
    notification.style.borderLeft = `4px solid ${colorConfig.border}`;
    
    // Agregar al DOM
    document.body.appendChild(notification);
    
    // Animación de entrada
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
        notification.style.opacity = '1';
    }, 10);
    
    // Remover después de 4 segundos
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        notification.style.opacity = '0';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 4000);
}

// Funciones globales para compatibilidad con onclick en HTML
window.mostrarModalPassword = function() {
    document.getElementById('passwordModal').classList.add('active');
};

window.cerrarModalPassword = function() {
    document.getElementById('passwordModal').classList.remove('active');
};

window.mostrarModalEliminar = function() {
    document.getElementById('deleteModal').classList.add('active');
};

window.cerrarModalEliminar = function() {
    document.getElementById('deleteModal').classList.remove('active');
    const checkbox = document.getElementById('confirmDelete');
    const button = document.getElementById('confirmDeleteBtn');
    if (checkbox) checkbox.checked = false;
    if (button) button.disabled = true;
};

// Manejar errores no capturados
window.addEventListener('error', function(e) {
    console.error('Error capturado:', e.error);
});

// Prevenir envío de formularios con Enter en campos no deseados
document.addEventListener('DOMContentLoaded', function() {
    // Prevenir que Enter envíe el formulario de avatar
    const avatarInput = document.getElementById('avatarInput');
    if (avatarInput) {
        avatarInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
            }
        });
    }
});

// Exportar funciones para uso global
window.ProfileManager = {
    initializeProfilePage,
    showNotification,
    validateProfileForm,
    validatePasswordForm,
    uploadAvatar,
    handleAvatarChange
};

// Debug: Verificar que todos los elementos necesarios estén presentes
function debugElements() {
    const elements = {
        'changeAvatarBtn': document.getElementById('changeAvatarBtn'),
        'avatarInput': document.getElementById('avatarInput'),
        'userAvatar': document.getElementById('userAvatar'),
        'changePasswordBtn': document.getElementById('changePasswordBtn'),
        'deleteAccountBtn': document.getElementById('deleteAccountBtn'),
        'passwordModal': document.getElementById('passwordModal'),
        'deleteModal': document.getElementById('deleteModal'),
        'profileForm': document.getElementById('profileForm'),
        'passwordForm': document.getElementById('passwordForm')
    };
    
    console.log('🔍 Debug de elementos:');
    for (const [name, element] of Object.entries(elements)) {
        console.log(`${name}:`, element ? '✅ Encontrado' : '❌ No encontrado');
    }
}

// Ejecutar debug al cargar (opcional)
// document.addEventListener('DOMContentLoaded', debugElements);