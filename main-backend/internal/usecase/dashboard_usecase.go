package usecase

import (
	"backend/internal/dto"
	"backend/internal/ports/outbound"
)

type DashboardUsecase struct {
	pasienRepo outbound.PasienRepository
	jadwalRepo outbound.JadwalRepository
}

func NewDashboardUsecase(
	pasienRepo outbound.PasienRepository,
	jadwalRepo outbound.JadwalRepository,
) *DashboardUsecase {
	return &DashboardUsecase{
		pasienRepo: pasienRepo,
		jadwalRepo: jadwalRepo,
	}
}

// GetDashboard mengambil statistik dashboard
func (u *DashboardUsecase) GetDashboard() (*dto.DashboardResponse, error) {
	totalPasien, err := u.pasienRepo.Count()
	if err != nil {
		return nil, err
	}

	totalJadwal, err := u.jadwalRepo.Count()
	if err != nil {
		return nil, err
	}

	return &dto.DashboardResponse{
		TotalPasien: int(totalPasien),
		TotalJadwal: int(totalJadwal),
	}, nil
}
