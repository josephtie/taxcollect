<template>
  <span 
    :class="badgeClasses" 
    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
  >
    <component :is="statusIcon" class="w-3 h-3 mr-1" />
    {{ statusText }}
  </span>
</template>

<script setup>
import { computed } from 'vue'
import { 
  CheckCircle, 
  XCircle, 
  Clock, 
  AlertCircle,
  UserCheck,
  UserX,
  Wifi,
  WifiOff
} from 'lucide-vue-next'

const props = defineProps({
  status: {
    type: String,
    required: true
  },
  type: {
    type: String,
    default: 'transaction', // 'transaction', 'agent', 'cloture'
  }
})

const statusConfig = computed(() => {
  if (props.type === 'agent') {
    const agentConfigs = {
      'En ligne': {
        color: 'success',
        icon: Wifi,
        text: 'En ligne'
      },
      'Hors ligne': {
        color: 'gray',
        icon: WifiOff,
        text: 'Hors ligne'
      },
      'ACTIF': {
        color: 'success',
        icon: UserCheck,
        text: 'Actif'
      },
      'INACTIF': {
        color: 'danger',
        icon: UserX,
        text: 'Inactif'
      }
    }
    return agentConfigs[props.status] || {
      color: 'gray',
      icon: Clock,
      text: props.status
    }
  }

  if (props.type === 'cloture') {
    const clotureConfigs = {
      'EN_COURS': {
        color: 'warning',
        icon: Clock,
        text: 'En cours'
      },
      'SOUMISE': {
        color: 'primary',
        icon: AlertCircle,
        text: 'Soumise'
      },
      'VALIDEE': {
        color: 'success',
        icon: CheckCircle,
        text: 'Validée'
      },
      'REJETEE': {
        color: 'danger',
        icon: XCircle,
        text: 'Rejetée'
      },
      'DEPOSEE': {
        color: 'success',
        icon: CheckCircle,
        text: 'Déposée'
      }
    }
    return clotureConfigs[props.status] || {
      color: 'gray',
      icon: Clock,
      text: props.status
    }
  }

  // Transaction par défaut
  const transactionConfigs = {
    'EN_ATTENTE': {
      color: 'warning',
      icon: Clock,
      text: 'En attente'
    },
    'VALIDEE': {
      color: 'success',
      icon: CheckCircle,
      text: 'Validée'
    },
    'ANNULEE': {
      color: 'danger',
      icon: XCircle,
      text: 'Annulée'
    },
    'SYNCHRONISEE': {
      color: 'success',
      icon: CheckCircle,
      text: 'Synchronisée'
    },
    'EN_ERREUR': {
      color: 'danger',
      icon: XCircle,
      text: 'En erreur'
    }
  }
  return transactionConfigs[props.status] || {
    color: 'gray',
    icon: Clock,
    text: props.status
  }
})

const badgeClasses = computed(() => {
  const colorMap = {
    success: 'bg-success-100 text-success-800',
    danger: 'bg-danger-100 text-danger-800',
    warning: 'bg-warning-100 text-warning-800',
    primary: 'bg-primary-100 text-primary-800',
    gray: 'bg-gray-100 text-gray-800'
  }
  return colorMap[statusConfig.value.color] || colorMap.gray
})

const statusIcon = computed(() => statusConfig.value.icon)
const statusText = computed(() => statusConfig.value.text)
</script>
