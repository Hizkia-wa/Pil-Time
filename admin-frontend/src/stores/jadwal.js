import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { jadwalApiClient } from '../services/api'
import { usePasienStore } from './pasien'
import { useObatStore } from './obat'

export const useJadwalStore = defineStore('jadwal', () => {
  const pasienStore = usePasienStore()
  const obatStore = useObatStore()

  const jadwalList = ref([])
  const loading = ref(false)
  const error = ref(null)

  const currentStep = ref(0)
  const searchQuery = ref('')
  const searchPasien = ref('')
  const searchObat = ref('')
  const selectedWaktuMinum = ref([])

  const steps = ['Pasien & Obat', 'Aturan Minum', 'Konfirmasi']

  const waktuMinumOptions = [
    { value: 'Pagi', label: 'Pagi', icon: '☀️' },
    { value: 'Siang', label: 'Siang', icon: '🌤️' },
    { value: 'Malam', label: 'Malam', icon: '🌙' }
  ]

  const aturanKonsumsi = ['Sebelum makan', 'Sesudah makan', 'Bersama makan']

  // FORM DEFAULT (RAPI & LENGKAP)
  const defaultForm = () => ({
  patientId: null,
  obatId: null,
  nama_obat: '',
  jumlah_dosis: 1,

  frekuensi_per_hari: 1,
  aturan_konsumsi: 'Sesudah makan',
  catatan: '',

  tanggal_mulai: '',
  tanggal_selesai: '',

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
    const list = jadwalList.value || []
    if (!searchQuery.value) return list

    return list.filter(j =>
      j.pasien_nama?.toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  })

  // =========================
  // HELPERS
  // =========================
  const getSelectedPasien = () =>
    pasienStore.pasienList?.find(p => p.pasien_id === form.value.patientId)

  const getSelectedObat = () =>
    obatStore.obatList?.find(o => o.obat_id === form.value.obatId)

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
    form.value.obatId = o.obat_id
    form.value.nama_obat = o.nama_obat
    searchObat.value = ''
  }

  const formatDate = (date) => {
  return date ? new Date(date).toISOString() : null
}

const submitJadwal = async () => {
  loading.value = true
  try {
    if (!form.value.patientId) throw new Error('Pilih pasien dulu')
    if (!form.value.obatId) throw new Error('Pilih obat dulu')
    if (!form.value.tanggal_mulai) throw new Error('Tanggal mulai wajib')

    // Kumpulkan waktu minum dari selectedWaktuMinum
    const jamMinumList = selectedWaktuMinum.value.map(w => {
      let jam = null

      if (w === 'Pagi') jam = form.value.waktu_reminder_pagi
      if (w === 'Siang') jam = form.value.waktu_reminder_siang
      if (w === 'Malam') jam = form.value.waktu_reminder_malam

      return jam
    }).filter(j => j)

    if (jamMinumList.length === 0) {
      throw new Error('Pilih minimal 1 waktu minum')
    }

    const payload = {
      pasien_id: form.value.patientId,
      obat_id: form.value.obatId,
      nakes_id: 1,

      dosis: String(form.value.jumlah_dosis),

      // 🔥 WAJIB ISO
      tanggal_mulai: formatDate(form.value.tanggal_mulai),
      tanggal_selesai: formatDate(form.value.tanggal_selesai),

      catatan: form.value.catatan || '',

      frekuensi_per_hari: jamMinumList.length,
      aturan_konsumsi: form.value.aturan_konsumsi,

      // POST ke jadwal-service (port 8081)
      jadwal_obats: jamMinumList
    }

    console.log('FINAL FIX PAYLOAD:', payload)

    // POST ke jadwal-service, bukan main backend
    await jadwalApiClient.post('/resep-jadwal', payload)

    // Refresh list setelah berhasil menambah
    await fetchJadwals()

    form.value = defaultForm()
    selectedWaktuMinum.value = []
    currentStep.value = 3

  } catch (err) {
    console.error(err)
    alert('Error: ' + (err.response?.data?.error || err.message))
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

    getSelectedObatAturan: () => getSelectedObat()?.aturan_pemakaian || '',
    getSelectedObatFungsi: () => getSelectedObat()?.fungsi || '',
    getSelectedObatGambar: () => getSelectedObat()?.gambar || '',

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
      currentStep.value = 2
    },

    submitJadwal
  }
})