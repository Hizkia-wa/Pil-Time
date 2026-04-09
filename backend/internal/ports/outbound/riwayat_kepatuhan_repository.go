package outbound

import "backend/internal/domain"

// TrackingJadwalRepository - Interface untuk tracking jadwal
type TrackingJadwalRepository interface {
	GetAll() ([]domain.TrackingJadwal, error)
	GetByID(id int) (*domain.TrackingJadwal, error)
	GetByPasienID(pasienID int) ([]domain.TrackingJadwal, error)
	GetByJadwalID(jadwalID int) ([]domain.TrackingJadwal, error)
	GetByTanggal(tanggal string) ([]domain.TrackingJadwal, error)
	Create(tracking *domain.TrackingJadwal) (*domain.TrackingJadwal, error)
	Update(id int, tracking *domain.TrackingJadwal) (*domain.TrackingJadwal, error)
	Delete(id int) error
}

// RiwayatObatRepository - Interface untuk riwayat obat
type RiwayatObatRepository interface {
	GetAll() ([]domain.RiwayatObat, error)
	GetByID(id int) (*domain.RiwayatObat, error)
	GetByPasienID(pasienID int) ([]domain.RiwayatObat, error)
	Create(riwayat *domain.RiwayatObat) (*domain.RiwayatObat, error)
	Update(id int, riwayat *domain.RiwayatObat) (*domain.RiwayatObat, error)
	Delete(id int) error
}
