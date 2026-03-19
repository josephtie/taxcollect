<template>
  <slot v-if="hasPermission" />
  <div v-else-if="showFallback" class="permission-fallback">
    <div class="alert alert-warning">
      <svg class="w-4 h-4 inline mr-2" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
      </svg>
      {{ fallbackMessage }}
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { permissionService } from '@/services/permissionService'

const props = defineProps({
  // Permission requise (string ou array)
  permission: {
    type: [String, Array],
    required: true
  },
  // Mode de vérification: 'any' (au moins une) ou 'all' (toutes)
  mode: {
    type: String,
    default: 'any',
    validator: (value) => ['any', 'all'].includes(value)
  },
  // Message alternatif si pas la permission
  fallbackMessage: {
    type: String,
    default: "Vous n'avez pas les permissions nécessaires pour accéder à cette ressource."
  },
  // Afficher le message alternatif
  showFallback: {
    type: Boolean,
    default: false
  }
})

const hasPermission = computed(() => {
  if (Array.isArray(props.permission)) {
    return props.mode === 'any' 
      ? permissionService.hasAnyPermission(props.permission)
      : permissionService.hasAllPermissions(props.permission)
  }
  return permissionService.hasPermission(props.permission)
})
</script>

<style scoped>
.permission-fallback {
  padding: 1rem;
  text-align: center;
}

.alert {
  padding: 0.75rem 1rem;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  line-height: 1.25rem;
}

.alert-warning {
  background-color: #fef3c7;
  border: 1px solid #fbbf24;
  color: #92400e;
}
</style>
