package usecase

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"time"
)

type RutinitasUsecase struct {
	repo outbound.RutinitasRepository
}

func NewRutinitasUsecase(repo outbound.RutinitasRepository) *RutinitasUsecase {
	return &RutinitasUsecase{repo: repo}
}

func (u *RutinitasUsecase) GetByID(id int) (*domain.Rutinitas, error) {
	return u.repo.GetByID(id)
}

func (u *RutinitasUsecase) Delete(id int) error {
	return u.repo.Delete(id)
}

func (u *RutinitasUsecase) GetStreak(pasienID int) (int, error) {
	streak := 0
	dateToCheck := time.Now()
	for {
		tgl := dateToCheck.Format("2006-01-02")
		total, _ := u.repo.CountActiveRutinitas(pasienID)
		if total == 0 { break }
		done, _ := u.repo.CountCompletedTracking(pasienID, tgl)
		if done >= total {
			streak++
			dateToCheck = dateToCheck.AddDate(0, 0, -1)
		} else {
			if tgl == time.Now().Format("2006-01-02") {
				dateToCheck = dateToCheck.AddDate(0, 0, -1)
				continue
			}
			break
		}
	}
	return streak, nil
}

func (u *RutinitasUsecase) MarkTracking(req dto.CreateTrackingRutunitasDTO) error {
	return u.repo.UpsertTracking(req)
}

func (u *RutinitasUsecase) Create(req dto.CreateRutunitasDTO) (*domain.Rutinitas, error) {
	return u.repo.Create(&domain.Rutinitas{
		PasienID:      req.PasienID,
		NamaRutinitas: req.NamaRutinitas,
		Deskripsi:     req.Deskripsi,
		WaktuReminder: req.WaktuReminder,
		Status:        "active",
	})
}