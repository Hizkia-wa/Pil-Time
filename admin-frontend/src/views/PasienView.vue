<template>
  <LayoutWrapper>
    <div class="p-8">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-slate-900">Kelola Pasien</h1>
      </div>

      <!-- Table -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">ID</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Nama</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Email</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Nomor HP</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">Aksi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="pasien in pasienStore.pasienList" :key="pasien.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 text-sm text-gray-600">{{ pasien.id }}</td>
              <td class="px-6 py-4 text-sm font-medium text-slate-900">{{ pasien.nama }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ pasien.email }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ pasien.nomor_hp }}</td>
              <td class="px-6 py-4 text-sm">
                <button 
                  @click="deletePasien(pasien.id)"
                  class="px-3 py-1 text-red-600 bg-red-50 rounded hover:bg-red-100 transition"
                >
                  Hapus
                </button>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Empty State -->
        <div v-if="pasienStore.pasienList.length === 0" class="px-6 py-12 text-center">
          <p class="text-gray-500">Belum ada data pasien</p>
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
