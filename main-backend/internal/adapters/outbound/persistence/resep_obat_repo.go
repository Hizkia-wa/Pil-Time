package persistence

import (
    "backend/internal/domain"
    "backend/internal/ports/outbound"

    "gorm.io/gorm"
)

type resepObatRepo struct {
    db *gorm.DB
}

func NewResepObatRepo(db *gorm.DB) outbound.ResepObatRepository {
    return &resepObatRepo{db}
}

func (r *resepObatRepo) Create(data *domain.ResepObat) error {
    return r.db.Create(data).Error
}