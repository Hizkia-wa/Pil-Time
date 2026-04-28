package dto

import "time"

type CreateObatDTO struct {
	NamaObat        string `json:"nama_obat" form:"nama_obat" binding:"required"`
	Fungsi          string `json:"fungsi" form:"fungsi"`
	AturanPemakaian string `json:"aturan_pemakaian" form:"aturan_pemakaian"`
	Pantangan       string `json:"pantangan" form:"pantangan"`
	Gambar          string `json:"gambar" form:"gambar"`
}

type UpdateObatDTO struct {
	NamaObat        string `json:"nama_obat" form:"nama_obat"`
	Fungsi          string `json:"fungsi" form:"fungsi"`
	AturanPemakaian string `json:"aturan_pemakaian" form:"aturan_pemakaian"`
	Pantangan       string `json:"pantangan" form:"pantangan"`
	Gambar          string `json:"gambar" form:"gambar"`
}

type CreateObatMandiriDTO struct {
	NamaObat   string   `json:"nama_obat" form:"nama_obat" binding:"required"`
	Dosis      string   `json:"dosis" form:"dosis" binding:"required"`
	Gambar     string   `json:"gambar" form:"gambar"`
	Pengingat  []string `json:"pengingat" form:"pengingat" binding:"required"` // Array: pagi, siang, sore, malam
	Frekuensi  string   `json:"frekuensi" form:"frekuensi" binding:"required"` // 1x sehari, 2x sehari
	DurasiHari int      `json:"durasi_hari" form:"durasi_hari" binding:"required"`
	Catatan    string   `json:"catatan" form:"catatan"`
	PasienID   int      `json:"pasien_id" form:"pasien_id" binding:"required"`
}

type ObatResponseDTO struct {
	ObatID          int       `json:"obat_id"`
	NamaObat        string    `json:"nama_obat"`
	Fungsi          string    `json:"fungsi"`
	AturanPemakaian string    `json:"aturan_pemakaian"`
	Pantangan       string    `json:"pantangan"`
	Gambar          string    `json:"gambar"`
	PasienID        *int      `json:"pasien_id"`
	Pengingat       []string  `json:"pengingat"` // Array of selected times
	Frekuensi       string    `json:"frekuensi"`
	DurasiHari      *int      `json:"durasi_hari"`
	Catatan         string    `json:"catatan"`
	IsMandiri       bool      `json:"is_mandiri"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}