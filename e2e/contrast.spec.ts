// The accessibility gate jsdom cannot be: a real browser computes the colours, so axe's `color-contrast` rule
// runs over the built page's own text (the dimmed header/footer links, muted text, card links). The home page and
// the 404 page must have no WCAG 2.2 AA violation in every theme × season (audit F10).
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

const THEMES = ['light', 'dark'] as const
const SEASONS = ['spring', 'summer', 'autumn', 'winter'] as const
const PAGES = [
  ['home', '/'],
  ['404', '/404.html'],
] as const

for (const [label, path] of PAGES) {
  for (const theme of THEMES) {
    for (const season of SEASONS) {
      test(`${label} page has no axe violations (${theme} · ${season})`, async ({ page }) => {
        await page.goto(path)
        await page.waitForSelector('main')
        // The app picks the theme and the season itself (stored mode, calendar month); pin both for the run.
        await page.evaluate(([t, s]) => {
          document.documentElement.setAttribute('data-theme', t)
          document.documentElement.setAttribute('data-season', s)
        }, [theme, season])
        const results = await new AxeBuilder({ page })
          .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa', 'best-practice'])
          .analyze()
        const summary = results.violations.map((v) => ({
          id: v.id,
          impact: v.impact,
          nodes: v.nodes.slice(0, 6).map((n) => `${n.target.join(' ')} — ${n.failureSummary?.split('\n').slice(0, 3).join(' | ')}`),
        }))
        expect(summary, JSON.stringify(summary, null, 2)).toEqual([])
      })
    }
  }
}
