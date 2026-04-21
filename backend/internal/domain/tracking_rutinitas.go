package domain

import "time"

// TrackingRutinitas represents routine activity compliance tracking
type TrackingRutinitas struct {
	TrackingRutunitasID int       `gorm:"primaryKey;column:tracking_rutinitas_id"`
	PasienID            int       `gorm:"column:pasien_id;not null;index"`
	Tanggal             time.Time `gorm:"column:tanggal;not null;index"`
	Status              string    `gorm:"column:status;index"`
	UpdatedAt           time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`

	// Relations
	Pasien *Pasien `gorm:"foreignKey:PasienID"`
}

func (TrackingRutinitas) TableName() string {
	return "tracking_rutinitas"
}
