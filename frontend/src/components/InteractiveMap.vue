<template>
  <div class="map-container">
    <div id="map" class="map"></div>
    
    <!-- Popup pour les détails de zone -->
    <div
      v-if="popupZone"
      class="absolute bg-white rounded-lg shadow-lg p-4 z-10"
      :style="{ top: popupPosition.y + 'px', left: popupPosition.x + 'px' }"
    >
      <div class="flex justify-between items-start mb-2">
        <h4 class="font-semibold text-gray-900">{{ popupZone.nom }}</h4>
        <button @click="closePopup" class="text-gray-400 hover:text-gray-600">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
      <div class="space-y-1 text-sm">
        <p><span class="font-medium">Contribuables:</span> {{ popupZone.contribuables }}</p>
        <p><span class="font-medium">Collecteurs:</span> {{ popupZone.collecteurs }}</p>
        <p class="text-xs text-gray-500">{{ popupZone.description }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'

const props = defineProps({
  zones: {
    type: Array,
    required: true
  },
  selectedZone: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['zone-selected', 'zone-clicked'])

// Reactive data
const map = ref(null)
const mapInstance = ref(null)
const markers = ref([])
const popupZone = ref(null)
const popupPosition = ref({ x: 0, y: 0 })

// Methods
const initMap = () => {
  if (typeof window.L === 'undefined') {
    console.warn('Leaflet non chargé')
    return
  }

  // Initialiser la carte centrée sur Grand-Bassam, Côte d'Ivoire
  mapInstance.value = window.L.map('map').setView([5.2043, -3.7394], 13)

  // Ajouter la couche de tuiles OpenStreetMap
  window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 19
  }).addTo(mapInstance.value)

  // Ajouter les marqueurs pour chaque zone
  updateMarkers()
}

const updateMarkers = () => {
  if (!mapInstance.value) return

  // Supprimer les marqueurs existants
  markers.value.forEach(marker => {
    mapInstance.value.removeLayer(marker)
  })
  markers.value = []

  // Ajouter les nouveaux marqueurs
  props.zones.forEach(zone => {
    if (zone.coordinates) {
      const marker = window.L.marker([zone.coordinates.lat, zone.coordinates.lng])
        .addTo(mapInstance.value)
        .bindTooltip(zone.nom, { permanent: false, direction: 'top' })

      // Couleur du marqueur selon le statut
      const iconColor = getMarkerColor(zone)
      
      marker.setIcon(window.L.divIcon({
        html: `<div class="custom-marker" style="background-color: ${iconColor}">
          <span class="marker-text">${zone.contribuables}</span>
        </div>`,
        className: 'custom-div-icon',
        iconSize: [30, 30],
        iconAnchor: [15, 15]
      }))

      // Événement de clic
      marker.on('click', () => {
        showPopup(zone, marker)
        emit('zone-clicked', zone)
      })

      markers.value.push(marker)
    }
  })
}

const getMarkerColor = (zone) => {
  // Couleur selon le nombre de contribuables
  if (zone.contribuables > 200) return '#dc2626' // rouge
  if (zone.contribuables > 100) return '#f59e0b' // orange
  return '#10b981' // vert
}

const showPopup = (zone, marker) => {
  const popup = window.L.popup()
    .setLatLng(marker.getLatLng())
    .setContent(`
      <div class="p-3">
        <h4 class="font-semibold">${zone.nom}</h4>
        <p class="text-sm text-gray-600">${zone.contribuables} contribuables</p>
        <p class="text-sm text-gray-600">${zone.collecteurs} collecteurs</p>
        <button onclick="window.selectZoneFromMap(${zone.id})" 
                class="mt-2 px-3 py-1 bg-primary-500 text-white text-xs rounded hover:bg-primary-600">
          Voir détails
        </button>
      </div>
    `)
    .openOn(mapInstance.value)

  // Stocker la référence pour la sélection globale
  window.currentZoneData = zone
}

const closePopup = () => {
  popupZone.value = null
}

const selectZoneFromMap = (zoneId) => {
  const zone = props.zones.find(z => z.id === zoneId)
  if (zone) {
    emit('zone-selected', zone)
  }
}

// Rendre la fonction disponible globalement pour le onclick dans le popup
window.selectZoneFromMap = selectZoneFromMap

// Watchers
watch(() => props.zones, () => {
  updateMarkers()
}, { deep: true })

watch(() => props.selectedZone, (newZone) => {
  if (newZone && mapInstance.value && newZone.coordinates) {
    mapInstance.value.setView([newZone.coordinates.lat, newZone.coordinates.lng], 14)
  }
})

// Lifecycle
onMounted(() => {
  // Charger Leaflet dynamiquement
  if (typeof window.L === 'undefined') {
    const link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css'
    document.head.appendChild(link)

    const script = document.createElement('script')
    script.src = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js'
    script.onload = () => {
      initMap()
    }
    document.head.appendChild(script)
  } else {
    initMap()
  }
})

onUnmounted(() => {
  if (mapInstance.value) {
    mapInstance.value.remove()
  }
  delete window.selectZoneFromMap
})
</script>

<style scoped>
.map-container {
  position: relative;
  height: 400px;
  border-radius: 0.5rem;
  overflow: hidden;
}

.map {
  height: 100%;
  width: 100%;
  z-index: 1;
}

/* Styles pour les marqueurs personnalisés */
:global(.custom-marker) {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.2);
  font-weight: bold;
  color: white;
  font-size: 10px;
}

:global(.marker-text) {
  font-size: 10px;
  font-weight: bold;
}

:global(.custom-div-icon) {
  background: transparent !important;
  border: none !important;
}

/* Popup styles */
.absolute {
  position: absolute;
  z-index: 1000;
}

/* Leaflet popup styles */
:global(.leaflet-popup-content-wrapper) {
  border-radius: 0.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

:global(.leaflet-popup-content) {
  margin: 0;
  font-family: inherit;
}
</style>
