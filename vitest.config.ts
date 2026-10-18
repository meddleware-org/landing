import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

// Unit tests (tests/): the build-time inline-script check and the route table. The real-browser accessibility
// gate lives in e2e/ and runs under Playwright (npm run test:e2e), not here.
export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    exclude: ['node_modules/**'],
  },
})
