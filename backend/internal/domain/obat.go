package domain

import "time"

// Obat represents a medication master data in the system
type Obat struct {
	ObatID          int       `gorm:"primaryKey;column:obat_id"`
	NamaObat        string    `gorm:"column:nama_obat;not null"`
	Fungsi          string    `gorm:"column:fungsi;type:text"`
	AturanPemakaian string    `gorm:"column:aturan_pemakaian;type:text"`
	Pantangan       string    `gorm:"column:pantangan;type:text"`
	Gambar          string    `gorm:"column:gambar"`
	CreatedAt       time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt       time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`
}

// TableName specifies the table name for GORM
func (Obat) TableName() string {
	return "obat"
}
