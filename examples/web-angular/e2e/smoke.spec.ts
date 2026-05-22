import { expect, test } from '@playwright/test';

test('service portal renders expected sections', async ({ page }) => {
  await page.goto('/');

  await expect(page.getByRole('heading', { name: 'Service Portal' })).toBeVisible();
  await expect(page.getByText('DevEx Platform Portfolio')).toBeVisible();

  await expect(page.getByRole('heading', { name: '.NET Service' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Python Service' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Node Service' })).toBeVisible();

  await expect(page.getByRole('link', { name: 'Health' }).first()).toBeVisible();
  await expect(page.getByRole('link', { name: 'Swagger' }).first()).toBeVisible();
  await expect(page.getByRole('link', { name: 'OpenAPI' }).first()).toBeVisible();
});
