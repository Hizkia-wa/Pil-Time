package usecase

import (
	"backend/internal/domain"
	"backend/internal/ports/outbound"
)

type PasienUsecase struct {
	repo outbound.PasienRepository
}

func NewPasienUsecase(r outbound.PasienRepository) *PasienUsecase {
	return &PasienUsecase{r}
}

func (u *PasienUsecase) Register(p *domain.Pasien) error {
	return u.repo.Create(p)
}