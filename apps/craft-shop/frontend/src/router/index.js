import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../lib/supabase'

import Shop from '../pages/Shop.vue'
import ProductDetails from '../pages/ProductDetails.vue'
import Gallery from '../pages/Gallery.vue'
import About from '../pages/About.vue'
import AdminLogin from '../pages/AdminLogin.vue'
import AdminDashboard from '../pages/AdminDashboard.vue'

const routes = [
  { path: '/', name: 'shop', component: Shop },
  { path: '/gallery', name: 'gallery', component: Gallery },
  { path: '/about', name: 'about', component: About },
  { path: '/product/:slug', name: 'product', component: ProductDetails },
  { path: '/admin/login', name: 'admin-login', component: AdminLogin },
  { path: '/admin', name: 'admin-dashboard', component: AdminDashboard, meta: { requiresAuth: true } }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to) => {
  if (!to.meta.requiresAuth && to.name !== 'admin-login') return true

  const { data } = await supabase.auth.getSession()

  if (to.name === 'admin-login' && data.session) {
    return '/admin'
  }

  if (!data.session) return '/admin/login'

  return true
})

export default router
