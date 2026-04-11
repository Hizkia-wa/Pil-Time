    <template>
  <div class="p-4 md:p-8">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:justify-between md:items-center gap-4 mb-6 md:mb-8">
      <div>
        <h1 class="text-xl md:text-2xl font-bold text-slate-900">Jadwal Obat</h1>
        <p class="text-xs md:text-sm text-gray-500 mt-1">Selamat datang, Ns. Sari Dewi</p>
      </div>
      <button
        @click="$emit('open-add')"
        class="w-full md:w-auto px-4 md:px-5 py-2.5 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition font-medium text-xs md:text-sm flex items-center justify-center gap-2 shadow-sm"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
        </svg>
        Tambah Jadwal Obat
      </button>
    </div>

    <!-- Search -->
    <div class="mb-4 md:mb-5">
      <div class="relative w-full md:max-w-sm">
        <svg class="absolute left-3 top-2.5 w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
        </svg>
        <input
          :value="searchQuery"
          @input="$emit('update:searchQuery', $event.target.value)"
          type="text"
          placeholder="Cari pasien atau nama obat..."
          class="w-full pl-9 pr-4 py-2 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none bg-white"
        />
      </div>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
      <!-- Desktop Table (Hidden on mobile) -->
      <table class="w-full hidden md:table">
        <thead>
          <tr class="border-b border-gray-100">
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Pasien</th>
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Nama Obat</th>
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Dosis</th>
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Frekuensi</th>
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Waktu</th>
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Durasi</th>
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Status</th>
            <th class="px-4 md:px-6 py-3.5 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Aksi</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-50">
          <tr v-for="jadwal in jadwalList" :key="jadwal.id" class="hover:bg-gray-50 transition">
            <td class="px-4 md:px-6 py-4 text-xs md:text-sm font-medium text-slate-900">{{ jadwal.pasien_nama }}</td>
            <td class="px-4 md:px-6 py-4 text-xs md:text-sm text-gray-600">{{ jadwal.nama_obat }}</td>
            <td class="px-4 md:px-6 py-4 text-xs md:text-sm text-gray-600">{{ jadwal.jumlah_dosis }} {{ jadwal.satuan }}</td>
            <td class="px-4 md:px-6 py-4 text-xs md:text-sm text-gray-600">{{ jadwal.frekuensi_per_hari }}x sehari</td>
            <td class="px-4 md:px-6 py-4 text-xs md:text-sm text-gray-600">{{ jadwal.waktu_minum }}</td>
            <td class="px-4 md:px-6 py-4 text-xs md:text-sm">
              <span v-if="jadwal.tipe_durasi === 'hari'"
                class="text-xs bg-blue-50 text-blue-700 px-2.5 py-1 rounded-full font-medium">
                {{ jadwal.jumlah_hari }} hari
              </span>
              <span v-else class="text-xs bg-gray-100 text-gray-600 px-2.5 py-1 rounded-full font-medium">
                Rutin
              </span>
            </td>
            <td class="px-4 md:px-6 py-4">
              <span class="text-xs bg-green-100 text-green-700 px-2.5 py-1 rounded-full font-medium flex items-center gap-1 w-fit">
                <span class="w-1.5 h-1.5 bg-green-500 rounded-full"></span>
                Aktif
              </span>
            </td>
            <td class="px-4 md:px-6 py-4">
              <button @click="$emit('delete', jadwal.id)"
                class="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                </svg>
              </button>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Mobile Card View (Hidden on desktop) -->
      <div class="md:hidden space-y-3">
        <div v-for="jadwal in jadwalList" :key="jadwal.id" class="bg-white rounded-lg p-4 border border-gray-100 shadow-sm">
          <div class="flex justify-between items-start mb-3">
            <div class="flex-1 min-w-0">
              <p class="font-semibold text-slate-900 text-sm">{{ jadwal.pasien_nama }}</p>
              <p class="text-xs text-gray-500 mt-1">{{ jadwal.nama_obat }}</p>
            </div>
            <button @click="$emit('delete', jadwal.id)"
              class="ml-2 p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded transition flex-shrink-0">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
              </svg>
            </button>
          </div>
          <div class="grid grid-cols-2 gap-2 text-xs">
            <div class="bg-gray-50 rounded p-2">
              <p class="text-gray-500 font-medium">Dosis</p>
              <p class="font-semibold text-slate-900 mt-1">{{ jadwal.jumlah_dosis }} {{ jadwal.satuan }}</p>
            </div>
            <div class="bg-gray-50 rounded p-2">
              <p class="text-gray-500 font-medium">Frekuensi</p>
              <p class="font-semibold text-slate-900 mt-1">{{ jadwal.frekuensi_per_hari }}x/hari</p>
            </div>
            <div class="bg-gray-50 rounded p-2">
              <p class="text-gray-500 font-medium">Waktu</p>
              <p class="font-semibold text-slate-900 mt-1">{{ jadwal.waktu_minum }}</p>
            </div>
            <div class="bg-gray-50 rounded p-2">
              <p class="text-gray-500 font-medium">Durasi</p>
              <p class="font-semibold text-slate-900 mt-1">
                <span v-if="jadwal.tipe_durasi === 'hari'">{{ jadwal.jumlah_hari }}d</span>
                <span v-else>Rutin</span>
              </p>
            </div>
          </div>
          <div class="mt-3 flex justify-end">
            <span class="text-xs bg-green-100 text-green-700 px-2.5 py-1 rounded-full font-medium flex items-center gap-1">
              <span class="w-1.5 h-1.5 bg-green-500 rounded-full"></span>
              Aktif
            </span>
          </div>
        </div>
      </div>

      <!-- Empty state -->
      <div v-if="jadwalList.length === 0" class="py-12 md:py-16 text-center">
        <svg class="w-10 h-10 md:w-12 md:h-12 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
        </svg>
        <p class="text-gray-400 text-xs md:text-sm">Belum ada data jadwal obat</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'JadwalTable',
  props: {
    jadwalList: { type: Array, default: () => [] },
    searchQuery: { type: String, default: '' },
  },
  emits: ['open-add', 'delete', 'update:searchQuery'],
}
</script>