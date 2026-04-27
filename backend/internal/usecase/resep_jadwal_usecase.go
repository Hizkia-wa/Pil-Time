package usecase

import (
    "backend/internal/domain"
    "backend/internal/dto"
    "backend/internal/ports/outbound"
    "time"
)

type ResepJadwalUsecase struct {
    resepRepo  outbound.ResepObatRepository
    jadwalRepo outbound.JadwalObatRepository
}

func NewResepJadwalUsecase(r outbound.ResepObatRepository, j outbound.JadwalObatRepository) *ResepJadwalUsecase {
    return &ResepJadwalUsecase{
        resepRepo:  r,
        jadwalRepo: j,
    }
}

func generateJamMinum(frekuensi int) []string {
	switch frekuensi {
	case 1:
		return []string{"08:00"}
	case 2:
		return []string{"08:00", "20:00"}
	case 3:
		return []string{"08:00", "14:00", "20:00"}
	default:
		return []string{"08:00"}
	}
}

func (u *ResepJadwalUsecase) Create(req *dto.CreateResepWithJadwalDTO) error {

    // ✅ PARSE TANGGAL
    tanggalMulai, err := time.Parse(time.RFC3339, req.TanggalMulai)
    if err != nil {
        return err
    }

    tanggalSelesai, err := time.Parse(time.RFC3339, req.TanggalSelesai)
    if err != nil {
        return err
    }

    // ✅ BUAT RESEP
    resep := &domain.ResepObat{
        PasienID: req.PasienID,
        ObatID:   req.ObatID,
        NakesID:  req.NakesID,
        Dosis:    req.Dosis,
        Catatan:  req.Catatan,

        TanggalMulai:   tanggalMulai,
        TanggalSelesai: tanggalSelesai,

        FrekuensiPerHari: req.FrekuensiPerHari,
        AturanKonsumsi:   req.AturanKonsumsi,
    }

    // ✅ SIMPAN RESEP
    if err := u.resepRepo.Create(resep); err != nil {
        return err
    }

    // ✅ HANDLE JAM MINUM
    jamList := req.JamMinum

    // fallback kalau kosong
    if len(jamList) == 0 {
        jamList = generateJamMinum(req.FrekuensiPerHari)
    }

    // ✅ SIMPAN JADWAL
    for _, jam := range jamList {

        parsedTime, err := time.Parse("15:04", jam)
        if err != nil {
            return err
        }

        jadwal := &domain.JadwalObat{
            ResepObatID: resep.ResepObatID,
            ObatID:      req.ObatID,
            NakesID:     req.NakesID,
            JamMinum:    parsedTime,
        }

        if err := u.jadwalRepo.Create(jadwal); err != nil {
            return err
        }
    }

    return nil
}