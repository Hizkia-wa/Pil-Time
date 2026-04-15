import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import apiClient, { jadwalApiClient } from '../services/api'
import { usePasienStore } from './pasien'

export const useJadwalStore = defineStore('jadwal', () => {
  const pasienStore = usePasienStore()
  
  // ── API State ──────────────────────────────────────────────
  const jadwalList = ref([])
  const loading = ref(false)
  const error = ref(null)

  // ── UI State ───────────────────────────────────────────────
  const currentStep = ref(0) // 0 = list, 1 = step1, 2 = step2, 3 = sukses
  const searchQuery = ref('')
  const searchPasien = ref('')
  const selectedWaktuMinum = ref([])

  // ── Constants ──────────────────────────────────────────────
  const steps = ['Pasien & Obat', 'Aturan Minum', 'Konfirmasi']
  const wakteMinum = [
    { value: 'Pagi', label: 'Pagi', icon: '☀️' },
    { value: 'Siang', label: 'Siang', icon: '🌤️' },
    { value: 'Malam', label: 'Malam', icon: '🌙' },
    { value: 'Saat gejala', label: 'Saat gejala', icon: '⏰' },
  ]
  const aturanKonsumsi = ['Sebelum makan', 'Sesudah makan', 'Bersama makan', 'Bebas']

  // ── Form State ────────────────────────────────────────────
  const defaultForm = () => ({
    patientId: null,
    nama_obat: '',
    jumlah_dosis: 1,
    satuan: '',
    kategori_obat: '',
    takaran_obat: '',
    frekuensi_per_hari: '',
    waktu_minum: '',
    aturan_konsumsi: '',
    catatan: '',
    tipe_durasi: 'hari',
    jumlah_hari: 7,
    tanggal_mulai: new Date().toISOString().split('T')[0],
    tanggal_selesai: '',
    waktu_reminder_pagi: '07:00',
    waktu_reminder_malam: '19:00',
    kirim_notifikasi: true,
  })

  const form = ref(defaultForm())

  // ── Computed ───────────────────────────────────────────────
  const filteredPasien = computed(() => {
    const list = pasienStore.pasienList || []
    if (!searchPasien.value) return list
    return list.filter(p =>
      p.nama.toLowerCase().includes(searchPasien.value.toLowerCase())
    )
  })

  const filteredJadwalList = computed(() => {
    const list = jadwalList.value || []
    if (!searchQuery.value) return list
    const q = searchQuery.value.toLowerCase()
    return list.filter(j =>
      j.pasien_nama?.toLowerCase().includes(q) ||
      j.nama_obat?.toLowerCase().includes(q)
    )
  })

  // ── Helpers ────────────────────────────────────────────────
  const getInitials = (nama) => {
    if (!nama) return '?'
    return nama.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
  }

  const getColorClass = (id) => {
    const colors = [
      'bg-teal-500', 'bg-purple-500', 'bg-yellow-500',
      'bg-red-500', 'bg-blue-500', 'bg-orange-500'
    ]
    return colors[(id || 0) % colors.length]
  }

  const formatDate = (dateStr) => {
    if (!dateStr) return '-'
    return new Date(dateStr).toLocaleDateString('id-ID', {
      year: 'numeric', month: 'long', day: 'numeric'
    })
  }

  const getSelectedPasien = () =>
    pasienStore.pasienList?.find(p => p.pasien_id === form.value.patientId)

  const getSelectedPasienName = () => getSelectedPasien()?.nama || ''
  const getSelectedPasienCode = () =>
    getSelectedPasien()?.kode || getSelectedPasien()?.nik || ''
  const getSelectedPasienDiagnosa = () => getSelectedPasien()?.diagnosa || ''

  // ── API Methods ────────────────────────────────────────────
  const fetchJadwals = async () => {
    loading.value = true
    try {
      const response = await jadwalApiClient.get('/jadwal')
      jadwalList.value = response.data.data || []
      error.value = null
    } catch (err) {
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  const createJadwal = async (data) => {
    try {
      const response = await jadwalApiClient.post('/jadwal', data)
      jadwalList.value.push(response.data.data)
      return response.data.data
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const updateJadwal = async (id, data) => {
    try {
      const response = await jadwalApiClient.put(`/jadwal/${id}`, data)
      const index = jadwalList.value.findIndex(j => j.id === id)
      if (index !== -1) {
        jadwalList.value[index] = response.data.data
      }
      return response.data.data
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const deleteJadwalApi = async (id) => {
    try {
      await jadwalApiClient.delete(`/jadwal/${id}`)
      jadwalList.value = jadwalList.value.filter(j => j.id !== id)
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  // ── UI Actions ────────────────────────────────────────────
  const selectPasien = (pasien) => {
    form.value.patientId = pasien.pasien_id
  }

  const toggleWaktuMinum = (val) => {
    const idx = selectedWaktuMinum.value.indexOf(val)
    if (idx > -1) selectedWaktuMinum.value.splice(idx, 1)
    else selectedWaktuMinum.value.push(val)
    
    // Sort waktu in canonical order: Pagi, Siang, Malam
    const order = { 'Pagi': 0, 'Siang': 1, 'Malam': 2, 'Saat gejala': 3 }
    selectedWaktuMinum.value.sort((a, b) => order[a] - order[b])
    
    form.value.waktu_minum = selectedWaktuMinum.value.join(', ')
  }

  const openAddSchedule = () => {
    form.value = defaultForm()
    selectedWaktuMinum.value = []
    searchPasien.value = ''
    currentStep.value = 1
  }

  const cancelAdd = () => {
    currentStep.value = 0
    fetchJadwals()
  }

  const goToStep2 = () => {
    if (!form.value.patientId) {
      alert('Pilih pasien terlebih dahulu')
      return
    }
    if (!form.value.nama_obat) {
      alert('Isi nama obat')
      return
    }
    currentStep.value = 2
  }

  const goToStep3 = async () => {
    try {
      await createJadwal({
        pasien_id: form.value.patientId,
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
        status: 'aktif',
      })
      currentStep.value = 3
    } catch (error) {
      alert('Error: ' + error.message)
    }
  }

  const deleteJadwal = async (id) => {
    if (confirm('Yakin ingin menghapus jadwal ini?')) {
      try {
        await deleteJadwalApi(id)
      } catch (error) {
        alert('Gagal menghapus: ' + error.message)
      }
    }
  }

  return {
    // API state
    jadwalList,
    loading,
    error,
    // UI state
    currentStep,
    steps,
    searchQuery,
    searchPasien,
    selectedWaktuMinum,
    form,
    wakteMinum,
    aturanKonsumsi,
    // Computed
    filteredPasien,
    filteredJadwalList,
    // Helpers
    getInitials,
    getColorClass,
    formatDate,
    getSelectedPasienName,
    getSelectedPasienCode,
    getSelectedPasienDiagnosa,
    // API Methods
    fetchJadwals,
    createJadwal,
    updateJadwal,
    deleteJadwalApi,
    // UI Actions
    selectPasien,
    toggleWaktuMinum,
    openAddSchedule,
    cancelAdd,
    goToStep2,
    goToStep3,
    deleteJadwal,
  }
})
