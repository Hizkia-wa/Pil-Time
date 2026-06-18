<template>
  <div class="p-4 md:p-8">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 md:p-6 transition-all">
        <div class="flex items-center gap-3 mb-5">
          <div class="w-10 h-10 rounded-xl bg-teal-50 flex items-center justify-center text-teal-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
          </div>
          <h3 class="text-sm font-bold text-slate-900">Data Pasien</h3>
        </div>

        <div class="relative mb-4">
          <input :value="searchPasien" @input="$emit('update:searchPasien', $event.target.value)"
            type="text" placeholder="Cari nama atau NIK..."
            class="w-full pl-10 pr-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:ring-2 focus:ring-teal-500 outline-none transition-all"/>
          <svg class="absolute left-3.5 top-3 w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
        </div>

        <div v-if="!form.patientId" class="mb-4 space-y-2 max-h-40 overflow-y-auto border-b pb-4">
          <div v-if="pasienList.length === 0" class="p-4 text-center text-xs text-gray-400 italic">Data pasien tidak tersedia...</div>
          <div v-for="pasien in pasienList" :key="pasien.pasien_id" @click="$emit('select-pasien', pasien)"
            class="p-3 rounded-xl cursor-pointer border border-gray-100 hover:bg-teal-50 hover:border-teal-200 flex items-center gap-3 transition-all">
            <div :class="['w-8 h-8 rounded-full flex items-center justify-center text-white text-[10px] font-bold', getColorClass(pasien.pasien_id)]">
              {{ getInitials(pasien.nama) }}
            </div>
            <div class="flex-1">
              <p class="text-xs font-bold text-slate-800">{{ pasien.nama }}</p>
              <p class="text-[9px] text-gray-400">{{ pasien.nik }}</p>
            </div>
          </div>
        </div>

        <transition name="fade">
          <div v-if="form.patientId" class="mt-4 p-5 bg-slate-50 rounded-2xl border border-slate-200 space-y-4 relative">
            <button @click="resetPasien" class="absolute top-4 right-4 text-[10px] font-bold text-teal-600 hover:text-red-500 uppercase tracking-widest">Ganti Pasien</button>
            <div class="flex items-center gap-4 border-b border-slate-200 pb-4">
              <div :class="['w-14 h-14 rounded-full flex items-center justify-center text-white font-bold text-xl shadow-inner', getColorClass(form.patientId)]">
                {{ getInitials(selectedPasienName) }}
              </div>
              <div>
                <h4 class="text-base font-bold text-slate-900 leading-tight">{{ selectedPasienName }}</h4>
                <p class="text-xs text-teal-600 font-bold tracking-wider mt-1">NIK: {{ selectedPasienNIK }}</p>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-y-4 gap-x-2">
              <div>
                <p class="text-[10px] text-gray-400 uppercase font-bold tracking-tighter">Jenis Kelamin</p>
                <p class="text-xs text-slate-700 font-semibold">{{ selectedPasienJK === 'L' ? 'Laki-laki' : 'Perempuan' }}</p>
              </div>
              <div>
                <p class="text-[10px] text-gray-400 uppercase font-bold tracking-tighter">Telepon</p>
                <p class="text-xs text-slate-700 font-semibold">{{ selectedPasienTelepon || '-' }}</p>
              </div>
              <div class="col-span-2">
                <p class="text-[10px] text-gray-400 uppercase font-bold tracking-tighter">Alamat</p>
                <p class="text-xs text-slate-700 font-semibold leading-relaxed italic">"{{ selectedPasienAlamat || 'Alamat tidak tersedia' }}"</p>
              </div>
            </div>
          </div>
        </transition>
      </div>

      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 md:p-6 transition-all">
        <div class="flex items-center gap-3 mb-5">
          <div class="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center text-purple-600">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"/></svg>
          </div>
          <h3 class="text-sm font-bold text-slate-900">Master Obat</h3>
        </div>

        <div class="relative mb-4">
          <input :value="searchObat" @input="$emit('update:searchObat', $event.target.value)"
            type="text" placeholder="Ketik nama obat untuk mencari..."
            class="w-full pl-10 pr-4 py-2.5 text-sm border border-gray-200 rounded-xl focus:ring-2 focus:ring-purple-500 outline-none transition-all"/>
          <svg class="absolute left-3.5 top-3 w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
        </div>

        <div v-if="!form.obatList || form.obatList.length === 0" class="mb-4 space-y-2 max-h-48 overflow-y-auto border-b pb-4">
          <div v-if="obatList.length === 0" class="p-4 text-center text-xs text-gray-400 italic">Obat tidak ditemukan...</div>
          <div v-for="obat in obatList" :key="obat.obat_id" @click="$emit('select-obat', obat)"
              class="p-3 rounded-xl cursor-pointer border border-gray-50 hover:bg-purple-50 hover:border-purple-200 flex items-center gap-3 transition-all">
            <div class="flex-1">
              <p class="text-xs font-bold text-slate-800">{{ obat.nama_obat }}</p>
              <p class="text-[9px] text-gray-400">Klik untuk memilih</p>
            </div>
          </div>
        </div> 
        <div v-else class="mb-4 space-y-2 max-h-48 overflow-y-auto border-b pb-4">
          <div v-for="obat in obatList" :key="obat.obat_id" @click="$emit('select-obat', obat)"
              :class="['p-3 rounded-xl cursor-pointer border flex items-center gap-3 transition-all', form.obatList.find(o => o.obat_id === obat.obat_id) ? 'bg-purple-50 border-purple-300' : 'border-gray-50 hover:bg-purple-50']">
            <div class="flex-1">
              <p class="text-xs font-bold text-slate-800">{{ obat.nama_obat }}</p>
            </div>
            <svg v-if="form.obatList.find(o => o.obat_id === obat.obat_id)" class="w-4 h-4 text-purple-600" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>
          </div>
        </div>

        <transition name="fade">
          <div v-if="form.obatList && form.obatList.length > 0" class="mt-4 p-5 bg-slate-50 rounded-2xl border border-slate-200 space-y-4 relative">
            <h4 class="text-sm font-bold text-slate-900 mb-2">Obat Terpilih ({{ form.obatList.length }})</h4>
            
            <div v-for="selected in form.obatList" :key="selected.obat_id" class="p-3 bg-white border border-slate-200 rounded-xl mb-3 shadow-sm relative">
              <button @click="$emit('select-obat', { obat_id: selected.obat_id })" class="absolute top-2 right-2 text-gray-400 hover:text-red-500">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
              </button>
              
              <div class="flex items-start gap-3">
                <div class="w-10 h-10 rounded-lg bg-purple-50 border border-purple-100 flex-shrink-0 flex items-center justify-center">
                  <img v-if="selected.gambar" :src="API_BASE_URL + selected.gambar" class="w-full h-full object-cover rounded-lg" />
                  <span v-else class="text-xl">💊</span>
                </div>
                <div class="flex-1 min-w-0 pr-6">
                  <h5 class="text-xs font-bold text-slate-900 truncate">{{ selected.nama_obat }}</h5>
                  <p class="text-[10px] text-gray-500 leading-snug mt-0.5">{{ selected.aturan || 'Sesuai anjuran' }}</p>
                  
                  <div class="mt-2">
                    <label class="block text-[10px] font-bold text-purple-600 uppercase tracking-wider mb-1">Dosis / Takaran</label>
                    <input :value="selected.dosis" @input="$emit('update-dosis', selected.obat_id, $event.target.value)"
                      type="text" placeholder="Contoh: 1 tablet / 1 sendok teh"
                      class="w-full px-2 py-1.5 text-xs border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500 outline-none transition-all"/>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="mt-2 p-3 bg-blue-50 border border-blue-100 rounded-xl flex items-center gap-2">
              <svg class="w-4 h-4 text-blue-500 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20"><path d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"/></svg>
              <p class="text-[10px] text-blue-700 font-bold italic">Atur jadwal konsumsi (frekuensi, waktu) di Langkah 2. Seluruh obat ini akan memiliki jadwal yang sama.</p>
            </div>
          </div>
        </transition>
      </div>
    </div>

    <div class="flex justify-end gap-3 mt-8">
      <button @click="$emit('cancel')" class="px-6 py-2.5 border border-gray-300 rounded-xl text-sm font-bold text-gray-600 hover:bg-gray-50">Batal</button>
      <button @click="$emit('next')" :disabled="!form.patientId || !form.obatList || form.obatList.length === 0"
        class="px-8 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 disabled:opacity-40 flex items-center gap-2 transition-all">
        Lanjut ke Aturan Minum
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/></svg>
      </button>
    </div>
  </div>
