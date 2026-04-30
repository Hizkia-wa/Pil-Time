package usecase

import (
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"backend/internal/utils"
	"errors"
	"time"
)

// ==================== TrackingJadwal Usecase ====================

type TrackingJadwalUsecase struct {
	trackingRepo outbound.TrackingJadwalRepository
	jadwalRepo   outbound.JadwalRepository
	pasienRepo   outbound.PasienRepository
}

func NewTrackingJadwalUsecase(
	tr outbound.TrackingJadwalRepository,
	jr outbound.JadwalRepository,
	pr outbound.PasienRepository,
) *TrackingJadwalUsecase {
	return &TrackingJadwalUsecase{
		trackingRepo: tr,
		jadwalRepo:   jr,
		pasienRepo:   pr,
	}
}

func (u *TrackingJadwalUsecase) GetAll() ([]dto.TrackingJadwalDTO, error) {
	trackings, err := u.trackingRepo.GetAll()
	if err != nil {
		return nil, err
	}

	var responses []dto.TrackingJadwalDTO
	for _, tracking := range trackings {
		jadwal, _ := u.jadwalRepo.GetByID(tracking.JadwalID)
		namaObat := ""
		if jadwal != nil {
			namaObat = jadwal.NamaObat
		}

		pasien, _ := u.pasienRepo.GetByID(uint(tracking.PasienID))
		namaPasien := ""
		if pasien != nil {
			namaPasien = pasien.Nama
		}

		dto := persistence.TrackingJadwalToDTO(&tracking, namaObat, namaPasien)
		responses = append(responses, *dto)
	}

	return responses, nil
}

func (u *TrackingJadwalUsecase) GetByID(id int) (*dto.TrackingJadwalDTO, error) {
	tracking, err := u.trackingRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	jadwal, _ := u.jadwalRepo.GetByID(tracking.JadwalID)
	namaObat := ""
	if jadwal != nil {
		namaObat = jadwal.NamaObat
	}

	pasien, _ := u.pasienRepo.GetByID(uint(tracking.PasienID))
	namaPasien := ""
	if pasien != nil {
		namaPasien = pasien.Nama
	}

	return persistence.TrackingJadwalToDTO(tracking, namaObat, namaPasien), nil
}

func (u *TrackingJadwalUsecase) GetByPasienID(pasienID int) ([]dto.TrackingJadwalDTO, error) {
	trackings, err := u.trackingRepo.GetByPasienID(pasienID)
	if err != nil {
		return nil, err
	}

	pasien, _ := u.pasienRepo.GetByID(uint(pasienID))
	namaPasien := ""
	if pasien != nil {
		namaPasien = pasien.Nama
	}

	var responses []dto.TrackingJadwalDTO
	for _, tracking := range trackings {
		jadwal, _ := u.jadwalRepo.GetByID(tracking.JadwalID)
		namaObat := ""
		if jadwal != nil {
			namaObat = jadwal.NamaObat
		}

		dto := persistence.TrackingJadwalToDTO(&tracking, namaObat, namaPasien)
		responses = append(responses, *dto)
	}

	return responses, nil
}

