package usecase

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"backend/pkg/email"
	"backend/pkg/utils"
	"errors"
	"time"
)

type PasienUsecase struct {
	repo         outbound.PasienRepository
	jadwalRepo   outbound.JadwalRepository
	emailService *email.EmailService
}

func NewPasienUsecase(r outbound.PasienRepository, j outbound.JadwalRepository) *PasienUsecase {
	return &PasienUsecase{
		repo:         r,
		jadwalRepo:   j,
		emailService: email.NewEmailService(),
	}
}

// Register melakukan registrasi pasien baru
func (u *PasienUsecase) Register(req *dto.RegisterPasienRequest) (*dto.RegisterPasienResponse, error) {
	// Cek email sudah ada atau belum
	existingEmail, _ := u.repo.GetByEmail(req.Email)
	if existingEmail != nil && existingEmail.Email != "" {
		return nil, errors.New("email sudah terdaftar")
	}

	// Cek NIK sudah ada atau belum
	existingNIK, _ := u.repo.GetByNIK(req.NIK)
	if existingNIK != nil && existingNIK.NIK != "" {
		return nil, errors.New("NIK sudah terdaftar")
	}

	// Hash password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, errors.New("gagal mengenkripsi password")
	}

	// Parse tanggal lahir
	tanggalLahir, err := time.Parse("2006-01-02", req.TanggalLahir)
	if err != nil {
		return nil, errors.New("format tanggal lahir salah (gunakan YYYY-MM-DD)")
	}

	// Buat pasien baru
	pasien := &domain.Pasien{
		Nama:         req.NamaLengkap,
		Email:        req.Email,
		Password:     hashedPassword,
		NIK:          req.NIK,
		TanggalLahir: tanggalLahir,
		NoTelepon:    req.Telepon,
		JenisKelamin: req.JenisKelamin,
		Alamat:       req.Alamat,
	}

	// Simpan ke database
	if err := u.repo.Create(pasien); err != nil {
		return nil, errors.New("gagal menyimpan data pasien")
	}

	// Return response
	return &dto.RegisterPasienResponse{
		PasienID:    pasien.PasienID,
		Email:       pasien.Email,
		NamaLengkap: pasien.Nama,
		NIK:         pasien.NIK,
		Message:     "Registrasi berhasil",
	}, nil
}

func (u *PasienUsecase) GetAll() ([]domain.Pasien, error) {
	return u.repo.GetAll()
}

// Login melakukan login pasien
func (u *PasienUsecase) Login(req *dto.LoginPasienRequest) (*dto.LoginPasienResponse, error) {
	// Cari pasien berdasarkan email
	pasien, err := u.repo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email atau password salah")
	}

	// Verify password
	if err := utils.VerifyPassword(req.Password, pasien.Password); err != nil {
		return nil, errors.New("email atau password salah")
	}

	// Return response
	return &dto.LoginPasienResponse{
		PasienID:    pasien.PasienID,
		Email:       pasien.Email,
		NamaLengkap: pasien.Nama,
		Message:     "Login berhasil",
	}, nil
}

// ForgotPassword mengirim kode reset password ke email
// NOTE: Feature ini memerlukan tabel terpisah untuk menyimpan reset tokens
// karena domain.Pasien tidak memiliki field ResetCode dan ResetCodeExpiry
func (u *PasienUsecase) ForgotPassword(req *dto.ForgotPasswordRequest) (*dto.ForgotPasswordResponse, error) {
	// Cek apakah email terdaftar
	pasien, err := u.repo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email tidak terdaftar")
	}

	// TODO: Implementasi dengan tabel reset_token terpisah
	// Untuk sekarang, return error
	return nil, errors.New("fitur reset password sedang dalam pengembangan")
}

