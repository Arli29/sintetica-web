document.addEventListener('DOMContentLoaded', function() {
    // Variables globales
    let currentDate = new Date(2025, 0, 1); // Enero 2025
    let selectedDate = null;
    let selectedTime = null;
    let selectedDuration = 1;
    const precioPorHora = 50000;

    // Inicializar
    initCalendar();
    generateTimeSlots();
    initEventListeners();
    updateSummary();

    function initCalendar() {
        updateCalendar();
    }

    function updateCalendar() {
        const monthNames = [
            "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
            "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
        ];
        
        // Actualizar mes actual
        document.getElementById('currentMonth').textContent = 
            `${monthNames[currentDate.getMonth()]} ${currentDate.getFullYear()}`;
        
        // Generar días del calendario
        const calendarDays = document.getElementById('calendarDays');
        calendarDays.innerHTML = '';

        const firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
        const lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
        const today = new Date();

        // Días vacíos al inicio
        const startDay = firstDay.getDay() === 0 ? 6 : firstDay.getDay() - 1; // Lunes como primer día
        for (let i = 0; i < startDay; i++) {
            const emptyDay = document.createElement('div');
            emptyDay.className = 'day empty';
            calendarDays.appendChild(emptyDay);
        }

        // Días del mes
        for (let day = 1; day <= lastDay.getDate(); day++) {
            const dayElement = document.createElement('div');
            dayElement.className = 'day';
            dayElement.textContent = day;
            
            const currentDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), day);
            
            // Marcar día actual
            if (currentDay.toDateString() === today.toDateString()) {
                dayElement.classList.add('today');
            }
            
            // Marcar día seleccionado
            if (selectedDate && currentDay.toDateString() === selectedDate.toDateString()) {
                dayElement.classList.add('selected');
            }

            // Deshabilitar días pasados
            if (currentDay < new Date(today.getFullYear(), today.getMonth(), today.getDate())) {
                dayElement.classList.add('disabled');
            }

            dayElement.addEventListener('click', function() {
                if (!this.classList.contains('disabled') && !this.classList.contains('empty')) {
                    selectDate(currentDay);
                }
            });
            
            calendarDays.appendChild(dayElement);
        }
    }

    function generateTimeSlots() {
        const amSlots = document.getElementById('amSlots');
        const pmSlots = document.getElementById('pmSlots');
        
        amSlots.innerHTML = '';
        pmSlots.innerHTML = '';

        // Generar horarios AM (6:00 AM - 11:00 AM)
        for (let hour = 6; hour < 12; hour++) {
            const timeSlot = createTimeSlot(hour, 'AM');
            amSlots.appendChild(timeSlot);
        }

        // Generar horarios PM (12:00 PM - 10:00 PM)
        for (let hour = 12; hour < 23; hour++) {
            const timeSlot = createTimeSlot(hour, 'PM');
            pmSlots.appendChild(timeSlot);
        }
    }

    function createTimeSlot(hour, period) {
        const timeSlot = document.createElement('button');
        const displayHour = hour > 12 ? hour - 12 : hour;
        timeSlot.textContent = `${displayHour}:00 ${period}`;
        timeSlot.className = 'time-slot';
        timeSlot.dataset.hour = hour;
        timeSlot.dataset.period = period;

        // Simular disponibilidad (en una app real esto vendría del backend)
        const isAvailable = Math.random() > 0.3; // 70% de disponibilidad
        if (!isAvailable) {
            timeSlot.classList.add('disabled');
        }

        timeSlot.addEventListener('click', function() {
            if (!this.classList.contains('disabled')) {
                selectTime(hour, period);
            }
        });
        
        return timeSlot;
    }

    function selectDate(date) {
        selectedDate = date;
        
        // Remover selección anterior de días
        document.querySelectorAll('.day.selected').forEach(day => {
            day.classList.remove('selected');
        });
        
        // Agregar selección actual
        const dayElements = document.querySelectorAll('.day');
        dayElements.forEach(day => {
            if (day.textContent == date.getDate() && !day.classList.contains('empty')) {
                day.classList.add('selected');
            }
        });

        updateSummary();
        checkContinueButton();
    }

    function selectTime(hour, period) {
        // Remover selección anterior
        document.querySelectorAll('.time-slot.selected').forEach(slot => {
            slot.classList.remove('selected');
        });

        // Agregar selección actual
        const selectedSlot = document.querySelector(`.time-slot[data-hour="${hour}"][data-period="${period}"]`);
        if (selectedSlot && !selectedSlot.classList.contains('disabled')) {
            selectedSlot.classList.add('selected');
            selectedTime = { hour, period };
        }

        updateSummary();
        checkContinueButton();
    }

    function initEventListeners() {
        // Navegación del calendario
        document.getElementById('prevMonth').addEventListener('click', () => {
            currentDate.setMonth(currentDate.getMonth() - 1);
            updateCalendar();
        });

        document.getElementById('nextMonth').addEventListener('click', () => {
            currentDate.setMonth(currentDate.getMonth() + 1);
            updateCalendar();
        });

        // Duración
        document.querySelectorAll('.duracion-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                document.querySelectorAll('.duracion-btn').forEach(b => b.classList.remove('selected'));
                e.target.classList.add('selected');
                selectedDuration = parseInt(e.target.dataset.hours);
                updateSummary();
            });
        });

        // Cupón
        document.getElementById('applyCupon').addEventListener('click', applyCupon);

        // Enter en input de cupón
        document.getElementById('cuponInput').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                applyCupon();
            }
        });

        // Botón continuar
        document.getElementById('continueBtn').addEventListener('click', continuarReserva);

        // Seleccionar primer duración por defecto
        document.querySelector('.duracion-btn').classList.add('selected');
    }

    function updateSummary() {
        // Fecha
        if (selectedDate) {
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            document.getElementById('selected-date').textContent = 
                selectedDate.toLocaleDateString('es-ES', options);
        }

        // Hora
        if (selectedTime) {
            const displayHour = selectedTime.hour > 12 ? selectedTime.hour - 12 : selectedTime.hour;
            document.getElementById('selected-time').textContent = 
                `${displayHour}:00 ${selectedTime.period}`;
            
            // Calcular hora fin
            const endHour = selectedTime.hour + selectedDuration;
            let endPeriod = 'AM';
            let displayEndHour = endHour;
            
            if (endHour >= 12) {
                endPeriod = 'PM';
                if (endHour > 12) {
                    displayEndHour = endHour - 12;
                }
            }
            
            // Manejar medianoche
            if (endHour >= 24) {
                displayEndHour = endHour - 24;
                endPeriod = 'AM';
            }
            
            document.getElementById('end-time').textContent = 
                `${displayEndHour}:00 ${endPeriod}`;
        }

        // Duración y precio
        document.getElementById('selected-duration').textContent = 
            `${selectedDuration} hora${selectedDuration > 1 ? 's' : ''}`;
        document.getElementById('total-hours').textContent = selectedDuration;

        const total = precioPorHora * selectedDuration;
        document.querySelector('.total-amount').textContent = `$${total.toLocaleString()}`;
    }

    function applyCupon() {
        const cuponInput = document.getElementById('cuponInput');
        const discountAmount = document.querySelector('.discount-amount');
        const cuponValue = cuponInput.value.trim().toUpperCase();
        
        // Cupones disponibles
        const cupones = {
            'SINTETICA10': 0.10,
            'SINTETICA15': 0.15,
            'SINTETICA20': 0.20,
            'BIENVENIDO25': 0.25
        };

        if (cupones[cuponValue]) {
            const total = precioPorHora * selectedDuration;
            const discount = Math.round(total * cupones[cuponValue]);
            discountAmount.textContent = `-$${discount.toLocaleString()}`;
            discountAmount.style.color = 'var(--success)';
            
            const finalTotal = total - discount;
            document.querySelector('.total-amount').textContent = `$${finalTotal.toLocaleString()}`;
            
            // Feedback visual
            cuponInput.style.borderColor = 'var(--success)';
            setTimeout(() => {
                cuponInput.style.borderColor = '#e9ecef';
            }, 2000);
            
        } else if (cuponValue === '') {
            discountAmount.textContent = '-$0';
            updateSummary();
        } else {
            discountAmount.textContent = '-$0';
            cuponInput.style.borderColor = 'var(--error)';
            setTimeout(() => {
                cuponInput.style.borderColor = '#e9ecef';
            }, 2000);
        }
    }

    function checkContinueButton() {
        const continueBtn = document.getElementById('continueBtn');
        if (selectedDate && selectedTime) {
            continueBtn.disabled = false;
            continueBtn.classList.add('enabled');
        } else {
            continueBtn.disabled = true;
            continueBtn.classList.remove('enabled');
        }
    }

    function continuarReserva() {
        if (!selectedDate || !selectedTime) return;

        // Aquí iría la lógica para avanzar al siguiente paso
        // Por ahora solo mostramos un alert
        const displayHour = selectedTime.hour > 12 ? selectedTime.hour - 12 : selectedTime.hour;
        const total = precioPorHora * selectedDuration;
        
        alert(`✅ Reserva confirmada:\n\n📅 Fecha: ${selectedDate.toLocaleDateString('es-ES')}\n⏰ Hora: ${displayHour}:00 ${selectedTime.period}\n⏱️ Duración: ${selectedDuration} hora${selectedDuration > 1 ? 's' : ''}\n💰 Total: $${total.toLocaleString()}\n\nSerás redirigido al pago...`);
        
        // En una implementación real, aquí redirigiríamos al paso de pago
        // window.location.href = 'pago.html';
    }
});