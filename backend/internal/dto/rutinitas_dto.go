package dto

import "time"

// --- DTO UNTUK RUTINITAS (MANDIRI) ---

// CreateRutunitasDTO digunakan saat pertama kali membuat jadwal rutinitas
type CreateRutunitasDTO struct {
	PasienID      int    `json:"pasien_id" binding:"required"`
	NamaRutinitas string `json:"nama_rutinitas" binding:"required"`
	Deskripsi     string `json:"deskripsi"`
	WaktuReminder string `json:"waktu_reminder" binding:"required"` // Format: "HH:mm"
}

// CreateTrackingRutunitasDTO digunakan untuk mencatat status harian (ceklis)
type CreateTrackingRutunitasDTO struct {
	RutinitasID int    `json:"rutinitas_id" binding:"required"`
	PasienID    int    `json:"pasien_id"` // Opsional, untuk tambahan validasi
	Tanggal     string `json:"tanggal"`   // Format: "YYYY-MM-DD"
	Status      string `json:"status" binding:"required"`    // "completed", "skipped", "missed"
}

// TrackingRutunitasResponseDTO untuk mengirim data tracking ke Frontend/Flutter
type TrackingRutunitasResponseDTO struct {
	TrackingID  int       `json:"tracking_id"`
	RutinitasID int       `json:"rutinitas_id"`
	Tanggal     string    `json:"tanggal"`
	Status      string    `json:"status"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// --- DTO UNTUK OBAT (JIKA DIPERLUKAN) ---

type TrackingObatResponseDTO struct {
	TrackingObatID int       `json:"tracking_obat_id"`
	PasienID       int       `json:"pasien_id"`
	NakesID        int       `json:"nakes_id"`
	Tanggal        time.Time `json:"tanggal"`
	Status         string    `json:"status"`
	UpdatedAt      time.Time `json:"updated_at"`
}