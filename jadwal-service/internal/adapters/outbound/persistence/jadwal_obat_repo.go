package persistence

import (
	"jadwal-service/internal/domain"

	"gorm.io/gorm"
)

type JadwalObatRepository interface {
	Create(jadwal *domain.JadwalObat) error
}

type jadwalObatRepo struct {
	db *gorm.DB
}

func NewJadwalObatRepo(db *gorm.DB) JadwalObatRepository {
	return &jadwalObatRepo{db}
}

func (r *jadwalObatRepo) Create(jadwal *domain.JadwalObat) error {
	return r.db.Create(jadwal).Error
}
