package outbound

import "backend/internal/domain"

type JadwalObatRepository interface {
    Create(data *domain.JadwalObat) error
}