// VerifyResetCode memverifikasi kode reset password
// NOTE: Feature ini memerlukan tabel terpisah untuk menyimpan reset tokens
func (u *PasienUsecase) VerifyResetCode(req *dto.VerifyResetCodeRequest) (*dto.VerifyResetCodeResponse, error) {
	// TODO: Implementasi dengan tabel reset_token terpisah
	return nil, errors.New("fitur reset password sedang dalam pengembangan")
}

// ResetPassword mengubah password pasien
// NOTE: Feature ini memerlukan tabel terpisah untuk menyimpan reset tokens
func (u *PasienUsecase) ResetPassword(req *dto.ResetPasswordRequest) (*dto.ResetPasswordResponse, error) {
	// TODO: Implementasi dengan tabel reset_token terpisah
	return nil, errors.New("fitur reset password sedang dalam pengembangan")
}

// GetPasienDashboard mengambil data dashboard untuk pasien dengan jadwal hari ini
func (u *PasienUsecase) GetPasienDashboard(pasienID int) (*dto.PasienDashboardResponse, error) {
	// Get pasien data
	pasien, err := u.repo.GetByID(uint(pasienID))
	if err != nil || pasien == nil {
		return nil, errors.New("pasien tidak ditemukan")
	}

	// Get all jadwal for pasien
	allJadwals, err := u.jadwalRepo.GetByPasienID(int(pasienID))
	if err != nil {
		return nil, errors.New("gagal mengambil jadwal pasien")
	}

	// Convert domain jadwal to DTO
	jadwalDTOs := []dto.JadwalResponseDTO{}
	todayJadwalDTOs := []dto.JadwalResponseDTO{}
	today := time.Now().Format("2006-01-02")

	for _, jadwal := range allJadwals {
		jadwalDTO := dto.JadwalResponseDTO{
			ID:                 jadwal.JadwalID,
			PasienID:           jadwal.PasienID,
			PasienNama:         pasien.Nama,
			NamaObat:           jadwal.NamaObat,
			JumlahDosis:        jadwal.JumlahDosis,
			Satuan:             jadwal.Satuan,
			KategoriObat:       jadwal.KategoriObat,
			TakaranObat:        jadwal.TakaranObat,
			FrekuensiPerHari:   jadwal.FrekuensiPerHari,
			WaktuMinum:         jadwal.WaktuMinum,
			AturanKonsumsi:     jadwal.AturanKonsumsi,
			Catatan:            jadwal.Catatan,
			TipeDurasi:         jadwal.TipeDurasi,
			JumlahHari:         jadwal.JumlahHari,
			TanggalMulai:       jadwal.TanggalMulai,
			TanggalSelesai:     jadwal.TanggalSelesai,
			WaktuReminderPagi:  jadwal.WaktuReminderPagi,
			WaktuReminderMalam: jadwal.WaktuReminderMalam,
			Status:             jadwal.Status,
			CreatedAt:          jadwal.CreatedAt,
			UpdatedAt:          jadwal.UpdatedAt,
		}

		jadwalDTOs = append(jadwalDTOs, jadwalDTO)

		// Check if jadwal is for today and still active
		if jadwal.Status == "aktif" || jadwal.Status == "active" {
			jadwalMulai := jadwal.TanggalMulai
			jadwalSelesai := jadwal.TanggalSelesai

			// Handle jadwal dengan tipe_durasi="rutin" (tanpa tanggal_selesai)
			if jadwal.TipeDurasi == "rutin" {
				// Jadwal rutin berlaku setiap hari jika sudah mulai
				if jadwalMulai <= today {
					todayJadwalDTOs = append(todayJadwalDTOs, jadwalDTO)
				}
			} else if jadwal.TipeDurasi == "hari" {
				// Jadwal terbatas berlaku hingga tanggal_selesai (jika ada)
				// Jika tanggal_selesai kosong, anggap jadwal berlaku indefinite
				if jadwalMulai <= today {
					if jadwalSelesai == "" {
						// Tanpa batas akhir - anggap berlaku selamanya
						todayJadwalDTOs = append(todayJadwalDTOs, jadwalDTO)
					} else if today <= jadwalSelesai {
						// Ada batas akhir - cek apakah masih dalam rentang
						todayJadwalDTOs = append(todayJadwalDTOs, jadwalDTO)
					}
				}
			}
		}
	}

	// Return dashboard response
	return &dto.PasienDashboardResponse{
		PasienID:     pasien.PasienID,
		Nama:         pasien.Nama,
		Email:        pasien.Email,
		NoTelepon:    pasien.NoTelepon,
		JenisKelamin: pasien.JenisKelamin,
		TanggalLahir: pasien.TanggalLahir.Format("2006-01-02"),
		Alamat:       pasien.Alamat,
		TodayJadwals: todayJadwalDTOs,
		AllJadwals:   jadwalDTOs,
	}, nil
}

