package persistence

import (
	"backend/internal/domain"
	"time"

	"gorm.io/gorm"
)

type pasienRepo struct {
	db *gorm.DB
}

func NewPasienRepo(db *gorm.DB) *pasienRepo {
	return &pasienRepo{db}
}

func (r *pasienRepo) GetAll() ([]domain.Pasien, error) {
	var data []domain.Pasien
	err := r.db.Find(&data).Error
	return data, err
}

func (r *pasienRepo) Create(p *domain.Pasien) error {
	return r.db.Create(p).Error
}

func (r *pasienRepo) GetByEmail(email string) (*domain.Pasien, error) {
	var pasien domain.Pasien
	err := r.db.Where("email = ?", email).First(&pasien).Error
	return &pasien, err
}

func (r *pasienRepo) GetByID(id uint) (*domain.Pasien, error) {
	var pasien domain.Pasien
	err := r.db.First(&pasien, id).Error
	return &pasien, err
}

func (r *pasienRepo) GetByNIK(nik string) (*domain.Pasien, error) {
	var pasien domain.Pasien
	err := r.db.Where("nik = ?", nik).First(&pasien).Error
	return &pasien, err
}

func (r *pasienRepo) UpdateResetCode(email string, code string, expiryTime time.Time) error {
	return r.db.Model(&domain.Pasien{}).
		Where("email = ?", email).
		Updates(map[string]interface{}{
			"reset_code":        code,
			"reset_code_expiry": expiryTime,
		}).Error
}

func (r *pasienRepo) UpdatePassword(email string, hashedPassword string) error {
	return r.db.Model(&domain.Pasien{}).
		Where("email = ?", email).
		Updates(map[string]interface{}{
			"password":          hashedPassword,
			"reset_code":        nil,
			"reset_code_expiry": nil,
		}).Error
}
