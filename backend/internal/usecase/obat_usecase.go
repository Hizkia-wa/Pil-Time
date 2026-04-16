package usecase

import (
	"backend/internal/adapters/outbound/persistence"
	"backend/internal/domain"
	"backend/internal/dto"
	"backend/internal/ports/outbound"
	"errors"
)

type ObatUsecase struct {
	repo outbound.ObatRepository
}

func NewObatUsecase(r outbound.ObatRepository) *ObatUsecase {
	return &ObatUsecase{repo: r}
}

// GetAll mendapatkan semua obat
func (u *ObatUsecase) GetAll() ([]dto.ObatResponseDTO, error) {
	obats, err := u.repo.GetAll()
	if err != nil {
		return nil, err
	}

	var responses []dto.ObatResponseDTO
	for _, obat := range obats {
		responses = append(responses, *persistence.ObatToResponseDTO(&obat))
	}
	return responses, nil
}

// GetByID mendapatkan obat berdasarkan ID
func (u *ObatUsecase) GetByID(id int) (*dto.ObatResponseDTO, error) {
	obat, err := u.repo.GetByID(id)
	if err != nil {
		return nil, err
	}
	if obat == nil || obat.ObatID == 0 {
		return nil, errors.New("obat tidak ditemukan")
	}
	return persistence.ObatToResponseDTO(obat), nil
}

// Create membuat obat baru
func (u *ObatUsecase) Create(req *dto.CreateObatDTO) (*dto.ObatResponseDTO, error) {
	// Validate input
	if req.NamaObat == "" {
		return nil, errors.New("nama obat tidak boleh kosong")
	}

	// Cek jika obat dengan nama yang sama sudah ada
	existing, _ := u.repo.GetByName(req.NamaObat)
	if existing != nil && existing.ObatID != 0 {
		return nil, errors.New("obat dengan nama tersebut sudah ada")
	}

	// Create domain object
	obat := &domain.Obat{
		NamaObat:         req.NamaObat,
		Fungsi:           req.Fungsi,
		AturanPenggunaan: req.AturanPenggunaan,
		Perhatian:        req.Perhatian,
	}

	// Save to database
	result, err := u.repo.Create(obat)
	if err != nil {
		return nil, errors.New("gagal menyimpan data obat")
	}

	return persistence.ObatToResponseDTO(result), nil
}

// Update memperbarui data obat
func (u *ObatUsecase) Update(id int, req *dto.UpdateObatDTO) (*dto.ObatResponseDTO, error) {
	// Cek obat ada atau tidak
	existing, err := u.repo.GetByID(id)
	if err != nil || existing == nil || existing.ObatID == 0 {
		return nil, errors.New("obat tidak ditemukan")
	}

	// Update fields yang tidak kosong
	if req.NamaObat != "" {
		existing.NamaObat = req.NamaObat
	}
	if req.Fungsi != "" {
		existing.Fungsi = req.Fungsi
	}
	if req.AturanPenggunaan != "" {
		existing.AturanPenggunaan = req.AturanPenggunaan
	}
	if req.Perhatian != "" {
		existing.Perhatian = req.Perhatian
	}

	// Save updates
	result, err := u.repo.Update(id, existing)
	if err != nil {
		return nil, errors.New("gagal memperbarui data obat")
	}

	return persistence.ObatToResponseDTO(result), nil
}

// Delete menghapus obat
func (u *ObatUsecase) Delete(id int) error {
	// Cek obat ada atau tidak
	existing, err := u.repo.GetByID(id)
	if err != nil || existing == nil || existing.ObatID == 0 {
		return errors.New("obat tidak ditemukan")
	}

	// Delete from database
	return u.repo.Delete(id)
}
