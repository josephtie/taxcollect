<template>
  <div class="relative w-full h-full">
    <div ref="mapContainer" class="w-full h-full rounded-lg overflow-hidden" :style="{ height: height, minHeight: '400px' }"></div>
    <div v-if="drawnGeoJson" class="absolute bottom-2 left-2 bg-white/90 px-3 py-1 rounded-lg text-xs text-gray-700 shadow">
      Polygone dessiné ({{ vertexCount }} points)
    </div>
    <div v-if="isDrawing" class="absolute top-2 left-1/2 -translate-x-1/2 bg-blue-600 text-white px-4 py-2 rounded-lg text-sm shadow-lg z-[1000] whitespace-nowrap">
      {{ drawHint }}
    </div>
    <div v-if="containmentViolation" class="absolute top-2 left-1/2 -translate-x-1/2 bg-red-600 text-white px-4 py-2 rounded-lg text-sm shadow-lg z-[1000] whitespace-nowrap flex items-center space-x-2">
      <AlertTriangle class="w-4 h-4" />
      <span>Le polygone dépasse les limites du parent ({{ containmentViolationName }})</span>
    </div>
    <!-- Parent layers legend -->
    <div v-if="parentLayers.length > 0" class="absolute bottom-2 right-2 bg-white/90 px-3 py-2 rounded-lg text-xs shadow space-y-1">
      <div v-for="pl in parentLayers" :key="pl.type" class="flex items-center space-x-2">
        <span class="w-4 h-0.5" :style="{ backgroundColor: parentStyleMap[pl.type]?.color }"></span>
        <span class="text-gray-700">{{ pl.name || pl.type }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import '@geoman-io/leaflet-geoman-free'
import '@geoman-io/leaflet-geoman-free/dist/leaflet-geoman.css'
import * as turf from '@turf/turf'
import { AlertTriangle } from 'lucide-vue-next'

const props = defineProps({
  height: { type: String, default: '400px' },
  initialGeoJson: { type: String, default: null },
  center: { type: Array, default: () => [5.2048, -3.7467] },
  zoom: { type: Number, default: 13 },
  existingPolygons: { type: Array, default: () => [] },
  editable: { type: Boolean, default: true },
  highlightGeoJson: { type: String, default: null },
  parentLayers: { type: Array, default: () => [] }
})

const typeColors = {
  commune: '#3b82f6',
  zone: '#10b981',
  quartier: '#f59e0b',
  secteur: '#8b5cf6'
}

const parentStyleMap = {
  commune: { color: '#3b82f6', weight: 4, fillOpacity: 0.05, dashArray: '10, 6' },
  zone: { color: '#10b981', weight: 3, fillOpacity: 0.05, dashArray: '8, 4' },
  quartier: { color: '#f59e0b', weight: 2, fillOpacity: 0.05, dashArray: '6, 3' }
}

const emit = defineEmits(['polygon-drawn', 'polygon-cleared', 'containment-violation'])

const mapContainer = ref(null)
const drawnGeoJson = ref(null)
const vertexCount = ref(0)
const isDrawing = ref(false)
const drawHint = ref('Cliquez sur la carte pour placer les points du polygone')
const containmentViolation = ref(false)
const containmentViolationName = ref('')
let map = null
let drawnItems = null
let existingLayers = []
let highlightLayer = null
let parentRenderLayers = []
let pmControlsActive = false

const fixLeafletIcons = () => {
  delete L.Icon.Default.prototype._getIconUrl
  L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png'
  })
}

const layerToGeoJson = (layer) => {
  const geoJson = layer.toGeoJSON()
  // layer.toGeoJSON() returns a Feature { type: "Feature", geometry: {...}, properties: {} }
  // Backend expects raw geometry { type: "Polygon"/"MultiPolygon", coordinates: [...] }
  const geometry = geoJson.geometry || geoJson
  return JSON.stringify(geometry)
}

const countVertices = (layer) => {
  const latlngs = layer.getLatLngs()
  if (latlngs && latlngs[0]) {
    if (Array.isArray(latlngs[0][0])) {
      return latlngs[0][0].length
    }
    return latlngs[0].length
  }
  return 0
}

const loadGeoJsonOnMap = (geoJsonStr, style = {}) => {
  if (!geoJsonStr) return null
  try {
    const geoJson = JSON.parse(geoJsonStr)
    const layer = L.geoJSON(geoJson, {
      style: {
        color: style.color || '#3388ff',
        weight: 2,
        fillOpacity: 0.2,
        ...style
      }
    })
    return layer
  } catch (e) {
    return null
  }
}

