document.addEventListener('DOMContentLoaded', function() {
  setTimeout(initMap, 100);
});

function initMap() {
  const mapElement = document.getElementById('map');
  if (!mapElement) {
    console.error('Elemento #map no encontrado');
    return;
  }

  // Centro y zoom
  const SM_CENTER = [11.2408, -74.1990];
  const START_ZOOM = 14;

  // Escenarios
  const escenarios = [
    { 
      name: 'Estadio de Fútbol La Castellana', 
      type: 'Campo de fútbol', 
      coords: [11.22955, -74.19985], 
      img: 'img/castellana.jpg',
      price: '$50.000',
      distance: '1.3 km'
    },
    { 
      name: 'Estadio Sierra Nevada', 
      type: 'Campo de fútbol', 
      coords: [11.2479, -74.1815], 
      img: 'img/sierra_nevada.jpg',
      price: '$55.000',
      distance: '4.2 km'
    },
    { 
      name: 'Coliseo Menor', 
      type: 'Complejo de voleibol', 
      coords: [11.2385, -74.2110], 
      img: 'img/coliseo_menor.jpg',
      price: '$45.000',
      distance: '2.1 km'
    },
  ];

  // Mapa
  const map = L.map('map', { 
    zoomControl: true,
    dragging: true,
    scrollWheelZoom: true
  }).setView(SM_CENTER, START_ZOOM);

  // Basemap estilo Google Maps
  L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
    attribution: '&copy; OpenStreetMap &copy; CARTO',
    subdomains: 'abcd',
    maxZoom: 20
  }).addTo(map);

  // Marcadores estándar (como Google Maps)
  const bounds = [];
  escenarios.forEach(e => {
    // Crear marcador estándar
    const marker = L.marker(e.coords).addTo(map);
    
    // Popup informativo estilo tarjeta
    const html = `
      <div class="map-popup-card">
        <img class="popup-img" src="${e.img}" alt="${e.name}" />
        <div class="popup-content">
          <h3 class="popup-title">${e.name}</h3>
          <p class="popup-type">${e.type}</p>
          <div class="popup-details">
            <span class="popup-distance">${e.distance}</span>
            <span class="popup-price">${e.price}</span>
          </div>
          <a href="reserva.html?escenario=${encodeURIComponent(e.name)}" class="popup-btn">Reservar</a>
        </div>
      </div>
    `;
    
    marker.bindPopup(html, {
      className: 'custom-popup',
      maxWidth: 300
    });
    
    bounds.push(e.coords);
  });

  // Ajusta la vista
  if (bounds.length) {
    map.fitBounds(bounds, { padding: [40, 40], maxZoom: START_ZOOM });
  }

  setTimeout(() => {
    map.invalidateSize();
  }, 500);
}
