import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:9091',
        changeOrigin: true,
        secure: false,
      },
      // authService appelle /auth/login sans passer par l'instance axios :
      // sans cette règle, le login échoue en dev quand VITE_API_URL est vide.
      '/auth': {
        target: 'http://localhost:9091',
        changeOrigin: true,
        secure: false,
      },
      // Photos d'agents et pièces d'identité servies par le backend.
      '/uploads': {
        target: 'http://localhost:9091',
        changeOrigin: true,
        secure: false,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
  test: {
    globals: true,
    environment: 'jsdom',
    root: '.',
    include: ['src/**/*.{test,spec}.{js,jsx,ts,tsx}'],
  },
})
