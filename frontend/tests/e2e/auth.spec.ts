import { test, expect } from '@playwright/test'
import { mockLogin, clearAuth } from './helpers/auth'

test.describe('Authentication', () => {
  test('E2E-AUTH-01: Login admin réussi', async ({ page }) => {
    await mockLogin(page)
    await page.goto('/dashboard')
    await expect(page).toHaveURL(/dashboard/)
    await expect(page.locator('h1')).toContainText(/Tableau de Bord/i)
  })

  test('E2E-AUTH-02: Login échec — credentials invalides', async ({ page }) => {
    await page.goto('/login')
    await page.fill('[data-testid="email-input"]', 'wronguser')
    await page.fill('[data-testid="password-input"]', 'wrongpassword')
    await page.click('[data-testid="login-button"]')
    await expect(page.locator('[data-testid="error-message"]')).toBeVisible({ timeout: 10000 })
  })

  test('E2E-AUTH-03: Accès sans auth → redirect login', async ({ page }) => {
    await clearAuth(page)
    await page.goto('/dashboard')
    await expect(page).toHaveURL(/login/)
  })

  test('E2E-AUTH-04: Logout', async ({ page }) => {
    await mockLogin(page)
    await page.goto('/dashboard')
    await expect(page).toHaveURL(/dashboard/)

    // Open user menu and logout
    await page.click('button:has-text("Admin")')
    await page.click('[data-testid="logout-button"]')
    await expect(page).toHaveURL(/login/)
  })
})
