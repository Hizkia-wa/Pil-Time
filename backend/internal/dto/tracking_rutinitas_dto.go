package dto

import "time"

// CreateTrackingRutunitasDTO - Request untuk membuat tracking rutinitas baru
type CreateTrackingRutunitasDTO struct {
	PasienID int    `json:"pasien_id" binding:"required"`
	Tanggal  string `json:"tanggal" binding:"required"`
	Status   string `json:"status"`
}

// UpdateTrackingRutunitasDTO - Request untuk update tracking rutinitas
type UpdateTrackingRutunitasDTO struct {
	Status string `json:"status"`
}

// TrackingRutunitasResponseDTO - Response format untuk tracking rutinitas
type TrackingRutunitasResponseDTO struct {
	TrackingRutunitasID int       `json:"tracking_rutinitas_id"`
	PasienID            int       `json:"pasien_id"`
	Tanggal             time.Time `json:"tanggal"`
	Status              string    `json:"status"`
	UpdatedAt           time.Time `json:"updated_at"`
}
