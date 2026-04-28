package usecase

import (
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/pkg/utils"
	"errors"

	"gorm.io/gorm"
)

type AdminUsecase struct {
	nakesRepo interface {
		GetByEmail(email string) (*domain.Nakes, error)
	}
}

func NewAdminUsecase(nakesRepo interface {
	GetByEmail(email string) (*domain.Nakes, error)
}) *AdminUsecase {
	return &AdminUsecase{
		nakesRepo: nakesRepo,
	}
}

// Login melakukan login admin/nakes
func (u *AdminUsecase) Login(req *dto.AdminLoginRequest) (*dto.AdminLoginResponse, error) {
	// Cari nakes berdasarkan email
	nakes, err := u.nakesRepo.GetByEmail(req.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("email atau password salah")
		}
		return nil, errors.New("terjadi kesalahan saat login")
	}

	if nakes == nil || nakes.Email == "" {
		return nil, errors.New("email atau password salah")
	}

	// Verify password
	if err := utils.VerifyPassword(req.Password, nakes.Password); err != nil {
		return nil, errors.New("email atau password salah")
	}

	// Generate token JWT
	token, err := utils.GenerateToken(nakes.NakesID, nakes.Email)
	if err != nil {
		return nil, errors.New("gagal membuat token")
	}

	// Return response
	resp := &dto.AdminLoginResponse{
		Data: dto.AdminLoginData{
			Token: token,
			User: dto.AdminUser{
				NakesID: nakes.NakesID,
				Email:   nakes.Email,
				Nama:    nakes.Nama,
			},
		},
		Message: "Login berhasil",
	}

	return resp, nil
}
