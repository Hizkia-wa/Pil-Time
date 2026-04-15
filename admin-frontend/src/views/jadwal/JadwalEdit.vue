<template>
  <LayoutWrapper>
    <div class="min-h-screen bg-gray-50">
      <!-- Header -->
      <div class="bg-white border-b border-gray-200 px-4 md:px-8 py-4">
        <div class="flex items-center gap-2 md:gap-4">
          <button 
            @click="goBack"
            class="flex items-center gap-2 text-gray-600 hover:text-gray-900 text-xs md:text-sm font-medium">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
            </svg>
            Kembali
          </button>
          <div>
            <h2 class="text-base md:text-lg font-bold text-slate-900">Edit Jadwal Obat</h2>
            <p class="text-xs text-gray-500">Ubah informasi jadwal minum obat</p>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="p-4 md:p-8">
        <div v-if="!loading && editForm" class="space-y-6">
          <!-- Info bar -->
          <div class="flex flex-col md:flex-row md:items-center md:gap-6 mb-6 bg-white rounded-xl px-4 md:px-6 py-4 shadow-sm border border-gray-100">
            <div class="flex items-center gap-3">
              <div class="flex items-center justify-center w-8 h-8 rounded-full bg-teal-100 text-white text-xs font-bold">
                {{ getInitials(jadwal?.pasien_nama) }}
              </div>
              <div>
                <p class="text-xs text-gray-400 uppercase tracking-wide">Pasien</p>
                <p class="text-sm font-semibold text-slate-900">{{ jadwal?.pasien_nama }}</p>
              </div>
            </div>
          </div>

          <!-- Edit Form -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
            <!-- Left: Adjustable Fields -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 md:p-6">
              <div class="flex items-center gap-3 mb-5">
                <div class="w-8 h-8 rounded-full bg-purple-50 flex items-center justify-center">
                  <svg class="w-4 h-4 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z"/>
                    <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7a1 1 0 00-1 1v6.05A2.5 2.5 0 0115.95 16H17a1 1 0 001-1v-5a1 1 0 00-.293-.707l-2-2A1 1 0 0015 7h-1z"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-sm font-semibold text-slate-900">Informasi Obat</h3>
                  <p class="text-xs text-gray-500">Detail obat yang diberikan</p>
                </div>
              </div>

              <div class="space-y-3 md:space-y-5">
                <div>
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1">
                    Nama Obat <span class="text-red-500">*</span>
                  </label>
                  <input v-model="editForm.nama_obat" type="text" placeholder="Nama obat"
                    class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"/>
                </div>

                <div class="grid grid-cols-2 gap-3">
                  <div>
                    <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1">
                      Dosis <span class="text-red-500">*</span>
                    </label>
                    <input v-model="editForm.jumlah_dosis" type="text" placeholder="1"
                      class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"/>
                  </div>
                  <div>
                    <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1">
                      Satuan <span class="text-red-500">*</span>
                    </label>
                    <input v-model="editForm.satuan" type="text" placeholder="tablet"
                      class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"/>
                  </div>
                </div>

                <div>
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1">
                    Frekuensi per Hari <span class="text-red-500">*</span>
                  </label>
                  <input v-model="editForm.frekuensi_per_hari" type="text" placeholder="Contoh: 2x sehari"
                    class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"/>
                </div>

                <div>
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-2">
                    Waktu Minum <span class="text-red-500">*</span>
                  </label>
                  <div class="flex flex-wrap gap-2 md:gap-3">
                    <button
                      v-for="waktu in wakteMinum" :key="waktu.value"
                      type="button"
                      @click="toggleWaktuMinum(waktu.value)"
                      :class="[
                        'flex items-center gap-2 px-3 md:px-4 py-2 rounded-lg text-xs md:text-sm font-medium border transition flex-1',
                        selectedWaktuMinum.includes(waktu.value)
                          ? 'bg-teal-600 text-white border-teal-600'
                          : 'bg-white text-gray-600 border-gray-200 hover:border-teal-300'
                      ]">
                      <span>{{ waktu.icon }}</span>
                      {{ waktu.label }}
                      <svg v-if="selectedWaktuMinum.includes(waktu.value)" class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                      </svg>
                    </button>
                  </div>
                </div>

                <div>
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-2">
                    Aturan Konsumsi <span class="text-red-500">*</span>
                  </label>
                  <div class="flex flex-wrap gap-2">
                    <button v-for="aturan in aturanKonsumsi" :key="aturan" type="button"
                      @click="editForm.aturan_konsumsi = aturan"
                      :class="[
                        'px-3 py-2 rounded-lg text-xs md:text-sm font-medium border transition',
                        editForm.aturan_konsumsi === aturan
                          ? 'bg-teal-600 text-white border-teal-600'
                          : 'bg-white text-gray-600 border-gray-200 hover:border-teal-300'
                      ]">
                      {{ aturan }}
                    </button>
                  </div>
                </div>

                <div>
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-1">Catatan</label>
                  <textarea v-model="editForm.catatan" placeholder="Catatan untuk pasien"
                    rows="4"
                    class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none resize-none">
                  </textarea>
                </div>
              </div>
            </div>

            <!-- Right: Durasi Info -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-4 md:p-6">
              <div class="flex items-center gap-3 mb-5">
                <div class="w-8 h-8 rounded-full bg-orange-50 flex items-center justify-center">
                  <svg class="w-4 h-4 text-orange-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v2a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-sm font-semibold text-slate-900">Durasi & Status</h3>
                  <p class="text-xs text-gray-500">Informasi pengobatan</p>
                </div>
              </div>

              <div class="space-y-5">
                <!-- Edit Duration Type -->
                <div>
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-2">
                    Tipe Durasi <span class="text-red-500">*</span>
                  </label>
                  <div class="flex gap-2">
                    <button type="button" @click="editForm.tipe_durasi = 'hari'"
                      :class="[
                        'flex-1 px-3 py-2 rounded-lg text-xs md:text-sm font-medium border transition',
                        editForm.tipe_durasi === 'hari'
                          ? 'bg-blue-600 text-white border-blue-600'
                          : 'bg-white text-gray-600 border-gray-200 hover:border-blue-300'
                      ]">
                      Hari
                    </button>
                    <button type="button" @click="editForm.tipe_durasi = 'rutin'"
                      :class="[
                        'flex-1 px-3 py-2 rounded-lg text-xs md:text-sm font-medium border transition',
                        editForm.tipe_durasi === 'rutin'
                          ? 'bg-blue-600 text-white border-blue-600'
                          : 'bg-white text-gray-600 border-gray-200 hover:border-blue-300'
                      ]">
                      Rutin
                    </button>
                  </div>
                </div>

                <!-- Edit Duration Days (if tipe_durasi is hari) -->
                <div v-if="editForm.tipe_durasi === 'hari'">
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-2">
                    Jumlah Hari <span class="text-red-500">*</span>
                  </label>
                  <input v-model="editForm.jumlah_hari" type="number" placeholder="Contoh: 7"
                    class="w-full px-3 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"/>
                </div>

                <!-- Display Dates -->
                <div class="space-y-3">
                  <div class="p-3 bg-gray-50 rounded-lg border border-gray-200">
                    <p class="text-xs text-gray-500 uppercase font-medium mb-1">Tanggal Mulai</p>
                    <p class="text-sm font-semibold text-slate-900">{{ formatDate(editForm.tanggal_mulai) }}</p>
                  </div>
                  <div v-if="editForm.tanggal_selesai" class="p-3 bg-gray-50 rounded-lg border border-gray-200">
                    <p class="text-xs text-gray-500 uppercase font-medium mb-1">Tanggal Selesai</p>
                    <p class="text-sm font-semibold text-slate-900">{{ formatDate(editForm.tanggal_selesai) }}</p>
                  </div>
                </div>

                <!-- Edit Status -->
                <div>
                  <label class="block text-xs md:text-sm font-medium text-gray-700 mb-2">
                    Status <span class="text-red-500">*</span>
                  </label>
                  <div class="flex gap-2">
                    <button type="button" @click="editForm.status = 'Aktif'"
                      :class="[
                        'flex-1 px-3 py-2 rounded-lg text-xs md:text-sm font-medium border transition',
                        editForm.status === 'Aktif'
                          ? 'bg-green-600 text-white border-green-600'
                          : 'bg-white text-gray-600 border-gray-200 hover:border-green-300'
                      ]">
                      Aktif
                    </button>
                    <button type="button" @click="editForm.status = 'Tidak Aktif'"
                      :class="[
                        'flex-1 px-3 py-2 rounded-lg text-xs md:text-sm font-medium border transition',
                        editForm.status === 'Tidak Aktif'
                          ? 'bg-red-600 text-white border-red-600'
                          : 'bg-white text-gray-600 border-gray-200 hover:border-red-300'
                      ]">
                      Tidak Aktif
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="flex gap-3 flex-col-reverse md:flex-row md:justify-end">
            <button 
              @click="goBack"
              class="flex-1 md:flex-none px-6 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium text-sm flex items-center justify-center gap-2">
              ← Batal
            </button>
            <button 
              @click="handleSave"
              :disabled="isSaving"
              class="flex-1 md:flex-none px-6 py-3 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition font-medium text-sm flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed">
              <svg v-if="!isSaving" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M5 13l4 4L19 7"/>
              </svg>
              <span v-if="isSaving" class="inline-block animate-spin rounded-full h-4 w-4 border-b-2 border-current"></span>
              {{ isSaving ? 'Menyimpan...' : 'Simpan Perubahan' }}
            </button>
          </div>
        </div>

        <!-- Loading State -->
        <div v-else-if="loading" class="flex items-center justify-center py-12">
          <div class="text-center">
            <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-teal-600 mb-4"></div>
            <p class="text-gray-500 text-sm">Memuat data...</p>
          </div>
        </div>

        <!-- Error State -->
        <div v-else class="text-center py-12">
          <svg class="w-12 h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
          </svg>
          <p class="text-gray-400 text-sm">Data jadwal tidak ditemukan</p>
        </div>
      </div>
    </div>
  </LayoutWrapper>
