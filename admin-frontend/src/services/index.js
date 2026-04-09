import apiClient from './api'

export const authService = {
  loginAdmin(email, password) {
    return apiClient.post('/admin/login', {
      email,
      password
    })
  }
}

export const pasienService = {
  getAllPasien() {
    return apiClient.get('/admin/pasien')
  },

  deletePasien(id) {
    return apiClient.delete(`/admin/pasien/${id}`)
  }
}

export const jadwalService = {
  getAllJadwal() {
    return apiClient.get('/admin/jadwal')
  },

  createJadwal(data) {
    return apiClient.post('/admin/jadwal', data)
  },

  updateJadwal(id, data) {
    return apiClient.put(`/admin/jadwal/${id}`, data)
  },

  deleteJadwal(id) {
    return apiClient.delete(`/admin/jadwal/${id}`)
  }
}

export const obatService = {
  getAllObat() {
    return apiClient.get('/info-obat')
  },

  createObat(data) {
    return apiClient.post('/info-obat', data)
  },

  updateObat(id, data) {
    return apiClient.put(`/info-obat/${id}`, data)
  },

  deleteObat(id) {
    return apiClient.delete(`/info-obat/${id}`)
  }
}

export const dashboardService = {
  getDashboard() {
    return apiClient.get('/admin/dashboard')
  }
}

export const riwayatService = {
  getAllRiwayat() {
    return apiClient.get('/admin/riwayat')
  }
}
