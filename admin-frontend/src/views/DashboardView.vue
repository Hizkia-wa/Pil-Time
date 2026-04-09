<template>
  <LayoutWrapper>
    <div class="p-8">
      <h1 class="text-3xl font-bold text-slate-900 mb-8">Dashboard</h1>

      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <!-- Total Pasien Card -->
        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-600 text-sm font-medium">Total Pasien</p>
              <p class="text-4xl font-bold text-slate-900 mt-2">{{ stats.totalPasien }}</p>
            </div>
            <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.856-1.487M15 10a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
            </div>
          </div>
        </div>

        <!-- Total Jadwal Card -->
        <div class="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
          <div class="flex justify-between items-start">
            <div>
              <p class="text-gray-600 text-sm font-medium">Total Jadwal</p>
              <p class="text-4xl font-bold text-slate-900 mt-2">{{ stats.totalJadwal }}</p>
            </div>
            <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="bg-white rounded-lg shadow p-6">
        <h2 class="text-lg font-semibold text-slate-900 mb-4">Akses Cepat</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <router-link 
            to="/pasien"
            class="block p-4 bg-gradient-to-br from-blue-50 to-blue-100 rounded-lg border border-blue-200 hover:shadow-md transition"
          >
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.856-1.487M15 10a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
              </div>
              <div>
                <p class="font-semibold text-slate-900">Kelola Pasien</p>
                <p class="text-sm text-gray-600">Manage patients</p>
              </div>
            </div>
          </router-link>

          <router-link 
            to="/jadwal"
            class="block p-4 bg-gradient-to-br from-green-50 to-green-100 rounded-lg border border-green-200 hover:shadow-md transition"
          >
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-green-500 rounded-lg flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
              </div>
              <div>
                <p class="font-semibold text-slate-900">Kelola Jadwal</p>
                <p class="text-sm text-gray-600">Manage schedules</p>
              </div>
            </div>
          </router-link>

          <router-link 
            to="/obat"
            class="block p-4 bg-gradient-to-br from-purple-50 to-purple-100 rounded-lg border border-purple-200 hover:shadow-md transition"
          >
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-purple-500 rounded-lg flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.452a6 6 0 00-3.86.454l-.312.042-.668-.316A6 6 0 004.97 8.978c.27-.934.86-1.674 1.615-2.065l.306-.135.106-.06a6 6 0 016.837-1.022l.464.146a6 6 0 014.918 3.72l.223.652a8.01 8.01 0 01-.928 6.271l-.332.633c-.327.654-.786 1.22-1.37 1.649m6.728-6.728a8 8 0 01-6.271.928l-.633-.332c-.654-.327-1.22-.786-1.649-1.37m0 0a8 8 0 016.728-6.728"></path>
                </svg>
              </div>
              <div>
                <p class="font-semibold text-slate-900">Info Obat</p>
                <p class="text-sm text-gray-600">Manage medicines</p>
              </div>
            </div>
          </router-link>
        </div>
      </div>
    </div>
  </LayoutWrapper>
</template>

<script>
import { ref, onMounted } from 'vue'
import LayoutWrapper from '../components/LayoutWrapper.vue'
import { dashboardService } from '../services'

export default {
  name: 'DashboardView',
  components: {
    LayoutWrapper
  },
  setup() {
    const stats = ref({
      totalPasien: 0,
      totalJadwal: 0
    })
    const loading = ref(false)

    const loadStats = async () => {
      loading.value = true
      try {
        const response = await dashboardService.getDashboard()
        if (response.data) {
          stats.value = {
            totalPasien: response.data.total_pasien || 0,
            totalJadwal: response.data.total_jadwal || 0
          }
        }
      } catch (error) {
        console.error('Failed to load dashboard stats:', error)
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      loadStats()
    })

    return {
      stats,
      loading
    }
  }
}
</script>
