package outbound

import (
	"backend/internal/domain"
	"time"
)

type PasienRepository interface {
	GetAll() ([]domain.Pasien, error)
	GetByID(id uint) (*domain.Pasien, error)
	GetByEmail(email string) (*domain.Pasien, error)
	GetByNIK(nik string) (*domain.Pasien, error)
	Create(pasien *domain.Pasien) error
	UpdateResetCode(email string, code string, expiryTime time.Time) error
	UpdatePassword(email string, hashedPassword string) error
	Count() (int64, error)
}
