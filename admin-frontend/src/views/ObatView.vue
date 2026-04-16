<template>
  <LayoutWrapper>
    <div>
      <!-- LIST MODE -->
      <section v-if="pageMode === 'list'">
        <div class="flex items-start justify-between gap-4 border-b border-slate-200 pb-3 mb-4">
          <div>
            <h1 class="text-2xl font-bold text-slate-800">Info Obat</h1>
            <p class="text-xs text-slate-500">Selamat datang di Portal Tenaga Kesehatan</p>
          </div>
          <button class="w-7 h-7 rounded-lg border border-slate-200 text-slate-500 text-sm">🔔</button>
        </div>

        <!-- Stats: horizontal 3-column full-width -->
        <div class="grid grid-cols-3 gap-3 mb-4">
          <article class="bg-slate-50 border border-slate-200 rounded-lg p-3">
            <p class="text-[11px] text-slate-500">Total info obat</p>
            <p class="text-3xl font-semibold text-slate-800 leading-tight">{{ stats.total }}</p>
            <p class="text-[11px] text-slate-400">dalam katalog</p>
          </article>
          <article class="bg-slate-50 border border-slate-200 rounded-lg p-3">
            <p class="text-[11px] text-slate-500">Kategori</p>
            <p class="text-3xl font-semibold text-slate-800 leading-tight">{{ stats.categories }}</p>
            <p class="text-[11px] text-slate-400">jenis kategori obat</p>
          </article>
          <article class="bg-slate-50 border border-slate-200 rounded-lg p-3">
            <p class="text-[11px] text-slate-500">Ditambahkan bulan ini</p>
            <p class="text-3xl font-semibold text-slate-800 leading-tight">{{ stats.addedThisMonth }}</p>
            <p class="text-[11px] text-slate-400">info obat baru</p>
          </article>
        </div>

        <div class="bg-white border border-slate-200 rounded-lg overflow-hidden">
          <div class="p-3 border-b border-slate-200 flex gap-3 items-center justify-between">
            <label class="relative flex-1">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-sm">🔍</span>
              <input
                v-model="searchTerm"
                type="text"
                placeholder="Cari info obat..."
                class="w-full h-10 rounded-lg border border-slate-200 bg-slate-50 pl-9 pr-3 text-sm text-slate-700 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </label>

            <button
              @click="openCreatePage"
              class="h-10 px-4 rounded-lg bg-teal-600 text-white text-sm font-medium hover:bg-teal-700 transition whitespace-nowrap"
            >
              + Tambah info obat
            </button>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full min-w-[700px]">
              <thead class="bg-slate-50 border-b border-slate-200">
                <tr class="text-left text-[11px] uppercase tracking-wide text-slate-500">
                  <th class="px-4 py-3 font-semibold">Nama Obat</th>
                  <th class="px-4 py-3 font-semibold">Kategori</th>
                  <th class="px-4 py-3 font-semibold">Frekuensi</th>
                  <th class="px-4 py-3 font-semibold">Durasi</th>
                  <th class="px-4 py-3 font-semibold text-center">Aksi</th>
                </tr>
              </thead>

              <tbody>
                <tr v-for="obat in pagedObat" :key="obat.obat_id" class="border-b border-slate-100 hover:bg-slate-50/60">
                  <td class="px-4 py-3 align-top">
                    <p class="text-sm font-semibold text-slate-800">{{ obat.nama_obat }}</p>
                    <p class="text-xs text-slate-400">{{ getSubLabel(obat) }}</p>
                  </td>

                  <td class="px-4 py-3 align-top">
                    <span :class="getKategoriClass(obat)" class="inline-flex items-center rounded-full px-2.5 py-0.5 text-[11px] font-medium">
                      {{ getKategori(obat) }}
                    </span>
                  </td>

                  <td class="px-4 py-3 align-top text-sm text-slate-600">{{ getFrekuensi(obat) }}</td>
                  <td class="px-4 py-3 align-top text-sm text-slate-500">{{ getDurasi(obat) }}</td>

                  <!-- Only edit button, no delete -->
                  <td class="px-4 py-3 align-top">
                    <div class="flex items-center justify-center">
                      <button
                        @click="openEditPage(obat)"
                        class="w-8 h-8 rounded-lg border border-slate-200 text-slate-500 hover:text-teal-600 hover:border-teal-200 hover:bg-teal-50 transition flex items-center justify-center"
                        title="Edit"
                      >
                        <span class="text-[13px]">✎</span>
                      </button>
                    </div>
                  </td>
                </tr>

                <tr v-if="pagedObat.length === 0">
                  <td colspan="5" class="px-4 py-10 text-center text-sm text-slate-400">
                    Belum ada data obat.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="p-3 text-xs text-slate-400 flex items-center justify-between bg-white">
            <p>
              Menampilkan {{ paginationStart }}-{{ paginationEnd }} dari {{ filteredObat.length }} obat
            </p>

            <div class="flex items-center gap-1">
              <button
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                class="w-7 h-7 border rounded text-slate-500 disabled:opacity-40"
              >
                ‹
              </button>

              <button
                v-for="page in totalPages"
                :key="`page-${page}`"
                @click="goToPage(page)"
                :class="[
                  'w-7 h-7 border rounded text-xs font-medium',
                  page === currentPage ? 'bg-teal-600 border-teal-600 text-white' : 'text-slate-500 border-slate-200'
                ]"
              >
                {{ page }}
              </button>

              <button
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                class="w-7 h-7 border rounded text-slate-500 disabled:opacity-40"
              >
                ›
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- FORM MODE -->
      <section v-else>
        <!-- Header with back button + title + step indicator -->
        <div class="flex items-center justify-between gap-3 mb-5">
          <div class="flex items-center gap-3">
            <button
              @click="backFromForm"
              class="h-9 px-3 rounded-lg border border-slate-200 text-slate-500 text-sm hover:bg-slate-100 flex items-center gap-1"
            >
              ← Kembali
            </button>

            <div>
              <h1 class="text-xl font-bold text-slate-800">Tambah Info Obat</h1>
              <p class="text-xs text-slate-500">Lengkapi semua informasi obat yang akan ditampilkan kepada pasien.</p>
            </div>
          </div>

          <!-- Step indicator top-right -->
          <div class="flex items-center gap-2 text-[11px]">
            <!-- Step 1 -->
            <div class="flex flex-col items-center">
              <div
                :class="[
                  'w-7 h-7 rounded-full flex items-center justify-center font-bold text-sm',
                  formStep >= 1 ? 'bg-teal-600 text-white' : 'bg-slate-200 text-slate-500'
                ]"
              >
                <span v-if="formStep > 1">✓</span>
                <span v-else>1</span>
              </div>
              <p :class="['mt-1 text-center', formStep === 1 ? 'text-teal-700 font-semibold' : 'text-slate-400']">
                Data Info Obat
              </p>
            </div>

            <!-- Connector line -->
            <div class="w-12 h-px bg-slate-300 mb-3"></div>

            <!-- Step 2 -->
            <div class="flex flex-col items-center">
              <div
                :class="[
                  'w-7 h-7 rounded-full flex items-center justify-center font-bold text-sm',
                  formStep >= 2 ? 'bg-teal-600 text-white' : 'bg-slate-200 text-slate-500'
                ]"
              >
                2
              </div>
              <p :class="['mt-1 text-center', formStep === 2 ? 'text-teal-700 font-semibold' : 'text-slate-400']">
                Konfirmasi
              </p>
            </div>
          </div>
        </div>

        <!-- STEP 1: Form -->
        <div v-if="formStep === 1" class="space-y-4">

          <!-- Identitas Obat -->
          <article class="bg-white border border-slate-200 rounded-xl p-5 shadow-sm">
            <div class="flex items-center gap-3 border-b border-slate-200 pb-3 mb-4">
              <div class="w-9 h-9 rounded-full bg-teal-50 border border-teal-100 flex items-center justify-center text-teal-600 text-base">🕐</div>
              <div>
                <h2 class="text-sm font-semibold text-slate-800">Identitas Obat</h2>
                <p class="text-xs text-slate-400">Nama dan kategori obat</p>
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <label class="block">
                <span class="text-sm text-slate-700">Nama Obat <span class="text-red-500">*</span></span>
                <input
                  v-model="form.nama_obat"
                  type="text"
                  placeholder="cth. Paracetamol, Amoxicillin..."
                  class="mt-1 h-10 w-full rounded-lg border border-slate-200 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
              </label>

              <label class="block">
                <span class="text-sm text-slate-700">Kategori / Indikasi <span class="text-red-500">*</span></span>
                <input
                  v-model="form.kategori_indikasi"
                  type="text"
                  placeholder="cth. Pereda Nyeri & Demam"
                  class="mt-1 h-10 w-full rounded-lg border border-slate-200 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500"
                />
              </label>
            </div>
          </article>

          <!-- Aturan Penggunaan -->
          <article class="bg-white border border-slate-200 rounded-xl p-5 shadow-sm">
            <div class="flex items-center gap-3 border-b border-slate-200 pb-3 mb-4">
              <div class="w-9 h-9 rounded-full bg-blue-50 border border-blue-100 flex items-center justify-center text-blue-600 text-base">📋</div>
              <div>
                <h2 class="text-sm font-semibold text-slate-800">Aturan Penggunaan</h2>
                <p class="text-xs text-slate-400">Frekuensi, durasi, dan waktu minum</p>
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-5 mb-4">
              <div>
                <span class="text-sm text-slate-700">Frekuensi Konsumsi <span class="text-red-500">*</span></span>
                <div class="mt-1 flex items-center gap-2">
                  <input v-model.number="form.frekuensi_min" type="number" min="1" class="h-10 w-16 rounded-lg border border-slate-200 px-2 text-sm text-center" />
                  <span class="text-slate-400">–</span>
                  <input v-model.number="form.frekuensi_max" type="number" min="1" class="h-10 w-16 rounded-lg border border-slate-200 px-2 text-sm text-center" />
                  <span class="text-sm text-slate-500">kali sehari</span>
                </div>
                <p class="text-[11px] text-slate-400 mt-1">Masukkan rentang, misal 3–4 kali sehari</p>
              </div>

              <div>
                <span class="text-sm text-slate-700">Durasi Pemakaian Umum <span class="text-red-500">*</span></span>
                <div class="mt-1 flex items-center gap-2">
                  <input v-model.number="form.durasi_min" type="number" min="1" class="h-10 w-16 rounded-lg border border-slate-200 px-2 text-sm text-center" />
                  <span class="text-slate-400">–</span>
                  <input v-model.number="form.durasi_max" type="number" min="1" class="h-10 w-16 rounded-lg border border-slate-200 px-2 text-sm text-center" />
                  <span class="text-sm text-slate-500">hari</span>
                </div>
                <p class="text-[11px] text-slate-400 mt-1">Durasi pemakaian yang dianjurkan</p>
              </div>
            </div>

            <div>
              <p class="text-sm text-slate-700 mb-2">Waktu Konsumsi <span class="text-red-500">*</span></p>
              <div class="flex flex-wrap gap-2">
                <button
                  v-for="option in waktuOptions"
                  :key="option"
                  @click="toggleWaktu(option)"
                  :class="[
                    'px-4 h-9 rounded-full border text-xs transition',
                    form.waktu_konsumsi.includes(option)
                      ? 'border-teal-600 text-teal-700 bg-teal-50 font-medium'
                      : 'border-slate-200 text-slate-500 bg-white hover:bg-slate-50'
                  ]"
                >
                  {{ option }}
                </button>
              </div>
            </div>
          </article>

          <!-- Informasi Klinis -->
          <article class="bg-white border border-slate-200 rounded-xl p-5 shadow-sm">
            <div class="flex items-center gap-3 border-b border-slate-200 pb-3 mb-4">
              <div class="w-9 h-9 rounded-full bg-amber-50 border border-amber-100 flex items-center justify-center text-amber-600 text-base">⚠️</div>
              <div>
                <h2 class="text-sm font-semibold text-slate-800">Informasi Klinis</h2>
                <p class="text-xs text-slate-400">Fungsi, aturan pakai, dan perhatian</p>
              </div>
            </div>

            <label class="block mb-4">
              <span class="text-sm text-slate-700">Fungsi Obat <span class="text-red-500">*</span></span>
              <textarea
                v-model="form.fungsi"
                rows="3"
                maxlength="300"
                placeholder="Jelaskan fungsi utama obat ini secara singkat dan jelas..."
                class="mt-1 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 resize-none"
              ></textarea>
              <p class="text-[11px] text-right text-slate-400">{{ form.fungsi.length }} / 300</p>
            </label>

            <label class="block mb-4">
              <span class="text-sm text-slate-700">Aturan Pakai <span class="text-red-500">*</span></span>
              <textarea
                v-model="form.aturan_penggunaan"
                rows="3"
                maxlength="400"
                placeholder="Petunjuk lengkap cara mengonsumsi, dosis, dan interval minum..."
                class="mt-1 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 resize-none"
              ></textarea>
              <p class="text-[11px] text-right text-slate-400">{{ form.aturan_penggunaan.length }} / 400</p>
            </label>

            <label class="block">
              <span class="text-sm text-slate-700">Perhatian <span class="text-red-500">*</span></span>
              <textarea
                v-model="form.perhatian"
                rows="3"
                maxlength="400"
                placeholder="Peringatan penting, efek samping, kondisi khusus, penyimpanan..."
                class="mt-1 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 resize-none"
              ></textarea>
              <p class="text-[11px] text-right text-slate-400">{{ form.perhatian.length }} / 400</p>
            </label>
          </article>

          <div class="flex justify-end pb-6">
            <button
              @click="goToConfirmation"
              :disabled="!isFormComplete"
              :class="[
                'h-11 px-6 rounded-lg text-sm font-medium transition',
                isFormComplete ? 'bg-teal-600 text-white hover:bg-teal-700' : 'bg-slate-200 text-slate-400 cursor-not-allowed'
              ]"
            >
              Konfirmasi →
            </button>
          </div>
        </div>

        <!-- STEP 2: Confirmation -->
        <div v-else-if="formStep === 2 && !showSuccess" class="bg-white border border-slate-200 rounded-xl p-6 max-w-2xl mx-auto w-full shadow-sm">
          <div class="text-center mb-6">
            <div class="mx-auto w-14 h-14 rounded-full bg-emerald-50 border border-emerald-200 flex items-center justify-center text-emerald-600 text-2xl">✓</div>
            <h2 class="text-2xl font-bold text-slate-800 mt-4">Konfirmasi Info Obat</h2>
            <p class="text-sm text-slate-500">Periksa kembali data sebelum disimpan.</p>
          </div>

          <div class="border border-slate-200 rounded-lg overflow-hidden text-sm">
            <div class="bg-slate-50 px-4 py-2 text-xs font-semibold text-slate-500 uppercase tracking-wide">Ringkasan Data Obat</div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Nama obat</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.nama_obat }}</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Kategori / indikasi</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.kategori_indikasi }}</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Frekuensi konsumsi</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.frekuensi_min }}–{{ form.frekuensi_max }} kali sehari</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Durasi pemakaian</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.durasi_min }}–{{ form.durasi_max }} hari</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Ketersediaan</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.waktu_konsumsi.join(', ') }}</p>
            </div>
          </div>

          <div class="flex justify-center gap-3 mt-4">
            <button
              @click="formStep = 1"
              class="h-10 px-4 rounded-lg border border-slate-200 text-sm text-slate-600 hover:bg-slate-50"
            >
              ← Kembali Edit
            </button>
            <button
              @click="submitForm"
              :disabled="submitting"
              class="h-10 px-4 rounded-lg bg-teal-600 text-white text-sm font-medium hover:bg-teal-700 disabled:opacity-60"
            >
              {{ submitting ? 'Menyimpan...' : 'Simpan Info Obat' }}
            </button>
          </div>
        </div>

        <!-- SUCCESS -->
        <div v-else class="bg-white border border-slate-200 rounded-xl p-6 max-w-2xl mx-auto w-full text-center shadow-sm">
          <div class="mx-auto w-14 h-14 rounded-full bg-emerald-50 border border-emerald-200 flex items-center justify-center text-emerald-600 text-2xl">✓</div>
          <h2 class="text-2xl font-bold text-slate-800 mt-4">Info obat berhasil ditambahkan</h2>
          <p class="text-sm text-slate-500 mt-2">Data informasi obat telah tersimpan dan dapat diakses oleh tenaga kesehatan terkait.</p>

          <div class="border border-slate-200 rounded-lg overflow-hidden text-sm mt-6 text-left">
            <div class="bg-slate-50 px-4 py-2 text-xs font-semibold text-slate-500 uppercase tracking-wide">Ringkasan Data Obat</div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Nama obat</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.nama_obat }}</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Kategori / indikasi</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.kategori_indikasi }}</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Frekuensi konsumsi</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.frekuensi_min }}–{{ form.frekuensi_max }} kali sehari</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Durasi pemakaian</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.durasi_min }}–{{ form.durasi_max }} hari</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Ketersediaan</p>
              <p class="px-4 py-2 text-right font-medium text-slate-700">{{ form.waktu_konsumsi.join(', ') }}</p>
            </div>
            <div class="grid grid-cols-[1fr,1fr] border-t border-slate-200">
              <p class="px-4 py-2 text-slate-500">Status</p>
              <p class="px-4 py-2 text-right font-medium text-emerald-600">● Tersimpan</p>
            </div>
          </div>

          <div class="flex justify-center gap-3 mt-4">
            <button
              @click="finishToList"
              class="h-10 px-4 rounded-lg border border-slate-200 text-sm text-slate-600 hover:bg-slate-50"
            >
              ← Kembali ke Daftar Obat
            </button>
            <button
              @click="resetAndAddMore"
              class="h-10 px-4 rounded-lg bg-teal-600 text-white text-sm font-medium hover:bg-teal-700"
            >
              + Tambah Info Obat Lain
            </button>
          </div>
        </div>
      </section>
    </div>
  </LayoutWrapper>
