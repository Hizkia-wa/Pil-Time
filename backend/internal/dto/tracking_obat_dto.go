package dto

import "time"

// CreateTrackingObatDTO - Request untuk membuat tracking obat baru
type CreateTrackingObatDTO struct {
	PasienID int    `json:"pasien_id" binding:"required"`
	NakesID  int    `json:"nakes_id" binding:"required"`
	Tanggal  string `json:"tanggal" binding:"required"`
	Status   string `json:"status"`
}

// UpdateTrackingObatDTO - Request untuk update tracking obat
type UpdateTrackingObatDTO struct {
	Status string `json:"status"`
}

// TrackingObatResponseDTO - Response format untuk tracking obat
type TrackingObatResponseDTO struct {
	TrackingObatID int       `json:"tracking_obat_id"`
	PasienID       int       `json:"pasien_id"`
	NakesID        int       `json:"nakes_id"`
	Tanggal        time.Time `json:"tanggal"`
	Status         string    `json:"status"`
	UpdatedAt      time.Time `json:"updated_at"`
}
