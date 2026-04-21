package domain

import "time"

// Obat represents a medication master data in the system
type Obat struct {
	ObatID           int       `gorm:"primaryKey;column:obat_id"`
	NamaObat         string    `gorm:"column:nama_obat;not null"`
	KategoriIndikasi string    `gorm:"column:kategori_indikasi"`
	FrekuensiMin     int       `gorm:"column:frekuensi_min;default:1"`
	FrekuensiMax     int       `gorm:"column:frekuensi_max;default:1"`
	DurasiMin        int       `gorm:"column:durasi_min;default:1"`
	DurasiMax        int       `gorm:"column:durasi_max;default:1"`
	WaktuKonsumsi    string    `gorm:"column:waktu_konsumsi;type:text"` // JSON array
	Fungsi           string    `gorm:"column:fungsi;type:text"`
	AturanPenggunaan string    `gorm:"column:aturan_penggunaan;type:text"`
	Perhatian        string    `gorm:"column:perhatian;type:text"`
	Gambar           string    `gorm:"column:gambar"`
	CreatedAt        time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`
}

// TableName specifies the table name for GORM
func (Obat) TableName() string {
	return "obat"
}
