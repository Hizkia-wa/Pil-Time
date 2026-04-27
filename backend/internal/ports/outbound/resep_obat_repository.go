package outbound

import "backend/internal/domain"

type ResepObatRepository interface {
    Create(data *domain.ResepObat) error
}