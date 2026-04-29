<template>
  <LayoutWrapper>
    <div class="min-h-screen bg-[#f8fafc] p-8">
      
      <!-- HEADER SECTION (Hanya muncul di daftar utama) -->
      <div v-if="jadwal.currentStep === 0" class="flex justify-between items-end mb-8">
        <div>
          <h1 class="text-[28px] font-bold text-slate-800">Jadwal Obat</h1>
          <p class="text-slate-500 mt-1">Selamat datang di Portal Tenaga Kesehatan</p>
        </div>
        <div class="flex gap-4 items-center">
          <div class="relative">
            <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-slate-400">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </span>
            <input v-model="jadwal.searchQuery" 
              class="search-input" 
              placeholder="Cari pasien atau nama obat..." />
          </div>
          <button @click="jadwal.openAddSchedule" class="btn-primary flex items-center gap-2">
            <span class="text-xl leading-none">+</span> Tambah Jadwal Obat
          </button>
        </div>
      </div>

      <!-- STEP PROGRESS INDICATOR (Muncul saat tambah data) -->
      <div v-if="jadwal.currentStep > 0 && jadwal.currentStep < 3" class="mb-8">
        <div class="flex items-center gap-4 mb-6">
          <button @click="jadwal.cancelAdd" class="text-slate-500 hover:text-teal-600 transition-colors flex items-center gap-1 text-sm font-medium">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
            Kembali
          </button>
        </div>
        
        <div class="flex items-center justify-center gap-8">
          <div v-for="(s, i) in jadwal.steps" :key="i" class="flex items-center gap-3">
            <div :class="['step-circle', jadwal.currentStep >= i+1 ? 'active' : 'inactive']">
              {{ i+1 }}
            </div>
            <span :class="['text-sm font-medium', jadwal.currentStep >= i+1 ? 'text-slate-800' : 'text-slate-400']">{{ s }}</span>
            <div v-if="i < jadwal.steps.length - 1" class="w-12 h-[2px] bg-slate-200 ml-2"></div>
          </div>
        </div>
      </div>

      <!-- MAIN CONTENT AREA -->
      <main>
        <!-- TABLE VIEW (Step 0) -->
        <div v-if="jadwal.currentStep === 0" class="card overflow-hidden !p-0 border-none shadow-sm">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50/50 border-b border-slate-100">
                <th class="table-th">Pasien</th>
                <th class="table-th">Nama Obat</th>
                <th class="table-th">Dosis</th>
                <th class="table-th">Frekuensi</th>
                <th class="table-th">Waktu</th>
                <th class="table-th">Durasi</th>
                <th class="table-th">Status</th>
                <th class="table-th text-center">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-50">
              <tr v-for="j in jadwal.filteredJadwalList" :key="j.id" class="hover:bg-slate-50/50 transition-colors">
                <td class="table-td font-semibold text-slate-700">{{ j.pasien_nama }}</td>
                <td class="table-td text-slate-600">{{ j.nama_obat || 'Paracetamol' }}</td>
                <td class="table-td text-slate-600">{{ j.jumlah_dosis || '1' }} Tablet</td>
                <td class="table-td text-slate-600">{{ j.frekuensi || '2x sehari' }}</td>
                <td class="table-td text-slate-600 text-xs">{{ j.waktu_gabungan || 'Pagi, Malam' }}</td>
                <td class="table-td">
                  <span :class="['px-3 py-1 rounded-full text-[11px] font-bold uppercase tracking-wider', 
                    j.durasi ? 'bg-blue-50 text-blue-500' : 'bg-teal-50 text-teal-600']">
                    {{ j.durasi || 'Rutin' }}
                  </span>
                </td>
                <td class="table-td">
                  <div class="flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full bg-green-500"></span>
                    <span class="text-sm font-semibold text-green-600">Aktif</span>
                  </div>
                </td>
                <td class="table-td text-center">
                  <button class="action-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
          <div v-if="jadwal.filteredJadwalList.length === 0" class="p-12 text-center text-slate-400">
             Belum ada data jadwal obat.
          </div>
        </div>

        <!-- STEP 1: PILIH PASIEN & OBAT -->
        <div v-if="jadwal.currentStep === 1" class="grid md:grid-cols-2 gap-8 animate-in fade-in duration-500">
          <div class="card">
            <h3 class="title">Pilih Pasien</h3>
            <input v-model="jadwal.searchPasien" class="input mb-4" placeholder="Cari nama pasien..." />
            <div class="list-container">
              <div v-for="p in jadwal.filteredPasien" :key="p.pasien_id"
                @click="jadwal.selectPasien(p)"
                :class="['list-item', jadwal.form.patientId === p.pasien_id ? 'active' : '']">
                {{ p.nama }}
              </div>
            </div>
          </div>

          <div class="card">
            <h3 class="title">Pilih Obat</h3>
            <input v-model="jadwal.searchObat" class="input mb-4" placeholder="Cari jenis obat..." />
            <div class="list-container">
              <div v-for="o in jadwal.filteredObat" :key="o.obat_id"
                @click="jadwal.selectObat(o)"
                :class="['list-item', jadwal.form.obatId === o.obat_id ? 'active' : '']">
                {{ o.nama_obat }}
              </div>
            </div>
          </div>

          <button @click="jadwal.goToStep2()" class="btn-primary col-span-full py-4 text-lg">Lanjutkan Pengaturan</button>
        </div>

        <!-- STEP 2: DETAIL JADWAL -->
        <div v-if="jadwal.currentStep === 2" class="grid md:grid-cols-2 gap-8 animate-in slide-in-from-bottom-4 duration-500">
          <div class="card">
            <h3 class="title">Frekuensi & Aturan</h3>
            <div class="flex flex-wrap gap-3 mb-6">
              <button v-for="w in jadwal.waktuMinumOptions" :key="w.value"
                @click="jadwal.toggleWaktuMinum(w.value)"
                :class="['chip', jadwal.selectedWaktuMinum.includes(w.value) ? 'active' : '']">
                <span class="mr-1">{{ w.icon }}</span> {{ w.label }}
              </button>
            </div>
            
            <div class="space-y-4">
              <div>
                <label class="label">Aturan Konsumsi</label>
                <select v-model="jadwal.form.aturan_konsumsi" class="input">
                  <option v-for="a in jadwal.aturanKonsumsi" :key="a">{{ a }}</option>
                </select>
              </div>
              <div>
                <label class="label">Jumlah Dosis</label>
                <input v-model="jadwal.form.jumlah_dosis" type="number" class="input" placeholder="Contoh: 1" />
              </div>
              <div>
                <label class="label">Catatan Tambahan</label>
                <textarea v-model="jadwal.form.catatan" class="input h-24" placeholder="Opsional..."></textarea>
              </div>
            </div>
          </div>

          <div class="card">
            <h3 class="title">Durasi & Pengingat</h3>
            <div class="grid grid-cols-2 gap-4 mb-6">
              <div>
                <label class="label">Tanggal Mulai</label>
                <input type="date" v-model="jadwal.form.tanggal_mulai" class="input"/>
              </div>
              <div>
                <label class="label">Tanggal Selesai</label>
                <input type="date" v-model="jadwal.form.tanggal_selesai" class="input"/>
              </div>
            </div>

            <div class="bg-slate-50 p-4 rounded-xl space-y-4">
              <h4 class="text-xs font-bold text-slate-400 uppercase tracking-widest">Waktu Reminder</h4>
              <div class="grid grid-cols-3 gap-3">
                <div>
                  <label class="text-[10px] font-bold text-slate-500 block mb-1">PAGI</label>
                  <input type="time" v-model="jadwal.form.waktu_reminder_pagi" class="input text-center py-1"/>
                </div>
                <div>
                  <label class="text-[10px] font-bold text-slate-500 block mb-1">SIANG</label>
                  <input type="time" v-model="jadwal.form.waktu_reminder_siang" class="input text-center py-1"/>
                </div>
                <div>
                  <label class="text-[10px] font-bold text-slate-500 block mb-1">MALAM</label>
                  <input type="time" v-model="jadwal.form.waktu_reminder_malam" class="input text-center py-1"/>
                </div>
              </div>
            </div>
          </div>

          <div class="flex gap-4 col-span-full mt-4">
            <button @click="jadwal.currentStep = 1" class="btn-secondary flex-1 py-4">Kembali</button>
            <button @click="handleSubmit" class="btn-primary flex-[2] py-4">Simpan Jadwal Obat</button>
          </div>
        </div>

        <!-- STEP 3: SUCCESS -->
        <div v-if="jadwal.currentStep === 3" class="max-w-md mx-auto card text-center py-12 animate-in zoom-in duration-300">
          <div class="w-20 h-20 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold text-slate-800 mb-2">Berhasil Disimpan!</h2>
          <p class="text-slate-500 mb-8">Jadwal konsumsi obat telah berhasil didaftarkan ke sistem.</p>
          <button @click="jadwal.cancelAdd" class="btn-primary w-full">Selesai</button>
        </div>
      </main>

      <!-- LOADING OVERLAY -->
      <div v-if="jadwal.loading" class="overlay">
        <div class="bg-white p-6 rounded-2xl shadow-xl flex flex-col items-center">
          <div class="animate-spin rounded-full h-10 w-10 border-4 border-teal-500 border-t-transparent mb-4"></div>
          <p class="text-slate-600 font-medium">Memproses data...</p>
        </div>
      </div>

    </div>
  </LayoutWrapper>
