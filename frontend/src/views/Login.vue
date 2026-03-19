<template>
  <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
    <div class="sm:mx-auto sm:w-full sm:max-w-md">
      <!-- Logo -->
      <div class="flex justify-center">
        <div class="flex items-center">
          <div class="w-12 h-12 bg-primary-600 rounded-lg flex items-center justify-center">
            <span class="text-white font-bold text-xl">T</span>
          </div>
          <span class="ml-3 text-2xl font-bold text-gray-900">TaxCollect</span>
        </div>
      </div>
      
      <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
        Connexion à votre compte
      </h2>
      <p class="mt-2 text-center text-sm text-gray-600">
        Tableau de bord de gestion des taxes
      </p>
    </div>

    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-white py-8 px-4 shadow-soft sm:rounded-lg sm:px-10">
        <form class="space-y-6" @submit.prevent="handleLogin">
          <div>
            <label for="username" class="form-label">
              Nom d'utilisateur
            </label>
            <div class="mt-1">
              <input
                id="username"
                v-model="form.username"
                name="username"
                type="text"
                autocomplete="username"
                required
                class="form-input"
                placeholder="admin"
              />
            </div>
          </div>

          <div>
            <label for="password" class="form-label">
              Mot de passe
            </label>
            <div class="mt-1">
              <input
                id="password"
                v-model="form.password"
                name="password"
                type="password"
                autocomplete="current-password"
                required
                class="form-input"
                placeholder="••••••••"
              />
            </div>
          </div>

          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <input
                id="remember-me"
                v-model="form.rememberMe"
                name="remember-me"
                type="checkbox"
                class="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
              />
              <label for="remember-me" class="ml-2 block text-sm text-gray-900">
                Se souvenir de moi
              </label>
            </div>

            <div class="text-sm">
              <a href="#" class="font-medium text-primary-600 hover:text-primary-500">
                Mot de passe oublié?
              </a>
            </div>
          </div>

          <div>
            <button
              type="submit"
              :disabled="loading"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <div v-if="loading" class="flex items-center">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Connexion en cours...
              </div>
              <span v-else>Se connecter</span>
            </button>
          </div>

          <div v-if="error" class="rounded-md bg-danger-50 p-4">
            <div class="flex">
              <div class="flex-shrink-0">
                <XCircle class="h-5 w-5 text-danger-400" />
              </div>
              <div class="ml-3">
                <h3 class="text-sm font-medium text-danger-800">
                  Erreur de connexion
                </h3>
                <div class="mt-2 text-sm text-danger-700">
                  {{ error }}
                </div>
              </div>
            </div>
          </div>
        </form>

        <div class="mt-6">
          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300" />
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-2 bg-white text-gray-500">Ou</span>
            </div>
          </div>

          <div class="mt-6 grid grid-cols-2 gap-3">
            <button
              @click="loginAs('ADMIN')"
              class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 transition-colors"
            >
              Admin
            </button>

            <button
              @click="loginAs('TRESOR')"
              class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 transition-colors"
            >
              Trésor
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Demo credentials info -->
    <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
      <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <Info class="h-5 w-5 text-blue-400" />
          </div>
          <div class="ml-3">
            <h3 class="text-sm font-medium text-blue-800">
              Identifiants de démonstration
            </h3>
            <div class="mt-2 text-sm text-blue-700">
              <p><strong>Admin:</strong> admin / password</p>
              <p><strong>Trésor:</strong> tresor / password</p>
              <p><strong>Agent:</strong> alix / alix123</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { XCircle, Info } from 'lucide-vue-next'

const router = useRouter()

const form = ref({
  username: '',
  password: '',
  rememberMe: false
})

const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  loading.value = true
  error.value = ''

  try {
    // Utiliser Keycloak pour l'authentification
    const { authService } = await import('@/services/authService')
    const result = await authService.login(form.value.username, form.value.password)
    
    if (result.success) {
      // Rediriger vers le dashboard
      router.push('/dashboard')
    } else {
      error.value = result.error || 'Erreur de connexion'
    }
  } catch (err) {
    console.error('Erreur login:', err)
    error.value = 'Une erreur est survenue lors de la connexion'
  } finally {
    loading.value = false
  }
}

const loginAs = (role) => {
  if (role === 'ADMIN') {
    form.value.username = 'admin'
    form.value.password = 'password'
  } else if (role === 'TRESOR') {
    form.value.username = 'tresor'
    form.value.password = 'password'
  }
}
</script>
