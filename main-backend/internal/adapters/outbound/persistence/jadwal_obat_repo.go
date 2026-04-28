package persistence

import (
    "backend/internal/domain"

    "gorm.io/gorm"
)

type JadwalObatRepo struct {
    db *gorm.DB
}

func NewJadwalObatRepo(db *gorm.DB) *JadwalObatRepo {
    return &JadwalObatRepo{db: db}
}

func (r *JadwalObatRepo) Create(j *domain.JadwalObat) error {
    return r.db.Create(j).Error
}