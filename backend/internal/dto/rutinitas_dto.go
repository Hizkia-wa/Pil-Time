package dto

import "time"

// CreateRutunitasDTO - Request untuk membuat rutinitas baru
type CreateRutunitasDTO struct {
	PasienID       int    `json:"pasien_id" binding:"required"`
	NamaRutinitas  string `json:"nama_rutinitas" binding:"required"`
	Deskripsi      string `json:"deskripsi"`
	WaktuReminder  string `json:"waktu_reminder"`
	TanggalMulai   string `json:"tanggal_mulai"`
	TanggalSelesai string `json:"tanggal_selesai"`
	Status         string `json:"status"`
}

// UpdateRutunitasDTO - Request untuk update rutinitas
type UpdateRutunitasDTO struct {
	NamaRutinitas  string `json:"nama_rutinitas"`
	Deskripsi      string `json:"deskripsi"`
	WaktuReminder  string `json:"waktu_reminder"`
	TanggalMulai   string `json:"tanggal_mulai"`
	TanggalSelesai string `json:"tanggal_selesai"`
	Status         string `json:"status"`
}

// RutunitasResponseDTO - Response format untuk rutinitas
type RutunitasResponseDTO struct {
	RutunitasID    int       `json:"rutinitas_id"`
	PasienID       int       `json:"pasien_id"`
	NamaRutinitas  string    `json:"nama_rutinitas"`
	Deskripsi      string    `json:"deskripsi"`
	WaktuReminder  string    `json:"waktu_reminder"`
	TanggalMulai   time.Time `json:"tanggal_mulai"`
	TanggalSelesai time.Time `json:"tanggal_selesai"`
	Status         string    `json:"status"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}
