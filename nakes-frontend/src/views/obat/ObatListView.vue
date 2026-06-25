<template>
  <div class="p-2 md:p-2">
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
      <div>
        <h1 class="text-2xl md:text-3xl font-bold text-slate-900">Daftar Informasi Obat</h1>
      </div>
      <button 
        @click="$emit('add-obat')"
        class="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-lg text-sm font-bold flex items-center gap-2 transition-all shadow-sm"
      >
        <span>+</span> Tambah Obat
      </button>
    </div>

    <div class="p-4 border-b border-slate-100">
      <div class="relative max-w-sm">
        <svg 
          class="absolute left-3 top-2.5 w-5 h-5 text-gray-400" 
          fill="none" 
          stroke="currentColor" 
          viewBox="0 0 24 24"
        >
          <path 
            stroke-linecap="round" 
            stroke-linejoin="round" 
            stroke-width="2" 
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
          />
        </svg>
        <input 
          type="text" 
          v-model="search"
          placeholder="Cari nama obat..."
          class="block w-full pl-10 pr-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-teal-500 outline-none"
        />
      </div>
    </div>

    <!-- Desktop Table View -->
    <div class="hidden md:block bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden">
      <table class="w-full text-left">
        <thead class="bg-slate-50">
          <tr class="text-xs text-slate-500 uppercase tracking-wider">
            <th class="px-6 py-4 text-left border-b border-slate-200">No</th>
            <th class="px-6 py-4 text-left border-b border-slate-200">Nama Obat</th>
            <th class="px-6 py-4 text-left border-b border-slate-200">Fungsi</th>
            <th class="px-6 py-4 text-center border-b border-slate-200">Aksi</th>
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
            <td class="px-6 py-4 text-center relative">
              <div class="relative inline-block text-left" :ref="el => { if(el) menuRefs[obat.obat_id] = el }">
                <button @click.stop="toggleDropdown(obat.obat_id)" class="p-2 text-slate-400 hover:text-teal-600 border border-slate-100 rounded-lg hover:bg-white transition-all shadow-sm">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                  </svg>
                </button>
                
                <Teleport to="body">
                  <div 
                    v-if="openDropdownId === obat.obat_id"
                    :style="getDropdownStyle(obat.obat_id)"
                    class="fixed w-44 bg-white rounded-xl shadow-lg border border-gray-100 z-50 py-2"
                    @click.stop
                  >
                    <button @click.stop="$emit('select-obat', obat); closeDropdown()" class="w-full text-left px-4 py-2.5 text-sm text-slate-600 hover:bg-slate-50 hover:text-teal-600 transition-colors flex items-center gap-2">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                      Lihat Detail
                    </button>
                    <button @click.stop="$emit('edit-obat', obat); closeDropdown()" class="w-full text-left px-4 py-2.5 text-sm text-slate-600 hover:bg-slate-50 hover:text-teal-600 transition-colors flex items-center gap-2">
                      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                      Edit
                    </button>
                  </div>
                </Teleport>
              </div>
            </td>
          </tr>
          <tr v-if="filteredList.length === 0">
            <td colspan="4" class="px-6 py-10 text-center text-slate-400">Belum ada data obat.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Mobile Card View -->
    <div class="md:hidden space-y-4">
      <div 
        v-for="(obat, index) in filteredList" 
        :key="obat.obat_id"
        @click="$emit('select-obat', obat)"
        class="bg-white rounded-2xl border p-5 shadow-sm hover:border-teal-500 transition-all cursor-pointer relative"
        :class="selectedId === obat.obat_id ? 'border-teal-500 bg-teal-50/20' : 'border-slate-100'"
      >
        <div class="flex justify-between items-start gap-4">
          <div class="space-y-2 text-left">
            <span class="inline-flex items-center justify-center w-6 h-6 rounded-full bg-slate-100 text-[10px] font-bold text-slate-500">
              #{{ index + 1 }}
            </span>
            <h3 class="font-bold text-slate-800 text-base leading-snug">{{ obat.nama_obat }}</h3>
            <p class="text-xs text-slate-500 leading-relaxed line-clamp-3">
              <span class="font-semibold text-teal-600">Fungsi:</span> {{ obat.fungsi || '-' }}
            </p>
          </div>

          <!-- Actions Dropdown -->
          <div class="relative inline-block text-left" :ref="el => { if(el) menuRefs['m_' + obat.obat_id] = el }">
            <button @click.stop="toggleDropdown('m_' + obat.obat_id)" class="p-2 text-slate-400 hover:text-teal-600 border border-slate-100 rounded-lg hover:bg-white transition-all shadow-sm">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
              </svg>
            </button>
            
            <Teleport to="body">
              <div 
                v-if="openDropdownId === 'm_' + obat.obat_id"
                :style="getDropdownStyle('m_' + obat.obat_id, true)"
                class="fixed w-40 bg-white rounded-xl shadow-lg border border-gray-100 z-50 py-1"
                @click.stop
              >
                <button @click.stop="$emit('select-obat', obat); closeDropdown()" class="w-full text-left px-3 py-2 text-xs text-slate-600 hover:bg-slate-50 hover:text-teal-600 transition-colors flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                  Lihat Detail
                </button>
                <button @click.stop="$emit('edit-obat', obat); closeDropdown()" class="w-full text-left px-3 py-2 text-xs text-slate-600 hover:bg-slate-50 hover:text-teal-600 transition-colors flex items-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                  Edit
                </button>
              </div>
            </Teleport>
          </div>
        </div>
      </div>
      <div v-if="filteredList.length === 0" class="bg-white rounded-2xl border p-8 text-center text-slate-400">
        Belum ada data obat.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useObatStore } from '../../stores/obat.js'

const props = defineProps(['obatList', 'selectedId'])
const emit = defineEmits(['add-obat', 'edit-obat', 'select-obat'])
const obatStore = useObatStore()
const search = ref('')
const openDropdownId = ref(null)
const menuRefs = ref({})

const toggleDropdown = (id) => {
  if (openDropdownId.value === id) {
    openDropdownId.value = null
  } else {
    openDropdownId.value = id
  }
}

const closeDropdown = () => {
  openDropdownId.value = null
}

const getDropdownStyle = (id, isMobile = false) => {
  const el = menuRefs.value[id]
  if (!el) return {}
  const rect = el.getBoundingClientRect()
  return {
    top: rect.bottom + 4 + 'px',
    left: rect.right - (isMobile ? 160 : 176) + 'px', 
  }
}

const handleClickOutside = (e) => {
  const isInsideAnyMenu = Object.values(menuRefs.value).some(
    el => el && el.contains(e.target)
  )
  if (!isInsideAnyMenu) openDropdownId.value = null
}

onMounted(() => document.addEventListener('click', handleClickOutside))
onBeforeUnmount(() => document.removeEventListener('click', handleClickOutside))

const filteredList = computed(() => {
  if (!search.value) return props.obatList
  return props.obatList.filter(o => o.nama_obat.toLowerCase().includes(search.value.toLowerCase()))
})

</script>