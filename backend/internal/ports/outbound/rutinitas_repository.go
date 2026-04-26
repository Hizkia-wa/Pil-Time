package outbound

import (
	"backend/internal/domain"
	"backend/internal/dto"
)

type RutinitasRepository interface {
	Create(rutinitas *domain.Rutinitas) (*domain.Rutinitas, error)
	GetByPasienID(pasienID int) ([]domain.Rutinitas, error)
	GetByID(id int) (*domain.Rutinitas, error)
	Delete(id int) error
	CountActiveRutinitas(pasienID int) (int, error)
	CountCompletedTracking(pasienID int, tanggal string) (int, error)
	UpsertTracking(req dto.CreateTrackingRutunitasDTO) error
}