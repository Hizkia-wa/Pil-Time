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
	emailService *email.EmailService
}

func NewPasienUsecase(r outbound.PasienRepository) *PasienUsecase {
	return &PasienUsecase{
		repo:         r,
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
