package dto

import "time"

// TrackingJadwalDTO - Response format untuk tracking jadwal
type TrackingJadwalDTO struct {
	ID         int       `json:"id"`
	JadwalID   int       `json:"jadwal_id"`
	PasienID   int       `json:"pasien_id"`
	NamaPasien string    `json:"nama_pasien"`
	NamaObat   string    `json:"nama_obat"`
	Tanggal    string    `json:"tanggal"`     // Format YYYY-MM-DD
	Jadwal     string    `json:"jadwal"`      // Waktu jadwal dalam format HH:MM
	WaktuMinum string    `json:"waktu_minum"` // Waktu pasien minum dalam format HH:MM
	Status     string    `json:"status"`      // 'Diminum', 'Terlambat', 'Terlewat'
	Catatan    string    `json:"catatan"`
	BuktiFoto  string    `json:"bukti_foto"`
	CreatedAt  time.Time `json:"created_at"`
}

// CreateTrackingJadwalDTO - Request untuk membuat tracking jadwal
type CreateTrackingJadwalDTO struct {
	JadwalID   int    `json:"jadwal_id" binding:"required"`
	PasienID   int    `json:"pasien_id" binding:"required"`
	Tanggal    string `json:"tanggal" binding:"required"` // YYYY-MM-DD format
	Status     string `json:"status" binding:"required"`
	WaktuMinum string `json:"waktu_minum"`
	Catatan    string `json:"catatan"`
	BuktiFoto  string `json:"bukti_foto"`
}

// UpdateTrackingJadwalDTO - Request untuk update tracking jadwal
type UpdateTrackingJadwalDTO struct {
	Status     string `json:"status"`
	WaktuMinum string `json:"waktu_minum"`
	Catatan    string `json:"catatan"`
	BuktiFoto  string `json:"bukti_foto"`
}

// RiwayatObatDTO - Response format untuk riwayat obat
type RiwayatObatDTO struct {
	ID         int       `json:"id"`
	PasienID   int       `json:"pasien_id"`
	NamaPasien string    `json:"nama_pasien"`
	Tanggal    string    `json:"tanggal"`
	Status     string    `json:"status"`
	Catatan    string    `json:"catatan"`
	CreatedAt  time.Time `json:"created_at"`
}

// CreateRiwayatObatDTO - Request untuk membuat riwayat obat
type CreateRiwayatObatDTO struct {
	PasienID int    `json:"pasien_id" binding:"required"`
	Tanggal  string `json:"tanggal" binding:"required"`
	Status   string `json:"status" binding:"required"`
	Catatan  string `json:"catatan"`
}
