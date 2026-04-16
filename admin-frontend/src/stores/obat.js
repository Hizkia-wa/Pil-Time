import { defineStore } from 'pinia'
import { ref } from 'vue'
import apiClient from '../services/api'

export const useObatStore = defineStore('obat', () => {
  const obatList = ref([])
  const loading = ref(false)
  const error = ref(null)

  const fetchObats = async () => {
    loading.value = true
    try {
      const response = await apiClient.get('/admin/info-obat')
      obatList.value = response.data.data || []
      error.value = null
    } catch (err) {
      error.value = err.message
      console.error('Error fetching obats:', err)
    } finally {
      loading.value = false
    }
  }

  const createObat = async (data) => {
    try {
      const response = await apiClient.post('/admin/info-obat', data)
      const newObat = response.data.data || data
      obatList.value.push(newObat)
      return newObat
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const updateObat = async (id, data) => {
    try {
      const response = await apiClient.put(`/admin/info-obat/${id}`, data)
      const updatedObat = response.data.data || data
      const index = obatList.value.findIndex(o => o.obat_id === id)
      if (index !== -1) {
        obatList.value[index] = updatedObat
      }
      return updatedObat
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  const deleteObat = async (id) => {
    try {
      await apiClient.delete(`/admin/info-obat/${id}`)
      obatList.value = obatList.value.filter(o => o.obat_id !== id)
    } catch (err) {
      error.value = err.message
      throw err
    }
  }

  return {
    obatList,
    loading,
    error,
    fetchObats,
    createObat,
    updateObat,
    deleteObat
  }
})
