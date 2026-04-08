package outbound

import "backend/internal/domain"

type PasienRepository interface {
	GetAll() ([]domain.Pasien, error)
	GetByID(id uint) (*domain.Pasien, error)
	GetByEmail(email string) (*domain.Pasien, error)
	Create(pasien *domain.Pasien) error
}