</template>

<script setup>
import { onMounted } from 'vue'
import LayoutWrapper from '../../components/LayoutWrapper.vue'
import { useJadwalStore } from '../../stores/jadwal'
import { usePasienStore } from '../../stores/pasien'
import { useObatStore } from '../../stores/obat'

const jadwal = useJadwalStore()
const pasien = usePasienStore()
const obat = useObatStore()

onMounted(async () => {
  await Promise.all([
    jadwal.fetchJadwals(),
    pasien.fetchPasiens(),
    obat.fetchObats()
  ])
})

const handleSubmit = () => {
  if (!jadwal.form.tanggal_mulai) {
    alert('Tanggal mulai wajib diisi')
    return
  }
  if (jadwal.selectedWaktuMinum.length === 0) {
    alert('Pilih minimal satu waktu minum (Pagi/Siang/Malam)')
    return
  }
  jadwal.submitJadwal()
}
</script>

<style scoped>
/* Layout & Cards */
.card {
  @apply bg-white p-6 rounded-[20px] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-slate-100;
}

/* Typography */
.title {
  @apply text-lg font-bold text-slate-800 mb-5 flex items-center gap-2;
}
.label {
  @apply text-xs font-bold text-slate-500 mb-1.5 block;
}

/* Buttons */
.btn-primary {
  @apply bg-[#00a79d] hover:bg-[#008f86] text-white px-6 py-2.5 rounded-xl font-semibold transition-all shadow-md active:scale-[0.98];
}
.btn-secondary {
  @apply bg-slate-100 hover:bg-slate-200 text-slate-600 px-6 py-2.5 rounded-xl font-semibold transition-all;
}
.action-btn {
  @apply p-2 text-slate-400 hover:text-[#00a79d] border border-slate-100 rounded-lg hover:bg-white transition-all shadow-sm;
}

/* Inputs */
.search-input {
  @apply pl-10 pr-4 py-2.5 border border-slate-200 rounded-xl w-72 focus:ring-4 focus:ring-teal-500/10 focus:border-[#00a79d] outline-none transition-all bg-slate-50/50;
}
.input {
  @apply w-full border border-slate-200 p-3 rounded-xl focus:ring-4 focus:ring-teal-500/10 focus:border-[#00a79d] outline-none transition-all bg-slate-50/30 text-slate-700;
}

/* Table Styles */
.table-th {
  @apply px-6 py-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest;
}
.table-td {
  @apply px-6 py-5 text-sm align-middle;
}

/* Selection Lists */
.list-container {
  @apply border border-slate-100 rounded-xl overflow-hidden max-h-60 overflow-y-auto;
}
.list-item {
  @apply p-4 cursor-pointer hover:bg-slate-50 border-b border-slate-50 last:border-none transition-colors text-slate-600;
}
.list-item.active {
  @apply bg-teal-50 text-teal-700 font-bold border-l-4 border-l-teal-500;
}

/* Chips */
.chip {
  @apply px-4 py-2 border border-slate-200 rounded-full cursor-pointer transition-all text-sm font-medium text-slate-500 bg-white;
}
.chip.active {
  @apply bg-[#00a79d] border-[#00a79d] text-white shadow-md shadow-teal-200;
}

/* Stepper */
.step-circle {
  @apply w-8 h-8 flex items-center justify-center rounded-full text-xs font-bold transition-all;
}
.step-circle.active {
  @apply bg-[#00a79d] text-white ring-4 ring-teal-100;
}
.step-circle.inactive {
  @apply bg-slate-200 text-slate-500;
}

/* Overlays */
.overlay {
  @apply fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-50;
}
</style>