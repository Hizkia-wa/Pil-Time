package domain

import "time"

// TrackingObat represents medication compliance tracking
type TrackingObat struct {
	TrackingObatID int       `gorm:"primaryKey;column:tracking_obat_id"`
	PasienID       int       `gorm:"column:pasien_id;not null;index"`
	NakesID        int       `gorm:"column:nakes_id;not null;index"`
	Tanggal        time.Time `gorm:"column:tanggal;not null;index"`
	Status         string    `gorm:"column:status;index"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`

	// Relations
	Pasien *Pasien `gorm:"foreignKey:PasienID"`
	Nakes  *Nakes  `gorm:"foreignKey:NakesID"`
}

func (TrackingObat) TableName() string {
	return "tracking_obat"
}
