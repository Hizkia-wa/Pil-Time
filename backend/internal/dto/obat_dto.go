package dto

import "time"

// CreateObatDTO - Request untuk membuat obat baru
type CreateObatDTO struct {
	NamaObat        string `json:"nama_obat" binding:"required"`
	Fungsi          string `json:"fungsi"`
	AturanPemakaian string `json:"aturan_pemakaian"`
	Pantangan       string `json:"pantangan"`
	Gambar          string `json:"gambar"`
}

// UpdateObatDTO - Request untuk update obat
type UpdateObatDTO struct {
	NamaObat        string `json:"nama_obat"`
	Fungsi          string `json:"fungsi"`
	AturanPemakaian string `json:"aturan_pemakaian"`
	Pantangan       string `json:"pantangan"`
	Gambar          string `json:"gambar"`
}

// ObatResponseDTO - Response format untuk obat
type ObatResponseDTO struct {
	ObatID          int       `json:"obat_id"`
	NamaObat        string    `json:"nama_obat"`
	Fungsi          string    `json:"fungsi"`
	AturanPemakaian string    `json:"aturan_pemakaian"`
	Pantangan       string    `json:"pantangan"`
	Gambar          string    `json:"gambar"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}
