package persistence

import (
	"backend/internal/domain"

	"gorm.io/gorm"
)

type nakesRepo struct {
	db *gorm.DB
}

func NewNakesRepo(db *gorm.DB) *nakesRepo {
	return &nakesRepo{db}
}

func (r *nakesRepo) GetByEmail(email string) (*domain.Nakes, error) {
	var nakes domain.Nakes
	err := r.db.Where("email = ?", email).First(&nakes).Error
	return &nakes, err
}

func (r *nakesRepo) GetByID(id int) (*domain.Nakes, error) {
	var nakes domain.Nakes
	err := r.db.First(&nakes, id).Error
	return &nakes, err
}
