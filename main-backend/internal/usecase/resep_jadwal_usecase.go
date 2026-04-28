package usecase

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"strconv"
	"strings"
	"time"
)

// HELPER FUNCTION
func parseInt(s string) int {
	if i, err := strconv.Atoi(s); err == nil {
		return i
	}
	return 1
}

type ResepJadwalUsecase struct {
	resepRepo      outbound.ResepObatRepository
	jadwalObatRepo outbound.JadwalObatRepository
	jadwalRepo     outbound.JadwalRepository
}

func NewResepJadwalUsecase(r outbound.ResepObatRepository, j outbound.JadwalObatRepository, jr outbound.JadwalRepository) *ResepJadwalUsecase {
	return &ResepJadwalUsecase{
		resepRepo:      r,
		jadwalObatRepo: j,
		jadwalRepo:     jr,
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

	// parseDate: support format YYYY-MM-DD dan RFC3339
	parseDate := func(s string) (time.Time, error) {
		if t, err := time.Parse("2006-01-02", s); err == nil {
			return t, nil
		}
		return time.Parse(time.RFC3339, s)
	}

	// PARSE TANGGAL MULAI
	tanggalMulai, err := parseDate(req.TanggalMulai)
	if err != nil {
		return err
	}

	// Handle tanggal_selesai yang mungkin kosong
	var tanggalSelesai time.Time
	if req.TanggalSelesai != "" && req.TanggalSelesai != "null" {
		tanggalSelesai, err = parseDate(req.TanggalSelesai)
		if err != nil {
			return err
		}
	} else {
		// Jika kosong, set ke 30 hari setelah tanggal mulai
		tanggalSelesai = tanggalMulai.AddDate(0, 0, 30)
	}

	// BUAT RESEP
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

	// SIMPAN RESEP
	if err := u.resepRepo.Create(resep); err != nil {
		return err
	}

	// HANDLE JAM MINUM
	jamList := req.JamMinum

	// fallback kalau kosong
	if len(jamList) == 0 {
		jamList = generateJamMinum(req.FrekuensiPerHari)
	}

	// SIMPAN JADWAL OBAT
	for _, jam := range jamList {

		parsedTime, err := time.Parse("15:04", jam)
		if err != nil {
			return err
		}

		jadwalObat := &domain.JadwalObat{
			ResepObatID: resep.ResepObatID,
			PasienID:    req.PasienID,
			ObatID:      req.ObatID,
			NakesID:     req.NakesID,
			JamMinum:    parsedTime,
		}

		if err := u.jadwalObatRepo.Create(jadwalObat); err != nil {
			return err
		}
	}

	// BUAT JADWAL DI TABEL JADWAL (UNTUK JADWAL-SERVICE)
	// Hitung jumlah hari
	jumlahHari := 0
	if !tanggalSelesai.IsZero() && !tanggalMulai.IsZero() {
		jumlahHari = int(tanggalSelesai.Sub(tanggalMulai).Hours() / 24)
	}

	// Format tanggal ke string format yang diharapkan tabel jadwal
	tglMulaiStr := tanggalMulai.Format("2006-01-02")
	tglSelesaiStr := ""
	if !tanggalSelesai.IsZero() {
		tglSelesaiStr = tanggalSelesai.Format("2006-01-02")
	}

	// Buat jadwal entry di tabel jadwal dengan waktu reminder dari jadwal obat
	jadwalForService := &domain.Jadwal{
		PasienID:           req.PasienID,
		NamaObat:           "Obat #" + strconv.Itoa(req.ObatID),
		JumlahDosis:        parseInt(req.Dosis),
		Satuan:             "tablet", // default
		KategoriObat:       "-",
		TakaranObat:        req.Dosis,
		FrekuensiPerHari:   strconv.Itoa(req.FrekuensiPerHari),
		WaktuMinum:         strings.Join(jamList, ", "),
		AturanKonsumsi:     req.AturanKonsumsi,
		Catatan:            req.Catatan,
		TipeDurasi:         "hari",
		JumlahHari:         jumlahHari,
		TanggalMulai:       tglMulaiStr,
		TanggalSelesai:     tglSelesaiStr,
		WaktuReminderPagi:  "",
		WaktuReminderMalam: "",
		Status:             "aktif",
	}

	_, err = u.jadwalRepo.Create(jadwalForService)
	if err != nil {
		return err
	}

	return nil
}
