package dto

import "time"

// CreateObatDTO - Request untuk membuat obat baru
type CreateObatDTO struct {
	NamaObat         string `json:"nama_obat" binding:"required"`
	Fungsi           string `json:"fungsi" binding:"required"`
	AturanPenggunaan string `json:"aturan_penggunaan" binding:"required"`
	Perhatian        string `json:"perhatian" binding:"required"`
}

// UpdateObatDTO - Request untuk update obat
type UpdateObatDTO struct {
	NamaObat         string `json:"nama_obat"`
	Fungsi           string `json:"fungsi"`
	AturanPenggunaan string `json:"aturan_penggunaan"`
	Perhatian        string `json:"perhatian"`
}

// ObatResponseDTO - Response format untuk obat
type ObatResponseDTO struct {
	ObatID           int       `json:"obat_id"`
	NamaObat         string    `json:"nama_obat"`
	Fungsi           string    `json:"fungsi"`
	AturanPenggunaan string    `json:"aturan_penggunaan"`
	Perhatian        string    `json:"perhatian"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}
