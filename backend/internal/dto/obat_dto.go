package dto

import "time"

type CreateObatDTO struct {
	NamaObat        string   `json:"nama_obat" form:"nama_obat" binding:"required"`
	Fungsi          string   `json:"fungsi" form:"fungsi"`
	AturanPemakaian string   `json:"aturan_pemakaian" form:"aturan_pemakaian"`
	Pantangan       string   `json:"pantangan" form:"pantangan"`
	Gambar          string   `json:"gambar" form:"gambar"`
}

type UpdateObatDTO struct {
	NamaObat        string   `json:"nama_obat" form:"nama_obat"`
	Fungsi          string   `json:"fungsi" form:"fungsi"`
	AturanPemakaian string   `json:"aturan_pemakaian" form:"aturan_pemakaian"`
	Pantangan       string   `json:"pantangan" form:"pantangan"`
	Gambar          string   `json:"gambar" form:"gambar"`
}

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