</template>

<script>
import { API_BASE_URL } from '../../../config'

export default {
  name: 'Step1PasienObat',
  props: {
    form: { type: Object, required: true },
    pasienList: { type: Array, default: () => [] },
    obatList: { type: Array, default: () => [] },
    searchPasien: { type: String, default: '' },
    searchObat: { type: String, default: '' },
    selectedPasienName: { type: String, default: '' },
    selectedPasienNIK: { type: String, default: '' },
    selectedPasienJK: { type: String, default: '' },
    selectedPasienTelepon: { type: String, default: '' },
    selectedPasienAlamat: { type: String, default: '' },
  },
  emits: ['update:form', 'update:searchPasien', 'update:searchObat', 'select-pasien', 'select-obat', 'update-dosis', 'next', 'cancel'],
  data() {
    return {
      API_BASE_URL
    }
  },
  methods: {
    update(field, value) {
      this.$emit('update:form', { ...this.form, [field]: value })
    },
    resetPasien() {
      this.update('patientId', null);
      this.$emit('update:searchPasien', '');
    },
    getInitials(nama) {
      if (!nama) return '?'
      return nama.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    },
    getColorClass(id) {
      const colors = ['bg-teal-500', 'bg-purple-500', 'bg-orange-500', 'bg-rose-500', 'bg-blue-500']
      return colors[(id || 0) % colors.length]
    },
  },
}
</script>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.3s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>