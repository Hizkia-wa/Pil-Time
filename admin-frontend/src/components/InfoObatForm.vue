<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 overflow-y-auto p-4">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-2xl my-8">
      <!-- Header -->
      <div class="flex justify-between items-center border-b border-gray-200 p-6 md:p-8">
        <div>
          <h2 class="text-2xl md:text-3xl font-bold text-slate-900">
            {{ editingObat?.obat_id ? 'Edit Info Obat' : 'Tambah Info Obat' }}
          </h2>
          <p class="text-xs md:text-sm text-gray-500 mt-1">
            Lengkapi semua informasi obat untuk pasien
          </p>
        </div>
        <button 
          @click="$emit('close')"
          class="text-gray-400 hover:text-gray-600 text-2xl font-bold"
        >
          ×
        </button>
      </div>

      <!-- Content -->
      <div class="px-6 md:px-8 py-6 space-y-6">
        <!-- Nama Obat -->
        <div class="bg-blue-50 rounded-lg border border-blue-200 p-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Nama Obat <span class="text-red-500">*</span>
          </label>
          <input 
            v-model="form.nama_obat" 
            type="text" 
            placeholder="cth. Paracetamol, Amoxicillin..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none text-sm"
          />
        </div>

        <!-- Fungsi Obat -->
        <div class="bg-purple-50 rounded-lg border border-purple-200 p-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Fungsi Obat <span class="text-red-500">*</span>
          </label>
          <textarea 
            v-model="form.fungsi"
            rows="4"
            placeholder="Jelaskan fungsi utama obat ini secara singkat dan jelas..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none text-sm resize-none"
          ></textarea>
        </div>

        <!-- Aturan Penggunaan -->
        <div class="bg-orange-50 rounded-lg border border-orange-200 p-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Aturan Penggunaan <span class="text-red-500">*</span>
          </label>
          <textarea 
            v-model="form.aturan_penggunaan"
            rows="4"
            placeholder="Petunjuk lengkap cara mengonsumsi, dosis, dan interval minimum..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent outline-none text-sm resize-none"
          ></textarea>
        </div>

        <!-- Perhatian/Peringatan -->
        <div class="bg-red-50 rounded-lg border border-red-200 p-4">
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Perhatian <span class="text-red-500">*</span>
          </label>
          <textarea 
            v-model="form.perhatian"
            rows="4"
            placeholder="Peringatan penting, efek samping, kondisi khusus, dan kontra indikasi..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent outline-none text-sm resize-none"
          ></textarea>
        </div>
      </div>

      <!-- Footer -->
      <div class="border-t border-gray-200 px-6 md:px-8 py-4 flex flex-col-reverse md:flex-row justify-end gap-3">
        <button 
          @click="$emit('close')"
          class="w-full md:w-auto px-6 py-2.5 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium text-sm md:text-base flex items-center justify-center gap-2"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
          Batal
        </button>
        <button 
          @click="handleSubmit"
          :disabled="!isFormValid"
          :class="['w-full md:w-auto px-6 py-2.5 bg-teal-600 text-white rounded-lg transition font-medium text-sm md:text-base flex items-center justify-center gap-2',
            isFormValid ? 'hover:bg-teal-700 cursor-pointer' : 'opacity-50 cursor-not-allowed']"
        >
          Simpan Info Obat
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'

export default {
  name: 'InfoObatForm',
  props: {
    editingObat: { type: Object, default: null }
  },
  emits: ['close', 'submit'],
  setup(props, { emit }) {
    const form = ref({
      nama_obat: props.editingObat?.nama_obat || '',
      fungsi: props.editingObat?.fungsi || '',
      aturan_penggunaan: props.editingObat?.aturan_penggunaan || '',
      perhatian: props.editingObat?.perhatian || ''
    })

    const isFormValid = computed(() => {
      return form.value.nama_obat?.trim() && 
             form.value.fungsi?.trim() &&
             form.value.aturan_penggunaan?.trim() &&
             form.value.perhatian?.trim()
    })

    const handleSubmit = async () => {
      if (!isFormValid.value) return
      
      try {
        emit('submit', form.value)
      } catch (error) {
        console.error('Error submitting form:', error)
      }
    }

    return {
      form,
      isFormValid,
      handleSubmit
    }
  }
}
</script>
