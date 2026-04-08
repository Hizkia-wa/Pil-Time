package persistence

import (
	"backend/internal/domain"
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