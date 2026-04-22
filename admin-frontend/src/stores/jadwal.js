import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { jadwalApiClient } from '../services/api'
import { usePasienStore } from './pasien'
import { useObatStore } from './obat'

export const useJadwalStore = defineStore('jadwal', () => {
  const pasienStore = usePasienStore()
  const obatStore = useObatStore()
  
  // ── API State ──────────────────────────────────────────────
  const jadwalList = ref([])
  const loading = ref(false)
  const error = ref(null)

  // ── UI State ───────────────────────────────────────────────
  const currentStep = ref(0)
  const searchQuery = ref('')
  const searchPasien = ref('')
  const searchObat = ref('')
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
    obatId: null,
    nama_obat: '',
    jumlah_dosis: 1,
    satuan: 'tablet',
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

  // ── Computed (DIUBAH AGAR MUNCUL SEMUA DI AWAL) ─────────────
  const filteredPasien = computed(() => {
    const list = pasienStore.pasienList || []
    // Jika kolom cari kosong, tampilkan semua list pasien
    if (!searchPasien.value.trim()) return list
    return list.filter(p =>
      p.nama.toLowerCase().includes(searchPasien.value.toLowerCase()) ||
      p.nik?.includes(searchPasien.value)
    )
  })

  const filteredObat = computed(() => {
    const list = obatStore.obatList || []
    // Jika kolom cari kosong, tampilkan semua list obat
    if (!searchObat.value.trim()) return list 
    return list.filter(o =>
      o.nama_obat.toLowerCase().includes(searchObat.value.toLowerCase())
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

  // ── Helpers Pasien ─────────────────────────────────────────
  const getSelectedPasien = () =>
    pasienStore.pasienList?.find(p => p.pasien_id === form.value.patientId)

  const getSelectedPasienName = () => getSelectedPasien()?.nama || ''
  const getSelectedPasienNIK = () => getSelectedPasien()?.nik || '-'
  const getSelectedPasienJK = () => getSelectedPasien()?.jenis_kelamin || '-'
  const getSelectedPasienAlamat = () => getSelectedPasien()?.alamat || '-'
  const getSelectedPasienTelepon = () => getSelectedPasien()?.no_telepon || '-'
  const getSelectedPasienCode = () => getSelectedPasien()?.nik || '-' 

  const getSelectedPasienTTL = () => {
    const p = getSelectedPasien()
    return p ? `${p.tempat_lahir}, ${p.tanggal_lahir}` : '-'
  }

  // ── Helpers Obat ───────────────────────────────────────────
  const getSelectedObat = () =>
    obatStore.obatList?.find(o => o.obat_id === form.value.obatId)

  const getSelectedObatAturan = () => getSelectedObat()?.aturan_pemakaian || ''
  const getSelectedObatFungsi = () => getSelectedObat()?.fungsi || ''
  const getSelectedObatPantangan = () => getSelectedObat()?.pantangan || ''
  const getSelectedObatGambar = () => getSelectedObat()?.gambar || ''

  // ── Actions ────────────────────────────────────────────────
  const selectPasien = (pasien) => {
    form.value.patientId = pasien.pasien_id
    searchPasien.value = ''
  }

  const selectObat = (obat) => {
    form.value.obatId = obat.obat_id
    form.value.nama_obat = obat.nama_obat
    searchObat.value = ''
  }

  const toggleWaktuMinum = (value) => {
    const index = selectedWaktuMinum.value.indexOf(value)
    if (index > -1) {
      selectedWaktuMinum.value.splice(index, 1)
    } else {
      selectedWaktuMinum.value.push(value)
    }
    form.value.waktu_minum = selectedWaktuMinum.value.join(', ')
  }

  const openAddSchedule = () => {
    form.value = defaultForm()
    selectedWaktuMinum.value = []
    searchPasien.value = ''
    searchObat.value = ''
    currentStep.value = 1
  }

  const cancelAdd = () => {
    currentStep.value = 0
    fetchJadwals()
  }

  const goToStep2 = () => {
    if (!form.value.patientId) return alert('Pilih pasien terlebih dahulu')
    if (!form.value.obatId) return alert('Pilih obat terlebih dahulu')
    currentStep.value = 2
  }

  const goToStep3 = () => {
    if (!form.value.waktu_minum) return alert('Pilih minimal satu waktu minum')
    currentStep.value = 3
  }

  const fetchJadwals = async () => {
    loading.value = true
    try {
      const response = await jadwalApiClient.get('/jadwal')
      jadwalList.value = response.data.data || []
    } catch (err) { 
      error.value = err.message 
    } finally { 
      loading.value = false 
    }
  }

  return {
    jadwalList, loading, error,
    currentStep, steps, searchQuery, searchPasien, searchObat,
    selectedWaktuMinum, form, wakteMinum, aturanKonsumsi,
    filteredPasien, filteredObat, filteredJadwalList,
    getSelectedPasienName, getSelectedPasienNIK, getSelectedPasienJK, 
    getSelectedPasienAlamat, getSelectedPasienTelepon, getSelectedPasienTTL,
    getSelectedPasienCode,
    getSelectedObatAturan, getSelectedObatFungsi, 
    getSelectedObatPantangan, getSelectedObatGambar,
    fetchJadwals, selectPasien, selectObat, toggleWaktuMinum,
    openAddSchedule, cancelAdd, goToStep2, goToStep3
  }
})