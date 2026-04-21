package dto

import "time"

// CreateObatDTO - Request untuk membuat obat baru
type CreateObatDTO struct {
	NamaObat         string   `json:"nama_obat" binding:"required"`
	KategoriIndikasi string   `json:"kategori_indikasi" binding:"required"`
	FrekuensiMin     int      `json:"frekuensi_min" binding:"required,min=1"`
	FrekuensiMax     int      `json:"frekuensi_max" binding:"required,min=1"`
	DurasiMin        int      `json:"durasi_min" binding:"required,min=1"`
	DurasiMax        int      `json:"durasi_max" binding:"required,min=1"`
	WaktuKonsumsi    []string `json:"waktu_konsumsi" binding:"required,min=1"`
	Fungsi           string   `json:"fungsi" binding:"required"`
	AturanPenggunaan string   `json:"aturan_penggunaan" binding:"required"`
	Perhatian        string   `json:"perhatian" binding:"required"`
	Gambar           string   `json:"gambar"`
}

// UpdateObatDTO - Request untuk update obat
type UpdateObatDTO struct {
	NamaObat         string   `json:"nama_obat"`
	KategoriIndikasi string   `json:"kategori_indikasi"`
	FrekuensiMin     int      `json:"frekuensi_min"`
	FrekuensiMax     int      `json:"frekuensi_max"`
	DurasiMin        int      `json:"durasi_min"`
	DurasiMax        int      `json:"durasi_max"`
	WaktuKonsumsi    []string `json:"waktu_konsumsi"`
	Fungsi           string   `json:"fungsi"`
	AturanPenggunaan string   `json:"aturan_penggunaan"`
	Perhatian        string   `json:"perhatian"`
	Gambar           string   `json:"gambar"`
}

// ObatResponseDTO - Response format untuk obat
type ObatResponseDTO struct {
	ObatID           int       `json:"obat_id"`
	NamaObat         string    `json:"nama_obat"`
	KategoriIndikasi string    `json:"kategori_indikasi"`
	FrekuensiMin     int       `json:"frekuensi_min"`
	FrekuensiMax     int       `json:"frekuensi_max"`
	DurasiMin        int       `json:"durasi_min"`
	DurasiMax        int       `json:"durasi_max"`
	WaktuKonsumsi    []string  `json:"waktu_konsumsi"`
	Fungsi           string    `json:"fungsi"`
	AturanPenggunaan string    `json:"aturan_penggunaan"`
	Perhatian        string    `json:"perhatian"`
	Gambar           string    `json:"gambar"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}
