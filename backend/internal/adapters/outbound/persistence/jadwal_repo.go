package persistence

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"

	"gorm.io/gorm"
)

var _ outbound.JadwalRepository = (*jadwalRepoImpl)(nil)

type jadwalRepoImpl struct {
	db *gorm.DB
}

func NewJadwalRepo(db *gorm.DB) outbound.JadwalRepository {
	return &jadwalRepoImpl{db}
}

func (r *jadwalRepoImpl) GetAll() ([]domain.Jadwal, error) {
	var jadwals []domain.Jadwal
	err := r.db.Find(&jadwals).Error
	return jadwals, err
}

func (r *jadwalRepoImpl) GetByID(id int) (*domain.Jadwal, error) {
	var jadwal domain.Jadwal
	err := r.db.First(&jadwal, id).Error
	return &jadwal, err
}

func (r *jadwalRepoImpl) GetByPasienID(pasienID int) ([]domain.Jadwal, error) {
	var jadwals []domain.Jadwal
	err := r.db.Where("pasien_id = ?", pasienID).Find(&jadwals).Error
	return jadwals, err
}

func (r *jadwalRepoImpl) Create(j *domain.Jadwal) (*domain.Jadwal, error) {
	err := r.db.Create(j).Error
	return j, err
}

func (r *jadwalRepoImpl) Update(id int, j *domain.Jadwal) (*domain.Jadwal, error) {
	err := r.db.Model(&domain.Jadwal{}).Where("jadwal_id = ?", id).Updates(j).Error
	if err != nil {
		return nil, err
	}
	return r.GetByID(id)
}

func (r *jadwalRepoImpl) Delete(id int) error {
	return r.db.Delete(&domain.Jadwal{}, id).Error
}

// Helper to convert domain to DTO
func JadwalToResponseDTO(jadwal *domain.Jadwal, pasienNama string) *dto.JadwalResponseDTO {
	return &dto.JadwalResponseDTO{
		ID:                 jadwal.JadwalID,
		PasienID:           jadwal.PasienID,
		PasienNama:         pasienNama,
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
		CreatedAt:          jadwal.CreatedAt,
		UpdatedAt:          jadwal.UpdatedAt,
	}
}

func (r *jadwalRepoImpl) Count() (int64, error) {
	var count int64
	err := r.db.Model(&domain.Jadwal{}).Count(&count).Error
	return count, err
}
