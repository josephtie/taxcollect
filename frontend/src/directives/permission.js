import { permissionService } from '@/services/permissionService'

// Directive v-permission pour contrôler l'affichage des éléments
export const permissionDirective = {
  mounted(el, binding) {
    const { value } = binding
    
    if (!value) {
      console.warn('v-permission: aucune permission spécifiée')
      return
    }

    // Vérifier si l'utilisateur a la permission requise
    const hasPermission = Array.isArray(value) 
      ? permissionService.hasAnyPermission(value)
      : permissionService.hasPermission(value)

    if (!hasPermission) {
      // Cacher l'élément si pas la permission
      el.style.display = 'none'
      el.setAttribute('aria-hidden', 'true')
    }
  },
  updated(el, binding) {
    // Recalculer si les permissions changent
    const { value } = binding
    
    if (!value) {
      el.style.display = ''
      el.removeAttribute('aria-hidden')
      return
    }

    const hasPermission = Array.isArray(value) 
      ? permissionService.hasAnyPermission(value)
      : permissionService.hasPermission(value)

    el.style.display = hasPermission ? '' : 'none'
    el.setAttribute('aria-hidden', !hasPermission)
  }
}

// Directive v-role pour contrôler l'affichage basé sur le rôle
export const roleDirective = {
  mounted(el, binding) {
    const { value } = binding
    
    if (!value) {
      console.warn('v-role: aucun rôle spécifié')
      return
    }

    const userRole = permissionService.getRole()
    const hasRole = Array.isArray(value) 
      ? value.includes(userRole)
      : userRole === value

    if (!hasRole) {
      el.style.display = 'none'
      el.setAttribute('aria-hidden', 'true')
    }
  },
  updated(el, binding) {
    const { value } = binding
    
    if (!value) {
      el.style.display = ''
      el.removeAttribute('aria-hidden')
      return
    }

    const userRole = permissionService.getRole()
    const hasRole = Array.isArray(value) 
      ? value.includes(userRole)
      : userRole === value

    el.style.display = hasRole ? '' : 'none'
    el.setAttribute('aria-hidden', !hasRole)
  }
}
