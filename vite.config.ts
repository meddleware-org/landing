import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  base: '/',
  plugins: [vue()],
  build: {
    target: 'esnext',
    // Two HTML entries over the same app: the page, and the 404 page the server returns (with status 404)
    // for unknown paths. Both reference one bundle.
    rollupOptions: {
      input: { main: 'index.html', notFound: '404.html' },
    },
  },
})