const clearDrawn = () => {
  if (drawnItems) {
    drawnItems.clearLayers()
    drawnGeoJson.value = null
    vertexCount.value = 0
    emit('polygon-cleared')
  }
}

const setGeoJson = (geoJsonStr) => {
  if (!drawnItems) return
  drawnItems.clearLayers()
  if (!geoJsonStr) {
    drawnGeoJson.value = null
    vertexCount.value = 0
    return
  }
  const layer = loadGeoJsonOnMap(geoJsonStr, { color: '#dc2626' })
  if (layer) {
    layer.eachLayer(l => {
      drawnItems.addLayer(l)
      drawnGeoJson.value = geoJsonStr
      vertexCount.value = countVertices(l)
    })
  }
}

const invalidateMapSize = () => {
  if (map) {
    map.invalidateSize()
  }
}

defineExpose({ clearDrawn, setGeoJson, getGeoJson: () => drawnGeoJson.value, invalidateMapSize, isWithinParent: () => !containmentViolation.value })

let resizeObserver = null

onMounted(() => {
  fixLeafletIcons()

  map = L.map(mapContainer.value).setView(props.center, props.zoom)

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors',
    maxZoom: 19
  }).addTo(map)

  // Layer for drawn items
  drawnItems = new L.FeatureGroup()
  map.addLayer(drawnItems)

  // Load parent layers, existing polygons, and highlight
  renderParentLayers()
  renderExistingPolygons()
  renderHighlight()

  // Load initial GeoJSON if provided (for edit mode)
  if (props.initialGeoJson) {
    setGeoJson(props.initialGeoJson)
  }

  // Geoman events
  map.on('pm:drawstart', (e) => {
    if (e.shape === 'Polygon') {
      isDrawing.value = true
      drawHint.value = 'Cliquez sur la carte pour placer les points. Continuez à cliquer pour ajouter des sommets.'
    }
  })

  map.on('pm:vertexadded', (e) => {
    if (e.shape === 'Polygon') {
      const count = e.layer && e.layer.getLatLngs ? countVertices(e.layer) : 0
      drawHint.value = `${count} point(s). Continuez à cliquer. Double-clic ou cliquez sur le 1er point pour fermer.`
    }
  })

  map.on('pm:create', (e) => {
    // Clear previous drawn layers, keep only the latest
    drawnItems.clearLayers()
    const layer = e.layer
    drawnItems.addLayer(layer)

    const geoJson = layerToGeoJson(layer)
    drawnGeoJson.value = geoJson
    vertexCount.value = countVertices(layer)
    isDrawing.value = false

    validateContainment(geoJson)
    emit('polygon-drawn', geoJson)
  })

  map.on('pm:edit', (e) => {
    const layer = e.layer
    const geoJson = layerToGeoJson(layer)
    drawnGeoJson.value = geoJson
    vertexCount.value = countVertices(layer)
    validateContainment(geoJson)
    emit('polygon-drawn', geoJson)
  })

  map.on('pm:remove', (e) => {
    drawnGeoJson.value = null
    vertexCount.value = 0
    emit('polygon-cleared')
  })

  map.on('pm:drawend', () => {
    isDrawing.value = false
  })

  // Add Geoman controls if editable at mount
  if (props.editable) {
    addPmControls()
  }

  // Fix size after mount — critical for flex/100% height containers
  nextTick(() => {
    if (map) map.invalidateSize()
  })
  setTimeout(() => { if (map) map.invalidateSize() }, 100)
  setTimeout(() => { if (map) map.invalidateSize() }, 300)
  setTimeout(() => { if (map) map.invalidateSize() }, 500)
  setTimeout(() => { if (map) map.invalidateSize() }, 1000)

  // Watch for container resize
  if (window.ResizeObserver) {
    resizeObserver = new ResizeObserver(() => {
      if (map) map.invalidateSize()
    })
    resizeObserver.observe(mapContainer.value)
  }
})

onUnmounted(() => {
  if (resizeObserver) {
    resizeObserver.disconnect()
    resizeObserver = null
  }
  if (map) {
    map.remove()
    map = null
  }
})

