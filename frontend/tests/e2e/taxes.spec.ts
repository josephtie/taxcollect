import { test, expect } from '@playwright/test'
import { mockLogin } from './helpers/auth'

test.describe('Taxes', () => {
  test.beforeEach(async ({ page }) => {
    await mockLogin(page)
    await page.goto('/taxes')
    await expect(page).toHaveURL(/taxes/)
  })

  test('E2E-TX-01: Tableau taxes chargé', async ({ page }) => {
    await expect(page.locator('[data-testid="taxes-table"]')).toBeVisible()
    await expect(page.locator('[data-testid="taxes-table"] table thead')).toContainText(/Nom/)
    await expect(page.locator('[data-testid="taxes-table"] table thead')).toContainText(/Périodicité/)
  })

  test('E2E-TX-02: Tableau avis avec colonne Référence', async ({ page }) => {
    // Switch to avis tab
    await page.click('button:has-text("Avis d\'imposition")')
    await expect(page.locator('[data-testid="avis-table"]')).toBeVisible()
    await expect(page.locator('[data-testid="avis-table"] thead')).toContainText(/Référence/)
    await expect(page.locator('[data-testid="avis-table"] thead')).toContainText(/Taxe/)
  })

  test('E2E-TX-03: Génération d\'avis', async ({ page }) => {
    // Switch to avis tab
    await page.click('button:has-text("Avis d\'imposition")')
    await expect(page.locator('[data-testid="generate-avis"]')).toBeVisible()
  })
})
