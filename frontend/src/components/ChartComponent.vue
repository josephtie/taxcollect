<template>
  <div class="bg-white rounded-lg shadow-soft p-6 border border-gray-100">
    <div class="flex items-center justify-between mb-6">
      <h3 class="text-lg font-semibold text-gray-900">{{ title }}</h3>
      <div v-if="showLegend" class="flex items-center space-x-4">
        <div class="flex items-center">
          <div class="w-3 h-3 bg-primary-600 rounded-full mr-2"></div>
          <span class="text-sm text-gray-600">{{ legendLabel }}</span>
        </div>
      </div>
    </div>
    
    <div class="relative" :style="{ height: height }">
      <canvas ref="chartCanvas"></canvas>
    </div>
    
    <div v-if="loading" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick, computed, onUnmounted } from 'vue'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js/auto'

// Enregistrer les composants Chart.js (auto-register avec chart.js/auto)
// ChartJS.register() n'est plus nécessaire avec 'chart.js/auto'

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: 'bar', // 'bar' or 'line'
  },
  data: {
    type: Array,
    required: true
  },
  height: {
    type: String,
    default: '300px'
  },
  loading: {
    type: Boolean,
    default: false
  },
  showLegend: {
    type: Boolean,
    default: true
  },
  legendLabel: {
    type: String,
    default: 'Montant collecté'
  },
  color: {
    type: String,
    default: '#3b82f6' // primary-600
  }
})

const chartCanvas = ref(null)
let chartInstance = null

const chartData = computed(() => {
  return {
    labels: props.data.map(item => item.date || item.label),
    datasets: [
      {
        label: props.legendLabel,
        data: props.data.map(item => item.amount || item.value),
        backgroundColor: props.type === 'line' 
          ? `${props.color}20` 
          : props.color,
        borderColor: props.color,
        borderWidth: props.type === 'line' ? 2 : 1,
        borderRadius: props.type === 'bar' ? 6 : 0,
        fill: props.type === 'line',
        tension: props.type === 'line' ? 0.4 : 0,
        pointBackgroundColor: props.color,
        pointBorderColor: '#fff',
        pointBorderWidth: 2,
        pointRadius: props.type === 'line' ? 4 : 0,
        pointHoverRadius: props.type === 'line' ? 6 : 0
      }
    ]
  }
})

const chartOptions = computed(() => {
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false // On utilise notre propre légende
      },
      tooltip: {
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        padding: 12,
        titleColor: '#fff',
        bodyColor: '#fff',
        borderColor: props.color,
        borderWidth: 1,
        displayColors: false,
        callbacks: {
          label: (context) => {
            const value = context.parsed.y
            return new Intl.NumberFormat('fr-FR', {
              style: 'currency',
              currency: 'XOF',
              minimumFractionDigits: 0,
              maximumFractionDigits: 0
            }).format(value)
          }
        }
      }
    },
    scales: {
      x: {
        grid: {
          display: false
        },
        ticks: {
          color: '#6b7280',
          font: {
            size: 12
          }
        }
      },
      y: {
        beginAtZero: true,
        grid: {
          color: '#f3f4f6',
          drawBorder: false
        },
        ticks: {
          color: '#6b7280',
          font: {
            size: 12
          },
          callback: (value) => {
            return new Intl.NumberFormat('fr-FR', {
              style: 'currency',
              currency: 'XOF',
              minimumFractionDigits: 0,
              maximumFractionDigits: 0
            }).format(value)
          }
        }
      }
    },
    interaction: {
      intersect: false,
      mode: 'index'
    },
    animation: {
      duration: 750,
      easing: 'easeInOutQuart'
    }
  }
})

const createChart = () => {
  if (!chartCanvas.value) return
  
  // Détruire le graphique existant avec vérification
  if (chartInstance) {
    try {
      chartInstance.destroy()
    } catch (error) {
      console.warn('Error destroying chart:', error)
    }
    chartInstance = null
  }
  
  const ctx = chartCanvas.value.getContext('2d')
  
  // Utiliser ChartJS avec le type approprié
  chartInstance = new ChartJS(ctx, {
    type: props.type,
    data: chartData.value,
    options: chartOptions.value
  })
}

const updateChart = () => {
  if (!chartInstance) return
  
  chartInstance.data = chartData.value
  chartInstance.update('active')
}

watch(() => props.data, () => {
  nextTick(() => {
    if (chartInstance) {
      updateChart()
    } else {
      createChart()
    }
  })
}, { deep: true })

watch(() => props.type, () => {
  nextTick(() => {
    createChart()
  })
})

onMounted(() => {
  nextTick(() => {
    createChart()
  })
})

// Nettoyage amélioré
onUnmounted(() => {
  if (chartInstance) {
    try {
      chartInstance.destroy()
      chartInstance = null
    } catch (error) {
      console.warn('Error destroying chart on unmount:', error)
    }
  }
})
</script>
