package persistence

import (
	"jadwal-service/internal/domain"

	"gorm.io/gorm"
)

type ResepObatRepository interface {
	Create(resep *domain.ResepObat) error
}

type resepObatRepo struct {
	db *gorm.DB
}

func NewResepObatRepo(db *gorm.DB) ResepObatRepository {
	return &resepObatRepo{db}
}

func (r *resepObatRepo) Create(resep *domain.ResepObat) error {
	return r.db.Create(resep).Error
}
