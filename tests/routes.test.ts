import { describe, it, expect } from 'vitest'
import { createRouter, createMemoryHistory } from 'vue-router'
import { routes } from '../src/routes'
import HomeView from '../src/views/HomeView.vue'
import NotFoundView from '../src/views/NotFoundView.vue'

// Unknown paths are served by the server with `404.html` and status 404 (audit F6); that page runs this
// same app, so every path other than `/` must resolve to the not-found view rather than to an empty outlet.
function resolve(path: string) {
  const router = createRouter({ history: createMemoryHistory(), routes })
  return router.resolve(path)
}

describe('routes', () => {
  it('renders the home view at /', () => {
    expect(resolve('/').matched.map((r) => r.components?.default)).toEqual([HomeView])
  })

  it.each(['/no/such', '/index', '/_headers', '/a/b/c/', '/%E0%A4%A'])('renders the not-found view at %s', (path) => {
    expect(resolve(path).matched.map((r) => r.components?.default)).toEqual([NotFoundView])
  })
})
