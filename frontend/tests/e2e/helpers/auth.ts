import { Page } from '@playwright/test'

const ADMIN_USER = {
  nom: 'Admin',
  prenom: 'Super',
  role: 'ADMIN',
  username: 'admin',
}

export async function mockLogin(page: Page) {
  await page.addInitScript(() => {
    localStorage.setItem('authToken', 'mock-token-for-e2e')
    localStorage.setItem('refreshToken', 'mock-refresh-token')
    localStorage.setItem('user', JSON.stringify({
      nom: 'Admin',
      prenom: 'Super',
      role: 'ADMIN',
      username: 'admin',
    }))
  })
}

export async function clearAuth(page: Page) {
  await page.addInitScript(() => {
    localStorage.removeItem('authToken')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('user')
  })
}
