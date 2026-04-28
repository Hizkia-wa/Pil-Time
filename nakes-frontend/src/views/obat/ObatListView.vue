<template>
  <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
    <div class="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/50">
      <div>
        <h2 class="text-lg font-bold text-slate-800">Daftar Informasi Obat</h2>
        <p class="text-xs text-slate-500">Kelola database obat untuk sistem reminder.</p>
      </div>
      <button 
        @click="$emit('add-obat')"
        class="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-lg text-sm font-bold flex items-center gap-2 transition-all"
      >
        <span>+</span> Tambah Obat
      </button>
    </div>

    <div class="p-4 border-b border-slate-100">
      <div class="relative max-w-sm">
        <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-slate-400">🔍</span>
        <input 
          type="text" 
          v-model="search"
          placeholder="Cari nama obat..."
          class="block w-full pl-10 pr-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-teal-500 outline-none"
        />
      </div>
    </div>

    <div class="overflow-x-auto">
      <table class="w-full text-left">
        <thead class="bg-slate-50 text-slate-600 text-[11px] font-bold uppercase tracking-wider">
          <tr>
            <th class="px-6 py-4">No</th>
            <th class="px-6 py-4">Nama Obat</th>
            <th class="px-6 py-4">Fungsi</th>
            <th class="px-6 py-4 text-center">Aksi</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr 
            v-for="(obat, index) in filteredList" 
            :key="obat.obat_id"
            @click="$emit('select-obat', obat)"
            class="hover:bg-slate-50 transition-colors cursor-pointer"
            :class="{ 'bg-teal-50': selectedId === obat.obat_id }"
          >
            <td class="px-6 py-4 text-sm text-slate-500">{{ index + 1 }}</td>
            <td class="px-6 py-4 font-medium text-slate-700">{{ obat.nama_obat }}</td>
            <td class="px-6 py-4 text-sm text-slate-600 truncate max-w-[200px]">{{ obat.fungsi || '-' }}</td>
            <td class="px-6 py-4">
                <div class="flex justify-center gap-2">
                    <button 
                    @click.stop="$emit('select-obat', obat)" 
                    class="p-2 text-teal-600 hover:bg-teal-50 rounded-lg"
                    title="Lihat Detail"
                    >
                    👁️
                    </button>

                    <button 
                    @click.stop="$emit('edit-obat', obat)" 
                    class="p-2 text-amber-600 hover:bg-amber-50 rounded-lg"
                    title="Edit"
                    >
                    ✏️
                    </button>
                    
                    <button 
                    @click.stop="deleteData(obat.obat_id)" 
                    class="p-2 text-red-600 hover:bg-red-50 rounded-lg"
                    title="Hapus"
                    >
                    🗑️
                    </button>
                </div>
            </td>
          </tr>
          <tr v-if="filteredList.length === 0">
            <td colspan="4" class="px-6 py-10 text-center text-slate-400">Belum ada data obat.</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useObatStore } from '../../stores/obat.js'

const props = defineProps(['obatList', 'selectedId'])
const emit = defineEmits(['add-obat', 'edit-obat', 'select-obat'])
const obatStore = useObatStore()
const search = ref('')

const filteredList = computed(() => {
  if (!search.value) return props.obatList
  return props.obatList.filter(o => o.nama_obat.toLowerCase().includes(search.value.toLowerCase()))
})

const deleteData = async (id) => {
  if(confirm('Hapus data ini?')) {
    await obatStore.deleteObat(id)
    await obatStore.fetchObats()
  }
}
</script>