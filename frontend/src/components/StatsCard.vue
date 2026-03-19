<template>
  <div class="bg-white rounded-lg shadow-soft p-6 border border-gray-100">
    <div class="flex items-center justify-between">
      <div>
        <p class="text-sm font-medium text-gray-600">{{ title }}</p>
        <p class="text-2xl font-bold text-gray-900 mt-1">
          {{ formattedValue }}
        </p>
        <div v-if="showChange && change !== null" class="flex items-center mt-2">
          <component 
            :is="changeIcon" 
            :class="changeColor" 
            class="w-4 h-4 mr-1"
          />
          <span :class="changeColor" class="text-sm font-medium">
            {{ formattedChange }}
          </span>
        </div>
      </div>
      <div :class="iconBgColor" class="p-3 rounded-lg">
        <component :is="icon" :class="iconColor" class="w-6 h-6" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { 
  TrendingUp, 
  TrendingDown, 
  DollarSign, 
  Users, 
  CreditCard, 
  Smartphone,
  Calendar,
  Activity
} from 'lucide-vue-next'

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  value: {
    type: [Number, String],
    required: true
  },
  icon: {
    type: [String, Object, Function],
    required: true
  },
  change: {
    type: Number,
    default: null
  },
  changeType: {
    type: String,
    default: 'percentage', // 'percentage' or 'absolute'
  },
  iconColor: {
    type: String,
    default: 'text-primary-600'
  },
  iconBgColor: {
    type: String,
    default: 'bg-primary-50'
  },
  format: {
    type: String,
    default: 'number' // 'number', 'currency', 'percentage'
  }
})

const showChange = computed(() => props.change !== null)

const changeIcon = computed(() => {
  if (props.change > 0) return TrendingUp
  if (props.change < 0) return TrendingDown
  return Activity
})

const changeColor = computed(() => {
  if (props.change > 0) return 'text-success-600'
  if (props.change < 0) return 'text-danger-600'
  return 'text-gray-600'
})

const formattedValue = computed(() => {
  if (props.format === 'currency') {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'XOF',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(props.value)
  }
  
  if (props.format === 'percentage') {
    return `${props.value}%`
  }
  
  return new Intl.NumberFormat('fr-FR').format(props.value)
})

const formattedChange = computed(() => {
  if (props.changeType === 'percentage') {
    return `${Math.abs(props.change).toFixed(1)}%`
  }
  
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(Math.abs(props.change))
})
</script>