</template>

<script>
import { onMounted, ref, computed } from 'vue'
import LayoutWrapper from '../../components/LayoutWrapper.vue'
import { useJadwalStore } from '../../stores/jadwal'
import { useRouter, useRoute } from 'vue-router'

export default {
  name: 'JadwalEdit',
  components: {
    LayoutWrapper
  },
  setup() {
    const router = useRouter()
    const route = useRoute()
    const jadwalStore = useJadwalStore()
    const loading = ref(false)
    const isSaving = ref(false)
    const editForm = ref(null)
    const selectedWaktuMinum = ref([])

    const aturanKonsumsi = ['Sebelum makan', 'Sesudah makan', 'Bersama makan', 'Bebas']
    const wakteMinum = [
      { value: 'Pagi', label: 'Pagi', icon: '☀️' },
      { value: 'Siang', label: 'Siang', icon: '🌤️' },
      { value: 'Malam', label: 'Malam', icon: '🌙' },
      { value: 'Saat gejala', label: 'Saat gejala', icon: '⏰' },
    ]

    const jadwal = computed(() => {
      const id = parseInt(route.params.id)
      return jadwalStore.jadwalList.find(j => j.id === id)
    })

    const toggleWaktuMinum = (val) => {
      const idx = selectedWaktuMinum.value.indexOf(val)
      if (idx > -1) {
        selectedWaktuMinum.value.splice(idx, 1)
      } else {
        selectedWaktuMinum.value.push(val)
      }
      
      // Sort waktu in canonical order: Pagi, Siang, Malam, Saat gejala
      const order = { 'Pagi': 0, 'Siang': 1, 'Malam': 2, 'Saat gejala': 3 }
      selectedWaktuMinum.value.sort((a, b) => order[a] - order[b])
      
      editForm.value.waktu_minum = selectedWaktuMinum.value.join(', ')
    }

    const getInitials = (nama) => {
      if (!nama) return '?'
      return nama.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    }

    const formatDate = (dateStr) => {
      if (!dateStr) return '-'
      return new Date(dateStr).toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    }

    const goBack = () => {
      router.back()
    }

    const handleSave = async () => {
      if (!editForm.value.nama_obat) {
        alert('Nama obat harus diisi')
        return
      }
      if (!editForm.value.jumlah_dosis) {
        alert('Dosis harus diisi')
        return
      }
      if (!editForm.value.satuan) {
        alert('Satuan harus diisi')
        return
      }
      if (!editForm.value.frekuensi_per_hari) {
        alert('Frekuensi harus diisi')
        return
      }
      if (!editForm.value.waktu_minum) {
        alert('Waktu minum harus diisi')
        return
      }
      if (!editForm.value.tipe_durasi) {
        alert('Tipe durasi harus dipilih')
        return
      }
      if (editForm.value.tipe_durasi === 'hari' && !editForm.value.jumlah_hari) {
        alert('Jumlah hari harus diisi')
        return
      }
      if (!editForm.value.status) {
        alert('Status harus dipilih')
        return
      }

      // Check if there are any changes
      const hasChanges =
        editForm.value.nama_obat !== jadwal.value.nama_obat ||
        editForm.value.jumlah_dosis !== jadwal.value.jumlah_dosis ||
        editForm.value.satuan !== jadwal.value.satuan ||
        editForm.value.frekuensi_per_hari !== jadwal.value.frekuensi_per_hari ||
        editForm.value.waktu_minum !== jadwal.value.waktu_minum ||
        editForm.value.aturan_konsumsi !== jadwal.value.aturan_konsumsi ||
        editForm.value.catatan !== jadwal.value.catatan ||
        editForm.value.tipe_durasi !== jadwal.value.tipe_durasi ||
        editForm.value.jumlah_hari !== jadwal.value.jumlah_hari ||
        editForm.value.status !== jadwal.value.status

      if (!hasChanges) {
        alert('Tidak ada perubahan untuk disimpan')
        return
      }

      isSaving.value = true
      try {
        await jadwalStore.updateJadwal(editForm.value.id, {
          nama_obat: editForm.value.nama_obat,
          jumlah_dosis: editForm.value.jumlah_dosis,
          satuan: editForm.value.satuan,
          frekuensi_per_hari: editForm.value.frekuensi_per_hari,
          waktu_minum: editForm.value.waktu_minum,
          aturan_konsumsi: editForm.value.aturan_konsumsi,
          catatan: editForm.value.catatan,
          tipe_durasi: editForm.value.tipe_durasi,
          jumlah_hari: editForm.value.jumlah_hari,
          status: editForm.value.status,
        })
        alert('Jadwal berhasil diperbarui')
        router.push({ name: 'jadwal' })
      } catch (error) {
        alert('Gagal memperbarui jadwal: ' + error.message)
      } finally {
        isSaving.value = false
      }
    }

    onMounted(() => {
      if (jadwalStore.jadwalList.length === 0) {
        loading.value = true
        jadwalStore.fetchJadwals().finally(() => {
          loading.value = false
          if (jadwal.value) {
            editForm.value = { ...jadwal.value }
            // Parse waktu_minum yang ada dan set selectedWaktuMinum
            if (editForm.value.waktu_minum) {
              selectedWaktuMinum.value = editForm.value.waktu_minum.split(',').map(w => w.trim())
            }
          }
        })
      } else if (jadwal.value) {
        editForm.value = { ...jadwal.value }
        // Parse waktu_minum yang ada dan set selectedWaktuMinum
        if (editForm.value.waktu_minum) {
          selectedWaktuMinum.value = editForm.value.waktu_minum.split(',').map(w => w.trim())
        }
      }
    })

    return {
      jadwal,
      editForm,
      loading,
      isSaving,
      aturanKonsumsi,
      wakteMinum,
      selectedWaktuMinum,
      formatDate,
      getInitials,
      goBack,
      handleSave,
      toggleWaktuMinum
    }
  }
}
</script>
