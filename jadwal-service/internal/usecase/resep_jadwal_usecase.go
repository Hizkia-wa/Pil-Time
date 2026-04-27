package usecase

import (
	"jadwal-service/internal/adapters/outbound/persistence"
	"jadwal-service/internal/domain"
	"jadwal-service/internal/dto"
	"strconv"
	"strings"
	"time"
)

type ResepJadwalUsecase struct {
	resepRepo      persistence.ResepObatRepository
	jadwalObatRepo persistence.JadwalObatRepository
	jadwalRepo     persistence.JadwalRepository
}

func NewResepJadwalUsecase(
	r persistence.ResepObatRepository,
	j persistence.JadwalObatRepository,
	jr persistence.JadwalRepository,
) *ResepJadwalUsecase {
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

// Helper function
func parseInt(s string) int {
	if i, err := strconv.Atoi(s); err == nil {
		return i
	}
	return 1
}

func (u *ResepJadwalUsecase) Create(req *dto.CreateResepWithJadwalDTO) error {

	// PARSE TANGGAL
	tanggalMulai, err := time.Parse(time.RFC3339, req.TanggalMulai)
	if err != nil {
		return err
	}

	// Handle tanggal_selesai yang mungkin kosong
	var tanggalSelesai time.Time
	if req.TanggalSelesai != "" && req.TanggalSelesai != "null" {
		var err error
		tanggalSelesai, err = time.Parse(time.RFC3339, req.TanggalSelesai)
		if err != nil {
			return err
		}
	} else {
		// Jika kosong, set ke 1 tahun setelah tanggal mulai
		tanggalSelesai = tanggalMulai.AddDate(1, 0, 0)
	}

	// BUAT RESEP
	resep := &domain.ResepObat{
		PasienID:         req.PasienID,
		ObatID:           req.ObatID,
		NakesID:          req.NakesID,
		Dosis:            req.Dosis,
		Catatan:          req.Catatan,
		TanggalMulai:     tanggalMulai,
		TanggalSelesai:   tanggalSelesai,
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

	// BUAT JADWAL DI TABEL JADWAL
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

	// Buat jadwal entry di tabel jadwal
	jadwalForService := &domain.Jadwal{
		PasienID:           req.PasienID,
		NamaObat:           "Obat ID: " + string(rune(req.ObatID)),
		JumlahDosis:        parseInt(req.Dosis),
		Satuan:             "tablet",
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

	// Simpan ke repo
	if err := u.jadwalRepo.Create(jadwalForService); err != nil {
		return err
	}

	return nil
}
