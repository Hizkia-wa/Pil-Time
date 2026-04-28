package usecase

import (
	"auth-service/internal/domain"
	"auth-service/internal/dto"
	"auth-service/internal/ports/outbound"
	"auth-service/pkg/email"
	"auth-service/pkg/utils"
	"errors"
	"fmt"
	"math/rand"
	"time"
)

type AuthUsecase struct {
	nakesRepo    outbound.NakesRepository
	pasienRepo   outbound.PasienRepository
	emailService *email.EmailService
}

func NewAuthUsecase(nr outbound.NakesRepository, pr outbound.PasienRepository) *AuthUsecase {
	return &AuthUsecase{
		nakesRepo:    nr,
		pasienRepo:   pr,
		emailService: email.NewEmailService(),
	}
}

// ===========================
//         NAKES AUTH
// ===========================

// LoginNakes melakukan login nakes/admin dan menghasilkan JWT
func (u *AuthUsecase) LoginNakes(req *dto.LoginNakesRequest) (*dto.LoginNakesResponse, error) {
	nakes, err := u.nakesRepo.GetByEmail(req.Email)
	if err != nil || nakes == nil || nakes.Email == "" {
		return nil, errors.New("email atau password salah")
	}

	if err := utils.VerifyPassword(req.Password, nakes.Password); err != nil {
		return nil, errors.New("email atau password salah")
	}

	token, err := utils.GenerateNakesToken(nakes.NakesID, nakes.Email)
	if err != nil {
		return nil, errors.New("gagal membuat token")
	}

	return &dto.LoginNakesResponse{
		Token:   token,
		Message: "Login berhasil",
		Data: dto.NakesData{
			NakesID: nakes.NakesID,
			Email:   nakes.Email,
			Nama:    nakes.Nama,
		},
	}, nil
}

// ===========================
//        PASIEN AUTH
// ===========================

// RegisterPasien melakukan registrasi pasien baru
func (u *AuthUsecase) RegisterPasien(req *dto.RegisterPasienRequest) (*dto.RegisterPasienResponse, error) {
	// Cek email sudah ada atau belum
	existingEmail, _ := u.pasienRepo.GetByEmail(req.Email)
	if existingEmail != nil && existingEmail.Email != "" {
		return nil, errors.New("email sudah terdaftar")
	}

	// Cek NIK sudah ada atau belum
	existingNIK, _ := u.pasienRepo.GetByNIK(req.NIK)
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

	if err := u.pasienRepo.Create(pasien); err != nil {
		return nil, errors.New("gagal menyimpan data pasien")
	}

	return &dto.RegisterPasienResponse{
		PasienID:    pasien.PasienID,
		Email:       pasien.Email,
		NamaLengkap: pasien.Nama,
		NIK:         pasien.NIK,
		Message:     "Registrasi berhasil",
	}, nil
}

// LoginPasien melakukan login pasien dan menghasilkan JWT
func (u *AuthUsecase) LoginPasien(req *dto.LoginPasienRequest) (*dto.LoginPasienResponse, error) {
	pasien, err := u.pasienRepo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email atau password salah")
	}

	if err := utils.VerifyPassword(req.Password, pasien.Password); err != nil {
		return nil, errors.New("email atau password salah")
	}

	token, err := utils.GeneratePasienToken(pasien.PasienID, pasien.Email)
	if err != nil {
		return nil, errors.New("gagal membuat token")
	}

	return &dto.LoginPasienResponse{
		Token:       token,
		PasienID:    pasien.PasienID,
		Email:       pasien.Email,
		NamaLengkap: pasien.Nama,
		Message:     "Login berhasil",
	}, nil
}

// ===========================
//       PASSWORD RESET
// ===========================

// ForgotPassword mengirim kode reset password ke email
func (u *AuthUsecase) ForgotPassword(req *dto.ForgotPasswordRequest) (*dto.ForgotPasswordResponse, error) {
	pasien, err := u.pasienRepo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email tidak terdaftar")
	}

	code := generateRandomCode()
	expiryTime := time.Now().Add(15 * time.Minute)

	if err := u.pasienRepo.UpdateResetCode(req.Email, code, expiryTime); err != nil {
		return nil, errors.New("gagal menyimpan kode reset")
	}

	if err := u.emailService.SendResetCode(req.Email, code); err != nil {
		return nil, errors.New("gagal mengirim email reset password")
	}

	return &dto.ForgotPasswordResponse{
		Message: "Kode reset password telah dikirim ke email Anda",
	}, nil
}

// VerifyResetCode memverifikasi kode reset password
func (u *AuthUsecase) VerifyResetCode(req *dto.VerifyResetCodeRequest) (*dto.VerifyResetCodeResponse, error) {
	pasien, err := u.pasienRepo.GetByEmail(req.Email)
	if err != nil || pasien == nil || pasien.Email == "" {
		return nil, errors.New("email tidak terdaftar")
	}

	if pasien.ResetCode == nil || *pasien.ResetCode == "" {
		return nil, errors.New("tidak ada permintaan reset password untuk email ini")
	}

	if pasien.ResetCodeExpiry == nil || time.Now().After(*pasien.ResetCodeExpiry) {
		return nil, errors.New("kode reset password sudah kadaluarsa")
	}

	if *pasien.ResetCode != req.Code {
		return nil, errors.New("kode reset password tidak valid")
	}

	return &dto.VerifyResetCodeResponse{
		Message: "Kode reset password valid",
	}, nil
}

// ResetPassword mengubah password pasien
func (u *AuthUsecase) ResetPassword(req *dto.ResetPasswordRequest) (*dto.ResetPasswordResponse, error) {
	// Verifikasi kode terlebih dahulu
	verifyReq := &dto.VerifyResetCodeRequest{
		Email: req.Email,
		Code:  req.Code,
	}
	if _, err := u.VerifyResetCode(verifyReq); err != nil {
		return nil, err
	}

	hashedPassword, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		return nil, errors.New("gagal mengenkripsi password")
	}

	if err := u.pasienRepo.UpdatePassword(req.Email, hashedPassword); err != nil {
		return nil, errors.New("gagal mengubah password")
	}

	return &dto.ResetPasswordResponse{
		Message: "Password berhasil diubah",
	}, nil
}

// ===========================
//       TOKEN VALIDATION
// ===========================

// ValidateToken memvalidasi JWT token dan mengembalikan claims
func (u *AuthUsecase) ValidateToken(tokenString string) (*dto.ValidateTokenResponse, error) {
	claims, err := utils.ValidateToken(tokenString)
	if err != nil {
		return &dto.ValidateTokenResponse{
			Valid:   false,
			Message: "Token tidak valid: " + err.Error(),
		}, nil
	}

	return &dto.ValidateTokenResponse{
		Valid:   true,
		UserID:  claims.ID,
		Email:   claims.Email,
		Role:    claims.Role,
		Message: "Token valid",
	}, nil
}

// ===========================
//          HELPERS
// ===========================

func generateRandomCode() string {
	rand.Seed(time.Now().UnixNano())
	code := rand.Intn(900000) + 100000
	return fmt.Sprintf("%06d", code)
}
