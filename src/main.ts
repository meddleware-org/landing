import '@meddleware/design-tokens/tokens.css'
import '@meddleware/design-tokens/seasons.css'
import '@meddleware/ui/base.css'
import './styles/main.css'

import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import { useSeason } from '@meddleware/ui'
import App from './App.vue'
import { routes } from './routes'

// Enable seasonal theming (sets data-season on <html>; seasons.css imported above).
useSeason()

const router = createRouter({
  history: createWebHistory(),
  routes,
})

createApp(App).use(router).mount('#app')
