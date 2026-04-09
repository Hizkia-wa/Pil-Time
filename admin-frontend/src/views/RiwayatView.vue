<template>
  <LayoutWrapper>
    <div class="p-8 max-w-7xl mx-auto">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-slate-900 mb-2">Riwayat Kepatuhan</h1>
        <p class="text-gray-600">Selamat datang. Ayo, Lihat Riwayat Kepatuhan Minum Obat</p>
      </div>

      <!-- Statistics Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <!-- Diminum -->
        <div class="bg-white rounded-2xl border-2 border-green-200 p-6 shadow-sm hover:shadow-md transition">
          <div class="flex items-start justify-between mb-4">
            <div class="flex items-center justify-center w-16 h-16 bg-green-100 rounded-full">
              <svg class="w-8 h-8 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
          <p class="text-4xl font-bold text-slate-900 mb-1">{{ riwayatStore.statistics?.diminum ?? 0 }}</p>
          <p class="text-gray-600 text-sm">Diminum</p>
        </div>

        <!-- Terlambat -->
        <div class="bg-white rounded-2xl border-2 border-orange-200 p-6 shadow-sm hover:shadow-md transition">
          <div class="flex items-start justify-between mb-4">
            <div class="flex items-center justify-center w-16 h-16 bg-orange-100 rounded-full">
              <svg class="w-8 h-8 text-orange-600" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v3.586L7.707 9.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L11 10.586V7z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
          <p class="text-4xl font-bold text-slate-900 mb-1">{{ riwayatStore.statistics?.terlambat ?? 0 }}</p>
          <p class="text-gray-600 text-sm">Terlambat</p>
        </div>

        <!-- Terlewat -->
        <div class="bg-white rounded-2xl border-2 border-red-200 p-6 shadow-sm hover:shadow-md transition">
          <div class="flex items-start justify-between mb-4">
            <div class="flex items-center justify-center w-16 h-16 bg-red-100 rounded-full">
              <svg class="w-8 h-8 text-red-600" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </div>
          </div>
          <p class="text-4xl font-bold text-slate-900 mb-1">{{ riwayatStore.statistics?.terlewat ?? 0 }}</p>
          <p class="text-gray-600 text-sm">Terlewat</p>
        </div>
      </div>

      <!-- Search and Filter -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <!-- Search Input -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Cari Pasien atau Obat</label>
            <div class="relative">
              <svg class="absolute left-3 top-3 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <input
                v-model="riwayatStore.searchQuery"
                @input="riwayatStore.setSearchQuery(riwayatStore.searchQuery)"
                type="text"
                placeholder="Ketik nama pasien atau obat..."
                class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
              />
            </div>
          </div>

          <!-- Status Filter -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">Filter Status</label>
            <select
              v-model="riwayatStore.filterStatus"
              @change="riwayatStore.setFilterStatus(riwayatStore.filterStatus)"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
            >
              <option value="all">Semua Status</option>
              <option value="diminum">Diminum</option>
              <option value="terlambat">Terlambat</option>
              <option value="terlewat">Terlewat</option>
            </select>
          </div>

          <!-- Reset Button -->
          <div class="flex items-end">
            <button
              @click="riwayatStore.resetFilters"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium"
            >
              Reset Filter
            </button>
          </div>
        </div>
      </div>

      <!-- Table -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div v-if="riwayatStore.loading" class="text-center py-12">
          <svg class="animate-spin h-12 w-12 text-teal-500 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <p class="text-gray-500">Memuat data...</p>
        </div>

        <div v-else-if="riwayatStore.filteredRiwayat.length === 0" class="text-center py-12">
          <svg class="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
          </svg>
          <p class="text-gray-500 mb-2">Tidak ada data riwayat kepatuhan</p>
          <p class="text-gray-400 text-sm">Cobalah ubah filter atau cari dengan kata kunci lain</p>
        </div>

        <table v-else class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">PASIEN</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">NAMA OBAT</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Tanggal</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Jadwal</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Waktu Minum</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Status</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-700">Catatan</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="item in riwayatStore.filteredRiwayat?.filter(i => i)" :key="item?.id || Math.random()" class="hover:bg-gray-50 transition">
              <td class="px-6 py-4 text-sm text-gray-900 font-medium">{{ item?.namaPasien || '-' }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ item?.namaObat || '-' }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ item?.tanggal || '-' }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ item?.jadwal || '-' }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ item?.waktuMinum || '-' }}</td>
              <td class="px-6 py-4">
                <span
                  :class="{
                    'px-3 py-1 rounded-full text-xs font-semibold': true,
                    'bg-green-100 text-green-800': item?.status === 'Diminum',
                    'bg-orange-100 text-orange-800': item?.status === 'Terlambat',
                    'bg-red-100 text-red-800': item?.status === 'Terlewat'
                  }"
                >
                  {{ item?.status || '-' }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-600">
                <span
                  v-if="item?.catatan"
                  class="inline-flex items-center gap-1 px-2 py-1 bg-blue-50 text-blue-700 rounded text-xs"
                >
                  {{ item.catatan }}
                </span>
                <span v-else class="text-gray-400">-</span>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Pagination Info -->
        <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex items-center justify-between">
          <p class="text-sm text-gray-600">
            Menampilkan <span class="font-semibold">{{ riwayatStore.filteredRiwayat.length }}</span> dari <span class="font-semibold">{{ riwayatStore.riwayatList.length }}</span> data
          </p>
        </div>
      </div>
    </div>
  </LayoutWrapper>
</template>

<script setup>
import { onMounted } from 'vue'
import LayoutWrapper from '../components/LayoutWrapper.vue'
import { useRiwayatStore } from '../stores/riwayat'

const riwayatStore = useRiwayatStore()

onMounted(() => {
  riwayatStore.fetchRiwayat()
})
</script>

<style scoped>
</style>
