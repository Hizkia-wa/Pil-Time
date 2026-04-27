package domain

import "time"

type ResepObat struct {
	ResepObatID int `gorm:"primaryKey;column:resep_obat_id"`

	PasienID       int
	ObatID         int
	NakesID        int
	Dosis          string
	TanggalMulai   time.Time
	TanggalSelesai time.Time
	Catatan        string
	CreatedAt      time.Time
	UpdatedAt      time.Time

	JadwalObats      []JadwalObat `gorm:"foreignKey:ResepObatID"`
	FrekuensiPerHari int
	AturanKonsumsi   string
}

func (ResepObat) TableName() string {
	return "resep_obat"
}
