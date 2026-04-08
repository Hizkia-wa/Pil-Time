package domain

import "time"

type Pasien struct {
	PasienID        int        `gorm:"primaryKey;column:pasien_id"`
	Email           string     `gorm:"column:email;uniqueIndex;not null"`
	Password        string     `gorm:"column:password;not null"`
	NamaLengkap     string     `gorm:"column:nama_lengkap;not null"`
	NIK             string     `gorm:"column:nik;uniqueIndex;not null"`
	TanggalLahir    time.Time  `gorm:"column:tanggal_lahir;not null"`
	Telepon         string     `gorm:"column:telepon;not null"`
	JenisKelamin    string     `gorm:"column:jenis_kelamin;not null"`
	Alamat          string     `gorm:"column:alamat;not null"`
	Status          string     `gorm:"column:status;default:'active'"`
	ResetCode       string     `gorm:"column:reset_code;default:null"`
	ResetCodeExpiry *time.Time `gorm:"column:reset_code_expiry;type:timestamp;default:null"`
	CreatedAt       time.Time  `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt       time.Time  `gorm:"autoUpdateTime:milli;column:updated_at"`
}

func (Pasien) TableName() string {
	return "pasien"
}
