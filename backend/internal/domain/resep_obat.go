package domain

import "time"

// ResepObat represents a medication prescription
type ResepObat struct {
	ResepObatID    int       `gorm:"primaryKey;column:resep_obat_id"`
	PasienID       int       `gorm:"column:pasien_id;not null;index"`
	ObatID         int       `gorm:"column:obat_id;not null;index"`
	NakesID        int       `gorm:"column:nakes_id;not null;index"`
	Dosis          string    `gorm:"column:dosis"`
	TanggalMulai   time.Time `gorm:"column:tanggal_mulai"`
	TanggalSelesai time.Time `gorm:"column:tanggal_selesai"`
	Catatan        string    `gorm:"column:catatan;type:text"`
	CreatedAt      time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`

	// Relations
	Pasien *Pasien `gorm:"foreignKey:PasienID"`
	Obat   *Obat   `gorm:"foreignKey:ObatID"`
	Nakes  *Nakes  `gorm:"foreignKey:NakesID"`
}

func (ResepObat) TableName() string {
	return "resep_obat"
}
