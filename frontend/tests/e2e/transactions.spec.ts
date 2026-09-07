import { test, expect } from '@playwright/test'
import { mockLogin } from './helpers/auth'

test.describe('Transactions', () => {
  test.beforeEach(async ({ page }) => {
    await mockLogin(page)
    await page.goto('/transactions')
    await expect(page).toHaveURL(/transactions/)
  })

  test('E2E-TR-01: Tableau transactions chargé', async ({ page }) => {
    await expect(page.locator('[data-testid="transactions-table"]')).toBeVisible()
  })

  test('E2E-TR-02: Filtrage par date', async ({ page }) => {
    await page.fill('[data-testid="filter-date-start"]', '2026-01-01')
    await page.fill('[data-testid="filter-date-end"]', '2026-06-30')
    await page.click('button:has-text("Appliquer")')
    await expect(page.locator('[data-testid="transactions-table"]')).toBeVisible()
  })

  test('E2E-TR-03: Export CSV — menu visible', async ({ page }) => {
    await page.click('button:has-text("Exporter")')
    await expect(page.locator('[data-testid="export-csv"]')).toBeVisible()
  })

  test('E2E-TR-04: Export XLSX — menu visible', async ({ page }) => {
    await page.click('button:has-text("Exporter")')
    await expect(page.locator('[data-testid="export-xlsx"]')).toBeVisible()
  })
})
