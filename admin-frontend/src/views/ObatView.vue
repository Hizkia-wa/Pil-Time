<template>
  <LayoutWrapper>
    <div>
      <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6 md:mb-8">
        <h1 class="text-2xl md:text-3xl font-bold text-slate-900">Info Obat</h1>
        <button 
          @click="openModal()"
          class="w-full md:w-auto px-3 md:px-4 py-2 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition font-medium text-sm md:text-base"
        >
          + Tambah Obat
        </button>
      </div>

      <!-- Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3 md:gap-4 lg:gap-6">
        <div v-for="obat in obatStore.obatList" :key="obat.id" class="bg-white rounded-lg shadow p-4 md:p-6 hover:shadow-lg transition border border-gray-200">
          <div class="mb-4">
            <h3 class="text-base md:text-lg font-semibold text-slate-900 line-clamp-2">{{ obat.nama_obat }}</h3>
            <p class="text-xs md:text-sm text-gray-500 mt-1">ID: {{ obat.id }}</p>
          </div>

          <div class="space-y-2 mb-4 text-xs md:text-sm">
            <div>
              <span class="text-gray-600">Dosis:</span>
              <p class="font-medium text-slate-900">{{ obat.dosis }}</p>
            </div>
            <div>
              <span class="text-gray-600">Tipe:</span>
              <p class="font-medium text-slate-900">{{ obat.tipe }}</p>
            </div>
            <div>
              <span class="text-gray-600">Deskripsi:</span>
              <p class="text-gray-700 mt-1 line-clamp-2 text-xs">{{ obat.deskripsi }}</p>
            </div>
          </div>

          <div class="flex gap-2 pt-4 border-t border-gray-200">
            <button 
              @click="openModal(obat)"
              class="flex-1 px-3 py-2 text-blue-600 bg-blue-50 rounded hover:bg-blue-100 transition text-xs md:text-sm font-medium"
            >
              Edit
            </button>
            <button 
              @click="deleteObat(obat.id)"
              class="flex-1 px-3 py-2 text-red-600 bg-red-50 rounded hover:bg-red-100 transition text-xs md:text-sm font-medium"
            >
              Hapus
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="obatStore.obatList.length === 0" class="text-center py-12 bg-white rounded-lg">
        <svg class="w-12 h-12 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.452a6 6 0 00-3.86.454l-.312.042-.668-.316A6 6 0 004.97 8.978c.27-.934.86-1.674 1.615-2.065l.306-.135.106-.06a6 6 0 016.837-1.022l.464.146a6 6 0 014.918 3.72l.223.652a8.01 8.01 0 01-.928 6.271l-.332.633c-.327.654-.786 1.22-1.37 1.649m6.728-6.728a8 8 0 01-6.271.928l-.633-.332c-.654-.327-1.22-.786-1.649-1.37m0 0a8 8 0 016.728-6.728"></path>
        </svg>
        <p class="text-gray-500 text-sm md:text-base">Belum ada data obat</p>
      </div>

      <!-- Modal -->
      <div v-if="showModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 overflow-y-auto p-4">
        <div class="bg-white rounded-lg shadow-xl p-6 md:p-8 w-full max-w-md my-8">
          <div class="flex justify-between items-center mb-4 md:mb-6">
            <h2 class="text-xl md:text-2xl font-bold text-slate-900">
              {{ editingId ? 'Edit Obat' : 'Tambah Obat Baru' }}
            </h2>
            <button 
              @click="showModal = false"
              class="text-gray-400 hover:text-gray-600 text-2xl font-bold"
            >
              ×
            </button>
          </div>

          <form @submit.prevent="handleSubmit" class="space-y-3 md:space-y-4">
            <!-- Nama Obat -->
            <div>
              <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1 md:mb-2">Nama Obat</label>
              <input
                v-model="form.nama_obat"
                type="text"
                required
                class="w-full px-3 md:px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none text-sm"
                placeholder="Contoh: Paracetamol"
              />
            </div>

            <!-- Dosis -->
            <div>
              <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1 md:mb-2">Dosis</label>
              <input
                v-model="form.dosis"
                type="text"
                required
                class="w-full px-3 md:px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none text-sm"
                placeholder="Contoh: 500mg"
              />
            </div>

            <!-- Tipe -->
            <div>
              <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1 md:mb-2">Tipe</label>
              <input
                v-model="form.tipe"
                type="text"
                required
                class="w-full px-3 md:px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none text-sm"
                placeholder="Contoh: Tablet"
              />
            </div>

            <!-- Deskripsi -->
            <div>
              <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1 md:mb-2">Deskripsi</label>
              <textarea
                v-model="form.deskripsi"
                required
                rows="3"
                class="w-full px-3 md:px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none text-sm resize-none"
                placeholder="Deskripsi obat..."
              ></textarea>
            </div>

            <!-- Buttons -->
            <div class="flex gap-3 pt-2 md:pt-4">
              <button
                type="button"
                @click="showModal = false"
                class="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium text-sm md:text-base"
              >
                Batal
              </button>
              <button
                type="submit"
                class="flex-1 px-4 py-2 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition font-medium text-sm md:text-base"
              >
                {{ editingId ? 'Update' : 'Simpan' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </LayoutWrapper>
</template>

<script>
import { ref, onMounted } from 'vue'
import LayoutWrapper from '../components/LayoutWrapper.vue'
import { useObatStore } from '../stores/obat'

export default {
  name: 'ObatView',
  components: {
    LayoutWrapper
  },
  setup() {
    const obatStore = useObatStore()
    const showModal = ref(false)
    const editingId = ref(null)
    const form = ref({
      nama_obat: '',
      dosis: '',
      tipe: '',
      deskripsi: ''
    })

    const openModal = (obat = null) => {
      if (obat) {
        editingId.value = obat.id
        form.value = {
          nama_obat: obat.nama_obat,
          dosis: obat.dosis,
          tipe: obat.tipe,
          deskripsi: obat.deskripsi
        }
      } else {
        editingId.value = null
        form.value = {
          nama_obat: '',
          dosis: '',
          tipe: '',
          deskripsi: ''
        }
      }
      showModal.value = true
    }

    const handleSubmit = async () => {
      try {
        if (editingId.value) {
          await obatStore.updateObat(editingId.value, form.value)
        } else {
          await obatStore.createObat(form.value)
        }
        showModal.value = false
      } catch (error) {
        alert('Error: ' + error.message)
      }
    }

    const deleteObat = async (id) => {
      if (confirm('Yakin ingin menghapus obat ini?')) {
        try {
          await obatStore.deleteObat(id)
        } catch (error) {
          alert('Gagal menghapus obat: ' + error.message)
        }
      }
    }

    onMounted(() => {
      obatStore.fetchObats()
    })

    return {
      obatStore,
      showModal,
      editingId,
      form,
      openModal,
      handleSubmit,
      deleteObat
    }
  }
}
</script>
