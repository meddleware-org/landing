import '@meddleware/design-tokens/tokens.css'
import '@meddleware/ui/base.css'
import './styles/main.css'

import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import HomeView from './views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [{ path: '/', component: HomeView }],
})

createApp(App).use(router).mount('#app')
