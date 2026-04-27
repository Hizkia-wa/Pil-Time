package domain

import "time"

type JadwalObat struct {
	JadwalObatID int `gorm:"primaryKey;column:jadwal_obat_id"`

	ResepObatID int
	PasienID    int
	ObatID      int
	NakesID     int
	JamMinum    time.Time
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

func (JadwalObat) TableName() string {
	return "jadwal_obat"
}
