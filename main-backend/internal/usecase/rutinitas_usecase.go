package usecase

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"errors"
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

// GetAllByPasien mengambil semua rutinitas yang dibuat oleh pasien sendiri beserta status hari ini
func (u *RutinitasUsecase) GetAllByPasien(pasienID int) ([]map[string]interface{}, error) {
	list, err := u.repo.GetByPasienID(pasienID)
	if err != nil {
		return nil, err
	}

	todayStatus, err := u.repo.GetTodayTracking(pasienID)
	if err != nil {
		todayStatus = make(map[int]string)
	}

	result := []map[string]interface{}{}
	for _, r := range list {
		status := "none"
		if s, ok := todayStatus[r.ID]; ok {
			status = s
		}

		item := map[string]interface{}{
			"id":             r.ID,
			"pasien_id":      r.PasienID,
			"nama_rutinitas": r.NamaRutinitas,
			"deskripsi":      r.Deskripsi,
			"waktu_reminder": r.WaktuReminder,
			"status":         r.Status,
			"today_status":   status,
		}
		result = append(result, item)
	}
	return result, nil
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

func (u *RutinitasUsecase) Update(id int, req dto.UpdateRutinitasDTO) (*domain.Rutinitas, error) {
	existing, err := u.repo.GetByID(id)
	if err != nil || existing == nil {
		return nil, errors.New("rutinitas tidak ditemukan")
	}

	if req.NamaRutinitas != "" {
		existing.NamaRutinitas = req.NamaRutinitas
	}
	if req.Deskripsi != "" {
		existing.Deskripsi = req.Deskripsi
	}
	if req.WaktuReminder != "" {
		existing.WaktuReminder = req.WaktuReminder
	}

	return u.repo.Update(id, existing)
}