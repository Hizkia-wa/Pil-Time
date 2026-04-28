package domain

import "time"

// TrackingJadwal - Sesuai PDM untuk tracking compliance jadwal obat
type TrackingJadwal struct {
	TrackingJadwalID int       `gorm:"primaryKey;column:tracking_jadwal_id"`
	JadwalID         int       `gorm:"column:jadwal_id;not null;index"`
	PasienID         int       `gorm:"column:pasien_id;not null;index"`
	Tanggal          time.Time `gorm:"column:tanggal;not null"`
	Status           string    `gorm:"column:status;not null"` // 'Diminum', 'Terlambat', 'Terlewat'
	WaktuMinum       string    `gorm:"column:waktu_minum"`     // HH:MM format
	Catatan          string    `gorm:"column:catatan;type:text"`
	BuktiFoto        string    `gorm:"column:bukti_foto"`
	CreatedAt        time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`
}

func (TrackingJadwal) TableName() string {
	return "tracking_jadwal"
}

// RiwayatObat - Sesuai PDM untuk history obat pasien
type RiwayatObat struct {
	RiwayatObatID int       `gorm:"primaryKey;column:riwayat_obat_id"`
	PasienID      int       `gorm:"column:pasien_id;not null;index"`
	Tanggal       time.Time `gorm:"column:tanggal;not null"`
	Status        string    `gorm:"column:status;not null"`
	Catatan       string    `gorm:"column:catatan;type:text"`
	CreatedAt     time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`
}

func (RiwayatObat) TableName() string {
	return "riwayat_obat"
}
