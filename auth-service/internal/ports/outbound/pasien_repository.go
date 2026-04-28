package outbound

import (
	"auth-service/internal/domain"
	"time"
)

// PasienRepository mendefinisikan kontrak akses data pasien
type PasienRepository interface {
	Create(p *domain.Pasien) error
	GetByEmail(email string) (*domain.Pasien, error)
	GetByNIK(nik string) (*domain.Pasien, error)
	GetByID(id uint) (*domain.Pasien, error)
	UpdateResetCode(email string, code string, expiryTime time.Time) error
	UpdatePassword(email string, hashedPassword string) error
}