const renderExistingPolygons = () => {
  if (!map) return
  existingLayers.forEach(l => map.removeLayer(l))
  existingLayers = []

  if (!props.existingPolygons || props.existingPolygons.length === 0) return

  const hasHighlight = !!props.highlightGeoJson

  props.existingPolygons.forEach((poly) => {
    const color = typeColors[poly._type] || '#3388ff'

    if (poly.geometryGeoJson) {
      const style = {
        color: color,
        fillOpacity: hasHighlight ? 0.05 : 0.15,
        weight: hasHighlight ? 1 : 2,
        opacity: hasHighlight ? 0.3 : 1.0
      }
      const layer = loadGeoJsonOnMap(poly.geometryGeoJson, style)
      if (layer) {
        layer.addTo(map)
        existingLayers.push(layer)
        if (poly.nom) {
          layer.bindTooltip(poly.nom, { permanent: false, direction: 'center' })
        }
      }
    }

    if (poly.latitude && poly.longitude) {
      const marker = L.circleMarker([poly.latitude, poly.longitude], {
        radius: hasHighlight ? 4 : 6,
        color: color,
        fillColor: color,
        fillOpacity: hasHighlight ? 0.3 : 0.8,
        weight: hasHighlight ? 1 : 2
      })
      marker.addTo(map)
      if (poly.nom) {
        marker.bindTooltip(poly.nom, { permanent: false, direction: 'top' })
      }
      existingLayers.push(marker)
    }
  })
}

const renderParentLayers = () => {
  if (!map) return
  parentRenderLayers.forEach(l => map.removeLayer(l))
  parentRenderLayers = []
  if (!props.parentLayers || props.parentLayers.length === 0) return

  props.parentLayers.forEach((pl) => {
    if (!pl.geoJson) return
    const style = parentStyleMap[pl.type] || { color: '#6b7280', weight: 2, fillOpacity: 0.05 }
    const layer = loadGeoJsonOnMap(pl.geoJson, style)
    if (layer) {
      layer.addTo(map)
      parentRenderLayers.push(layer)
      if (pl.name) {
        layer.bindTooltip(pl.name, { permanent: false, direction: 'center', className: 'parent-tooltip' })
      }
    }
  })
}

const validateContainment = (geoJsonStr) => {
  containmentViolation.value = false
  containmentViolationName.value = ''
  if (!geoJsonStr || !props.parentLayers || props.parentLayers.length === 0) {
    emit('containment-violation', false)
    return
  }
  try {
    const drawnFeature = JSON.parse(geoJsonStr)
    for (const pl of props.parentLayers) {
      if (!pl.geoJson) continue
      const parentFeature = JSON.parse(pl.geoJson)
      const isWithin = turf.booleanWithin(drawnFeature, parentFeature)
      if (!isWithin) {
        containmentViolation.value = true
        containmentViolationName.value = pl.name || pl.type
        emit('containment-violation', true)
        return
      }
    }
    emit('containment-violation', false)
  } catch (e) {
    emit('containment-violation', false)
  }
}

const renderHighlight = () => {
  if (!map) return
  if (highlightLayer) {
    map.removeLayer(highlightLayer)
    highlightLayer = null
  }
  if (!props.highlightGeoJson) return

  const layer = loadGeoJsonOnMap(props.highlightGeoJson, {
    color: '#059669',
    weight: 4,
    fillOpacity: 0.10,
    dashArray: '8, 4'
  })
  if (layer) {
    layer.addTo(map)
    highlightLayer = layer
    // Fit map bounds to the highlighted polygon
    try {
      const bounds = layer.getBounds()
      if (bounds.isValid()) {
        map.fitBounds(bounds, { padding: [40, 40] })
      }
    } catch (e) {}
  }
}

const addPmControls = () => {
  if (pmControlsActive || !map) return
  map.pm.addControls({
    position: 'topleft',
    drawPolygon: true,
    editMode: true,
    removalMode: true,
    drawPolyline: false,
    drawRectangle: false,
    drawCircle: false,
    drawCircleMarker: false,
    drawMarker: false,
    drawText: false,
    cutPolygon: false,
    rotateLayer: false,
  })
  map.pm.setPathOptions({
    color: '#dc2626',
    weight: 3,
    fillOpacity: 0.20,
  })
  pmControlsActive = true
}

const removePmControls = () => {
  if (map && pmControlsActive) {
    map.pm.removeControls()
    pmControlsActive = false
  }
  if (drawnItems) {
    drawnItems.clearLayers()
    drawnGeoJson.value = null
    vertexCount.value = 0
  }
}

watch(() => props.existingPolygons, () => {
  renderExistingPolygons()
}, { deep: true })

watch(() => props.highlightGeoJson, () => {
  renderExistingPolygons()
  renderHighlight()
})

watch(() => props.parentLayers, () => {
  renderParentLayers()
  if (drawnGeoJson.value) validateContainment(drawnGeoJson.value)
}, { deep: true })

watch(() => props.editable, (newVal) => {
  if (!map) return
  if (newVal) {
    addPmControls()
  } else {
    removePmControls()
  }
})

watch(() => props.initialGeoJson, (newVal) => {
  if (!map) return
  if (newVal) {
    setGeoJson(newVal)
  } else {
    clearDrawn()
  }
})
</script>
