package domain

import "time"

// Rutinitas represents patient's routine activities
type Rutinitas struct {
	RutunitasID    int       `gorm:"primaryKey;column:rutinitas_id"`
	PasienID       int       `gorm:"column:pasien_id;not null;index"`
	NamaRutinitas  string    `gorm:"column:nama_rutinitas;not null"`
	Deskripsi      string    `gorm:"column:deskripsi;type:text"`
	WaktuReminder  string    `gorm:"column:waktu_reminder"` // Time format HH:MM
	TanggalMulai   time.Time `gorm:"column:tanggal_mulai"`
	TanggalSelesai time.Time `gorm:"column:tanggal_selesai"`
	Status         string    `gorm:"column:status"`
	CreatedAt      time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`

	// Relations
	Pasien *Pasien `gorm:"foreignKey:PasienID"`
}

func (Rutinitas) TableName() string {
	return "rutinitas"
}
