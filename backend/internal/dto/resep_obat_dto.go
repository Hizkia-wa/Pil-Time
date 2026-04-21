package dto

import "time"

// CreateResepObatDTO - Request untuk membuat resep obat baru
type CreateResepObatDTO struct {
	PasienID       int    `json:"pasien_id" binding:"required"`
	ObatID         int    `json:"obat_id" binding:"required"`
	NakesID        int    `json:"nakes_id" binding:"required"`
	Dosis          string `json:"dosis"`
	TanggalMulai   string `json:"tanggal_mulai"`
	TanggalSelesai string `json:"tanggal_selesai"`
	Catatan        string `json:"catatan"`
}

// UpdateResepObatDTO - Request untuk update resep obat
type UpdateResepObatDTO struct {
	Dosis          string `json:"dosis"`
	TanggalMulai   string `json:"tanggal_mulai"`
	TanggalSelesai string `json:"tanggal_selesai"`
	Catatan        string `json:"catatan"`
}

// ResepObatResponseDTO - Response format untuk resep obat
type ResepObatResponseDTO struct {
	ResepObatID    int       `json:"resep_obat_id"`
	PasienID       int       `json:"pasien_id"`
	ObatID         int       `json:"obat_id"`
	NakesID        int       `json:"nakes_id"`
	Dosis          string    `json:"dosis"`
	TanggalMulai   time.Time `json:"tanggal_mulai"`
	TanggalSelesai time.Time `json:"tanggal_selesai"`
	Catatan        string    `json:"catatan"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}
