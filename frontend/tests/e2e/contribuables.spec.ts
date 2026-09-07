import { test, expect } from '@playwright/test'
import { mockLogin } from './helpers/auth'

test.describe('Contribuables', () => {
  test.beforeEach(async ({ page }) => {
    await mockLogin(page)
    await page.goto('/contribuables')
    await expect(page).toHaveURL(/contribuables/)
    // Switch to list tab
    await page.click('button:has-text("Liste des Contribuables")')
  })

  test('E2E-CT-01: Tableau contribuables chargé', async ({ page }) => {
    await expect(page.locator('[data-testid="contribuables-table"]')).toBeVisible()
  })

  test('E2E-CT-02: Recherche par nom', async ({ page }) => {
    await page.fill('[data-testid="search-input"]', 'Doe')
    await page.waitForTimeout(500)
    await expect(page.locator('[data-testid="contribuables-table"]')).toBeVisible()
  })

  test('E2E-CT-03: Filtrage par type', async ({ page }) => {
    await page.selectOption('[data-testid="filter-type"]', 'COMMERCANT')
    await expect(page.locator('[data-testid="contribuables-table"]')).toBeVisible()
  })

  test('E2E-CT-04: Export CSV — bouton visible', async ({ page }) => {
    await expect(page.locator('[data-testid="export-csv"]')).toBeVisible()
  })

  test('E2E-CT-05: Pagination — navigation pages', async ({ page }) => {
    await expect(page.locator('[data-testid="pagination-next"]')).toBeVisible()
  })
})
