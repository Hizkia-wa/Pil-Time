package outbound

import "auth-service/internal/domain"

// NakesRepository mendefinisikan kontrak akses data nakes
type NakesRepository interface {
	GetByEmail(email string) (*domain.Nakes, error)
}
