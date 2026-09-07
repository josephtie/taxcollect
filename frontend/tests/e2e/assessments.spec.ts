import { test, expect } from '@playwright/test'
import { mockLogin } from './helpers/auth'

test.describe('Assessments (Avis d\'imposition)', () => {
  test.beforeEach(async ({ page }) => {
    await mockLogin(page)
    await page.goto('/assessments')
    await expect(page).toHaveURL(/assessments/)
  })

  test('E2E-AV-01: Tableau avis avec colonnes Référence et Taxe', async ({ page }) => {
    await expect(page.locator('[data-testid="assessments-table"]')).toBeVisible()
    await expect(page.locator('[data-testid="assessments-table"] thead')).toContainText(/Référence/)
    await expect(page.locator('[data-testid="assessments-table"] thead')).toContainText(/Taxe/)
  })

  test('E2E-AV-02: Filtrage par période', async ({ page }) => {
    await page.fill('[data-testid="filter-period-start"]', '2026-01-01')
    await expect(page.locator('[data-testid="assessments-table"]')).toBeVisible()
  })

  test('E2E-AV-03: Filtrage par statut', async ({ page }) => {
    await page.selectOption('[data-testid="filter-statut"]', 'IMPAYE')
    await expect(page.locator('[data-testid="assessments-table"]')).toBeVisible()
  })

  test('E2E-AV-04: Export CSV — menu visible', async ({ page }) => {
    await page.click('button:has-text("Exporter")')
    await expect(page.locator('[data-testid="export-csv"]')).toBeVisible()
  })

  test('E2E-AV-05: Export XLSX — menu visible', async ({ page }) => {
    await page.click('button:has-text("Exporter")')
    await expect(page.locator('[data-testid="export-xlsx"]')).toBeVisible()
  })

  test('E2E-AV-06: Génération avis — modal', async ({ page }) => {
    await page.click('[data-testid="generate-assessments"]')
    await expect(page.locator('.fixed.inset-0')).toBeVisible({ timeout: 5000 })
  })
})
