import { defineStore } from 'pinia'
import { ref } from 'vue'
import apiClient from '../services/api'

export const useJadwalStore = defineStore('jadwal', () => {
  const jadwalList = ref([])
  const loading = ref(false)
  const error = ref(null)

  const fetchJadwals = async () => {
    loading.value = true
    try {
      const response = await apiClient.get('/admin/jadwal')
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
      const response = await apiClient.post('/admin/jadwal', data)
      jadwalList.value.push(response.data.data)
      return response.data.data
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const updateJadwal = async (id, data) => {
    try {
      const response = await apiClient.put(`/admin/jadwal/${id}`, data)
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

  const deleteJadwal = async (id) => {
    try {
      await apiClient.delete(`/admin/jadwal/${id}`)
      jadwalList.value = jadwalList.value.filter(j => j.id !== id)
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  return {
    jadwalList,
    loading,
    error,
    fetchJadwals,
    createJadwal,
    updateJadwal,
    deleteJadwal
  }
})