func (u *TrackingJadwalUsecase) Create(req *dto.CreateTrackingJadwalDTO) (*dto.TrackingJadwalDTO, error) {
	if req.JadwalID == 0 || req.PasienID == 0 {
		return nil, errors.New("jadwal_id dan pasien_id harus disediakan")
	}

	tanggal, err := time.Parse("2006-01-02", req.Tanggal)
	if err != nil {
		return nil, errors.New("format tanggal tidak valid, gunakan YYYY-MM-DD")
	}

	// ── AUTO-DETERMINE STATUS via Compliance Checker ──────────────
	// Status ditentukan server berdasarkan waktu konfirmasi vs jadwal.
	// Jika WaktuMinum kosong, gunakan time.Now() sebagai waktu konfirmasi.
	confirmationTime := time.Now()
	if req.WaktuMinum != "" {
		// Gabungkan tanggal + waktu_minum untuk mendapat timestamp lengkap
		parsed, parseErr := time.ParseInLocation(
			"2006-01-02 15:04",
			req.Tanggal+" "+req.WaktuMinum,
			time.Local,
		)
		if parseErr == nil {
			confirmationTime = parsed
		}
	}

	// Ambil jadwal untuk mendapatkan scheduled_time
	schedStatus := req.Status // fallback ke status dari request
	jadwal, jadwalErr := u.jadwalRepo.GetByID(req.JadwalID)
	if jadwalErr == nil && jadwal != nil && jadwal.WaktuMinum != "" {
		wibLoc, locErr := utils.GetWIBLocation()
		if locErr == nil {
			result, checkErr := utils.CheckComplianceFromStrings(
				req.Tanggal,
				jadwal.WaktuMinum,
				confirmationTime,
				wibLoc,
			)
			if checkErr == nil {
				schedStatus = string(result.Status)
			}
		}
	}
	// ─────────────────────────────────────────────────────────────

	tracking := &domain.TrackingJadwal{
		JadwalID:   req.JadwalID,
		PasienID:   req.PasienID,
		Tanggal:    tanggal,
		Status:     schedStatus,
		WaktuMinum: req.WaktuMinum,
		Catatan:    req.Catatan,
		BuktiFoto:  req.BuktiFoto,
	}

	result2, err := u.trackingRepo.Create(tracking)
	if err != nil {
		return nil, err
	}

	namaObat := ""
	if jadwal != nil {
		namaObat = jadwal.NamaObat
	} else {
		jadwal2, _ := u.jadwalRepo.GetByID(result2.JadwalID)
		if jadwal2 != nil {
			namaObat = jadwal2.NamaObat
		}
	}

	pasien, _ := u.pasienRepo.GetByID(uint(result2.PasienID))
	namaPasien := ""
	if pasien != nil {
		namaPasien = pasien.Nama
	}

	return persistence.TrackingJadwalToDTO(result2, namaObat, namaPasien), nil
}

func (u *TrackingJadwalUsecase) Update(id int, req *dto.UpdateTrackingJadwalDTO) (*dto.TrackingJadwalDTO, error) {
	tracking, err := u.trackingRepo.GetByID(id)
	if err != nil {
		return nil, err
	}

	if req.Status != "" {
		tracking.Status = req.Status
	}
	if req.WaktuMinum != "" {
		tracking.WaktuMinum = req.WaktuMinum
	}
	if req.Catatan != "" {
		tracking.Catatan = req.Catatan
	}
	if req.BuktiFoto != "" {
		tracking.BuktiFoto = req.BuktiFoto
	}

	result, err := u.trackingRepo.Update(id, tracking)
	if err != nil {
		return nil, err
	}

	jadwal, _ := u.jadwalRepo.GetByID(result.JadwalID)
	namaObat := ""
	if jadwal != nil {
		namaObat = jadwal.NamaObat
	}

	pasien, _ := u.pasienRepo.GetByID(uint(result.PasienID))
	namaPasien := ""
	if pasien != nil {
		namaPasien = pasien.Nama
	}

	return persistence.TrackingJadwalToDTO(result, namaObat, namaPasien), nil
}

func (u *TrackingJadwalUsecase) Delete(id int) error {
	return u.trackingRepo.Delete(id)
}

// GetStatistics untuk dashboard compliance
func (u *TrackingJadwalUsecase) GetStatistics(pasienID int) (map[string]interface{}, error) {
	var trackings []domain.TrackingJadwal
	var err error

	if pasienID > 0 {
		trackings, err = u.trackingRepo.GetByPasienID(pasienID)
	} else {
		trackings, err = u.trackingRepo.GetAll()
	}

	if err != nil {
		return nil, err
	}

	stats := map[string]interface{}{
		"diminum":         0,
		"terlambat":       0,
		"terlewat":        0,
		"total":           len(trackings),
		"compliance_rate": 0.0,
	}

	diminum := 0
	terlambat := 0
	terlewat := 0

	for _, t := range trackings {
		switch t.Status {
		case "Diminum":
			diminum++
		case "Terlambat":
			terlambat++
		case "Terlewat":
			terlewat++
		}
	}

	stats["diminum"] = diminum
	stats["terlambat"] = terlambat
	stats["terlewat"] = terlewat

	if len(trackings) > 0 {
		complianceRate := float64(diminum) / float64(len(trackings)) * 100
		stats["compliance_rate"] = complianceRate
	}

	return stats, nil
}
