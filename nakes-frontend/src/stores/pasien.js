import { defineStore } from 'pinia'
import { ref } from 'vue'
import apiClient from '../services/api'

export const usePasienStore = defineStore('pasien', () => {
  const pasienList = ref([])
  const loading = ref(false)
  const error = ref(null)

  const fetchPasiens = async () => {
    loading.value = true
    try {
      const response = await apiClient.get('/admin/pasien')
      pasienList.value = response.data.data || []
      error.value = null
    } catch (err) {
      const errMsg = err.response?.data?.error || err.response?.data?.message || err.message
      error.value = errMsg
    } finally {
      loading.value = false
    }
  }

  return {
    pasienList,
    loading,
    error,
    fetchPasiens
  }
})
