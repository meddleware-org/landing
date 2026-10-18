import type { RouteRecordRaw } from 'vue-router'
import HomeView from './views/HomeView.vue'
import NotFoundView from './views/NotFoundView.vue'

// The page has one route. Unknown paths are answered by the server with `404.html` and a real 404 status
// (static-server NOT_FOUND_PAGE); that page runs this same app, so the catch-all renders the not-found view.
export const routes: RouteRecordRaw[] = [
  { path: '/', component: HomeView },
  { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFoundView },
]
