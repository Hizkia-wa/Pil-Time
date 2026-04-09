import axios from 'axios'
import { useAuthStore } from '../stores/auth'

const apiClient = axios.create({
  baseURL: 'http://localhost:8080/api',
  headers: {
    'Content-Type': 'application/json'
  }
})

apiClient.interceptors.request.use(
  config => {
    const authStore = useAuthStore()
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    return config
  },
  error => Promise.reject(error)
)

apiClient.interceptors.response.use(
  response => response,
  error => {
    // Jangan redirect ke login jika sudah di halaman login
    if (error.response?.status === 401) {
      const currentPath = window.location.pathname
      if (currentPath !== '/login') {
        const authStore = useAuthStore()
        authStore.logout()
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

export default apiClient
