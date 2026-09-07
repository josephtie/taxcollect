import { test, expect } from '@playwright/test'
import { mockLogin } from './helpers/auth'

test.describe('Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    await mockLogin(page)
    await page.goto('/dashboard')
    await expect(page).toHaveURL(/dashboard/)
  })

  test('E2E-DB-01: KPIs visibles', async ({ page }) => {
    await expect(page.locator('[data-testid="kpi-cards"]')).toBeVisible()
  })

  test('E2E-DB-02: Navigation vers Transactions', async ({ page }) => {
    await page.goto('/transactions')
    await expect(page).toHaveURL(/transactions/)
    await expect(page.locator('h1')).toContainText(/Transactions/i)
  })

  test('E2E-DB-03: Navigation vers Contribuables', async ({ page }) => {
    await page.goto('/contribuables')
    await expect(page).toHaveURL(/contribuables/)
    await expect(page.locator('h1')).toContainText(/Contribuables/i)
  })
})
