package domain

import "time"

type Pasien struct {
	PasienID        int        `gorm:"primaryKey;column:pasien_id"`
	Nama            string     `gorm:"column:nama;not null"`
	Email           string     `gorm:"column:email;uniqueIndex"`
	Password        string     `gorm:"column:password;not null"`
	NIK             string     `gorm:"column:nik;uniqueIndex"`
	TanggalLahir    time.Time  `gorm:"column:tanggal_lahir"`
	TempatLahir     string     `gorm:"column:tempat_lahir"`
	Alamat          string     `gorm:"column:alamat;type:text"`
	JenisKelamin    string     `gorm:"column:jenis_kelamin"`
	NoTelepon       string     `gorm:"column:no_telepon"`
	ResetCode       *string    `gorm:"column:reset_code"`
	ResetCodeExpiry *time.Time `gorm:"column:reset_code_expiry"`
	CreatedAt       time.Time  `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt       time.Time  `gorm:"autoUpdateTime:milli;column:updated_at"`
}

func (Pasien) TableName() string {
	return "pasien"
}
