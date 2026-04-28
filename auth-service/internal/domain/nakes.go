package domain

import "time"

type Nakes struct {
	NakesID      int       `gorm:"primaryKey;column:nakes_id"`
	Email        string    `gorm:"column:email;uniqueIndex;not null"`
	Password     string    `gorm:"column:password;not null"`
	Nama         string    `gorm:"column:nama;not null"`
	NIK          string    `gorm:"column:nik"`
	JenisKelamin string    `gorm:"column:jenis_kelamin"`
	Alamat       string    `gorm:"column:alamat"`
	CreatedAt    time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt    time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`
}

func (Nakes) TableName() string {
	return "nakes"
}
