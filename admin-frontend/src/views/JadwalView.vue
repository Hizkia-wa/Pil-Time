<template>
  <LayoutWrapper>
    <div class="p-8">
      <!-- Success Modal -->
      <div v-if="showSuccessModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white rounded-lg shadow-xl p-8 w-full max-w-2xl">
          <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-20 h-20 bg-teal-100 rounded-full mb-6">
              <svg class="w-10 h-10 text-teal-600" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
              </svg>
            </div>
            <h2 class="text-2xl font-bold text-slate-900 mb-2">Jadwal Berhasil Disimpan!</h2>
            <p class="text-gray-600 mb-4">Jadwal minimum obat untuk <span class="font-semibold">{{ successData.patientName }}</span> telah ditambahkan.</p>
            <p class="text-sm text-gray-500">Notifikasi pengingat akan dikirim ke aplikasi pasien sesuai jadwal.</p>
          </div>

          <!-- Summary Cards -->
          <div class="bg-gray-50 rounded-lg p-6 mb-8 space-y-4">
            <div class="flex items-center space-x-4 pb-4 border-b border-gray-200">
              <div class="flex items-center justify-center w-10 h-10 bg-teal-100 rounded-full">
                <svg class="w-5 h-5 text-teal-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
                </svg>
              </div>
              <div>
                <p class="text-xs text-gray-600">PASIEN</p>
                <p class="font-semibold text-gray-900">{{ successData.patientName }}</p>
              </div>
            </div>
            <div class="flex items-center space-x-4 pb-4 border-b border-gray-200">
              <div class="flex items-center justify-center w-10 h-10 bg-purple-100 rounded-full">
                <svg class="w-5 h-5 text-purple-600" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z" />
                  <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7a1 1 0 00-1 1v6.05A2.5 2.5 0 0115.95 16H17a1 1 0 001-1v-5a1 1 0 00-.293-.707l-2-2A1 1 0 0015 7h-1z" />
                </svg>
              </div>
              <div>
                <p class="text-xs text-gray-600">OBAT</p>
                <p class="font-semibold text-gray-900">{{ successData.medicineName }}</p>
              </div>
            </div>
            <div class="flex items-center space-x-4 pb-4 border-b border-gray-200">
              <div class="flex items-center justify-center w-10 h-10 bg-yellow-100 rounded-full">
                <svg class="w-5 h-5 text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v2a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
                </svg>
              </div>
              <div>
                <p class="text-xs text-gray-600">JADWAL</p>
                <p class="font-semibold text-gray-900">{{ successData.frequency }}</p>
              </div>
            </div>
            <div class="flex items-center space-x-4">
              <div class="flex items-center justify-center w-10 h-10 bg-orange-100 rounded-full">
                <svg class="w-5 h-5 text-orange-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v3.586L7.707 9.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L11 10.586V7z" clip-rule="evenodd" />
                </svg>
              </div>
              <div>
                <p class="text-xs text-gray-600">MULAI</p>
                <p class="font-semibold text-gray-900">{{ successData.startDate }}</p>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="flex gap-4">
            <button 
              @click="closeSuccessModal"
              class="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium"
            >
              ← Kembali ke Daftar
            </button>
            <button 
              @click="openAddModal"
              class="flex-1 px-4 py-2 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition font-medium"
            >
              + Tambah Jadwal Lain
            </button>
          </div>
        </div>
      </div>

      <!-- Add/Edit Modal -->
      <div v-if="showAddModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 overflow-y-auto">
        <div class="bg-white rounded-lg shadow-xl p-8 w-full max-w-4xl my-8">
          <button 
            @click="closeAddModal"
            class="float-right text-gray-400 hover:text-gray-600 text-2xl font-bold"
          >
            ×
          </button>
          <h2 class="text-2xl font-bold text-slate-900 mb-6">Tambah Jadwal Obat</h2>
          <p class="text-gray-600 text-sm mb-8">Isi formulir berikut untuk membuat jadwal minimum obat pasien</p>

          <form @submit.prevent="handleSubmit" class="space-y-6">
            <div class="grid grid-cols-2 gap-8">
              <!-- Left Column: Patient Selection -->
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                    <svg class="w-5 h-5 text-teal-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
                    </svg>
                    Pilih Pasien
                  </label>
                  <p class="text-xs text-gray-600 mb-3">Cari dan pilih pasien yang akan menerima jadwal obat</p>
                </div>

                <input 
                  v-model="searchPasien"
                  type="text"
                  placeholder="Cari nama pasien..."
                  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none mb-4"
                />

                <div class="space-y-2 max-h-80 overflow-y-auto border border-gray-200 rounded-lg p-4">
                  <div 
                    v-for="pasien in filteredPasien"
                    :key="pasien.id"
                    @click="selectPasien(pasien)"
                    :class="['p-3 rounded-lg cursor-pointer transition', form.patientId === pasien.id ? 'bg-teal-50 border-l-4 border-teal-500' : 'hover:bg-gray-50']"
                  >
                    <div class="flex items-center space-x-3">
                      <div :class="['w-10 h-10 rounded-full flex items-center justify-center text-white font-semibold', getColorClass(pasien.id)]">
                        {{ getInitials(pasien.nama) }}
                      </div>
                      <div>
                        <p :class="['font-medium', form.patientId === pasien.id ? 'text-teal-600' : 'text-gray-900']">{{ pasien.nama }}</p>
                        <p class="text-xs text-gray-500">{{ pasien.no_rekam_medis }}</p>
                      </div>
                      <svg v-if="form.patientId === pasien.id" class="w-5 h-5 text-teal-500 ml-auto" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                      </svg>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Right Column: Medicine Information -->
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                    <svg class="w-5 h-5 text-purple-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
                      <path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z" />
                      <path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7a1 1 0 00-1 1v6.05A2.5 2.5 0 0115.95 16H17a1 1 0 001-1v-5a1 1 0 00-.293-.707l-2-2A1 1 0 0015 7h-1z" />
                    </svg>
                    Informasi Obat
                  </label>
                  <p class="text-xs text-gray-600 mb-3">Masukkan detail obat yang akan dijadwalkan</p>
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nama Obat</label>
                  <input 
                    v-model="form.nama_obat"
                    type="text"
                    required
                    placeholder="Contoh: Amlodipine"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"
                  />
                </div>

                <div class="grid grid-cols-2 gap-3">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Jumlah Dosis</label>
                    <input 
                      v-model.number="form.jumlah_dosis"
                      type="number"
                      required
                      min="1"
                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"
                    />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Satuan</label>
                    <select v-model="form.satuan" required class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none">
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
                  <input 
                    v-model="form.kategori_obat"
                    type="text"
                    required
                    placeholder="Contoh: Antihipertensi"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Takaran Obat</label>
                  <input 
                    v-model="form.takaran_obat"
                    type="text"
                    required
                    placeholder="Contoh: 5mg"
                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent outline-none"
                  />
                </div>
              </div>
            </div>

            <!-- Schedule Details -->
            <div class="border-t border-gray-200 pt-6">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">Jadwal Pemberian Obat</h3>
              
              <div class="grid grid-cols-2 gap-8">
                <!-- Left: Frequency & Waktu Minimum -->
                <div class="space-y-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-3 flex items-center">
                      <svg class="w-5 h-5 text-yellow-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v2a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd" />
                      </svg>
                      Frekuensi & Waktu Minimum
                    </label>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Frekuensi per Hari *</label>
                    <input 
                      v-model.number="form.frekuensi_per_hari"
                      type="number"
                      required
                      min="1"
                      placeholder="Contoh: 2x sehari"
                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent outline-none"
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Waktu Minum *</label>
                    <div class="flex gap-2">
                      <label v-for="waktu in wakteMinum" :key="waktu" class="flex items-center">
                        <input 
                          v-model="form.waktu_minum"
                          :value="waktu"
                          type="radio"
                          required
                          class="w-4 h-4 text-teal-600"
                        />
                        <span class="ml-2 text-sm text-gray-700">{{ waktu }}</span>
                      </label>
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Aturan Konsumsi *</label>
                    <div class="space-y-2">
                      <label v-for="aturan in aturanKonsumsi" :key="aturan" class="flex items-center">
                        <input 
                          v-model="form.aturan_konsumsi"
                          :value="aturan"
                          type="radio"
                          required
                          class="w-4 h-4 text-teal-600"
                        />
                        <span class="ml-2 text-sm text-gray-700">{{ aturan }}</span>
                      </label>
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Catatan untuk Pasien</label>
                    <textarea 
                      v-model="form.catatan"
                      rows="4"
                      placeholder="Minimum dengan seglaa air penuh, hindari konsmsi lainnya/bersama jus jeruk"
                      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none resize-none"
                    ></textarea>
                  </div>
                </div>

                <!-- Right: Duration & Jadwal -->
                <div class="space-y-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-3 flex items-center">
                      <svg class="w-5 h-5 text-red-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
                      </svg>
                      Durasi & Jadwal
                    </label>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tipe Durasi *</label>
                    <div class="flex gap-2">
                      <button 
                        v-for="tipe in tipeJadwal"
                        :key="tipe"
                        @click.prevent="form.tipe_durasi = tipe"
                        :class="['flex-1 px-3 py-2 rounded-lg transition border font-medium', 
                          form.tipe_durasi === tipe 
                            ? 'bg-green-600 text-white border-green-600' 
                            : 'border-gray-300 text-gray-700 hover:bg-gray-50']"
                      >
                        {{ tipe === 'hari' ? '📅 Jumlah Hari' : '🔄 Rutin' }}
                      </button>
                    </div>
                  </div>

                  <div v-if="form.tipe_durasi === 'hari'" class="space-y-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">Jumlah Hari *</label>
                      <div class="flex items-center gap-4">
                        <button 
                          @click.prevent="form.jumlah_hari--"
                          type="button"
                          class="px-3 py-2 bg-gray-200 rounded hover:bg-gray-300"
                        >
                          −
                        </button>
                        <span class="text-3xl font-bold text-gray-900 w-20 text-center">{{ form.jumlah_hari }}</span>
                        <button 
                          @click.prevent="form.jumlah_hari++"
                          type="button"
                          class="px-3 py-2 bg-gray-200 rounded hover:bg-gray-300"
                        >
                          +
                        </button>
                        <span class="text-sm text-gray-600">hari</span>
                      </div>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Mulai *</label>
                      <input 
                        v-model="form.tanggal_mulai"
                        type="date"
                        required
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"
                      />
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Selesai *</label>
                      <input 
                        v-model="form.tanggal_selesai"
                        type="date"
                        disabled
                        class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-500"
                      />
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Waktu Pengingat Spesifik</label>
                    <div class="grid grid-cols-2 gap-2">
                      <div>
                        <label class="block text-xs text-gray-600 mb-1">Pagi</label>
                        <input 
                          v-model="form.waktu_reminder_pagi"
                          type="time"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"
                        />
                      </div>
                      <div>
                        <label class="block text-xs text-gray-600 mb-1">Malam</label>
                        <input 
                          v-model="form.waktu_reminder_malam"
                          type="time"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"
                        />
                      </div>
                    </div>

                    <div class="mt-3 p-3 bg-teal-50 rounded-lg border border-teal-200">
                      <p class="text-xs text-teal-700">
                        ✓ Pengingat akan dikirim 5 menit sebelum waktu minum yang dijadwalkan.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Buttons -->
            <div class="flex gap-3 pt-6 border-t border-gray-200">
              <button
                type="button"
                @click="closeAddModal"
                class="flex-1 px-4 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium"
              >
                ← Kembali
              </button>
              <button
                type="submit"
                class="flex-1 px-4 py-3 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition font-medium"
              >
                Konfirmasi →
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Main Content -->
      <div class="flex justify-between items-center mb-8">
        <div>
          <h1 class="text-3xl font-bold text-slate-900">Jadwal Obat Pasien</h1>
          <p class="text-gray-600 text-sm mt-2">Selamat datang, Ns. Sari Dewi</p>
        </div>
        <button 
          @click="openAddModal"
          class="px-6 py-2 bg-teal-600 text-white rounded-lg hover:bg-teal-700 transition font-medium flex items-center gap-2"
        >
          + Tambah Jadwal Obat
        </button>
      </div>

      <!-- Search Bar -->
      <div class="mb-6">
        <div class="relative">
          <svg class="absolute left-3 top-3 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input 
            v-model="searchQuery"
            type="text"
            placeholder="Cari pasien atau nama obat..."
            class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent outline-none"
          />
        </div>
      </div>

      <!-- Table -->
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">PASIEN</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">NAMA OBAT</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">DOSIS</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">FREKUENSI</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">WAKTU</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">DURASI</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">STATUS</th>
              <th class="px-6 py-3 text-left text-sm font-semibold text-gray-900">AKSI</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="jadwal in filteredJadwalList" :key="jadwal.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 text-sm font-medium text-slate-900">{{ jadwal.pasien_nama }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ jadwal.nama_obat }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ jadwal.jumlah_dosis }} {{ jadwal.satuan }}</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ jadwal.frekuensi_per_hari }}x sehari</td>
              <td class="px-6 py-4 text-sm text-gray-600">{{ jadwal.waktu_minum }}</td>
              <td class="px-6 py-4 text-sm">
                <span v-if="jadwal.tipe_durasi === 'hari'" class="text-gray-600">{{ jadwal.jumlah_hari }} hari</span>
                <span v-else class="text-gray-600">Rutin</span>
              </td>
              <td class="px-6 py-4 text-sm">
                <span :class="['px-2 py-1 rounded-full text-xs font-semibold', jadwal.status === 'aktif' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800']">
                  {{ jadwal.status === 'aktif' ? '● Aktif' : '● Rutin' }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm space-x-2 flex">
                <button 
                  @click="editJadwal(jadwal)"
                  class="px-3 py-1 text-blue-600 bg-blue-50 rounded hover:bg-blue-100 transition text-xs"
                >
                  ✎ Edit
                </button>
                <button 
                  @click="deleteJadwal(jadwal.id)"
                  class="px-3 py-1 text-red-600 bg-red-50 rounded hover:bg-red-100 transition text-xs"
                >
                  🗑 Hapus
                </button>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Empty State -->
        <div v-if="filteredJadwalList.length === 0" class="px-6 py-12 text-center">
          <p class="text-gray-500">Belum ada data jadwal obat</p>
        </div>
      </div>
    </div>
  </LayoutWrapper>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import LayoutWrapper from '../components/LayoutWrapper.vue'
import { useJadwalStore } from '../stores/jadwal'

export default {
  name: 'JadwalView',
  components: {
    LayoutWrapper
  },
  setup() {
    const jadwalStore = useJadwalStore()
    const showAddModal = ref(false)
    const showSuccessModal = ref(false)
    const searchQuery = ref('')
    const searchPasien = ref('')
    
    // Sample patient data - replace with actual API call
    const daftarPasien = ref([
      { id: 1, nama: 'Megan Palmer', no_rekam_medis: 'P-001' },
      { id: 2, nama: 'Budi Santoso', no_rekam_medis: 'P-003' },
      { id: 3, nama: 'Siti Rahayu', no_rekam_medis: 'P-003' },
      { id: 4, nama: 'Hendra Wijaya', no_rekam_medis: 'P-004' },
      { id: 5, nama: 'Ahmad Fauzii', no_rekam_medis: 'P-005' }
    ])

    const wakteMinum = ['Pagi', 'Siang', 'Malam', 'Saat tidur']
    const aturanKonsumsi = ['Sebelum makan', 'Sesudah makan', 'Bersama makan']
    const tipeJadwal = ['hari', 'rutin']

    const form = ref({
      patientId: null,
      nama_obat: '',
      jumlah_dosis: null,
      satuan: '',
      kategori_obat: '',
      takaran_obat: '',
      frekuensi_per_hari: null,
      waktu_minum: '',
      aturan_konsumsi: '',
      catatan: '',
      tipe_durasi: 'hari',
      jumlah_hari: 7,
      tanggal_mulai: '',
      tanggal_selesai: '',
      waktu_reminder_pagi: '07:00',
      waktu_reminder_malam: '19:00'
    })

    const successData = ref({
      patientName: '',
      medicineName: '',
      frequency: '',
      startDate: ''
    })

    const filteredPasien = computed(() => {
      if (!searchPasien.value) return daftarPasien.value
      return daftarPasien.value.filter(p => 
        p.nama.toLowerCase().includes(searchPasien.value.toLowerCase())
      )
    })

    const filteredJadwalList = computed(() => {
      if (!searchQuery.value) return jadwalStore.jadwalList
      const query = searchQuery.value.toLowerCase()
      return jadwalStore.jadwalList.filter(j =>
        j.pasien_nama.toLowerCase().includes(query) ||
        j.nama_obat.toLowerCase().includes(query)
      )
    })

    const getInitials = (nama) => {
      return nama.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    }

    const getColorClass = (id) => {
      const colors = ['bg-teal-500', 'bg-purple-500', 'bg-yellow-500', 'bg-red-500', 'bg-blue-500']
      return colors[id % colors.length]
    }

    const selectPasien = (pasien) => {
      form.value.patientId = pasien.id
    }

    const openAddModal = () => {
      form.value = {
        patientId: null,
        nama_obat: '',
        jumlah_dosis: null,
        satuan: '',
        kategori_obat: '',
        takaran_obat: '',
        frekuensi_per_hari: null,
        waktu_minum: '',
        aturan_konsumsi: '',
        catatan: '',
        tipe_durasi: 'hari',
        jumlah_hari: 7,
        tanggal_mulai: '',
        tanggal_selesai: '',
        waktu_reminder_pagi: '07:00',
        waktu_reminder_malam: '19:00'
      }
      searchPasien.value = ''
      showAddModal.value = true
      showSuccessModal.value = false
    }

    const closeAddModal = () => {
      showAddModal.value = false
    }

    const closeSuccessModal = () => {
      showSuccessModal.value = false
    }

    const handleSubmit = async () => {
      try {
        const pasien = daftarPasien.value.find(p => p.id === form.value.patientId)
        
        const jadwalData = {
          pasien_id: form.value.patientId,
          pasien_nama: pasien.nama,
          nama_obat: form.value.nama_obat,
          jumlah_dosis: form.value.jumlah_dosis,
          satuan: form.value.satuan,
          kategori_obat: form.value.kategori_obat,
          takaran_obat: form.value.takaran_obat,
          frekuensi_per_hari: form.value.frekuensi_per_hari,
          waktu_minum: form.value.waktu_minum,
          aturan_konsumsi: form.value.aturan_konsumsi,
          catatan: form.value.catatan,
          tipe_durasi: form.value.tipe_durasi,
          jumlah_hari: form.value.jumlah_hari,
          tanggal_mulai: form.value.tanggal_mulai,
          tanggal_selesai: form.value.tanggal_selesai,
          waktu_reminder_pagi: form.value.waktu_reminder_pagi,
          waktu_reminder_malam: form.value.waktu_reminder_malam,
          status: 'aktif'
        }

        await jadwalStore.createJadwal(jadwalData)
        
        // Show success modal
        successData.value = {
          patientName: pasien.nama,
          medicineName: form.value.nama_obat,
          frequency: form.value.frekuensi_per_hari + 'x sehari - ' + form.value.waktu_minum,
          startDate: new Date(form.value.tanggal_mulai).toLocaleDateString('id-ID', { year: 'numeric', month: 'long', day: 'numeric' })
        }
        
        showAddModal.value = false
        showSuccessModal.value = true
      } catch (error) {
        alert('Error: ' + error.message)
      }
    }

    const editJadwal = (jadwal) => {
      // Implement edit functionality
      alert('Edit functionality coming soon')
    }

    const deleteJadwal = async (id) => {
      if (confirm('Yakin ingin menghapus jadwal ini?')) {
        try {
          await jadwalStore.deleteJadwal(id)
        } catch (error) {
          alert('Gagal menghapus jadwal: ' + error.message)
        }
      }
    }

    onMounted(() => {
      jadwalStore.fetchJadwals()
    })

    return {
      jadwalStore,
      showAddModal,
      showSuccessModal,
      searchQuery,
      searchPasien,
      daftarPasien,
      filteredPasien,
      filteredJadwalList,
      form,
      successData,
      wakteMinum,
      aturanKonsumsi,
      tipeJadwal,
      getInitials,
      getColorClass,
      selectPasien,
      openAddModal,
      closeAddModal,
      closeSuccessModal,
      handleSubmit,
      editJadwal,
      deleteJadwal
    }
  }
}
</script>
