import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

/* =========================
   GUEST PAGES
========================= */
const LandingView = () => import('../views/guests/DashboardView.vue')
const TentangView = () => import('../views/guests/TentangView.vue')
const InstallView = () => import('../views/guests/InstallView.vue')
const PanduanView = () => import('../views/guests/PanduanView.vue')

/* =========================
   AUTH
========================= */
const LoginView = () => import('../views/LoginView.vue')

/* =========================
   ADMIN PAGES
========================= */
const DashboardView = () => import('../views/DashboardView.vue')
const PasienView = () => import('../views/PasienView.vue')
const JadwalView = () => import('../views/jadwal/JadwalView.vue')
const JadwalDetail = () => import('../views/jadwal/JadwalDetail.vue')
const JadwalEdit = () => import('../views/jadwal/JadwalEdit.vue')
const RiwayatView = () => import('../views/RiwayatView.vue')
const ObatView = () => import('../views/ObatView.vue')

const routes = [

  /* =========================
     GUEST ROUTES
  ========================= */

  {
    path: '/',
    name: 'landing',
    component: LandingView,
    meta: {
      requiresAuth: false,
      guest: true
    }
  },

  {
    path: '/tentang',
    name: 'tentang',
    component: TentangView,
    meta: {
      requiresAuth: false,
      guest: true
    }
  },

  {
    path: '/install',
    name: 'install',
    component: InstallView,
    meta: {
      requiresAuth: false,
      guest: true
    }
  },

  {
    path: '/panduan',
    name: 'panduan',
    component: PanduanView,
    meta: {
      requiresAuth: false,
      guest: true
    }
  },

  /* =========================
     LOGIN
  ========================= */

  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: {
      requiresAuth: false
    }
  },

  /* =========================
     ADMIN ROUTES
  ========================= */

  {
    path: '/dashboard',
    name: 'dashboard',
    component: DashboardView,
    meta: {
      requiresAuth: true,
      role: 'admin'
    }
  },

  {
    path: '/pasien',
    name: 'pasien',
    component: PasienView,
    meta: {
      requiresAuth: true,
      role: 'admin'
    }
  },

  {
    path: '/jadwal',
    name: 'jadwal',
    component: JadwalView,
    meta: {
      requiresAuth: true,
      role: 'admin'
    }
  },

  {
    path: '/jadwal/:id',
    name: 'jadwal-detail',
    component: JadwalDetail,
    meta: {
      requiresAuth: true,
      role: 'admin'
    }
  },

  {
    path: '/jadwal/:id/edit',
    name: 'jadwal-edit',
    component: JadwalEdit,
    meta: {
      requiresAuth: true,
      role: 'admin'
    }
  },

  {
    path: '/riwayat',
    name: 'riwayat',
    component: RiwayatView,
    meta: {
      requiresAuth: true,
      role: 'admin'
    }
  },

  {
    path: '/obat',
    name: 'obat',
    component: ObatView,
    meta: {
      requiresAuth: true,
      role: 'admin'
    }
  },

  /* =========================
     404 REDIRECT
  ========================= */

  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }

]

const router = createRouter({
  history: createWebHistory(),
  routes
})

/* =========================
   NAVIGATION GUARD
========================= */

router.beforeEach((to, from, next) => {

  const authStore = useAuthStore()

  const requiresAuth = to.meta.requiresAuth
  const isLoggedIn = !!authStore.token

  // Jika halaman butuh login
  if (requiresAuth && !isLoggedIn) {
    next('/login')
  }

  // Jika sudah login dan buka login lagi
  else if (to.path === '/login' && isLoggedIn) {
    next('/dashboard')
  }

  // Lanjut
  else {
    next()
  }

})

export default router