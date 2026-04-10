package domain

import "time"

type Nakes struct {
	NakesID   int       `gorm:"primaryKey;column:nakes_id"`
	Email     string    `gorm:"column:email;uniqueIndex;not null"`
	Password  string    `gorm:"column:password;not null"`
	Nama      string    `gorm:"column:nama;not null"`
	JenisIlmu string    `gorm:"column:jenis_ilmu"`
	Pin       string    `gorm:"column:pin"`
	Gambar    string    `gorm:"column:gambar"`
	Status    string    `gorm:"column:status;default:'active'"`
	CreatedAt time.Time `gorm:"autoCreateTime:milli;column:created_at"`
	UpdatedAt time.Time `gorm:"autoUpdateTime:milli;column:updated_at"`
}

func (Nakes) TableName() string {
	return "nakes"
}
