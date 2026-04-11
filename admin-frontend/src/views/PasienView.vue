<template>
  <LayoutWrapper>
    <div>
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6 md:mb-8">
        <h1 class="text-2xl md:text-3xl font-bold text-slate-900">Kelola Pasien</h1>
      </div>

      <!-- Desktop Table View -->
      <div class="hidden md:block bg-white rounded-lg shadow overflow-hidden border border-gray-200">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-4 md:px-6 py-3 text-left text-xs md:text-sm font-semibold text-gray-900">ID</th>
              <th class="px-4 md:px-6 py-3 text-left text-xs md:text-sm font-semibold text-gray-900">Nama</th>
              <th class="px-4 md:px-6 py-3 text-left text-xs md:text-sm font-semibold text-gray-900">Email</th>
              <th class="px-4 md:px-6 py-3 text-left text-xs md:text-sm font-semibold text-gray-900">Nomor HP</th>
              <th class="px-4 md:px-6 py-3 text-left text-xs md:text-sm font-semibold text-gray-900">Aksi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="pasien in pasienStore.pasienList" :key="pasien.id" class="hover:bg-gray-50 transition">
              <td class="px-4 md:px-6 py-3 md:py-4 text-xs md:text-sm text-gray-600">{{ pasien.id }}</td>
              <td class="px-4 md:px-6 py-3 md:py-4 text-xs md:text-sm font-medium text-slate-900">{{ pasien.nama }}</td>
              <td class="px-4 md:px-6 py-3 md:py-4 text-xs md:text-sm text-gray-600 truncate">{{ pasien.email }}</td>
              <td class="px-4 md:px-6 py-3 md:py-4 text-xs md:text-sm text-gray-600">{{ pasien.nomor_hp }}</td>
              <td class="px-4 md:px-6 py-3 md:py-4 text-xs md:text-sm">
                <button 
                  @click="deletePasien(pasien.id)"
                  class="px-2 md:px-3 py-1 text-red-600 bg-red-50 rounded hover:bg-red-100 transition text-xs md:text-sm font-medium"
                >
                  Hapus
                </button>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Empty State Desktop -->
        <div v-if="pasienStore.pasienList.length === 0" class="px-6 py-12 text-center">
          <svg class="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.856-1.487M15 10a3 3 0 11-6 0 3 3 0 016 0z"></path>
          </svg>
          <p class="text-gray-500 text-sm">Belum ada data pasien</p>
        </div>
      </div>

      <!-- Mobile Card View -->
      <div class="md:hidden space-y-3">
        <div v-for="pasien in pasienStore.pasienList" :key="pasien.id" class="bg-white rounded-lg shadow p-4 border border-gray-200">
          <div class="flex justify-between items-start mb-3">
            <div class="flex-1 min-w-0">
              <h3 class="font-semibold text-slate-900 text-sm truncate">{{ pasien.nama }}</h3>
              <p class="text-xs text-gray-500 mt-0.5">ID: {{ pasien.id }}</p>
            </div>
            <button 
              @click="deletePasien(pasien.id)"
              class="ml-2 p-2 text-red-600 hover:bg-red-50 rounded transition flex-shrink-0"
              title="Hapus"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
          
          <div class="space-y-2 text-xs">
            <div class="flex items-center justify-between">
              <span class="text-gray-600">Email:</span>
              <span class="text-slate-900 font-medium truncate ml-2">{{ pasien.email }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="text-gray-600">Nomor HP:</span>
              <span class="text-slate-900 font-medium">{{ pasien.nomor_hp }}</span>
            </div>
          </div>
        </div>

        <!-- Empty State Mobile -->
        <div v-if="pasienStore.pasienList.length === 0" class="text-center py-8 bg-white rounded-lg">
          <svg class="w-12 h-12 text-gray-400 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.856-1.487M15 10a3 3 0 11-6 0 3 3 0 016 0z"></path>
          </svg>
          <p class="text-gray-500 text-sm">Belum ada data pasien</p>
        </div>
      </div>
    </div>
  </LayoutWrapper>
</template>

<script>
import { onMounted } from 'vue'
import LayoutWrapper from '../components/LayoutWrapper.vue'
import { usePasienStore } from '../stores/pasien'

export default {
  name: 'PasienView',
  components: {
    LayoutWrapper
  },
  setup() {
    const pasienStore = usePasienStore()

    const deletePasien = async (id) => {
      if (confirm('Yakin ingin menghapus data pasien ini?')) {
        try {
          await pasienStore.deletePasien(id)
        } catch (error) {
          alert('Gagal menghapus pasien: ' + error.message)
        }
      }
    }

    onMounted(() => {
      pasienStore.fetchPasiens()
    })

    return {
      pasienStore,
      deletePasien
    }
  }
}
</script>
