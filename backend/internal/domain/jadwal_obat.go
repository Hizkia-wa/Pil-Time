package domain

import "time"

// JadwalObat represents a medication schedule (time to take medicine)
type JadwalObat struct {
	JadwalObatID   int       `gorm:"primaryKey;column:jadwal_obat_id"`
	ObatID         int       `gorm:"column:obat_id;not null;index"`
	TrackingObatID int       `gorm:"column:tracking_obat_id"`
	NakesID        int       `gorm:"column:nakes_id;not null;index"`
	JamMinum       string    `gorm:"column:jam_minum"` // Time format HH:MM
	CreatedAt      time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`

	// Relations
	Obat  *Obat  `gorm:"foreignKey:ObatID"`
	Nakes *Nakes `gorm:"foreignKey:NakesID"`
}

func (JadwalObat) TableName() string {
	return "jadwal_obat"
}
