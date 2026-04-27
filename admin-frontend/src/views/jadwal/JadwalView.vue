<template>
  <LayoutWrapper>
    <div class="min-h-screen bg-gray-100 p-6">

      <!-- STEP -->
      <div v-if="jadwal.currentStep > 0" class="flex justify-between mb-6">
        <button @click="jadwal.cancelAdd" class="text-gray-600">
          ← Kembali
        </button>

        <div class="flex gap-3">
          <div v-for="(s,i) in jadwal.steps" :key="i"
            class="flex items-center gap-2">
            <div
              class="w-7 h-7 flex items-center justify-center rounded-full text-xs"
              :class="jadwal.currentStep >= i+1 ? 'bg-teal-600 text-white' : 'bg-gray-300'">
              {{ i+1 }}
            </div>
            <span class="text-sm">{{ s }}</span>
          </div>
        </div>
      </div>

      <!-- STEP 1 -->
      <div v-if="jadwal.currentStep === 1" class="grid md:grid-cols-2 gap-6">

        <!-- PASIEN -->
        <div class="card">
          <h3 class="title">Pilih Pasien</h3>

          <input v-model="jadwal.searchPasien" class="input" placeholder="Cari pasien..." />

          <div class="list">
            <div v-for="p in jadwal.filteredPasien"
              :key="p.pasien_id"
              @click="jadwal.selectPasien(p)"
              :class="['item',
                jadwal.form.patientId === p.pasien_id ? 'active' : ''
              ]">
              {{ p.nama }}
            </div>
          </div>
        </div>

        <!-- OBAT -->
        <div class="card">
          <h3 class="title">Pilih Obat</h3>

          <input v-model="jadwal.searchObat" class="input" placeholder="Cari obat..." />

          <div class="list">
            <div v-for="o in jadwal.filteredObat"
              :key="o.obat_id"
              @click="jadwal.selectObat(o)"
              :class="['item',
                jadwal.form.obatId === o.obat_id ? 'active' : ''
              ]">
              {{ o.nama_obat }}
            </div>
          </div>
        </div>

        <button 
          @click="jadwal.form.patientId && jadwal.form.obatId 
            ? jadwal.goToStep2() 
            : alert('Pilih pasien & obat dulu')"
          class="btn-primary col-span-full">
          Lanjut
        </button>
      </div>

      <!-- STEP 2 -->
      <div v-if="jadwal.currentStep === 2" class="grid md:grid-cols-2 gap-6">

        <!-- KIRI -->
        <div class="card">
          <h3 class="title">Frekuensi & Waktu Minum</h3>

          <div class="flex gap-2 mb-4">
            <button v-for="w in jadwal.waktuMinumOptions"
              :key="w.value"
              @click="jadwal.toggleWaktuMinum(w.value)"
              :class="['chip',
                jadwal.selectedWaktuMinum.includes(w.value) ? 'active' : ''
              ]">
              {{ w.icon }} {{ w.label }}
            </button>
          </div>

          <select v-model="jadwal.form.aturan_konsumsi" class="input">
            <option v-for="a in jadwal.aturanKonsumsi" :key="a">
              {{ a }}
            </option>
          </select>

          <input v-model="jadwal.form.jumlah_dosis"
            type="number"
            class="input mt-3"
            placeholder="Jumlah Dosis" />

          <textarea v-model="jadwal.form.catatan"
            class="input mt-3"
            placeholder="Catatan"></textarea>
        </div>

        <!-- KANAN -->
        <div class="card">
  <h3 class="title">Durasi & Jadwal</h3>

  <label>Tanggal Mulai *</label>
  <input type="date" v-model="jadwal.form.tanggal_mulai" class="input mb-3"/>

  <label>Tanggal Selesai</label>
  <input type="date" v-model="jadwal.form.tanggal_selesai" class="input mb-4"/>

  <h4 class="font-semibold mb-2">Waktu Reminder</h4>

  <label>Pagi</label>
  <input type="time" v-model="jadwal.form.waktu_reminder_pagi" class="input mb-2"/>

  <label>Siang</label>
  <input type="time" v-model="jadwal.form.waktu_reminder_siang" class="input mb-2"/>

  <label>Malam</label>
  <input type="time" v-model="jadwal.form.waktu_reminder_malam" class="input"/>
</div>

        <div class="flex gap-2 col-span-full">
          <button @click="jadwal.currentStep = 1" class="btn-secondary">
            Kembali
          </button>

          <button 
            @click="handleSubmit"
            class="btn-primary">
            Simpan
          </button>
        </div>
      </div>

      <!-- STEP 3 -->
      <div v-if="jadwal.currentStep === 3" class="card text-center">
        <h2 class="text-green-600 font-bold text-lg">
          ✅ Berhasil disimpan
        </h2>

        <button @click="jadwal.cancelAdd" class="btn-primary mt-4">
          Kembali
        </button>
      </div>

      <!-- TABLE -->
      <div v-if="jadwal.currentStep === 0">

        <div class="flex justify-between mb-4">
          <input v-model="jadwal.searchQuery"
            class="input"
            placeholder="Cari pasien..." />

          <button @click="jadwal.openAddSchedule"
            class="btn-primary">
            + Tambah
          </button>
        </div>

        <div class="card">
          <div v-for="j in jadwal.filteredJadwalList"
            :key="j.id"
            class="border-b p-3">
            {{ j.pasien_nama }}
          </div>
        </div>
      </div>

      <!-- LOADING -->
      <div v-if="jadwal.loading" class="overlay">
        Loading...
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
    alert('Pilih waktu minum dulu')
    return
  }

  jadwal.submitJadwal()
}
</script>

<style scoped>
.card {
  @apply bg-white p-5 rounded-xl shadow;
}
.title {
  @apply font-bold mb-3;
}
.input {
  @apply w-full border p-2 rounded-lg;
}
.list {
  @apply border rounded-lg mt-2 max-h-40 overflow-y-auto;
}
.item {
  @apply p-2 cursor-pointer hover:bg-gray-100;
}
.item.active {
  @apply bg-teal-600 text-white;
}
.btn-primary {
  @apply bg-teal-600 text-white px-4 py-2 rounded-lg;
}
.btn-secondary {
  @apply bg-gray-300 px-4 py-2 rounded-lg;
}
.chip {
  @apply px-3 py-1 border rounded-full cursor-pointer;
}
.chip.active {
  @apply bg-teal-600 text-white;
}
.overlay {
  @apply fixed inset-0 bg-black/30 flex items-center justify-center text-white;
}
</style>