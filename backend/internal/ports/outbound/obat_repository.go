package outbound

import "backend/internal/domain"

// ObatRepository defines the interface for obat data access
type ObatRepository interface {
	GetAll() ([]domain.Obat, error)
	GetByID(id int) (*domain.Obat, error)
	GetByName(name string) (*domain.Obat, error)
	Create(o *domain.Obat) (*domain.Obat, error)
	Update(id int, o *domain.Obat) (*domain.Obat, error)
	Delete(id int) error
	Count() (int64, error)
}
