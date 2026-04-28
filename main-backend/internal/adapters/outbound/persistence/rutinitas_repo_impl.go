package persistence

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"gorm.io/gorm"
	"time"
)

type rutinitasRepoImpl struct {
	db *gorm.DB
}

func NewRutinitasRepo(db *gorm.DB) outbound.RutinitasRepository {
	return &rutinitasRepoImpl{db}
}

func (r *rutinitasRepoImpl) Create(rutinitas *domain.Rutinitas) (*domain.Rutinitas, error) {
	err := r.db.Create(rutinitas).Error
	return rutinitas, err
}

func (r *rutinitasRepoImpl) GetByPasienID(pasienID int) ([]domain.Rutinitas, error) {
	var rutinitas []domain.Rutinitas
	err := r.db.Where("pasien_id = ?", pasienID).Find(&rutinitas).Error
	return rutinitas, err
}

func (r *rutinitasRepoImpl) GetByID(id int) (*domain.Rutinitas, error) {
	var rutinitas domain.Rutinitas
	err := r.db.First(&rutinitas, id).Error
	return &rutinitas, err
}

func (r *rutinitasRepoImpl) Delete(id int) error {
	return r.db.Delete(&domain.Rutinitas{}, id).Error
}

func (r *rutinitasRepoImpl) CountActiveRutinitas(pasienID int) (int, error) {
	var count int64
	err := r.db.Model(&domain.Rutinitas{}).Where("pasien_id = ? AND status = ?", pasienID, "active").Count(&count).Error
	return int(count), err
}

func (r *rutinitasRepoImpl) CountCompletedTracking(pasienID int, tanggal string) (int, error) {
	var count int64
	err := r.db.Model(&domain.TrackingRutinitas{}).
		Joins("JOIN rutinitas ON rutinitas.id = tracking_rutinitas.rutinitas_id").
		Where("rutinitas.pasien_id = ? AND tracking_rutinitas.status = ? AND tracking_rutinitas.tanggal = ?", pasienID, "done", tanggal).
		Count(&count).Error
	return int(count), err
}

// PERBAIKAN UTAMA: Fungsi UpsertTracking agar Checkbox berfungsi
func (r *rutinitasRepoImpl) UpsertTracking(req dto.CreateTrackingRutunitasDTO) error {
	today := time.Now().Format("2006-01-02")
	var tracking domain.TrackingRutinitas

	// 1. Cari dulu apakah sudah ada tracking untuk rutinitas ini di TANGGAL HARI INI
	err := r.db.Where("rutinitas_id = ? AND tanggal = ?", req.RutinitasID, today).First(&tracking).Error

	if err == gorm.ErrRecordNotFound {
		// 2. Jika tidak ada, buat data baru
		return r.db.Create(&domain.TrackingRutinitas{
			RutinitasID: req.RutinitasID,
			Status:      req.Status, // Akan berisi 'done' atau 'none' dari Flutter
			Tanggal:     today,      // Simpan sebagai string format YYYY-MM-DD sesuai domain
		}).Error
	}

	// 3. Jika sudah ada, update statusnya saja (untuk toggle check/uncheck)
	return r.db.Model(&tracking).Update("status", req.Status).Error
}