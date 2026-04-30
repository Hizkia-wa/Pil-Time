package domain

import "gorm.io/gorm"

// FcmToken menyimpan FCM device token milik pasien.
// Digunakan backend untuk kirim push notification ke device pasien.
type FcmToken struct {
	gorm.Model
	PasienID uint   `gorm:"uniqueIndex;not null" json:"pasien_id"`
	Token    string `gorm:"not null"            json:"token"`
}
