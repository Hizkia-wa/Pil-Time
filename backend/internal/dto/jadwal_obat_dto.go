package dto

import "time"

// CreateJadwalObatDTO - Request untuk membuat jadwal obat baru
type CreateJadwalObatDTO struct {
	ObatID         int    `json:"obat_id" binding:"required"`
	TrackingObatID int    `json:"tracking_obat_id"`
	NakesID        int    `json:"nakes_id" binding:"required"`
	JamMinum       string `json:"jam_minum"`
}

// UpdateJadwalObatDTO - Request untuk update jadwal obat
type UpdateJadwalObatDTO struct {
	JamMinum string `json:"jam_minum"`
}

// JadwalObatResponseDTO - Response format untuk jadwal obat
type JadwalObatResponseDTO struct {
	JadwalObatID   int       `json:"jadwal_obat_id"`
	ObatID         int       `json:"obat_id"`
	TrackingObatID int       `json:"tracking_obat_id"`
	NakesID        int       `json:"nakes_id"`
	JamMinum       string    `json:"jam_minum"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}
