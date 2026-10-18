// The page must load under exactly the policy the image serves (the Dockerfile's CSP default) with no violation:
// the policy is narrowed to 'self' for connect-src and img-src because the page makes no cross-origin request, and
// this is the browser probe that keeps it that way (audit F11). `vite preview` sends no CSP of its own, so the
// header is added to the document responses here.
import { readFileSync } from 'node:fs'
import { test, expect, type Page } from '@playwright/test'

const csp = readFileSync('Dockerfile', 'utf8').match(/^ARG CSP="([^"]*)"/m)?.[1]
if (!csp) throw new Error("no 'ARG CSP=\"…\"' default in the Dockerfile")

async function withPolicy(page: Page): Promise<void> {
  await page.addInitScript(() => {
    const w = window as unknown as { __violations: string[] }
    w.__violations = []
    document.addEventListener('securitypolicyviolation', (e) => {
      w.__violations.push(`${e.violatedDirective} ${e.blockedURI}`)
    })
  })
  await page.route('**/*', async (route) => {
    if (route.request().resourceType() !== 'document') return route.continue()
    const response = await route.fetch()
    await route.fulfill({ response, headers: { ...response.headers(), 'content-security-policy': csp! } })
  })
}

const violations = (page: Page) => page.evaluate(() => (window as unknown as { __violations: string[] }).__violations)

for (const [label, path] of [
  ['home', '/'],
  ['404', '/404.html'],
] as const) {
  test(`${label} page loads under the served CSP with no violation`, async ({ page }) => {
    await withPolicy(page)
    await page.goto(path)
    await page.waitForSelector('main')
    // The app mounted (script-src 'self' let the bundle run) and styled itself (the stylesheet loaded).
    await expect(page.getByRole('main')).toBeVisible()
    expect(await page.evaluate(() => getComputedStyle(document.body).backgroundColor)).not.toBe('rgba(0, 0, 0, 0)')
    expect(await violations(page)).toEqual([])
  })
}

test('the policy is enforced in the test (a cross-origin request is a violation)', async ({ page }) => {
  await withPolicy(page)
  await page.goto('/')
  await page.waitForSelector('main')
  await page.evaluate(() => fetch('https://example.invalid/').catch(() => undefined))
  expect(await violations(page)).toEqual(['connect-src https://example.invalid/'])
})
