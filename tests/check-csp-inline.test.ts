// @vitest-environment node
import { describe, it, expect, afterEach } from 'vitest'
import { spawnSync } from 'node:child_process'
import { createHash } from 'node:crypto'
import { mkdtempSync, mkdirSync, writeFileSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'

// The build-time inline-script check (audit F7): the image serves `script-src 'self'`, so any inline
// <script> in dist/ must fail the build instead of failing in the browser.
const SCRIPT = join(process.cwd(), 'scripts', 'check-csp-inline.mjs')
const SELF = "default-src 'self'; script-src 'self'; connect-src 'self'"

const dirs: string[] = []
afterEach(() => {
  for (const d of dirs.splice(0)) rmSync(d, { recursive: true, force: true })
})

function dist(html: string): string {
  const dir = mkdtempSync(join(tmpdir(), 'csp-inline-'))
  dirs.push(dir)
  mkdirSync(join(dir, 'dist'))
  writeFileSync(join(dir, 'dist', 'index.html'), html)
  return join(dir, 'dist')
}
function run(csp: string, distDir: string) {
  const r = spawnSync(process.execPath, [SCRIPT, csp, distDir], { encoding: 'utf8' })
  return { code: r.status, out: r.stdout + r.stderr }
}

describe('check-csp-inline', () => {
  it('passes for a page whose only script is an external module', () => {
    const d = dist('<html><body><div id="app"></div><script type="module" src="/assets/index-abc.js"></script></body></html>')
    expect(run(SELF, d).code).toBe(0)
  })

  it('fails for an inline script that script-src does not allow', () => {
    const d = dist('<html><body><script>window.x = 1</script></body></html>')
    const r = run(SELF, d)
    expect(r.code).toBe(1)
    expect(r.out).toContain('not allowed by script-src')
  })

  it('passes for an inline script whose sha256 is listed in script-src', () => {
    const body = 'window.x = 1'
    const hash = createHash('sha256').update(body).digest('base64')
    const d = dist(`<html><body><script>${body}</script></body></html>`)
    expect(run(`default-src 'self'; script-src 'self' 'sha256-${hash}'`, d).code).toBe(0)
  })

  it("fails when script-src allows 'unsafe-inline'", () => {
    const d = dist('<html><body></body></html>')
    expect(run("script-src 'self' 'unsafe-inline'", d).code).toBe(1)
  })

  it('fails when there is no HTML to check', () => {
    const dir = mkdtempSync(join(tmpdir(), 'csp-inline-'))
    dirs.push(dir)
    expect(run(SELF, dir).code).toBe(2)
  })

  it("reads the Dockerfile's CSP default and accepts the built page's shape", () => {
    const d = dist('<html><body><script type="module" src="/assets/a.js"></script></body></html>')
    const r = spawnSync(process.execPath, [SCRIPT, `@${join(process.cwd(), 'Dockerfile')}`, d], { encoding: 'utf8' })
    expect(r.status).toBe(0)
  })
})
