<template>
  <div class="p-8">
    <!-- Info bar (muncul setelah pasien dipilih) -->
    <div v-if="form.patientId"
      class="flex items-center gap-6 mb-6 bg-white rounded-xl px-6 py-3 shadow-sm border border-gray-100">
      <div class="flex items-center gap-3">
        <div :class="['w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold', getColorClass(form.patientId)]">
          {{ getInitials(selectedPasienName) }}
        </div>
        <div>
          <p class="text-xs text-gray-400 uppercase tracking-wide">Pasien</p>
          <p class="text-sm font-semibold text-slate-900">{{ selectedPasienName }}</p>
        </div>
        <span class="text-xs bg-teal-50 text-teal-700 px-2 py-0.5 rounded-full font-medium">
          {{ selectedPasienCode }}
        </span>
      </div>
      <div v-if="form.nama_obat" class="flex items-center gap-3 pl-6 border-l border-gray-200">
        <div class="w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center">
          <svg class="w-4 h-4 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
            <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z"/>
            <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7a1 1 0 00-1 1v6.05A2.5 2.5 0 0115.95 16H17a1 1 0 001-1v-5a1 1 0 00-.293-.707l-2-2A1 1 0 0015 7h-1z"/>
          </svg>
        </div>
        <div>
          <p class="text-xs text-gray-400 uppercase tracking-wide">Obat</p>
          <p class="text-sm font-semibold text-slate-900">{{ form.nama_obat }}</p>
        </div>
      </div>
      <div v-if="form.jumlah_dosis && form.satuan" class="flex items-center gap-3 pl-6 border-l border-gray-200">
        <div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center">
          <svg class="w-4 h-4 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd"/>
          </svg>
        </div>
        <div>
          <p class="text-xs text-gray-400 uppercase tracking-wide">Dosis</p>
          <p class="text-sm font-semibold text-slate-900">{{ form.jumlah_dosis }} {{ form.satuan }} · {{ form.kategori_obat }}</p>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-2 gap-6">
      <!-- Left: Pilih Pasien -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-8 h-8 rounded-full bg-teal-50 flex items-center justify-center">
            <svg class="w-4 h-4 text-teal-600" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"/>
            </svg>
          </div>
          <div>
            <h3 class="text-sm font-semibold text-slate-900">Pilih Pasien</h3>
            <p class="text-xs text-gray-500">Cari dan pilih pasien yang akan dijadwalkan</p>
          </div>
        </div>

        <div class="relative mb-4">
          <svg class="absolute left-3 top-2.5 w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
          </svg>
          <input
            :value="searchPasien"
            @input="$emit('update:searchPasien', $event.target.value)"
            type="text"
            placeholder="Cari nama pasien..."
            class="w-full pl-9 pr-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"
          />
        </div>

        <div class="space-y-2 max-h-72 overflow-y-auto">
          <div
            v-for="pasien in pasienList"
            :key="pasien.pasien_id"
            @click="$emit('select-pasien', pasien)"
            :class="[
              'p-3 rounded-lg cursor-pointer transition border',
              form.patientId === pasien.pasien_id
                ? 'bg-teal-50 border-teal-300'
                : 'border-gray-100 hover:bg-gray-50 hover:border-gray-200'
            ]"
          >
            <div class="flex items-center gap-3">
              <div :class="['w-9 h-9 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0', getColorClass(pasien.pasien_id)]">
                {{ getInitials(pasien.nama) }}
              </div>
              <div class="flex-1 min-w-0">
                <p :class="['text-sm font-medium truncate', form.patientId === pasien.pasien_id ? 'text-teal-700' : 'text-slate-900']">
                  {{ pasien.nama }}
                </p>
                <p class="text-xs text-gray-500">{{ pasien.kode || pasien.nik }} · {{ pasien.diagnosa || '' }}</p>
              </div>
              <svg v-if="form.patientId === pasien.pasien_id" class="w-5 h-5 text-teal-500 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- Selected banner -->
        <div v-if="form.patientId" class="mt-4 p-3 bg-teal-50 rounded-lg border border-teal-200 flex items-center gap-3">
          <svg class="w-4 h-4 text-teal-600 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
          </svg>
          <div>
            <p class="text-xs text-teal-600 font-medium">✓ Pasien Terpilih</p>
            <p class="text-sm font-semibold text-teal-800">{{ selectedPasienName }}</p>
            <p class="text-xs text-teal-600">{{ selectedPasienCode }} · {{ selectedPasienDiagnosa }}</p>
          </div>
        </div>
      </div>

      <!-- Right: Informasi Obat -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
        <div class="flex items-center gap-3 mb-4">
          <div class="w-8 h-8 rounded-full bg-purple-50 flex items-center justify-center">
            <svg class="w-4 h-4 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
              <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z"/>
              <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7a1 1 0 00-1 1v6.05A2.5 2.5 0 0115.95 16H17a1 1 0 001-1v-5a1 1 0 00-.293-.707l-2-2A1 1 0 0015 7h-1z"/>
            </svg>
          </div>
          <div>
            <h3 class="text-sm font-semibold text-slate-900">Informasi Obat</h3>
            <p class="text-xs text-gray-500">Masukkan detail obat yang akan diberikan</p>
          </div>
        </div>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">
              Nama Obat <span class="text-red-500">*</span>
            </label>
            <input :value="form.nama_obat" @input="update('nama_obat', $event.target.value)"
              type="text" placeholder="Contoh: Amlodipine"
              class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"/>
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Jumlah Dosis <span class="text-red-500">*</span>
              </label>
              <input :value="form.jumlah_dosis" @input="update('jumlah_dosis', +$event.target.value)"
                type="number" min="1" placeholder="1"
                class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"/>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Satuan <span class="text-red-500">*</span>
              </label>
              <select :value="form.satuan" @change="update('satuan', $event.target.value)"
                class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none bg-white">
                <option value="">Pilih satuan</option>
                <option value="tablet">tablet</option>
                <option value="kapsel">kapsel</option>
                <option value="ml">ml</option>
                <option value="botol">botol</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Kategori Obat</label>
            <input :value="form.kategori_obat" @input="update('kategori_obat', $event.target.value)"
              type="text" placeholder="Contoh: Antihipertensi"
              class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"/>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Takaran Obat</label>
            <input :value="form.takaran_obat" @input="update('takaran_obat', $event.target.value)"
              type="text" placeholder="Contoh: 5mg"
              class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"/>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <div class="flex justify-end gap-3 mt-6">
      <button @click="$emit('cancel')"
        class="px-6 py-2.5 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition">
        Batal
      </button>
      <button @click="$emit('next')"
        class="px-6 py-2.5 bg-teal-600 text-white rounded-lg text-sm font-medium hover:bg-teal-700 transition flex items-center gap-2">
        Lanjut: Aturan Minum
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
        </svg>
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Step1PasienObat',
  props: {
    form: { type: Object, required: true },
    pasienList: { type: Array, default: () => [] },
    searchPasien: { type: String, default: '' },
    selectedPasienName: { type: String, default: '' },
    selectedPasienCode: { type: String, default: '' },
    selectedPasienDiagnosa: { type: String, default: '' },
  },
  emits: ['update:form', 'update:searchPasien', 'select-pasien', 'next', 'cancel'],
  methods: {
    update(field, value) {
      this.$emit('update:form', { ...this.form, [field]: value })
    },
    getInitials(nama) {
      if (!nama) return '?'
      return nama.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    },
    getColorClass(id) {
      const colors = ['bg-teal-500', 'bg-purple-500', 'bg-yellow-500', 'bg-red-500', 'bg-blue-500', 'bg-orange-500']
      return colors[(id || 0) % colors.length]
    },
  },
}
</script>