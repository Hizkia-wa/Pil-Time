<template>
  <div class="min-h-screen bg-gray-50 flex">
    <!-- Sidebar -->
    <aside class="w-64 bg-slate-900 flex flex-col min-h-screen sticky top-0 h-screen overflow-y-auto flex-shrink-0">
      
      <!-- Logo Header -->
      <div class="flex items-center gap-3 px-5 py-5 border-b border-slate-700/50">
        <div class="w-10 h-10 rounded-full overflow-hidden bg-gradient-to-br from-teal-400 to-cyan-500 flex items-center justify-center flex-shrink-0">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"></path>
          </svg>
        </div>
        <div>
          <h1 class="text-sm font-bold text-white leading-tight">SahabatSehat</h1>
          <p class="text-xs text-slate-400">Portal Nakes</p>
        </div>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 px-3 py-5 space-y-6">

        <!-- UTAMA -->
        <div>
          <p class="text-xs font-semibold text-slate-500 uppercase tracking-widest px-3 mb-2">Utama</p>
          <div class="space-y-1">
            <router-link
              to="/dashboard"
              class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all"
              :class="$route.path === '/dashboard'
                ? 'bg-teal-500/20 text-teal-400'
                : 'text-slate-400 hover:bg-slate-800 hover:text-white'"
            >
              <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
              </svg>
              Dashboard
            </router-link>

            <router-link
              to="/pasien"
              class="flex items-center justify-between gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all"
              :class="$route.path === '/pasien'
                ? 'bg-teal-500/20 text-teal-400'
                : 'text-slate-400 hover:bg-slate-800 hover:text-white'"
            >
              <div class="flex items-center gap-3">
                <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.856-.587M9 20H4v-2a3 3 0 015.856-.587M15 10a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                Data Pasien
              </div>
              <span v-if="stats.totalPasien > 0" class="text-xs bg-teal-500 text-white rounded-full px-2 py-0.5 font-semibold">
                {{ stats.totalPasien }}
              </span>
            </router-link>
          </div>
        </div>

        <!-- MANAJEMEN -->
        <div>
          <p class="text-xs font-semibold text-slate-500 uppercase tracking-widest px-3 mb-2">Manajemen</p>
          <div class="space-y-1">
            <router-link
              to="/jadwal"
              class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all"
              :class="$route.path === '/jadwal'
                ? 'bg-teal-500 text-white'
                : 'text-slate-400 hover:bg-slate-800 hover:text-white'"
            >
              <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
              Jadwal Obat
            </router-link>

            <router-link
              to="/riwayat"
              class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all"
              :class="$route.path === '/riwayat'
                ? 'bg-teal-500 text-white'
                : 'text-slate-400 hover:bg-slate-800 hover:text-white'"
            >
              <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path>
              </svg>
              Riwayat Kepatuhan
            </router-link>
          </div>
        </div>

        <!-- LAINNYA -->
        <div>
          <p class="text-xs font-semibold text-slate-500 uppercase tracking-widest px-3 mb-2">Lainnya</p>
          <div class="space-y-1">
            <router-link
              to="/obat"
              class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all"
              :class="$route.path === '/obat'
                ? 'bg-teal-500 text-white'
                : 'text-slate-400 hover:bg-slate-800 hover:text-white'"
            >
              <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              Info Obat
            </router-link>
          </div>
        </div>

      </nav>

      <!-- Footer -->
      <div class="px-3 py-4 border-t border-slate-700/50">
        <div class="flex items-center justify-between gap-2 px-2">
          <div class="flex items-center gap-3 min-w-0">
            <!-- Avatar -->
            <div class="w-8 h-8 rounded-full bg-teal-500 flex items-center justify-center flex-shrink-0 text-white text-xs font-bold">
              {{ userInitials }}
            </div>
            <div class="min-w-0">
              <p class="text-sm font-semibold text-white truncate">{{ authStore.user?.nama_nakes || 'Admin' }}</p>
              <p class="text-xs text-slate-400 truncate">{{ authStore.user?.role || 'Petugas' }}</p>
            </div>
          </div>
          <!-- Logout -->
          <button
            @click="logout"
            title="Logout"
            class="text-slate-400 hover:text-red-400 transition flex-shrink-0"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
            </svg>
          </button>
        </div>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 overflow-auto">
      <slot />
    </main>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import { dashboardService } from '../services'

export default {
  name: 'LayoutWrapper',
  setup() {
    const authStore = useAuthStore()
    const router = useRouter()
    const stats = ref({ totalPasien: 0 })

    const userInitials = computed(() => {
      const name = authStore.user?.nama_nakes || 'A'
      return name.split(' ').map(n => n[0]).slice(0, 2).join('').toUpperCase()
    })

    const logout = () => {
      authStore.logout()
      router.push('/login')
    }

    const loadStats = async () => {
      try {
        const response = await dashboardService.getDashboard()
        if (response.data) {
          stats.value.totalPasien = response.data.total_pasien || 0
        }
      } catch (e) {
        console.error('Failed to load stats:', e)
      }
    }

    onMounted(() => loadStats())

    return { authStore, logout, stats, userInitials }
  }
}
</script>