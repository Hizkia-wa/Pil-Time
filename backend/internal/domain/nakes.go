package domain

import "time"

type Nakes struct {
	NakesID      int       `gorm:"primaryKey;column:nakes_id"`
	Nama         string    `gorm:"column:nama;not null"`
	Email        string    `gorm:"column:email;uniqueIndex"`
	Password     string    `gorm:"column:password;not null"`
	NIK          string    `gorm:"column:nik;uniqueIndex"`
	JenisKelamin string    `gorm:"column:jenis_kelamin"`
	Alamat       string    `gorm:"column:alamat;type:text"`
	CreatedAt    time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt    time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`
}

func (Nakes) TableName() string {
	return "nakes"
}
