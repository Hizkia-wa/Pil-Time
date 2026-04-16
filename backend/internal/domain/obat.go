package domain

import "time"

// Obat represents a medication in the system
type Obat struct {
	ObatID           int       `json:"obat_id" gorm:"primaryKey"`
	NamaObat         string    `json:"nama_obat" gorm:"index"`
	Fungsi           string    `json:"fungsi" gorm:"type:text"`
	AturanPenggunaan string    `json:"aturan_penggunaan" gorm:"type:text"`
	Perhatian        string    `json:"perhatian" gorm:"type:text"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

// TableName specifies the table name for GORM
func (Obat) TableName() string {
	return "obat"
}