</template>

<script>
import { computed, onMounted, ref } from 'vue'
import LayoutWrapper from '../components/LayoutWrapper.vue'
import { useObatStore } from '../stores/obat'

const PER_PAGE = 8

export default {
  name: 'ObatView',
  components: {
    LayoutWrapper
  },
  setup() {
    const obatStore = useObatStore()

    const pageMode = ref('list')
    const formStep = ref(1)
    const showSuccess = ref(false)
    const submitting = ref(false)

    const isEditing = ref(false)
    const editingId = ref(null)

    const searchTerm = ref('')
    const currentPage = ref(1)

    const form = ref(getInitialForm())

    const waktuOptions = ['Sebelum makan', 'Sesudah makan', 'Saat makan', 'Kapan saja']

    const filteredObat = computed(() => {
      const keyword = searchTerm.value.trim().toLowerCase()
      if (!keyword) return obatStore.obatList

      return obatStore.obatList.filter((obat) => {
        return [obat.nama_obat, obat.fungsi, obat.kategori_indikasi]
          .filter(Boolean)
          .some((val) => String(val).toLowerCase().includes(keyword))
      })
    })

    const totalPages = computed(() => {
      const pages = Math.ceil(filteredObat.value.length / PER_PAGE)
      return pages > 0 ? pages : 1
    })

    const pagedObat = computed(() => {
      const start = (currentPage.value - 1) * PER_PAGE
      return filteredObat.value.slice(start, start + PER_PAGE)
    })

    const paginationStart = computed(() => {
      if (filteredObat.value.length === 0) return 0
      return (currentPage.value - 1) * PER_PAGE + 1
    })

    const paginationEnd = computed(() => {
      return Math.min(currentPage.value * PER_PAGE, filteredObat.value.length)
    })

    const stats = computed(() => {
      const list = obatStore.obatList || []
      const categories = new Set(
        list
          .map((item) => item.kategori_indikasi)
          .filter((item) => String(item || '').trim() !== '')
      )

      const now = new Date()
      const addedThisMonth = list.filter((item) => {
        if (!item.created_at) return false
        const date = new Date(item.created_at)
        return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear()
      }).length

      return {
        total: list.length,
        categories: categories.size,
        addedThisMonth
      }
    })

    const isFormComplete = computed(() => {
      return (
        form.value.nama_obat.trim() &&
        form.value.kategori_indikasi.trim() &&
        Number(form.value.frekuensi_min) > 0 &&
        Number(form.value.frekuensi_max) > 0 &&
        Number(form.value.durasi_min) > 0 &&
        Number(form.value.durasi_max) > 0 &&
        form.value.waktu_konsumsi.length > 0 &&
        form.value.fungsi.trim() &&
        form.value.aturan_penggunaan.trim() &&
        form.value.perhatian.trim()
      )
    })

    const goToPage = (page) => {
      if (page < 1 || page > totalPages.value) return
      currentPage.value = page
    }

    const openCreatePage = () => {
      isEditing.value = false
      editingId.value = null
      pageMode.value = 'form'
      formStep.value = 1
      showSuccess.value = false
      form.value = getInitialForm()
    }

    const openEditPage = (obat) => {
      isEditing.value = true
      editingId.value = obat.obat_id
      pageMode.value = 'form'
      formStep.value = 1
      showSuccess.value = false
      form.value = {
        nama_obat: obat.nama_obat || '',
        kategori_indikasi: obat.kategori_indikasi || '',
        frekuensi_min: Number(obat.frekuensi_min || 1),
        frekuensi_max: Number(obat.frekuensi_max || 1),
        durasi_min: Number(obat.durasi_min || 1),
        durasi_max: Number(obat.durasi_max || 1),
        waktu_konsumsi: Array.isArray(obat.waktu_konsumsi) ? [...obat.waktu_konsumsi] : [],
        fungsi: obat.fungsi || '',
        aturan_penggunaan: obat.aturan_penggunaan || '',
        perhatian: obat.perhatian || ''
      }
    }

    const toggleWaktu = (value) => {
      if (form.value.waktu_konsumsi.includes(value)) {
        form.value.waktu_konsumsi = form.value.waktu_konsumsi.filter((item) => item !== value)
      } else {
        form.value.waktu_konsumsi = [...form.value.waktu_konsumsi, value]
      }
    }

    const goToConfirmation = () => {
      if (!isFormComplete.value) {
        alert('Lengkapi semua data wajib terlebih dahulu.')
        return
      }

      if (form.value.frekuensi_min > form.value.frekuensi_max || form.value.durasi_min > form.value.durasi_max) {
        alert('Rentang frekuensi atau durasi tidak valid.')
        return
      }

      formStep.value = 2
    }

    const submitForm = async () => {
      if (submitting.value) return

      submitting.value = true
      try {
        const payload = {
          nama_obat: form.value.nama_obat.trim(),
          kategori_indikasi: form.value.kategori_indikasi.trim(),
          frekuensi_min: Number(form.value.frekuensi_min),
          frekuensi_max: Number(form.value.frekuensi_max),
          durasi_min: Number(form.value.durasi_min),
          durasi_max: Number(form.value.durasi_max),
          waktu_konsumsi: form.value.waktu_konsumsi,
          fungsi: form.value.fungsi.trim(),
          aturan_penggunaan: form.value.aturan_penggunaan.trim(),
          perhatian: form.value.perhatian.trim()
        }

        if (isEditing.value && editingId.value) {
          await obatStore.updateObat(editingId.value, payload)
        } else {
          await obatStore.createObat(payload)
        }

        showSuccess.value = true
      } catch (error) {
        alert('Gagal menyimpan data: ' + error.message)
      } finally {
        submitting.value = false
      }
    }

    const backFromForm = () => {
      if (showSuccess.value) {
        finishToList()
        return
      }

      if (formStep.value === 2) {
        formStep.value = 1
        return
      }

      if (confirm('Batalkan pengisian info obat?')) {
        pageMode.value = 'list'
      }
    }

    const finishToList = () => {
      pageMode.value = 'list'
      showSuccess.value = false
      formStep.value = 1
      isEditing.value = false
      editingId.value = null
      form.value = getInitialForm()
    }

    const resetAndAddMore = () => {
      isEditing.value = false
      editingId.value = null
      showSuccess.value = false
      formStep.value = 1
      form.value = getInitialForm()
    }

    const deleteObat = async (id) => {
      if (!confirm('Yakin ingin menghapus obat ini?')) return

      try {
        await obatStore.deleteObat(id)
      } catch (error) {
        alert('Gagal menghapus obat: ' + error.message)
      }
    }

    const getKategori = (obat) => {
      return obat.kategori_indikasi || 'Belum diisi'
    }

    const getKategoriClass = (obat) => {
      const kategori = String(obat.kategori_indikasi || '').toLowerCase()

      if (kategori.includes('antibiotik')) return 'bg-blue-50 text-blue-700'
      if (kategori.includes('antasida') || kategori.includes('ppi')) return 'bg-rose-50 text-rose-700'
      if (kategori.includes('antihipertensi')) return 'bg-indigo-50 text-indigo-700'
      if (kategori.includes('antihistamin')) return 'bg-lime-50 text-lime-700'
      if (kategori.includes('antidiabetes')) return 'bg-violet-50 text-violet-700'
      if (kategori.includes('vitamin') || kategori.includes('suplemen')) return 'bg-amber-50 text-amber-700'

      return 'bg-emerald-50 text-emerald-700'
    }

    const getFrekuensi = (obat) => {
      if (obat.frekuensi_min && obat.frekuensi_max) {
        return `${obat.frekuensi_min}–${obat.frekuensi_max}x sehari`
      }
      return 'Tidak tersedia'
    }

    const getDurasi = (obat) => {
      if (obat.durasi_min && obat.durasi_max) {
        return `${obat.durasi_min}–${obat.durasi_max} hari`
      }
      return 'Tidak tersedia'
    }

    const getSubLabel = (obat) => {
      return obat.fungsi ? trimLabel(obat.fungsi) : 'Informasi klinis belum tersedia'
    }

    onMounted(() => {
      obatStore.fetchObats()
    })

    return {
      obatStore,
      pageMode,
      formStep,
      form,
      waktuOptions,
      submitting,
      showSuccess,
      searchTerm,
      currentPage,
      stats,
      filteredObat,
      pagedObat,
      totalPages,
      paginationStart,
      paginationEnd,
      isFormComplete,
      goToPage,
      openCreatePage,
      openEditPage,
      toggleWaktu,
      goToConfirmation,
      submitForm,
      backFromForm,
      finishToList,
      resetAndAddMore,
      deleteObat,
      getKategori,
      getKategoriClass,
      getFrekuensi,
      getDurasi,
      getSubLabel
    }
  }
}

function getInitialForm() {
  return {
    nama_obat: '',
    kategori_indikasi: '',
    frekuensi_min: 1,
    frekuensi_max: 1,
    durasi_min: 1,
    durasi_max: 1,
    waktu_konsumsi: [],
    fungsi: '',
    aturan_penggunaan: '',
    perhatian: ''
  }
}

function trimLabel(value) {
  if (!value) return ''
  if (value.length <= 45) return value
  return `${value.slice(0, 45)}...`
}
</script>