// Script de débuggage pour les permissions
// À exécuter dans la console du navigateur

console.log('=== DEBUG PERMISSIONS ===')

// 1. Vider le localStorage
localStorage.clear()
console.log('LocalStorage vidé')

// 2. Simuler une connexion admin
const fakeToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Il9FZl9qM1p6Y3hQWGFZM1pYc3h5Mm9ZLVZzNnBvM0hJYkN6c0E3M0FZMm8ifQ.eyJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAvcmVhbG1zL21haXJpZSIsImF1ZCI6ImFjY291bnQiLCJleHAiOjE3MzY4OTI2MDAsIm5iZiI6MTczNjg5MjYwMCwic3ViIjoiYWRtaW4iLCJ0eXBlIjoiQmVhcmVyIiwiYXpwIjoidGF4LWJhY2tlbmQiLCJzZXNzaW9uX3N0YXRlIjoiMTIzNDU2Nzg5MCIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiQURNSU4iLCJ1bWFfcHJvdGVjdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7InRheC1iYWNrZW5kIjp7InJvbGVzIjpbIkFETUlOIl19fSwic2NvcGUiOiJvcGVuaWQgZW1haWwgcHJvZmlsZSIsImVtYWlsIjoiYWRtaW5AbWFpcmllLmNvbSIsInByZWZlcnJlZF91c2VybmFtZSI6ImFkbWluIiwiZ2l2ZW5fbmFtZSI6IkFkbWluIiwibmFtZSI6IkFkbWluIiwiZmFtaWx5X25hbWUiOiJBZG1pbiJ9.example'

// Parser le token pour voir les rôles
function parseJWT(token) {
  try {
    const base64Url = token.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)
    }).join(''))
    
    return JSON.parse(jsonPayload)
  } catch (error) {
    console.error('Erreur parsing JWT:', error)
    return null
  }
}

const payload = parseJWT(fakeToken)
console.log('Payload JWT test:', payload)

// 3. Tester la détection de rôle
function extractRoleFromToken(payload) {
  console.log('Payload JWT:', payload)
  
  if (payload.resource_access && payload.resource_access['tax-backend']) {
    const roles = payload.resource_access['tax-backend'].roles
    console.log('Roles from resource_access:', roles)
    const role = roles.includes('ADMIN') ? 'ADMIN' : 
                 roles.includes('TRESOR') ? 'TRESOR' : 
                 roles.includes('AGENT') ? 'AGENT' : 'USER'
    console.log('Role determined:', role)
    return role
  }
  
  const realmRoles = payload.realm_access?.roles || []
  console.log('Roles from realm_access:', realmRoles)
  const role = realmRoles[0] || 'USER'
  console.log('Role determined from realm:', role)
  return role
}

const role = extractRoleFromToken(payload)
console.log('Role final:', role)

// 4. Tester les permissions
const { ROLE_PERMISSIONS } = await import('./src/services/permissionService.js')
console.log('Permissions pour ADMIN:', ROLE_PERMISSIONS.ADMIN)

console.log('=== FIN DEBUG ===')
