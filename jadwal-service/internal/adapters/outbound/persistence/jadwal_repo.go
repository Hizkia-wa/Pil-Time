package persistence

import (
	"jadwal-service/internal/domain"
	"jadwal-service/internal/dto"

	"gorm.io/gorm"
)

type JadwalRepository interface {
	GetAll() ([]domain.Jadwal, error)
	GetByID(id int) (*domain.Jadwal, error)
	GetByPasienID(pasienID int) ([]domain.Jadwal, error)
	Create(jadwal *domain.Jadwal) error
	Update(id int, jadwal *domain.Jadwal) error
	Delete(id int) error
}

type jadwalRepo struct {
	db *gorm.DB
}

func NewJadwalRepo(db *gorm.DB) JadwalRepository {
	return &jadwalRepo{db}
}

func (r *jadwalRepo) GetAll() ([]domain.Jadwal, error) {
	var jadwals []domain.Jadwal
	err := r.db.Find(&jadwals).Error
	return jadwals, err
}

func (r *jadwalRepo) GetByID(id int) (*domain.Jadwal, error) {
	var jadwal domain.Jadwal
	err := r.db.First(&jadwal, id).Error
	if err != nil {
		return nil, err
	}
	return &jadwal, nil
}

func (r *jadwalRepo) GetByPasienID(pasienID int) ([]domain.Jadwal, error) {
	var jadwals []domain.Jadwal
	err := r.db.Where("pasien_id = ?", pasienID).Find(&jadwals).Error
	return jadwals, err
}

func (r *jadwalRepo) Create(jadwal *domain.Jadwal) error {
	return r.db.Create(jadwal).Error
}

func (r *jadwalRepo) Update(id int, jadwal *domain.Jadwal) error {
	return r.db.Where("jadwal_id = ?", id).Updates(jadwal).Error
}

func (r *jadwalRepo) Delete(id int) error {
	return r.db.Delete(&domain.Jadwal{}, id).Error
}

// Helper untuk convert domain ke DTO
func JadwalToResponseDTO(jadwal *domain.Jadwal) *dto.JadwalResponseDTO {
	return &dto.JadwalResponseDTO{
		ID:                 jadwal.JadwalID,
		PasienID:           jadwal.PasienID,
		NamaObat:           jadwal.NamaObat,
		JumlahDosis:        jadwal.JumlahDosis,
		Satuan:             jadwal.Satuan,
		KategoriObat:       jadwal.KategoriObat,
		TakaranObat:        jadwal.TakaranObat,
		FrekuensiPerHari:   jadwal.FrekuensiPerHari,
		WaktuMinum:         jadwal.WaktuMinum,
		AturanKonsumsi:     jadwal.AturanKonsumsi,
		Catatan:            jadwal.Catatan,
		TipeDurasi:         jadwal.TipeDurasi,
		JumlahHari:         jadwal.JumlahHari,
		TanggalMulai:       jadwal.TanggalMulai,
		TanggalSelesai:     jadwal.TanggalSelesai,
		WaktuReminderPagi:  jadwal.WaktuReminderPagi,
		WaktuReminderMalam: jadwal.WaktuReminderMalam,
		Status:             jadwal.Status,
	}
}