// GetPasienJadwal mengambil semua jadwal untuk pasien tertentu
func (u *PasienUsecase) GetPasienJadwal(pasienID int) (*dto.PasienJadwalResponse, error) {
	// Get pasien data
	pasien, err := u.repo.GetByID(uint(pasienID))
	if err != nil || pasien == nil {
		return nil, errors.New("pasien tidak ditemukan")
	}

	// Get all jadwal for pasien
	allJadwals, err := u.jadwalRepo.GetByPasienID(pasienID)
	if err != nil {
		return nil, errors.New("gagal mengambil jadwal pasien")
	}

	// Convert domain jadwal to DTO
	jadwalDTOs := []dto.JadwalResponseDTO{}
	for _, jadwal := range allJadwals {
		jadwalDTO := dto.JadwalResponseDTO{
			ID:                 jadwal.JadwalID,
			PasienID:           jadwal.PasienID,
			PasienNama:         pasien.Nama,
			NamaObat:           jadwal.NamaObat,
			JumlahDosis:        jadwal.JumlahDosis,
			Satuan:             jadwal.Satuan,
			KategoriObat:       jadwal.KategoriObat,
			TakaranObat:        jadwal.TakaranObat,
			FrekuensiPerHari:   jadwal.FrekuensiPerHari,
			WaktuMinum:         jadwal.WaktuMinum,
			AturanKonsumsi:     jadwal.AturanKonsumsi,
			Catatan:            jadwal.Catatan,
			TipeDurasi:         jadwal.TipeDurasi,
			JumlahHari:         jadwal.JumlahHari,
			TanggalMulai:       jadwal.TanggalMulai,
			TanggalSelesai:     jadwal.TanggalSelesai,
			WaktuReminderPagi:  jadwal.WaktuReminderPagi,
			WaktuReminderMalam: jadwal.WaktuReminderMalam,
			Status:             jadwal.Status,
			CreatedAt:          jadwal.CreatedAt,
			UpdatedAt:          jadwal.UpdatedAt,
		}
		jadwalDTOs = append(jadwalDTOs, jadwalDTO)
	}

	return &dto.PasienJadwalResponse{
		PasienID: pasien.PasienID,
		Nama:     pasien.Nama,
		Jadwals:  jadwalDTOs,
	}, nil
}

// GetByID mengambil data pasien berdasarkan ID
func (u *PasienUsecase) GetByID(pasienID int) (*dto.PasienResponseDTO, error) {
	pasien, err := u.repo.GetByID(uint(pasienID))
	if err != nil || pasien == nil {
		return nil, errors.New("pasien tidak ditemukan")
	}

	return &dto.PasienResponseDTO{
		PasienID:     pasien.PasienID,
		Nama:         pasien.Nama,
		Email:        pasien.Email,
		NIK:          pasien.NIK,
		TanggalLahir: pasien.TanggalLahir.Format("2006-01-02"),
		TempatLahir:  pasien.TempatLahir,
		Alamat:       pasien.Alamat,
		JenisKelamin: pasien.JenisKelamin,
		NoTelepon:    pasien.NoTelepon,
	}, nil
}
