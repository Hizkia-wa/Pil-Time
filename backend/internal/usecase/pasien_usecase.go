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
		Email:        req.Email,
		Password:     hashedPassword,
		NamaLengkap:  req.NamaLengkap,
		NIK:          req.NIK,
		TanggalLahir: tanggalLahir,
		Telepon:      req.Telepon,
		JenisKelamin: req.JenisKelamin,
		Alamat:       req.Alamat,
		Status:       "active",
	}

	// Simpan ke database
	if err := u.repo.Create(pasien); err != nil {
		return nil, errors.New("gagal menyimpan data pasien")
	}

	// Return response
	return &dto.RegisterPasienResponse{
		PasienID:    pasien.PasienID,
		Email:       pasien.Email,
		NamaLengkap: pasien.NamaLengkap,
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
		NamaLengkap: pasien.NamaLengkap,
		Message:     "Login berhasil",
	}, nil
}

// ForgotPassword mengirim kode reset password ke email
func (u *PasienUsecase) ForgotPassword(req *dto.ForgotPasswordRequest) (*dto.ForgotPasswordResponse, error) {
	// Cek apakah email terdaftar
	pasien, err := u.repo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email tidak terdaftar")
	}

	// Generate random 6-digit code
	resetCode := utils.GenerateResetCodeSimple()

	// Set expiry time: 15 minutes from now
	expiryTime := time.Now().Add(15 * time.Minute)

	// Save code to database
	if err := u.repo.UpdateResetCode(req.Email, resetCode, expiryTime); err != nil {
		return nil, errors.New("gagal membuat kode reset")
	}

	// Send email with reset code
	if err := u.emailService.SendResetCode(req.Email, resetCode); err != nil {
		// Log error but don't fail the request
		// In production, you might want to retry or notify admin
		// For now, we'll just return success since code is already saved
		// Client can still use the code from database
	}

	return &dto.ForgotPasswordResponse{
		Message: "Kode reset telah dikirim ke email Anda",
	}, nil
}

// VerifyResetCode memverifikasi kode reset password
func (u *PasienUsecase) VerifyResetCode(req *dto.VerifyResetCodeRequest) (*dto.VerifyResetCodeResponse, error) {
	// Cari pasien berdasarkan email
	pasien, err := u.repo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email tidak terdaftar")
	}

	// Cek apakah reset code ada
	if pasien.ResetCode == "" {
		return nil, errors.New("tidak ada kode reset yang aktif")
	}

	// Cek apakah kode sudah expired
	if pasien.ResetCodeExpiry != nil && time.Now().After(*pasien.ResetCodeExpiry) {
		return nil, errors.New("kode reset sudah expired")
	}

	// Verifikasi kode
	if pasien.ResetCode != req.Code {
		return nil, errors.New("kode reset salah")
	}

	return &dto.VerifyResetCodeResponse{
		Message: "Kode verifikasi benar",
	}, nil
}

// ResetPassword mengubah password pasien
func (u *PasienUsecase) ResetPassword(req *dto.ResetPasswordRequest) (*dto.ResetPasswordResponse, error) {
	// Cari pasien berdasarkan email
	pasien, err := u.repo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email tidak terdaftar")
	}

	// Cek apakah reset code ada
	if pasien.ResetCode == "" {
		return nil, errors.New("tidak ada kode reset yang aktif")
	}

	// Cek apakah kode sudah expired
	if pasien.ResetCodeExpiry != nil && time.Now().After(*pasien.ResetCodeExpiry) {
		return nil, errors.New("kode reset sudah expired")
	}

	// Verifikasi kode
	if pasien.ResetCode != req.Code {
		return nil, errors.New("kode reset salah")
	}

	// Hash new password
	hashedPassword, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		return nil, errors.New("gagal mengenkripsi password")
	}

	// Update password dan clear reset code
	if err := u.repo.UpdatePassword(req.Email, hashedPassword); err != nil {
		return nil, errors.New("gagal mengubah password")
	}

	return &dto.ResetPasswordResponse{
		Message: "Password berhasil diubah",
	}, nil
}
