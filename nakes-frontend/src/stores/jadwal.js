import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { jadwalApiClient } from '../services/api'
import { usePasienStore } from './pasien'
import { useObatStore } from './obat'
import { useAuthStore } from './auth'
import { useNotificationStore } from './notification'

export const useJadwalStore = defineStore('jadwal', () => {
  const pasienStore = usePasienStore()
  const obatStore = useObatStore()
  const authStore = useAuthStore()

  const jadwalList = ref([])
  const loading = ref(false)
  const error = ref(null)

  const currentStep = ref(0)
  const searchQuery = ref('')
  const filterKategori = ref('Semua')
  const searchPasien = ref('')
  const searchObat = ref('')
  const selectedWaktuMinum = ref([])

  const steps = ['Pasien & Obat', 'Aturan Minum', 'Selesai']

  const waktuMinumOptions = [
    { value: 'Pagi', label: 'Pagi', icon: '☀️' },
    { value: 'Siang', label: 'Siang', icon: '🌤️' },
    { value: 'Malam', label: 'Malam', icon: '🌙' }
  ]

  const aturanKonsumsi = ['Sebelum makan', 'Sesudah makan', 'Bersama makan']

  // FORM DEFAULT (RAPI & LENGKAP)
  const defaultForm = () => ({
  patientId: null,
  obatList: [],

  frekuensi_per_hari: 1,
  aturan_konsumsi: 'Sesudah makan',
  catatan: '',

  tanggal_mulai: '',
  tanggal_selesai: '',

  tipe_durasi: 'hari',
  jumlah_hari: 1,

  waktu_reminder_pagi: '07:00',
  waktu_reminder_siang: '13:00',
  waktu_reminder_malam: '19:00'
})

  const form = ref(defaultForm())

  // =========================
  // COMPUTED
  // =========================
  const filteredPasien = computed(() => {
    const list = pasienStore.pasienList || []
    if (!searchPasien.value.trim()) return list

    return list.filter(p =>
      p.nama.toLowerCase().includes(searchPasien.value.toLowerCase()) ||
      p.nik?.includes(searchPasien.value)
    )
  })

  const filteredObat = computed(() => {
    const list = obatStore.obatList || []
    if (!searchObat.value.trim()) return list

    return list.filter(o =>
      o.nama_obat.toLowerCase().includes(searchObat.value.toLowerCase())
    )
  })

  const filteredJadwalList = computed(() => {
    const now = new Date()
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const list = (jadwalList.value || []).filter(j => {
      // Jadwal 'rutin' tidak pernah expired — selalu tampil
      if (j.tipe_durasi === 'rutin') return true

      if (j.tipe_durasi === 'hari' && j.tanggal_selesai) {
        const selesai = new Date(j.tanggal_selesai)
        selesai.setHours(0, 0, 0, 0)

        // Tanggal selesai sudah lampau (sebelum hari ini) → sembunyikan
        if (selesai < today) return false

        // Tanggal selesai = hari ini → cek apakah waktu minum terakhir sudah >75 menit
        if (selesai.getTime() === today.getTime() && j.waktu_minum) {
          const waktuList = j.waktu_minum.split(',').map(w => w.trim()).filter(Boolean)
          // Ambil waktu terlambat hari ini (sort descending, ambil yang terakhir)
          const lastWaktu = [...waktuList].sort().pop()
          if (lastWaktu) {
            const parts = lastWaktu.split(':')
            if (parts.length === 2) {
              const jadwalDt = new Date()
              jadwalDt.setHours(parseInt(parts[0]), parseInt(parts[1]), 0, 0)
              const diffMinutes = (now - jadwalDt) / 60000
              // Sembunyikan jika sudah >75 menit (konsisten dengan threshold backend & mobile)
              if (diffMinutes > 75) return false
            }
          }
        }
      }

      return true
    })

    // Apply search and category filter
    return list.filter(j => {
      // 1. Search Query Match
      let matchesSearch = true
      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        const matchPasien = j.pasien_nama?.toLowerCase().includes(query)
        const matchObat = j.nama_obat?.toLowerCase().includes(query)
        matchesSearch = matchPasien || matchObat
      }

      // 2. Category Match
      let matchesCategory = true
      if (filterKategori.value === 'Mandiri') {
        matchesCategory = j.kategori_obat === 'Mandiri'
      } else if (filterKategori.value === 'Resep Nakes') {
        matchesCategory = j.kategori_obat !== 'Mandiri'
      }

      return matchesSearch && matchesCategory
    })
  })

  // =========================
  // HELPERS
  // =========================
  const getSelectedPasien = () =>
    pasienStore.pasienList?.find(p => p.pasien_id === form.value.patientId)

  // =========================
  // ACTIONS
  // =========================
  const toggleWaktuMinum = (value) => {
    const index = selectedWaktuMinum.value.indexOf(value)

    if (index > -1) {
      selectedWaktuMinum.value.splice(index, 1)
    } else {
      selectedWaktuMinum.value.push(value)
    }

    // auto sync
    form.value.frekuensi_per_hari = selectedWaktuMinum.value.length
  }

  const selectPasien = (p) => {
    form.value.patientId = p.pasien_id
    searchPasien.value = ''
  }

  const selectObat = (o) => {
    const exists = form.value.obatList.find(item => item.obat_id === o.obat_id)
    if (exists) {
      form.value.obatList = form.value.obatList.filter(item => item.obat_id !== o.obat_id)
    } else {
      form.value.obatList.push({
        obat_id: o.obat_id,
        nama_obat: o.nama_obat,
        dosis: '1',
        aturan: o.aturan_pemakaian,
        fungsi: o.fungsi,
        pantangan: o.pantangan,
        gambar: o.gambar
      })
    }
    searchObat.value = ''
  }

  const updateObatDosis = (obatId, newDosis) => {
    const index = form.value.obatList.findIndex(o => o.obat_id === obatId)
    if (index > -1) {
      form.value.obatList[index].dosis = newDosis
    }
  }

  const formatDate = (date) => {
  return date ? new Date(date).toISOString() : null
}

const submitJadwal = async () => {
  loading.value = true
  try {
    if (!form.value.patientId) throw new Error('Pilih pasien terlebih dahulu')
    if (form.value.obatList.length === 0) throw new Error('Pilih minimal satu obat terlebih dahulu')
    if (!form.value.tanggal_mulai) throw new Error('Tanggal mulai wajib diisi')
    
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const startDate = new Date(form.value.tanggal_mulai)
    if (startDate < today) {
      throw new Error('Tanggal mulai tidak boleh di masa lampau (sebelum hari ini)')
    }

    // Kumpulkan waktu minum dari selectedWaktuMinum
    const jamMinumList = selectedWaktuMinum.value.map(w => {
      let jam = null

      if (w === 'Pagi') jam = form.value.waktu_reminder_pagi
      if (w === 'Siang') jam = form.value.waktu_reminder_siang
      if (w === 'Malam') jam = form.value.waktu_reminder_malam

      return jam
    }).filter(j => j)

    if (jamMinumList.length === 0) {
      throw new Error('Pilih minimal 1 waktu minum (Pagi/Siang/Malam)')
    }

    const payload = {
      pasien_id: form.value.patientId,
      obat_list: form.value.obatList.map(o => ({
        obat_id: o.obat_id,
        dosis: String(o.dosis)
      })),
      nakes_id: authStore.user?.nakes_id || authStore.user?.id || 1,

      // Format tanggal: YYYY-MM-DD (bukan ISO)
      tanggal_mulai: form.value.tanggal_mulai || '',
      tanggal_selesai: form.value.tanggal_selesai || '',

      catatan: form.value.catatan || '',

      frekuensi_per_hari: jamMinumList.length,
      aturan_konsumsi: form.value.aturan_konsumsi,
      
      tipe_durasi: form.value.tipe_durasi || 'hari',
      jumlah_hari: form.value.jumlah_hari || 1,

      // Backend menggunakan 'jam_minum' bukan 'jadwal_obats'
      jam_minum: jamMinumList
    }

    console.log('Payload resep-jadwal:', payload)

    // POST ke backend (port 8080) — jadwal sudah di-merge
    await jadwalApiClient.post('/resep-jadwal', payload)

    // Refresh list setelah berhasil menambah
    await fetchJadwals()

    form.value = defaultForm()
    selectedWaktuMinum.value = []
    currentStep.value = 3

  } catch (err) {
    console.error(err)
    const notificationStore = useNotificationStore()
    const errMsg = err.response?.data?.error || err.response?.data?.message || err.message
    notificationStore.error(errMsg, 'Gagal Menyimpan')
  } finally {
    loading.value = false
  }
}

  const fetchJadwals = async () => {
    loading.value = true
    try {
      const res = await jadwalApiClient.get('/jadwal')
      jadwalList.value = res.data.data || []
    } catch (err) {
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  const deleteJadwal = async (id) => {
    try {
      await jadwalApiClient.delete(`/jadwal/${id}`)
      await fetchJadwals()
    } catch (err) {
      console.error(err)
      throw err
    }
  }

  const updateJadwal = async (id, data) => {
  try {
    await jadwalApiClient.put(`/jadwal/${id}`, data)
    await fetchJadwals()
  } catch (err) {
    console.error(err)
    throw err
  }
}

  // =========================
  // RETURN
  // =========================
  return {
    jadwalList,
    loading,
    error,
    currentStep,
    steps,
    searchQuery,
    filterKategori,
    searchPasien,
    searchObat,
    selectedWaktuMinum,
    form,
    waktuMinumOptions,
    aturanKonsumsi,

    filteredPasien,
    filteredObat,
    filteredJadwalList,

    getSelectedPasienName: () => getSelectedPasien()?.nama || '',
    getSelectedPasienNIK: () => getSelectedPasien()?.nik || '-',
    getSelectedPasienJK: () => getSelectedPasien()?.jenis_kelamin || '-',
    getSelectedPasienAlamat: () => getSelectedPasien()?.alamat || '-',
    getSelectedPasienTelepon: () => getSelectedPasien()?.no_telepon || '-',

    fetchJadwals,
    selectPasien,
    selectObat,
    toggleWaktuMinum,

    openAddSchedule: () => {
      form.value = defaultForm()
      selectedWaktuMinum.value = []
      currentStep.value = 1
    },

    cancelAdd: () => {
      currentStep.value = 0
      fetchJadwals()
    },

    goToStep2: () => {
      const notificationStore = useNotificationStore()
      if (!form.value.patientId) {
        notificationStore.warning('Silakan pilih pasien terlebih dahulu', 'Perhatian')
        return
      }
      if (form.value.obatList.length === 0) {
        notificationStore.warning('Silakan pilih minimal satu obat terlebih dahulu', 'Perhatian')
        return
      }
      currentStep.value = 2
    },

    updateObatDosis,
    submitJadwal,
    deleteJadwal,
    updateJadwal
  }
})