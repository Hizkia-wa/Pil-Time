package domain

import "time"

type Obat struct {
	ObatID          int       `gorm:"primaryKey;column:obat_id"`
	NamaObat        string    `gorm:"column:nama_obat"`
	Fungsi          string    `gorm:"column:fungsi"`
	AturanPemakaian string    `gorm:"column:aturan_pemakaian"` // Pastikan nama ini ada
	Pantangan       string    `gorm:"column:pantangan"`        // Pastikan nama ini ada
	Gambar          string    `gorm:"column:gambar"`
	CreatedAt       time.Time `gorm:"column:created_at"`
	UpdatedAt       time.Time `gorm:"column:updated_at"`
}

// Menentukan nama tabel agar GORM tidak mencari tabel "obats" (plural)
func (Obat) TableName() string {
	return "obat"
}