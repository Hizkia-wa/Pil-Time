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
      const errMsg = err.response?.data?.error || err.response?.data?.message || err.message
      error.value = errMsg
      console.error('Error fetching obats:', err)
    } finally {
      loading.value = false
    }
  }

  const createObat = async (data) => {
    try {
      const response = await apiClient.post('/admin/info-obat', data, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })
      const newObat = response.data.data
      await fetchObats() 
      return newObat
    } catch (err) {
      const errMsg = err.response?.data?.error || err.response?.data?.message || err.message
      error.value = errMsg
      throw err
    }
  }

  const updateObat = async (id, data) => {
    try {
      const response = await apiClient.put(`/admin/info-obat/${id}`, data, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })
      await fetchObats() 
      return response.data.data
    } catch (err) {
      const errMsg = err.response?.data?.error || err.response?.data?.message || err.message
      error.value = errMsg
      throw err
    }
  }

  const deleteObat = async (id) => {
    try {
      await apiClient.delete(`/admin/info-obat/${id}`)
      obatList.value = obatList.value.filter(o => o.obat_id !== id)
    } catch (err) {
      const errMsg = err.response?.data?.error || err.response?.data?.message || err.message
      error.value = errMsg
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