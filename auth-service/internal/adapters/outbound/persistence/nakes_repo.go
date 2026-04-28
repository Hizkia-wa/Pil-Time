package persistence

import (
	"auth-service/internal/domain"
	"auth-service/internal/ports/outbound"

	"gorm.io/gorm"
)

var _ outbound.NakesRepository = (*nakesRepo)(nil)

type nakesRepo struct {
	db *gorm.DB
}

func NewNakesRepo(db *gorm.DB) outbound.NakesRepository {
	return &nakesRepo{db}
}

func (r *nakesRepo) GetByEmail(email string) (*domain.Nakes, error) {
	var nakes domain.Nakes
	err := r.db.Where("email = ?", email).First(&nakes).Error
	if err != nil {
		return nil, err
	}
	return &nakes, nil
}
