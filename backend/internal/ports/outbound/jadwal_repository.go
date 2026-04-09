package outbound

import "backend/internal/domain"

type JadwalRepository interface {
	GetAll() ([]domain.Jadwal, error)
	GetByID(id int) (*domain.Jadwal, error)
	GetByPasienID(pasienID int) ([]domain.Jadwal, error)
	Create(j *domain.Jadwal) (*domain.Jadwal, error)
	Update(id int, j *domain.Jadwal) (*domain.Jadwal, error)
	Delete(id int) error
	Count() (int64, error)
}
