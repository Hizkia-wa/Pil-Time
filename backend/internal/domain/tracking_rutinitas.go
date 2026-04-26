package domain

import "time"

type TrackingRutinitas struct {
	ID          int       `gorm:"primaryKey" json:"id"`
	RutinitasID int       `gorm:"column:rutinitas_id" json:"rutinitas_id"`
	Status      string    `json:"status"`
	Tanggal     string    `json:"tanggal"` // Pakai string agar tidak error format time
	CreatedAt   time.Time `json:"created_at"`
}