package usecase

import (
	"errors"
	"jadwal-service/internal/adapters/outbound/persistence"
	"jadwal-service/internal/domain"
	"jadwal-service/internal/dto"
	"time"
)

type JadwalUsecase struct {
	jadwalRepo persistence.JadwalRepository
}

func NewJadwalUsecase(jr persistence.JadwalRepository) *JadwalUsecase {
	return &JadwalUsecase{
		jadwalRepo: jr,
	}
}

func (u *JadwalUsecase) GetAllJadwal() ([]dto.JadwalResponseDTO, error) {
	jadwals, err := u.jadwalRepo.GetAll()
	if err != nil {
		return nil, err
	}

	var responses []dto.JadwalResponseDTO
	for _, jadwal := range jadwals {
		dto := persistence.JadwalToResponseDTO(&jadwal)
		responses = append(responses, *dto)
	}

	return responses, nil
}

func (u *JadwalUsecase) GetJadwalByID(id int) (*dto.JadwalResponseDTO, error) {
	jadwal, err := u.jadwalRepo.GetByID(id)
	if err != nil {
		return nil, err
	}
	return persistence.JadwalToResponseDTO(jadwal), nil
}

func (u *JadwalUsecase) GetJadwalByPasien(pasienID int) ([]dto.JadwalResponseDTO, error) {
	jadwals, err := u.jadwalRepo.GetByPasienID(pasienID)
	if err != nil {
		return nil, err
	}

	var responses []dto.JadwalResponseDTO
	for _, jadwal := range jadwals {
		dto := persistence.JadwalToResponseDTO(&jadwal)
		responses = append(responses, *dto)
	}

	return responses, nil
}

func (u *JadwalUsecase) CreateJadwal(req *dto.CreateJadwalDTO) (*dto.JadwalResponseDTO, error) {
	// Validasi input
	if req.PasienID <= 0 {
		return nil, errors.New("pasien_id harus valid")
	}

	// Hitung tanggal selesai jika tipe_durasi = "hari"
	var tanggalSelesai string
	if req.TipeDurasi == "hari" && req.JumlahHari > 0 {
		mulai, err := time.Parse("2006-01-02", req.TanggalMulai)
		if err == nil {
			selesai := mulai.AddDate(0, 0, req.JumlahHari)
			tanggalSelesai = selesai.Format("2006-01-02")
		}
	}

	jadwal := &domain.Jadwal{
		PasienID:           req.PasienID,
		NamaObat:           req.NamaObat,
		JumlahDosis:        req.JumlahDosis,
		Satuan:             req.Satuan,
		KategoriObat:       req.KategoriObat,
		TakaranObat:        req.TakaranObat,
		FrekuensiPerHari:   req.FrekuensiPerHari,
		WaktuMinum:         req.WaktuMinum,
		AturanKonsumsi:     req.AturanKonsumsi,
		Catatan:            req.Catatan,
		TipeDurasi:         req.TipeDurasi,
		JumlahHari:         req.JumlahHari,
		TanggalMulai:       req.TanggalMulai,
		TanggalSelesai:     tanggalSelesai,
		WaktuReminderPagi:  req.WaktuReminderPagi,
		WaktuReminderMalam: req.WaktuReminderMalam,
		Status:             "aktif",
	}

	if err := u.jadwalRepo.Create(jadwal); err != nil {
		return nil, err
	}

	return persistence.JadwalToResponseDTO(jadwal), nil
}

func (u *JadwalUsecase) UpdateJadwal(id int, req *dto.UpdateJadwalDTO) (*dto.JadwalResponseDTO, error) {
	jadwal, err := u.jadwalRepo.GetByID(id)
	if err != nil {
		return nil, errors.New("jadwal tidak ditemukan")
	}

	// Update fields yang tidak kosong
	if req.NamaObat != "" {
		jadwal.NamaObat = req.NamaObat
	}
	if req.JumlahDosis > 0 {
		jadwal.JumlahDosis = req.JumlahDosis
	}
	if req.Satuan != "" {
		jadwal.Satuan = req.Satuan
	}
	if req.KategoriObat != "" {
		jadwal.KategoriObat = req.KategoriObat
	}
	if req.TakaranObat != "" {
		jadwal.TakaranObat = req.TakaranObat
	}
	if req.FrekuensiPerHari != "" {
		jadwal.FrekuensiPerHari = req.FrekuensiPerHari
	}
	if req.WaktuMinum != "" {
		jadwal.WaktuMinum = req.WaktuMinum
	}
	if req.AturanKonsumsi != "" {
		jadwal.AturanKonsumsi = req.AturanKonsumsi
	}
	if req.Catatan != "" {
		jadwal.Catatan = req.Catatan
	}
	if req.Status != "" {
		jadwal.Status = req.Status
	}

	if err := u.jadwalRepo.Update(id, jadwal); err != nil {
		return nil, err
	}

	return persistence.JadwalToResponseDTO(jadwal), nil
}

func (u *JadwalUsecase) DeleteJadwal(id int) error {
	return u.jadwalRepo.Delete(id)
}
