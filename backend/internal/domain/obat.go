package domain

import (
	"encoding/json"
	"time"
)

type Obat struct {
	ObatID          int       `gorm:"primaryKey;column:obat_id"`
	NamaObat        string    `gorm:"column:nama_obat"`
	Fungsi          string    `gorm:"column:fungsi"`
	AturanPemakaian string    `gorm:"column:aturan_pemakaian"`
	Pantangan       string    `gorm:"column:pantangan"`
	Gambar          string    `gorm:"column:gambar"`
	PasienID        *int      `gorm:"column:pasien_id"` // FK to Pasien, managed by SQL migration
	Pengingat       string    `gorm:"column:pengingat;type:text"` // JSON array: ["pagi", "siang", "sore"]
	Frekuensi       string    `gorm:"column:frekuensi"` // 1x sehari, 2x sehari, dll
	DurasiHari      *int      `gorm:"column:durasi_hari"`
	Catatan         string    `gorm:"column:catatan;type:text"`
	IsMandiri       bool      `gorm:"column:is_mandiri;default:false"`
	CreatedAt       time.Time `gorm:"column:created_at"`
	UpdatedAt       time.Time `gorm:"column:updated_at"`
}

// Menentukan nama tabel agar GORM tidak mencari tabel "obats" (plural)
func (Obat) TableName() string {
	return "obat"
}

// GetPengingat returns pengingat as slice of strings
func (o *Obat) GetPengingat() []string {
	var result []string
	err := json.Unmarshal([]byte(o.Pengingat), &result)
	if err != nil {
		return []string{}
	}
	return result
}

// SetPengingat sets pengingat from slice of strings
func (o *Obat) SetPengingat(times []string) error {
	data, err := json.Marshal(times)
	if err != nil {
		return err
	}
	o.Pengingat = string(data)
	return nil
}